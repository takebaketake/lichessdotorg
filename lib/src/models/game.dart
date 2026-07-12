class GameUser {
  final String id;
  final String name;
  final String? title;
  final bool? patron;

  const GameUser({
    required this.id,
    required this.name,
    this.title,
    this.patron,
  });

  factory GameUser.fromJson(Map<String, dynamic> json) => GameUser(
    id: json['id'] as String,
    name: json['name'] as String,
    title: json['title'] as String?,
    patron: json['patron'] as bool?,
  );
}

class PlayerAnalysis {
  final int inaccuracy;
  final int mistake;
  final int blunder;
  final int acpl;

  const PlayerAnalysis({
    required this.inaccuracy,
    required this.mistake,
    required this.blunder,
    required this.acpl,
  });

  factory PlayerAnalysis.fromJson(Map<String, dynamic> json) => PlayerAnalysis(
    inaccuracy: json['inaccuracy'] as int,
    mistake: json['mistake'] as int,
    blunder: json['blunder'] as int,
    acpl: json['acpl'] as int,
  );
}

class GamePlayer {
  final GameUser? user;
  final int? rating;
  final int? ratingDiff;
  final int? aiLevel;
  final PlayerAnalysis? analysis;

  const GamePlayer({
    this.user,
    this.rating,
    this.ratingDiff,
    this.aiLevel,
    this.analysis,
  });

  factory GamePlayer.fromJson(Map<String, dynamic> json) => GamePlayer(
    user: json['user'] != null
        ? GameUser.fromJson(json['user'] as Map<String, dynamic>)
        : null,
    rating: json['rating'] as int?,
    ratingDiff: json['ratingDiff'] as int?,
    aiLevel: json['aiLevel'] as int?,
    analysis: json['analysis'] != null
        ? PlayerAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
        : null,
  );
}

class GamePlayers {
  final GamePlayer white;
  final GamePlayer black;

  const GamePlayers({required this.white, required this.black});

  factory GamePlayers.fromJson(Map<String, dynamic> json) => GamePlayers(
    white: GamePlayer.fromJson(json['white'] as Map<String, dynamic>),
    black: GamePlayer.fromJson(json['black'] as Map<String, dynamic>),
  );
}

class GameOpening {
  final String eco;
  final String name;
  final int ply;

  const GameOpening({required this.eco, required this.name, required this.ply});

  factory GameOpening.fromJson(Map<String, dynamic> json) => GameOpening(
    eco: json['eco'] as String,
    name: json['name'] as String,
    ply: json['ply'] as int,
  );
}

class GameClock {
  final int initial;
  final int increment;
  final int totalTime;

  const GameClock({
    required this.initial,
    required this.increment,
    required this.totalTime,
  });

  factory GameClock.fromJson(Map<String, dynamic> json) => GameClock(
    initial: json['initial'] as int,
    increment: json['increment'] as int,
    totalTime: json['totalTime'] as int,
  );
}

class LichessGame {
  final String id;
  final bool rated;
  final String variant;
  final String speed;
  final String perf;
  final int createdAt;
  final int? lastMoveAt;
  final String status;
  final GamePlayers players;
  final String? winner;
  final GameOpening? opening;
  final String? moves;
  final String? pgn;
  final int? daysPerTurn;
  final GameClock? clock;
  final String? tournament;
  final String? swiss;

  const LichessGame({
    required this.id,
    required this.rated,
    required this.variant,
    required this.speed,
    required this.perf,
    required this.createdAt,
    this.lastMoveAt,
    required this.status,
    required this.players,
    this.winner,
    this.opening,
    this.moves,
    this.pgn,
    this.daysPerTurn,
    this.clock,
    this.tournament,
    this.swiss,
  });

  factory LichessGame.fromJson(Map<String, dynamic> json) => LichessGame(
    id: json['id'] as String,
    rated: json['rated'] as bool,
    variant: json['variant'] as String,
    speed: json['speed'] as String,
    perf: json['perf'] as String,
    createdAt: json['createdAt'] as int,
    lastMoveAt: json['lastMoveAt'] as int?,
    status: json['status'] as String,
    players: GamePlayers.fromJson(json['players'] as Map<String, dynamic>),
    winner: json['winner'] as String?,
    opening: json['opening'] != null
        ? GameOpening.fromJson(json['opening'] as Map<String, dynamic>)
        : null,
    moves: json['moves'] as String?,
    pgn: json['pgn'] as String?,
    daysPerTurn: json['daysPerTurn'] as int?,
    clock: json['clock'] != null
        ? GameClock.fromJson(json['clock'] as Map<String, dynamic>)
        : null,
    tournament: json['tournament'] as String?,
    swiss: json['swiss'] as String?,
  );
}
