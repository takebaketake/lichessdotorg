class TeamLeader {
  final String id;
  final String name;

  const TeamLeader({required this.id, required this.name});

  factory TeamLeader.fromJson(Map<String, dynamic> json) => TeamLeader(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}

class LichessTeam {
  final String id;
  final String name;
  final String? description;
  final bool open;
  final TeamLeader? leader;
  final List<TeamLeader>? leaders;
  final int nbMembers;
  final bool? joined;
  final bool? requested;

  const LichessTeam({
    required this.id,
    required this.name,
    this.description,
    required this.open,
    this.leader,
    this.leaders,
    required this.nbMembers,
    this.joined,
    this.requested,
  });

  factory LichessTeam.fromJson(Map<String, dynamic> json) => LichessTeam(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        open: json['open'] as bool? ?? false,
        leader: json['leader'] != null
            ? TeamLeader.fromJson(json['leader'] as Map<String, dynamic>)
            : null,
        leaders: json['leaders'] != null
            ? (json['leaders'] as List<dynamic>)
                .map((e) => TeamLeader.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        nbMembers: json['nbMembers'] as int,
        joined: json['joined'] as bool?,
        requested: json['requested'] as bool?,
      );
}

class TeamSearchResult {
  final int currentPage;
  final int maxPerPage;
  final List<LichessTeam> currentPageResults;
  final int nbResults;
  final int? previousPage;
  final int? nextPage;
  final int nbPages;

  const TeamSearchResult({
    required this.currentPage,
    required this.maxPerPage,
    required this.currentPageResults,
    required this.nbResults,
    this.previousPage,
    this.nextPage,
    required this.nbPages,
  });

  factory TeamSearchResult.fromJson(Map<String, dynamic> json) =>
      TeamSearchResult(
        currentPage: json['currentPage'] as int,
        maxPerPage: json['maxPerPage'] as int,
        currentPageResults: (json['currentPageResults'] as List<dynamic>)
            .map((e) => LichessTeam.fromJson(e as Map<String, dynamic>))
            .toList(),
        nbResults: json['nbResults'] as int,
        previousPage: json['previousPage'] as int?,
        nextPage: json['nextPage'] as int?,
        nbPages: json['nbPages'] as int,
      );
}
