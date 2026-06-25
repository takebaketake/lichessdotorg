import 'dart:async';

/// A counting semaphore that limits the number of concurrent async operations.
class Semaphore {
  Semaphore(this._max);

  final int _max;
  int _active = 0;
  final _queue = <Completer<void>>[];

  Future<T> run<T>(Future<T> Function() fn) async {
    await _acquire();
    try {
      return await fn();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() async {
    if (_active < _max) {
      _active++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
    _active++;
  }

  void _release() {
    _active--;
    if (_queue.isNotEmpty) {
      _queue.removeAt(0).complete();
    }
  }
}
