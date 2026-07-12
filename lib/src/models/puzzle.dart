class PuzzleGamePerf {
  final String key;
  final String name;

  const PuzzleGamePerf({required this.key, required this.name});

  factory PuzzleGamePerf.fromJson(Map<String, dynamic> json) =>
      PuzzleGamePerf(key: json['key'] as String, name: json['name'] as String);
}

class PuzzleGamePlayer {
  final String name;
  final String id;
  final String color;
  final int rating;

  const PuzzleGamePlayer({
    required this.name,
    required this.id,
    required this.color,
    required this.rating,
  });

  factory PuzzleGamePlayer.fromJson(Map<String, dynamic> json) =>
      PuzzleGamePlayer(
        name: json['name'] as String,
        id: json['id'] as String,
        color: json['color'] as String,
        rating: json['rating'] as int,
      );
}

class PuzzleGame {
  final String id;
  final PuzzleGamePerf perf;
  final bool rated;
  final List<PuzzleGamePlayer> players;
  final String pgn;
  final String? clock;

  const PuzzleGame({
    required this.id,
    required this.perf,
    required this.rated,
    required this.players,
    required this.pgn,
    this.clock,
  });

  factory PuzzleGame.fromJson(Map<String, dynamic> json) => PuzzleGame(
    id: json['id'] as String,
    perf: PuzzleGamePerf.fromJson(json['perf'] as Map<String, dynamic>),
    rated: json['rated'] as bool,
    players: (json['players'] as List<dynamic>)
        .map((e) => PuzzleGamePlayer.fromJson(e as Map<String, dynamic>))
        .toList(),
    pgn: json['pgn'] as String,
    clock: json['clock'] as String?,
  );
}

class PuzzleData {
  final String id;
  final int rating;
  final int plays;
  final List<String> solution;
  final List<String> themes;
  final int initialPly;

  const PuzzleData({
    required this.id,
    required this.rating,
    required this.plays,
    required this.solution,
    required this.themes,
    required this.initialPly,
  });

  factory PuzzleData.fromJson(Map<String, dynamic> json) => PuzzleData(
    id: json['id'] as String,
    rating: json['rating'] as int,
    plays: json['plays'] as int,
    solution: (json['solution'] as List<dynamic>).cast<String>(),
    themes: (json['themes'] as List<dynamic>).cast<String>(),
    initialPly: json['initialPly'] as int,
  );
}

class DailyPuzzle {
  final PuzzleGame game;
  final PuzzleData puzzle;

  const DailyPuzzle({required this.game, required this.puzzle});

  factory DailyPuzzle.fromJson(Map<String, dynamic> json) => DailyPuzzle(
    game: PuzzleGame.fromJson(json['game'] as Map<String, dynamic>),
    puzzle: PuzzleData.fromJson(json['puzzle'] as Map<String, dynamic>),
  );
}
