class LichessPlayingGame {
  final String gameId;
  final String fullId;
  final String color;
  final String fen;
  final bool hasMoved;
  final bool isMyTurn;
  final String opponentName;
  final int? opponentRating;
  final int? secondsLeft;

  LichessPlayingGame({
    required this.gameId,
    required this.fullId,
    required this.color,
    required this.fen,
    required this.hasMoved,
    required this.isMyTurn,
    required this.opponentName,
    this.opponentRating,
    this.secondsLeft,
  });

  factory LichessPlayingGame.fromJson(Map<String, dynamic> json) {
    final opponent = json['opponent'] as Map<String, dynamic>?;
    return LichessPlayingGame(
      gameId: json['gameId'] as String,
      fullId: json['fullId'] as String,
      color: json['color'] as String,
      fen: json['fen'] as String,
      hasMoved: json['hasMoved'] as bool? ?? false,
      isMyTurn: json['isMyTurn'] as bool? ?? false,
      opponentName: opponent?['username'] as String? ?? 'Unknown',
      opponentRating: opponent?['rating'] as int?,
      secondsLeft: json['secondsLeft'] as int?,
    );
  }
}

sealed class LichessBoardEvent {
  const LichessBoardEvent();

  static LichessBoardEvent fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'gameFull') {
      return LichessBoardGameFull.fromJson(json);
    } else if (type == 'gameState') {
      return LichessBoardGameState.fromJson(json);
    }
    return const LichessBoardKeepAlive();
  }
}

class LichessBoardKeepAlive extends LichessBoardEvent {
  const LichessBoardKeepAlive();
}

class LichessBoardPlayer {
  final String? id;
  final String? name;
  final int? rating;
  final int? aiLevel;

  LichessBoardPlayer({this.id, this.name, this.rating, this.aiLevel});

  factory LichessBoardPlayer.fromJson(Map<String, dynamic> json) {
    return LichessBoardPlayer(
      id: json['id'] as String?,
      name: json['name'] as String?,
      rating: json['rating'] as int?,
      aiLevel: json['aiLevel'] as int?,
    );
  }
}

class LichessBoardGameFull extends LichessBoardEvent {
  final String id;
  final String? initialFen;
  final LichessBoardPlayer white;
  final LichessBoardPlayer black;
  final String moves;
  final int wtime;
  final int btime;
  final int winc;
  final int binc;
  final String status;
  final String? winner;

  LichessBoardGameFull({
    required this.id,
    this.initialFen,
    required this.white,
    required this.black,
    required this.moves,
    required this.wtime,
    required this.btime,
    required this.winc,
    required this.binc,
    required this.status,
    this.winner,
  });

  factory LichessBoardGameFull.fromJson(Map<String, dynamic> json) {
    final whiteJson = json['white'] as Map<String, dynamic>? ?? {};
    final blackJson = json['black'] as Map<String, dynamic>? ?? {};
    final stateJson = json['state'] as Map<String, dynamic>? ?? {};
    return LichessBoardGameFull(
      id: json['id'] as String,
      initialFen: json['initialFen'] as String?,
      white: LichessBoardPlayer.fromJson(whiteJson),
      black: LichessBoardPlayer.fromJson(blackJson),
      moves: stateJson['moves'] as String? ?? '',
      wtime: stateJson['wtime'] as int? ?? 0,
      btime: stateJson['btime'] as int? ?? 0,
      winc: stateJson['winc'] as int? ?? 0,
      binc: stateJson['binc'] as int? ?? 0,
      status: stateJson['status'] as String? ?? 'started',
      winner: stateJson['winner'] as String?,
    );
  }
}

class LichessBoardGameState extends LichessBoardEvent {
  final String moves;
  final int wtime;
  final int btime;
  final int winc;
  final int binc;
  final String status;
  final String? winner;

  LichessBoardGameState({
    required this.moves,
    required this.wtime,
    required this.btime,
    required this.winc,
    required this.binc,
    required this.status,
    this.winner,
  });

  factory LichessBoardGameState.fromJson(Map<String, dynamic> json) {
    return LichessBoardGameState(
      moves: json['moves'] as String? ?? '',
      wtime: json['wtime'] as int? ?? 0,
      btime: json['btime'] as int? ?? 0,
      winc: json['winc'] as int? ?? 0,
      binc: json['binc'] as int? ?? 0,
      status: json['status'] as String? ?? 'started',
      winner: json['winner'] as String?,
    );
  }
}
