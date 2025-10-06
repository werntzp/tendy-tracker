import "package:flutter/material.dart";
import "shared.dart";
import "storage.dart";
import "games_model.dart";

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

    @override
    _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = JsonStorage(SAVED_GAMES_FILE);
  late Future<List<Game>> _games;

  @override
  void initState() {
    super.initState();
    // Initialize your future here
    _games = _storage.readGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Games")),
      body: FutureBuilder<List<Game>>(
        future: _games,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No games found"));
          }

          final games = snapshot.data!;
          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Card(
                margin: EdgeInsets.all(8),
                elevation: 3,
                child: ListTile(  
                  isThreeLine: true,
                  title: Text(
                    "${game.game_date} - ${game.home_team} vs ${game.away_team}",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${game.home_team} goalie faced ${game.away_shots} shots (SV: ${game.home_svg}%, xG: ${game.home_xg})\r\n${game.away_team} goalie faced ${game.home_shots} shots (SV: ${game.away_svg}%, xG: ${game.away_xg})",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    "${game.home_goals} - ${game.away_goals}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

}
