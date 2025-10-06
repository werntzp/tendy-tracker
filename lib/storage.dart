import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'games_model.dart';

class JsonStorage {
  final String filename;

  JsonStorage(this.filename);

  String getUniqueID() {
    Uuid _uuid = const Uuid();
    String newID = _uuid.v4();
    return newID; 
}
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  Future<List<Game>> readGames() async {
    final file = await _getFile();

    if (!await file.exists()) {
      // If file doesn’t exist yet, initialize with empty list
      await file.writeAsString(json.encode({"games": []}));
    }

    final contents = await file.readAsString();
    final data = json.decode(contents);
    final List<dynamic> gamesJson = data['games'];
    return gamesJson.map((json) => Game.fromJson(json)).toList();
  }

  Future<void> saveGames(List<Game> games) async {
    final file = await _getFile();
    final data = {
        "games": games.map((g) => {
        "id": g.id,
        "game_date": g.game_date,
        "home_team": g.home_team,
        "away_team": g.away_team,
        "home_goals": g.home_goals,
        "home_shots": g.home_shots,
        "home_svg": g.home_svg,
        "home_xg": g.home_xg,
        "away_goals": g.away_goals,
        "away_shots": g.away_shots,
        "away_svg": g.away_svg,
        "away_xg": g.away_xg,
      }).toList()

    };
    await file.writeAsString(json.encode(data));
  }

  Future<void> addGame(Game newGame) async {
    final games = await readGames();
    games.add(newGame);
    await saveGames(games);
  }

  
}

