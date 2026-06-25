sealed class GameStreamEvent {
  const GameStreamEvent();

  // The stream sends two distinct event shapes (neither uses a 't' field):
  //   1. Game metadata: {"id":"...", "players":{...}, ...}  — no fen
  //   2. FEN update:    {"fen":"...", "lm":"...", ...}       — no id
  // Distinguish by presence of "id" vs "fen".
  static GameStreamEvent fromJson(Map<String, dynamic> json) {
    final t = json['t'] as String?;
    if (t == 'finish') return const GameStreamFinish();
    if (json.containsKey('id')) return GameStreamInitial.fromJson(json);
    if (json.containsKey('fen')) return GameStreamMove.fromJson(json);
    return const GameStreamKeepAlive();
  }
}

class GameStreamInitial extends GameStreamEvent {
  const GameStreamInitial({
    required this.id,
    this.whiteName,
    this.whiteRating,
    this.blackName,
    this.blackRating,
    this.fen,
    this.lastMoveUci,
  });

  final String id;
  final String? whiteName;
  final int? whiteRating;
  final String? blackName;
  final int? blackRating;
  /// Current board position at stream open time (useful for reconnect resync).
  final String? fen;
  /// UCI of the last move played, if any.
  final String? lastMoveUci;

  factory GameStreamInitial.fromJson(Map<String, dynamic> json) {
    final players = json['players'] as Map<String, dynamic>?;
    final white = players?['white'] as Map<String, dynamic>?;
    final black = players?['black'] as Map<String, dynamic>?;
    final whiteUser = white?['user'] as Map<String, dynamic>?;
    final blackUser = black?['user'] as Map<String, dynamic>?;
    final lm = json['lm'] as String?;

    return GameStreamInitial(
      id: json['id'] as String,
      whiteName: whiteUser?['name'] as String?,
      whiteRating: white?['rating'] as int?,
      blackName: blackUser?['name'] as String?,
      blackRating: black?['rating'] as int?,
      fen: json['fen'] as String?,
      lastMoveUci: lm != null && lm.length >= 4 ? lm : null,
    );
  }
}

class GameStreamMove extends GameStreamEvent {
  const GameStreamMove({required this.fen, this.lastMoveUci});

  final String fen;
  final String? lastMoveUci;

  factory GameStreamMove.fromJson(Map<String, dynamic> json) {
    final uci = json['uci'] as String? ?? json['lm'] as String?;
    return GameStreamMove(
      fen: json['fen'] as String,
      lastMoveUci: uci != null && uci.length >= 4 ? uci : null,
    );
  }
}

class GameStreamFinish extends GameStreamEvent {
  const GameStreamFinish();
}

class GameStreamKeepAlive extends GameStreamEvent {
  const GameStreamKeepAlive();
}
