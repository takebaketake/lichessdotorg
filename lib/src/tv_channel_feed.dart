import 'dart:async';

import 'client.dart';

/// A resilient listener for a Lichess TV channel feed.
///
/// [LichessClient.streamTvFeed] yields a raw, one-shot NDJSON stream that ends
/// the instant the underlying HTTP connection closes — whether the featured
/// game ended, the network blipped, a proxy dropped an idle connection, or a
/// mobile radio handed off. It also cannot notice a *half-open* connection that
/// silently stops delivering bytes without ever closing.
///
/// [TvChannelFeed] wraps that raw stream and keeps the pipe alive:
///
///  * a stall watchdog, re-armed on every event, reconnects when no event
///    arrives within [idleTimeout] (catches half-open connections);
///  * dropped connections are reconnected with exponential backoff between
///    [baseBackoff] and [maxBackoff];
///  * the failure counter resets whenever an event flows, so only
///    [maxConsecutiveFailures] *consecutive* failures cause it to give up and
///    close [events].
///
/// Every fresh connection re-emits a `featured` event, so a consumer can detect
/// a reconnect purely from the event stream (same game id ⇒ catch up; a
/// different id ⇒ the watched game ended). The feed itself knows nothing about
/// games, PGNs, or board state — its sole job is to keep a healthy stream of
/// [TvFeedEvent]s flowing.
class TvChannelFeed {
  TvChannelFeed({
    required this._client,
    required this._channel,
    this.idleTimeout = const Duration(seconds: 90),
    this.baseBackoff = const Duration(seconds: 2),
    this.maxBackoff = const Duration(seconds: 15),
    this.maxConsecutiveFailures = 8,
  });

  final LichessClient _client;
  final String _channel;

  /// Reconnect if no event arrives within this window (half-open detection).
  final Duration idleTimeout;

  /// First reconnect delay; doubles each consecutive failure up to [maxBackoff].
  final Duration baseBackoff;
  final Duration maxBackoff;

  /// Give up after this many consecutive failed connections (reset on any event).
  final int maxConsecutiveFailures;

  final StreamController<TvFeedEvent> _out = StreamController<TvFeedEvent>();
  StreamSubscription<TvFeedEvent>? _sub;
  Timer? _watchdog;
  Timer? _retryTimer;
  int _failures = 0;
  bool _started = false;
  bool _closed = false;
  bool _receivedEventThisAttempt = false;

  /// The resilient stream of TV feed events. Closes only when the feed gives up
  /// after [maxConsecutiveFailures] consecutive failures, or when [stop] /
  /// [dispose] is called.
  Stream<TvFeedEvent> get events => _out.stream;

  /// Whether the feed has permanently stopped (gave up, stopped, or disposed).
  bool get isClosed => _closed;

  /// Open the first connection. Call once, after listening to [events].
  void start() {
    if (_started || _closed) return;
    _started = true;
    _connect();
  }

  void _connect() {
    if (_closed) return;
    _receivedEventThisAttempt = false;
    _sub = _client
        .streamTvFeed(_channel)
        .listen(
          _onEvent,
          onDone: _onConnectionEnded,
          onError: (_) => _onConnectionEnded(),
          cancelOnError: true,
        );
    _armWatchdog();
  }

  void _onEvent(TvFeedEvent event) {
    _failures = 0; // healthy data flowing — reset the give-up budget
    _receivedEventThisAttempt = true;
    _armWatchdog();
    if (!_closed) _out.add(event);
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(idleTimeout, () {
      // No events for too long — assume a half-open connection and reconnect.
      _teardownConnection();
      _scheduleReconnect();
    });
  }

  void _onConnectionEnded() {
    _teardownConnection();
    if (!_receivedEventThisAttempt) {
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
      if (!_closed) _connect();
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
      _close(); // give up — the consumer sees [events] close
      return;
    }
    final backoffMs = (baseBackoff.inMilliseconds * (1 << (_failures - 1)))
        .clamp(baseBackoff.inMilliseconds, maxBackoff.inMilliseconds);
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(milliseconds: backoffMs), () {
      if (!_closed) _connect();
    });
  }

  /// Stop following the channel and close [events]. Idempotent.
  Future<void> stop() => _close();

  /// Release all resources. Idempotent. Does not close the [LichessClient].
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
