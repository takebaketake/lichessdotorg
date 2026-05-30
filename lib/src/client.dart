import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'models/explorer.dart';
import 'models/game.dart';
import 'models/puzzle.dart';
import 'models/team.dart';
import 'models/tournament.dart';
import 'models/tv.dart';
import 'models/user.dart';

export 'exceptions.dart';
export 'models/explorer.dart';
export 'models/game.dart';
export 'models/puzzle.dart';
export 'models/team.dart';
export 'models/tournament.dart';
export 'models/tv.dart';
export 'models/user.dart';

class LichessClient {
  static const _base = 'https://lichess.org/api';

  final http.Client _http;
  final String? _token;

  LichessClient({http.Client? httpClient, String? token})
      : _http = httpClient ?? http.Client(),
        _token = token;

  void close() => _http.close();

  Map<String, String> get _jsonHeaders => {
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Map<String, String> get _ndJsonHeaders => {
        'Accept': 'application/x-ndjson',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> _getJson(String path,
      {Map<String, String?>? query}) async {
    final uri = _buildUri(path, query);
    final response = await _http.get(uri, headers: _jsonHeaders);
    if (response.statusCode != 200) {
      throw LichessException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _getNdJson(String path,
      {Map<String, String?>? query}) async {
    final uri = _buildUri(path, query);
    final response = await _http.get(uri, headers: _ndJsonHeaders);
    if (response.statusCode != 200) {
      throw LichessException(response.statusCode, response.body);
    }
    return response.body
        .trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList();
  }

  Future<String> _getString(String path, {Map<String, String?>? query}) async {
    final uri = _buildUri(path, query);
    final response = await _http.get(
      uri,
      headers: {
        'Accept': 'application/x-chess-pgn',
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode != 200) {
      throw LichessException(response.statusCode, response.body);
    }
    return response.body;
  }

  Uri _buildUri(String path, Map<String, String?>? query) {
    if (query == null || query.isEmpty) {
      return Uri.parse('$_base$path');
    }
    final filtered = {
      for (final e in query.entries)
        if (e.value != null) e.key: e.value!,
    };
    return Uri.parse('$_base$path').replace(queryParameters: filtered);
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<LichessUser> getUser(String username) async {
    final json = await _getJson('/user/$username');
    return LichessUser.fromJson(json);
  }

  /// Returns users in the same order as [usernames].
  Future<List<LichessUser>> getUsers(List<String> usernames) async {
    final uri = Uri.parse('$_base/users');
    final response = await _http.post(
      uri,
      headers: {
        'Content-Type': 'text/plain',
        ..._jsonHeaders,
      },
      body: usernames.join(','),
    );
    if (response.statusCode != 200) {
      throw LichessException(response.statusCode, response.body);
    }
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => LichessUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RatingHistory>> getUserRatingHistory(String username) async {
    final uri = Uri.parse('$_base/user/$username/rating-history');
    final response = await _http.get(uri, headers: _jsonHeaders);
    if (response.statusCode != 200) {
      throw LichessException(response.statusCode, response.body);
    }
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => RatingHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// [perf] must be one of: ultraBullet, bullet, blitz, rapid, classical,
  /// correspondence, chess960, crazyhouse, antichess, atomic, horde,
  /// kingOfTheHill, racingKings, threeCheck.
  Future<UserPerfStats> getUserPerf(String username, String perf) async {
    final json = await _getJson('/user/$username/perf/$perf');
    return UserPerfStats.fromJson(json);
  }

  // ── Games ──────────────────────────────────────────────────────────────────

  Future<LichessGame> getGame(
    String id, {
    bool moves = true,
    bool opening = false,
    bool clocks = false,
    bool evals = false,
  }) async {
    final json = await _getJson('/game/$id', query: {
      'moves': '$moves',
      'opening': '$opening',
      'clocks': '$clocks',
      'evals': '$evals',
    });
    return LichessGame.fromJson(json);
  }

  Future<String> getGamePgn(String id) async {
    return _getString('/game/$id');
  }

  /// Downloads games for [username] in NDJSON format.
  ///
  /// [perf] filters by speed/variant (e.g. bullet, blitz, rapid, classical,
  /// chess960, crazyhouse, antichess, atomic, horde, kingOfTheHill,
  /// racingKings, threeCheck, ultraBullet).
  /// [color] filters by "white" or "black".
  Future<List<LichessGame>> getUserGames(
    String username, {
    int? max,
    int? since,
    int? until,
    String? vs,
    bool? rated,
    String? perf,
    String? color,
    bool? analysed,
    bool moves = true,
    bool tags = true,
    bool clocks = false,
    bool evals = false,
    bool opening = false,
  }) async {
    final rows = await _getNdJson('/games/user/$username', query: {
      'max': max?.toString(),
      'since': since?.toString(),
      'until': until?.toString(),
      'vs': vs,
      'rated': rated?.toString(),
      'perf': perf,
      'color': color,
      'analysed': analysed?.toString(),
      'moves': '$moves',
      'tags': '$tags',
      'clocks': '$clocks',
      'evals': '$evals',
      'opening': '$opening',
    });
    return rows.map(LichessGame.fromJson).toList();
  }

  /// Export multiple games by their IDs.
  Future<List<LichessGame>> getGames(
    List<String> ids, {
    bool moves = true,
    bool opening = false,
    bool clocks = false,
    bool evals = false,
  }) async {
    final uri = Uri.parse('$_base/games').replace(queryParameters: {
      'moves': '$moves',
      'opening': '$opening',
      'clocks': '$clocks',
      'evals': '$evals',
    });
    final response = await _http.post(
      uri,
      headers: {
        'Content-Type': 'text/plain',
        ..._ndJsonHeaders,
      },
      body: ids.join(','),
    );
    if (response.statusCode != 200) {
      throw LichessException(response.statusCode, response.body);
    }
    return response.body
        .trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .map((line) => LichessGame.fromJson(
            jsonDecode(line) as Map<String, dynamic>))
        .toList();
  }

  // ── Puzzles ────────────────────────────────────────────────────────────────

  Future<DailyPuzzle> getDailyPuzzle() async {
    final json = await _getJson('/puzzle/daily');
    return DailyPuzzle.fromJson(json);
  }

  // ── TV ─────────────────────────────────────────────────────────────────────

  Future<TvChannels> getTvChannels() async {
    final json = await _getJson('/tv/channels');
    return TvChannels.fromJson(json);
  }

  // ── Tournaments ────────────────────────────────────────────────────────────

  Future<TournamentList> getCurrentTournaments() async {
    final json = await _getJson('/tournament');
    return TournamentList.fromJson(json);
  }

  Future<LichessTournament> getTournament(String id) async {
    final json = await _getJson('/tournament/$id');
    return LichessTournament.fromJson(json);
  }

  // ── Teams ──────────────────────────────────────────────────────────────────

  Future<LichessTeam> getTeam(String teamId) async {
    final json = await _getJson('/team/$teamId');
    return LichessTeam.fromJson(json);
  }

  Future<TeamSearchResult> searchTeams(String text, {int page = 1}) async {
    final json = await _getJson('/team/search', query: {
      'text': text,
      'page': '$page',
    });
    return TeamSearchResult.fromJson(json);
  }

  /// Returns team members as a stream of users via NDJSON.
  Future<List<LichessUser>> getTeamMembers(String teamId, {int? max}) async {
    final rows = await _getNdJson('/team/$teamId/users', query: {
      if (max != null) 'max': '$max',
    });
    return rows.map(LichessUser.fromJson).toList();
  }

  // ── Opening Explorer ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _getExplorerJson(
    String path,
    Map<String, dynamic> params,
  ) async {
    final filtered = <String, dynamic>{
      for (final e in params.entries)
        if (e.value != null) e.key: e.value,
    };
    final uri = Uri.https('explorer.lichess.ovh', path, filtered);
    final response = await _http.get(uri, headers: _jsonHeaders);
    if (response.statusCode != 200) {
      throw LichessException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Move statistics from the Lichess games database for a position.
  ///
  /// [fen] is the board position; omit to use the starting position.
  /// [play] is a comma-separated sequence of UCI moves applied on top of [fen].
  /// [speeds] filters by time control (ultraBullet, bullet, blitz, rapid,
  /// classical, correspondence).
  /// [ratings] filters by Glicko-2 rating bucket (600, 1000, 1200, 1400,
  /// 1600, 1800, 2000, 2200, 2500).
  Future<ExplorerResult> getLichessExplorer({
    String? fen,
    String? play,
    String variant = 'standard',
    List<String>? speeds,
    List<int>? ratings,
    String? since,
    String? until,
    int moves = 12,
    int topGames = 4,
    int recentGames = 4,
  }) async {
    final json = await _getExplorerJson('/lichess', {
      'variant': variant,
      'moves': '$moves',
      'topGames': '$topGames',
      'recentGames': '$recentGames',
      'fen': fen,
      'play': play,
      'speeds': speeds,
      'ratings': ratings?.map((r) => '$r').join(','),
      'since': since,
      'until': until,
    });
    return ExplorerResult.fromJson(json);
  }

  /// Move statistics from a specific player's game history.
  ///
  /// [color] must be "white" or "black".
  /// [modes] filters by "rated" or "casual".
  Future<ExplorerResult> getPlayerExplorer(
    String player,
    String color, {
    String? fen,
    String? play,
    String variant = 'standard',
    List<String>? speeds,
    List<String>? modes,
    String? since,
    String? until,
    int moves = 12,
    int recentGames = 8,
  }) async {
    final json = await _getExplorerJson('/player', {
      'player': player,
      'color': color,
      'variant': variant,
      'moves': '$moves',
      'recentGames': '$recentGames',
      'fen': fen,
      'play': play,
      'speeds': speeds,
      'modes': modes,
      'since': since,
      'until': until,
    });
    return ExplorerResult.fromJson(json);
  }

  /// Move statistics from the masters database (FIDE-rated 2200+ games).
  ///
  /// [since] and [until] are years (e.g. "1952", "2023").
  Future<ExplorerResult> getMastersExplorer({
    String? fen,
    String? play,
    String? since,
    String? until,
    int moves = 12,
    int topGames = 4,
  }) async {
    final json = await _getExplorerJson('/masters', {
      'moves': '$moves',
      'topGames': '$topGames',
      'fen': fen,
      'play': play,
      'since': since,
      'until': until,
    });
    return ExplorerResult.fromJson(json);
  }

  // ── Cloud Eval ─────────────────────────────────────────────────────────────

  /// Engine evaluation from the Lichess cloud analysis cache.
  ///
  /// Returns a [LichessException] with status 404 if the position has not
  /// been cached yet. [multiPv] controls how many lines to return (1–5).
  Future<CloudEval> getCloudEval(
    String fen, {
    int multiPv = 1,
    String variant = 'standard',
  }) async {
    final json = await _getJson('/cloud-eval', query: {
      'fen': fen,
      'multiPv': '$multiPv',
      'variant': variant,
    });
    return CloudEval.fromJson(json);
  }
}
