class ExplorerPlayer {
  final String name;
  final int rating;

  const ExplorerPlayer({required this.name, required this.rating});

  factory ExplorerPlayer.fromJson(Map<String, dynamic> json) => ExplorerPlayer(
    name: json['name'] as String,
    rating: json['rating'] as int,
  );
}

class ExplorerGame {
  final String id;
  final String? uci;
  final ExplorerPlayer white;
  final ExplorerPlayer black;
  final String? winner;
  final int? year;
  final String? month;

  const ExplorerGame({
    required this.id,
    this.uci,
    required this.white,
    required this.black,
    this.winner,
    this.year,
    this.month,
  });

  factory ExplorerGame.fromJson(Map<String, dynamic> json) => ExplorerGame(
    id: json['id'] as String,
    uci: json['uci'] as String?,
    white: ExplorerPlayer.fromJson(json['white'] as Map<String, dynamic>),
    black: ExplorerPlayer.fromJson(json['black'] as Map<String, dynamic>),
    winner: json['winner'] as String?,
    year: json['year'] as int?,
    month: json['month'] as String?,
  );
}

class ExplorerMove {
  final String uci;
  final String san;
  final int white;
  final int draws;
  final int black;

  /// Average rating of the player making the move (Lichess/masters explorer).
  final int? averageRating;

  /// Average rating of the opponent (player explorer).
  final int? averageOpponentRating;

  /// Representative game for this move (masters explorer).
  final ExplorerGame? game;

  const ExplorerMove({
    required this.uci,
    required this.san,
    required this.white,
    required this.draws,
    required this.black,
    this.averageRating,
    this.averageOpponentRating,
    this.game,
  });

  int get total => white + draws + black;

  double get whiteWinRate => total == 0 ? 0 : white / total;
  double get drawRate => total == 0 ? 0 : draws / total;
  double get blackWinRate => total == 0 ? 0 : black / total;

  factory ExplorerMove.fromJson(Map<String, dynamic> json) => ExplorerMove(
    uci: json['uci'] as String,
    san: json['san'] as String,
    white: json['white'] as int,
    draws: json['draws'] as int,
    black: json['black'] as int,
    averageRating: json['averageRating'] as int?,
    averageOpponentRating: json['averageOpponentRating'] as int?,
    game: json['game'] != null
        ? ExplorerGame.fromJson(json['game'] as Map<String, dynamic>)
        : null,
  );
}

class ExplorerOpening {
  final String eco;
  final String name;

  const ExplorerOpening({required this.eco, required this.name});

  factory ExplorerOpening.fromJson(Map<String, dynamic> json) =>
      ExplorerOpening(eco: json['eco'] as String, name: json['name'] as String);
}

class ExplorerResult {
  final int white;
  final int draws;
  final int black;
  final List<ExplorerMove> moves;
  final List<ExplorerGame> topGames;
  final List<ExplorerGame> recentGames;
  final ExplorerOpening? opening;

  const ExplorerResult({
    required this.white,
    required this.draws,
    required this.black,
    required this.moves,
    required this.topGames,
    required this.recentGames,
    this.opening,
  });

  int get total => white + draws + black;

  double get whiteWinRate => total == 0 ? 0 : white / total;
  double get drawRate => total == 0 ? 0 : draws / total;
  double get blackWinRate => total == 0 ? 0 : black / total;

  factory ExplorerResult.fromJson(Map<String, dynamic> json) => ExplorerResult(
    white: json['white'] as int,
    draws: json['draws'] as int,
    black: json['black'] as int,
    moves: (json['moves'] as List<dynamic>)
        .map((e) => ExplorerMove.fromJson(e as Map<String, dynamic>))
        .toList(),
    topGames: (json['topGames'] as List<dynamic>? ?? [])
        .map((e) => ExplorerGame.fromJson(e as Map<String, dynamic>))
        .toList(),
    recentGames: (json['recentGames'] as List<dynamic>? ?? [])
        .map((e) => ExplorerGame.fromJson(e as Map<String, dynamic>))
        .toList(),
    opening: json['opening'] != null
        ? ExplorerOpening.fromJson(json['opening'] as Map<String, dynamic>)
        : null,
  );
}

class CloudEvalPv {
  final String moves;

  /// Centipawn evaluation (positive = white advantage). Null when [mate] is set.
  final int? cp;

  /// Moves to forced mate (positive = white mates). Null when [cp] is set.
  final int? mate;

  const CloudEvalPv({required this.moves, this.cp, this.mate});

  factory CloudEvalPv.fromJson(Map<String, dynamic> json) => CloudEvalPv(
    moves: json['moves'] as String,
    cp: json['cp'] as int?,
    mate: json['mate'] as int?,
  );
}

class CloudEval {
  final String fen;
  final int knodes;
  final int depth;
  final List<CloudEvalPv> pvs;

  const CloudEval({
    required this.fen,
    required this.knodes,
    required this.depth,
    required this.pvs,
  });

  factory CloudEval.fromJson(Map<String, dynamic> json) => CloudEval(
    fen: json['fen'] as String,
    knodes: json['knodes'] as int,
    depth: json['depth'] as int,
    pvs: (json['pvs'] as List<dynamic>)
        .map((e) => CloudEvalPv.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
