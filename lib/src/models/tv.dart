class TvPlayer {
  final String color;
  final String name;
  final String id;
  final int rating;

  const TvPlayer({
    required this.color,
    required this.name,
    required this.id,
    required this.rating,
  });

  factory TvPlayer.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return TvPlayer(
      color: json['color'] as String,
      name: user['name'] as String,
      id: user['id'] as String,
      rating: json['rating'] as int,
    );
  }
}

sealed class TvFeedEvent {
  const TvFeedEvent();

  factory TvFeedEvent.fromJson(Map<String, dynamic> json) {
    final type = json['t'] as String;
    final data = json['d'] as Map<String, dynamic>;
    return switch (type) {
      'featured' => TvFeaturedGame.fromJson(data),
      'fen' => TvFenUpdate.fromJson(data),
      _ => throw FormatException('Unknown TV feed event type: $type'),
    };
  }
}

class TvFeaturedGame extends TvFeedEvent {
  final String gameId;
  final String orientation;
  final List<TvPlayer> players;
  final String fen;
  final int whiteClockSecs;
  final int blackClockSecs;

  TvFeaturedGame({
    required this.gameId,
    required this.orientation,
    required this.players,
    required this.fen,
    required this.whiteClockSecs,
    required this.blackClockSecs,
  }) : super();

  factory TvFeaturedGame.fromJson(Map<String, dynamic> json) {
    return TvFeaturedGame(
      gameId: json['id'] as String,
      orientation: json['orientation'] as String,
      players: (json['players'] as List<dynamic>)
          .map((p) => TvPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
      fen: json['fen'] as String,
      whiteClockSecs: json['wc'] as int? ?? 0,
      blackClockSecs: json['bc'] as int? ?? 0,
    );
  }
}

class TvFenUpdate extends TvFeedEvent {
  final String fen;
  final String? lastMoveUci;
  final int whiteClockSecs;
  final int blackClockSecs;

  TvFenUpdate({
    required this.fen,
    required this.lastMoveUci,
    required this.whiteClockSecs,
    required this.blackClockSecs,
  }) : super();

  factory TvFenUpdate.fromJson(Map<String, dynamic> json) {
    return TvFenUpdate(
      fen: json['fen'] as String,
      lastMoveUci: json['lm'] as String?,
      whiteClockSecs: json['wc'] as int? ?? 0,
      blackClockSecs: json['bc'] as int? ?? 0,
    );
  }
}

class TvChannel {
  final String userId;
  final String userName;
  final int rating;
  final String gameId;

  const TvChannel({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.gameId,
  });

  factory TvChannel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return TvChannel(
      userId: user['id'] as String,
      userName: user['name'] as String,
      rating: json['rating'] as int,
      gameId: json['gameId'] as String,
    );
  }
}

class TvChannels {
  final TvChannel? bot;
  final TvChannel? blitz;
  final TvChannel? racingKings;
  final TvChannel? ultraBullet;
  final TvChannel? bullet;
  final TvChannel? classical;
  final TvChannel? threeCheck;
  final TvChannel? antichess;
  final TvChannel? computer;
  final TvChannel? horde;
  final TvChannel? rapid;
  final TvChannel? atomic;
  final TvChannel? crazyhouse;
  final TvChannel? chess960;
  final TvChannel? kingOfTheHill;
  final TvChannel? topRated;

  const TvChannels({
    this.bot,
    this.blitz,
    this.racingKings,
    this.ultraBullet,
    this.bullet,
    this.classical,
    this.threeCheck,
    this.antichess,
    this.computer,
    this.horde,
    this.rapid,
    this.atomic,
    this.crazyhouse,
    this.chess960,
    this.kingOfTheHill,
    this.topRated,
  });

  factory TvChannels.fromJson(Map<String, dynamic> json) {
    TvChannel? parse(String key) {
      final data = json[key];
      return data != null
          ? TvChannel.fromJson(data as Map<String, dynamic>)
          : null;
    }

    return TvChannels(
      bot: parse('bot'),
      blitz: parse('blitz'),
      racingKings: parse('racingKings'),
      ultraBullet: parse('ultraBullet'),
      bullet: parse('bullet'),
      classical: parse('classical'),
      threeCheck: parse('threeCheck'),
      antichess: parse('antichess'),
      computer: parse('computer'),
      horde: parse('horde'),
      rapid: parse('rapid'),
      atomic: parse('atomic'),
      crazyhouse: parse('crazyhouse'),
      chess960: parse('chess960'),
      kingOfTheHill: parse('kingOfTheHill'),
      topRated: parse('best'),
    );
  }
}
