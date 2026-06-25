class Streamer {
  const Streamer({required this.id, required this.name, this.title});

  final String id;
  final String name;
  final String? title;

  factory Streamer.fromJson(Map<String, dynamic> json) {
    return Streamer(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String?,
    );
  }
}
