class UserStatus {
  final String id;
  final String name;
  final bool online;
  final bool playing;
  final String? gameId;

  const UserStatus({
    required this.id,
    required this.name,
    required this.online,
    required this.playing,
    this.gameId,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      id: json['id'] as String,
      name: json['name'] as String,
      online: json['online'] as bool? ?? false,
      playing: json['playing'] as bool? ?? false,
      gameId: json['playingId'] as String?,
    );
  }
}
