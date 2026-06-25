class UserProfile {
  final String? country;
  final String? location;
  final String? bio;
  final String? firstName;
  final String? lastName;
  final int? fideRating;
  final int? uscfRating;
  final int? ecfRating;
  final int? cfcRating;
  final int? rcfRating;
  final String? links;

  const UserProfile({
    this.country,
    this.location,
    this.bio,
    this.firstName,
    this.lastName,
    this.fideRating,
    this.uscfRating,
    this.ecfRating,
    this.cfcRating,
    this.rcfRating,
    this.links,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        country: json['country'] as String?,
        location: json['location'] as String?,
        bio: json['bio'] as String?,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        fideRating: json['fideRating'] as int?,
        uscfRating: json['uscfRating'] as int?,
        ecfRating: json['ecfRating'] as int?,
        cfcRating: json['cfcRating'] as int?,
        rcfRating: json['rcfRating'] as int?,
        links: json['links'] as String?,
      );
}

class UserCount {
  final int all;
  final int rated;
  final int ai;
  final int draw;
  final int drawH;
  final int loss;
  final int lossH;
  final int win;
  final int winH;
  final int? bookmark;
  final int? playing;
  final int? import;
  final int? me;

  const UserCount({
    required this.all,
    required this.rated,
    required this.ai,
    required this.draw,
    required this.drawH,
    required this.loss,
    required this.lossH,
    required this.win,
    required this.winH,
    this.bookmark,
    this.playing,
    this.import,
    this.me,
  });

  factory UserCount.fromJson(Map<String, dynamic> json) => UserCount(
        all: json['all'] as int,
        rated: json['rated'] as int,
        ai: json['ai'] as int,
        draw: json['draw'] as int,
        drawH: json['drawH'] as int,
        loss: json['loss'] as int,
        lossH: json['lossH'] as int,
        win: json['win'] as int,
        winH: json['winH'] as int,
        bookmark: json['bookmark'] as int?,
        playing: json['playing'] as int?,
        import: json['import'] as int?,
        me: json['me'] as int?,
      );
}

class UserPlayTime {
  final int total;
  final int tv;

  const UserPlayTime({required this.total, required this.tv});

  factory UserPlayTime.fromJson(Map<String, dynamic> json) => UserPlayTime(
        total: json['total'] as int,
        tv: json['tv'] as int,
      );
}

class UserPerf {
  final int games;
  final int rating;
  final int rd;
  final int prog;
  final bool? prov;

  const UserPerf({
    required this.games,
    required this.rating,
    required this.rd,
    required this.prog,
    this.prov,
  });

  factory UserPerf.fromJson(Map<String, dynamic> json) => UserPerf(
        games: json['games'] as int,
        rating: json['rating'] as int,
        rd: json['rd'] as int,
        prog: json['prog'] as int,
        prov: json['prov'] as bool?,
      );
}

class StormPerf {
  final int runs;
  final int score;

  const StormPerf({required this.runs, required this.score});

  factory StormPerf.fromJson(Map<String, dynamic> json) => StormPerf(
        runs: json['runs'] as int,
        score: json['score'] as int,
      );
}

class LichessUser {
  final String id;
  final String username;
  final bool? online;
  final Map<String, UserPerf>? perfs;
  final StormPerf? storm;
  final int? createdAt;
  final bool? disabled;
  final bool? tosViolation;
  final UserProfile? profile;
  final int? seenAt;
  final bool? patron;
  final int? nbFollowers;
  final int? nbFollowing;
  final UserPlayTime? playTime;
  final String? title;
  final String? url;
  final String? playing;
  final int? completionRate;
  final UserCount? count;
  final bool? followable;
  final bool? following;
  final bool? blocking;
  final bool? followsYou;

  const LichessUser({
    required this.id,
    required this.username,
    this.online,
    this.perfs,
    this.storm,
    this.createdAt,
    this.disabled,
    this.tosViolation,
    this.profile,
    this.seenAt,
    this.patron,
    this.nbFollowers,
    this.nbFollowing,
    this.playTime,
    this.title,
    this.url,
    this.playing,
    this.completionRate,
    this.count,
    this.followable,
    this.following,
    this.blocking,
    this.followsYou,
  });

  factory LichessUser.fromJson(Map<String, dynamic> json) {
    Map<String, UserPerf>? perfs;
    StormPerf? storm;
    final perfsJson = json['perfs'] as Map<String, dynamic>?;
    if (perfsJson != null) {
      perfs = {};
      for (final entry in perfsJson.entries) {
        final val = entry.value;
        if (val is! Map<String, dynamic>) continue;
        if (entry.key == 'storm') {
          storm = StormPerf.fromJson(val);
        } else if (val.containsKey('games') &&
            val.containsKey('rating') &&
            val.containsKey('rd') &&
            val.containsKey('prog')) {
          perfs[entry.key] = UserPerf.fromJson(val);
        }
      }
    }

    return LichessUser(
      id: json['id'] as String,
      username: (json['username'] ?? json['name'] ?? json['id']) as String,
      online: json['online'] as bool?,
      perfs: perfs,
      storm: storm,
      createdAt: json['createdAt'] as int?,
      disabled: json['disabled'] as bool?,
      tosViolation: json['tosViolation'] as bool?,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      seenAt: json['seenAt'] as int?,
      patron: json['patron'] as bool?,
      nbFollowers: json['nbFollowers'] as int?,
      nbFollowing: json['nbFollowing'] as int?,
      playTime: json['playTime'] != null
          ? UserPlayTime.fromJson(json['playTime'] as Map<String, dynamic>)
          : null,
      title: json['title'] as String?,
      url: json['url'] as String?,
      playing: json['playing'] is String ? json['playing'] as String : null,
      completionRate: json['completionRate'] as int?,
      count: json['count'] != null
          ? UserCount.fromJson(json['count'] as Map<String, dynamic>)
          : null,
      followable: json['followable'] as bool?,
      following: json['following'] as bool?,
      blocking: json['blocking'] as bool?,
      followsYou: json['followsYou'] as bool?,
    );
  }
}

class RatingPoint {
  final int year;
  final int month;
  final int day;
  final int rating;

  const RatingPoint({
    required this.year,
    required this.month,
    required this.day,
    required this.rating,
  });

  factory RatingPoint.fromList(List<dynamic> list) => RatingPoint(
        year: list[0] as int,
        month: list[1] as int,
        day: list[2] as int,
        rating: list[3] as int,
      );
}

class RatingHistory {
  final String name;
  final List<RatingPoint> points;

  const RatingHistory({required this.name, required this.points});

  factory RatingHistory.fromJson(Map<String, dynamic> json) => RatingHistory(
        name: json['name'] as String,
        points: (json['points'] as List<dynamic>)
            .map((e) => RatingPoint.fromList(e as List<dynamic>))
            .toList(),
      );
}

class PerfGlicko {
  final double rating;
  final double deviation;
  final bool? provisional;

  const PerfGlicko({
    required this.rating,
    required this.deviation,
    this.provisional,
  });

  factory PerfGlicko.fromJson(Map<String, dynamic> json) => PerfGlicko(
        rating: (json['rating'] as num).toDouble(),
        deviation: (json['deviation'] as num).toDouble(),
        provisional: json['provisional'] as bool?,
      );
}

class UserPerfStats {
  final String userId;
  final String userName;
  final PerfGlicko glicko;
  final int games;
  final int progress;
  final int? rank;
  final double? percentile;

  const UserPerfStats({
    required this.userId,
    required this.userName,
    required this.glicko,
    required this.games,
    required this.progress,
    this.rank,
    this.percentile,
  });

  factory UserPerfStats.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final perf = json['perf'] as Map<String, dynamic>;
    final glicko = PerfGlicko.fromJson(perf['glicko'] as Map<String, dynamic>);
    return UserPerfStats(
      userId: user['id'] as String,
      userName: user['name'] as String,
      glicko: glicko,
      games: perf['nb'] as int,
      progress: perf['progress'] as int,
      rank: json['rank'] as int?,
      percentile: (json['percentile'] as num?)?.toDouble(),
    );
  }
}
