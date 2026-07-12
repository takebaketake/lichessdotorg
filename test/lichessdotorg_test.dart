import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lichessdotorg/lichessdotorg.dart';

void main() async {
  final token = Platform.environment['LICHESS_AUTH_KEY'] ?? '';
  if (token.isEmpty) {
    print(
      'DIAGNOSTIC: LICHESS_AUTH_KEY environment variable is not set. Please set it to run the diagnostic test.',
    );
    return;
  }
  final client = http.Client();
  try {
    print('DIAGNOSTIC: Fetching raw following...');
    final response = await client.get(
      Uri.parse('https://lichess.org/api/rel/following'),
      headers: {
        'Accept': 'application/x-ndjson',
        'Authorization': 'Bearer $token',
      },
    );
    print('Status: ${response.statusCode}');
    final lines = response.body
        .trim()
        .split('\n')
        .where((l) => l.isNotEmpty)
        .toList();
    print('Lines count: ${lines.length}');
    for (int i = 0; i < lines.length; i++) {
      print('Line $i: ${lines[i]}');
      final map = jsonDecode(lines[i]) as Map<String, dynamic>;
      try {
        final user = LichessUser.fromJson(map);
        print('  Successfully parsed user: ${user.id}');
      } catch (e, stack) {
        print('  Failed to parse user at line $i: $e');
        print(stack);
      }
    }
  } catch (e) {
    print('DIAGNOSTIC: Error: $e');
  } finally {
    client.close();
  }
}
