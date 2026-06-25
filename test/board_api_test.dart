import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lichessdotorg/lichessdotorg.dart';
import 'package:test/test.dart';

void main() {
  group('Lichess Board API Models', () {
    test('LichessPlayingGame parsing', () {
      final jsonStr = '''{
        "gameId": "q7tPZ42A",
        "fullId": "q7tPZ42Axxxx",
        "color": "black",
        "fen": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
        "hasMoved": true,
        "isMyTurn": false,
        "opponent": {
          "username": "Stockfish level 1",
          "rating": 1500
        },
        "secondsLeft": 300
      }''';
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final game = LichessPlayingGame.fromJson(map);

      expect(game.gameId, 'q7tPZ42A');
      expect(game.color, 'black');
      expect(game.opponentName, 'Stockfish level 1');
      expect(game.opponentRating, 1500);
      expect(game.secondsLeft, 300);
      expect(game.isMyTurn, false);
    });

    test('LichessBoardEvent parsing - gameFull', () {
      final jsonStr = '''{
        "type": "gameFull",
        "id": "q7tPZ42A",
        "initialFen": "startpos",
        "white": {
          "id": "player1",
          "name": "Player One",
          "rating": 1600
        },
        "black": {
          "id": "player2",
          "name": "Player Two",
          "rating": 1700
        },
        "state": {
          "type": "gameState",
          "moves": "e2e4 e7e5",
          "wtime": 120000,
          "btime": 115000,
          "winc": 3000,
          "binc": 3000,
          "status": "started"
        }
      }''';
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final event = LichessBoardEvent.fromJson(map);

      expect(event, isA<LichessBoardGameFull>());
      final full = event as LichessBoardGameFull;
      expect(full.id, 'q7tPZ42A');
      expect(full.initialFen, 'startpos');
      expect(full.white.name, 'Player One');
      expect(full.black.name, 'Player Two');
      expect(full.moves, 'e2e4 e7e5');
      expect(full.wtime, 120000);
      expect(full.btime, 115000);
      expect(full.winc, 3000);
      expect(full.status, 'started');
    });

    test('LichessBoardEvent parsing - gameState', () {
      final jsonStr = '''{
        "type": "gameState",
        "moves": "e2e4 e7e5 g1f3",
        "wtime": 118000,
        "btime": 115000,
        "winc": 3000,
        "binc": 3000,
        "status": "started"
      }''';
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final event = LichessBoardEvent.fromJson(map);

      expect(event, isA<LichessBoardGameState>());
      final state = event as LichessBoardGameState;
      expect(state.moves, 'e2e4 e7e5 g1f3');
      expect(state.wtime, 118000);
      expect(state.btime, 115000);
      expect(state.winc, 3000);
      expect(state.binc, 3000);
      expect(state.status, 'started');
    });
  });

  group('LichessClient Board API Methods', () {
    test('getOngoingGames success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/account/playing');
        expect(request.method, 'GET');
        return http.Response(
          jsonEncode({
            'nowPlaying': [
              {
                'gameId': 'q7tPZ42A',
                'fullId': 'q7tPZ42Axxxx',
                'color': 'white',
                'fen': 'startpos',
                'hasMoved': false,
                'isMyTurn': true,
                'opponent': {'username': 'Stockfish level 2'},
                'secondsLeft': 60
              }
            ]
          }),
          200,
        );
      });

      final client = LichessClient(httpClient: mockClient, token: 'test-token');
      final games = await client.getOngoingGames();

      expect(games, hasLength(1));
      expect(games.first.gameId, 'q7tPZ42A');
      expect(games.first.opponentName, 'Stockfish level 2');
      expect(games.first.isMyTurn, true);
      client.close();
    });

    test('createAiChallenge success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/challenge/ai');
        expect(request.method, 'POST');
        expect(request.bodyFields['level'], '3');
        expect(request.bodyFields['color'], 'black');
        return http.Response(jsonEncode({'id': 'newGameId123'}), 201);
      });

      final client = LichessClient(httpClient: mockClient, token: 'test-token');
      final id = await client.createAiChallenge(level: 3, color: 'black');

      expect(id, 'newGameId123');
      client.close();
    });

    test('createOpenChallenge success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/challenge/open');
        expect(request.method, 'POST');
        expect(request.bodyFields['color'], 'random');
        return http.Response(
          jsonEncode({
            'challenge': {
              'id': 'openId',
              'url': 'https://lichess.org/openId'
            }
          }),
          200,
        );
      });

      final client = LichessClient(httpClient: mockClient, token: 'test-token');
      final res = await client.createOpenChallenge();

      expect(res['challenge']['id'], 'openId');
      expect(res['challenge']['url'], 'https://lichess.org/openId');
      client.close();
    });
  });
}
