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
      return data != null ? TvChannel.fromJson(data as Map<String, dynamic>) : null;
    }

    return TvChannels(
      bot: parse('Bot'),
      blitz: parse('Blitz'),
      racingKings: parse('Racing Kings'),
      ultraBullet: parse('UltraBullet'),
      bullet: parse('Bullet'),
      classical: parse('Classical'),
      threeCheck: parse('Three-check'),
      antichess: parse('Antichess'),
      computer: parse('Computer'),
      horde: parse('Horde'),
      rapid: parse('Rapid'),
      atomic: parse('Atomic'),
      crazyhouse: parse('Crazyhouse'),
      chess960: parse('Chess960'),
      kingOfTheHill: parse('King of the Hill'),
      topRated: parse('Top Rated'),
    );
  }
}
