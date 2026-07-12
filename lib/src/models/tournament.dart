class TournamentClock {
  final int limit;
  final int increment;

  const TournamentClock({required this.limit, required this.increment});

  factory TournamentClock.fromJson(Map<String, dynamic> json) =>
      TournamentClock(
        limit: json['limit'] as int,
        increment: json['increment'] as int,
      );
}

class TournamentVariant {
  final String key;
  final String short;
  final String name;

  const TournamentVariant({
    required this.key,
    required this.short,
    required this.name,
  });

  factory TournamentVariant.fromJson(Map<String, dynamic> json) =>
      TournamentVariant(
        key: json['key'] as String,
        short: json['short'] as String,
        name: json['name'] as String,
      );
}

class TournamentPerf {
  final String key;
  final String name;
  final String? icon;

  const TournamentPerf({required this.key, required this.name, this.icon});

  factory TournamentPerf.fromJson(Map<String, dynamic> json) => TournamentPerf(
    key: json['key'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String?,
  );
}

class TournamentSchedule {
  final String freq;
  final String speed;

  const TournamentSchedule({required this.freq, required this.speed});

  factory TournamentSchedule.fromJson(Map<String, dynamic> json) =>
      TournamentSchedule(
        freq: json['freq'] as String,
        speed: json['speed'] as String,
      );
}

class LichessTournament {
  final String id;
  final String? createdBy;
  final String? system;
  final int? minutes;
  final TournamentClock? clock;
  final bool rated;
  final String fullName;
  final int nbPlayers;
  final TournamentVariant? variant;
  final String startsAt;
  final String? endsAt;
  final int status;
  final TournamentPerf? perf;
  final TournamentSchedule? schedule;
  final int? secondsToStart;
  final int? secondsToFinish;
  final bool? isFinished;
  final bool? isRecentlyFinished;
  final String? winner;
  final bool? private;
  final bool? pairingsClosed;

  const LichessTournament({
    required this.id,
    this.createdBy,
    this.system,
    this.minutes,
    this.clock,
    required this.rated,
    required this.fullName,
    required this.nbPlayers,
    this.variant,
    required this.startsAt,
    this.endsAt,
    required this.status,
    this.perf,
    this.schedule,
    this.secondsToStart,
    this.secondsToFinish,
    this.isFinished,
    this.isRecentlyFinished,
    this.winner,
    this.private,
    this.pairingsClosed,
  });

  factory LichessTournament.fromJson(
    Map<String, dynamic> json,
  ) => LichessTournament(
    id: json['id'] as String,
    createdBy: json['createdBy'] as String?,
    system: json['system'] as String?,
    minutes: json['minutes'] as int?,
    clock: json['clock'] != null
        ? TournamentClock.fromJson(json['clock'] as Map<String, dynamic>)
        : null,
    rated: json['rated'] as bool? ?? false,
    fullName: json['fullName'] as String,
    nbPlayers: json['nbPlayers'] as int,
    variant: json['variant'] != null
        ? TournamentVariant.fromJson(json['variant'] as Map<String, dynamic>)
        : null,
    startsAt: json['startsAt'] as String,
    endsAt: json['endsAt'] as String?,
    status: json['status'] as int,
    perf: json['perf'] != null
        ? TournamentPerf.fromJson(json['perf'] as Map<String, dynamic>)
        : null,
    schedule: json['schedule'] != null
        ? TournamentSchedule.fromJson(json['schedule'] as Map<String, dynamic>)
        : null,
    secondsToStart: json['secondsToStart'] as int?,
    secondsToFinish: json['secondsToFinish'] as int?,
    isFinished: json['isFinished'] as bool?,
    isRecentlyFinished: json['isRecentlyFinished'] as bool?,
    winner: json['winner'] as String?,
    private: json['private'] as bool?,
    pairingsClosed: json['pairingsClosed'] as bool?,
  );
}

class TournamentList {
  final List<LichessTournament> created;
  final List<LichessTournament> started;
  final List<LichessTournament> finished;

  const TournamentList({
    required this.created,
    required this.started,
    required this.finished,
  });

  factory TournamentList.fromJson(Map<String, dynamic> json) {
    List<LichessTournament> parse(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map((e) => LichessTournament.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TournamentList(
      created: parse('created'),
      started: parse('started'),
      finished: parse('finished'),
    );
  }
}
