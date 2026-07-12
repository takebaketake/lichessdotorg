import 'client.dart';

class LiveGamesPollResult {
  final List<UserStatus> popular;
  final List<UserStatus> following;

  const LiveGamesPollResult({required this.popular, required this.following});
}

/// Fetches live game statuses for two ID lists (popular, following)
/// with two optimizations:
///
/// 1. If the combined effective IDs across both lists fit within the 100-ID
///    API limit, a single request is fired and results are partitioned back.
///    Otherwise one request is fired per non-empty category.
///
/// 2. When a category has more than 100 IDs, the 100-slot budget is split:
///    - Up to 50 slots for IDs that had live games in the previous poll.
///    - Up to 50 slots juggled round-robin through the remaining IDs, so
///      every ID is eventually polled even though it cannot always fit.
class LiveGamesPoller {
  static const _maxPerRequest = 100;
  static const _liveSlot = 50;
  static const _juggleSlot = 50;

  final LichessClient _client;

  final Map<String, Set<String>> _prevLiveIds = {};
  final Map<String, int> _juggleCursor = {};

  LiveGamesPoller(this._client);

  Future<LiveGamesPollResult> poll({
    required List<String> popular,
    required List<String> following,
  }) async {
    // Lichess returns IDs in lowercase; normalize here so set lookups match.
    final effPopular = _computeEffective(
      'popular',
      popular.map((id) => id.toLowerCase()).toList(),
    );
    final effFollowing = _computeEffective(
      'following',
      following.map((id) => id.toLowerCase()).toList(),
    );

    final total = effPopular.length + effFollowing.length;

    List<UserStatus> popularResult;
    List<UserStatus> followingResult;

    if (total <= _maxPerRequest) {
      final merged = {...effPopular, ...effFollowing}.toList();

      final statuses = merged.isEmpty
          ? <UserStatus>[]
          : await _client.getUsersStatus(merged, withGameIds: true);

      final popularSet = effPopular.toSet();
      final followingSet = effFollowing.toSet();

      popularResult = statuses.where((s) => popularSet.contains(s.id)).toList();
      followingResult = statuses
          .where((s) => followingSet.contains(s.id))
          .toList();
    } else {
      final results = await Future.wait([
        effPopular.isEmpty
            ? Future.value(<UserStatus>[])
            : _client.getUsersStatus(effPopular, withGameIds: true),
        effFollowing.isEmpty
            ? Future.value(<UserStatus>[])
            : _client.getUsersStatus(effFollowing, withGameIds: true),
      ]);
      popularResult = results[0];
      followingResult = results[1];
    }

    _prevLiveIds['popular'] = popularResult
        .where((s) => s.gameId != null)
        .map((s) => s.id)
        .toSet();
    _prevLiveIds['following'] = followingResult
        .where((s) => s.gameId != null)
        .map((s) => s.id)
        .toSet();

    return LiveGamesPollResult(
      popular: popularResult,
      following: followingResult,
    );
  }

  /// Returns the effective IDs to request for [category], applying the
  /// live-priority / juggle split when [allIds] exceeds 100.
  ///
  /// Side-effect: advances the juggle cursor for [category].
  List<String> _computeEffective(String category, List<String> allIds) {
    if (allIds.length <= _maxPerRequest) return allIds;

    final prevLive = _prevLiveIds[category] ?? const {};
    final live = allIds.where(prevLive.contains).take(_liveSlot).toList();
    final liveSet = live.toSet();
    final rest = allIds.where((id) => !liveSet.contains(id)).toList();

    List<String> juggled;
    if (rest.isEmpty) {
      juggled = const [];
    } else {
      final cursor = (_juggleCursor[category] ?? 0) % rest.length;
      juggled = rest.skip(cursor).take(_juggleSlot).toList();
      _juggleCursor[category] = (cursor + juggled.length) % rest.length;
    }

    return [...live, ...juggled];
  }
}
