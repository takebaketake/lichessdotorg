import 'dart:async';

import 'client.dart';

/// A resilient listener for a set of Lichess game streams.
///
/// [LichessClient.streamGames] yields a raw, one-shot NDJSON stream that ends
/// the instant the underlying HTTP connection closes — whether the game ended,
/// the network blipped, a proxy dropped an idle connection, or a mobile radio
/// handed off. It also cannot detect a *half-open* connection that silently
/// stops delivering bytes without ever closing.
///
/// [GameStreamFeed] wraps that raw stream and keeps the pipe alive:
///
///  * a stall watchdog, re-armed on every event, reconnects when no event
///    arrives within [idleTimeout] (catches half-open connections);
///  * dropped connections are reconnected with exponential backoff between
///    [baseBackoff] and [maxBackoff];
///  * the failure counter resets whenever an event flows, so only
///    [maxConsecutiveFailures] *consecutive* failures cause it to give up and
///    close [events].
///  * when [GameStreamFinish] is received the feed closes [events] normally
///    without reconnecting — the game is over.
///
/// Listen to [events] then call [start]. [dispose] / [stop] to shut down.
class GameStreamFeed {
  GameStreamFeed({
    required this._client,
    required List<String> ids,
    this.idleTimeout = const Duration(seconds: 90),
    this.baseBackoff = const Duration(seconds: 2),
    this.maxBackoff = const Duration(seconds: 15),
    this.maxConsecutiveFailures = 8,
  }) : _ids = List.unmodifiable(ids);

  final LichessClient _client;
  final List<String> _ids;

  final Duration idleTimeout;
  final Duration baseBackoff;
  final Duration maxBackoff;
  final int maxConsecutiveFailures;

  final StreamController<GameStreamEvent> _out =
      StreamController<GameStreamEvent>();
  StreamSubscription<GameStreamEvent>? _sub;
  Timer? _watchdog;
  Timer? _retryTimer;
  int _failures = 0;
  bool _started = false;
  bool _closed = false;
  bool _finished = false;
  bool _receivedEventThisAttempt = false;

  /// The resilient stream of game events. Closes when the game ends normally
  /// ([GameStreamFinish]), when the feed gives up after
  /// [maxConsecutiveFailures] consecutive failures, or when [stop] / [dispose]
  /// is called.
  Stream<GameStreamEvent> get events => _out.stream;

  bool get isClosed => _closed;

  void start() {
    if (_started || _closed) return;
    _started = true;
    _connect();
  }

  void _connect() {
    if (_closed || _finished) return;
    _receivedEventThisAttempt = false;
    _sub = _client.streamGames(_ids).listen(
      _onEvent,
      onDone: _onConnectionEnded,
      onError: (_) => _onConnectionEnded(),
      cancelOnError: true,
    );
    _armWatchdog();
  }

  void _onEvent(GameStreamEvent event) {
    _failures = 0;
    _receivedEventThisAttempt = true;
    _armWatchdog();
    if (_closed) return;
    _out.add(event);
    if (event is GameStreamFinish) {
      _finished = true;
      _close();
    }
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(idleTimeout, () {
      _teardownConnection();
      _scheduleReconnect();
    });
  }

  void _onConnectionEnded() {
    _teardownConnection();
    if (_finished) {
      _close();
    } else if (!_receivedEventThisAttempt) {
      // The socket never opened (network down). Retry at max backoff without
      // burning the consecutive-failure budget — the counter only matters for
      // detecting a sick server, not for an offline device.
      _scheduleOfflineRetry();
    } else {
      _scheduleReconnect();
    }
  }

  void _scheduleOfflineRetry() {
    if (_closed) return;
    _retryTimer?.cancel();
    _retryTimer = Timer(maxBackoff, () {
      if (!_closed && !_finished) _connect();
    });
  }

  void _teardownConnection() {
    _watchdog?.cancel();
    _watchdog = null;
    final sub = _sub;
    _sub = null;
    sub?.cancel();
  }

  void _scheduleReconnect() {
    if (_closed) return;
    _failures++;
    if (_failures > maxConsecutiveFailures) {
      _close();
      return;
    }
    final backoffMs = (baseBackoff.inMilliseconds * (1 << (_failures - 1)))
        .clamp(baseBackoff.inMilliseconds, maxBackoff.inMilliseconds);
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(milliseconds: backoffMs), () {
      if (!_closed && !_finished) _connect();
    });
  }

  Future<void> stop() => _close();
  Future<void> dispose() => _close();

  Future<void> _close() async {
    if (_closed) return;
    _closed = true;
    _watchdog?.cancel();
    _retryTimer?.cancel();
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
    await _out.close();
  }
}
