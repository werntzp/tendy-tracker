class Game {
  final String id;
  final String game_date;
  final String home_team;
  final String away_team;
  final String home_goals;
  final String away_goals;
  final String home_shots;
  final String away_shots;
  final String home_svg;
  final String away_svg;
  final String home_xg;
  final String away_xg;

  Game({
    required this.id,
    required this.game_date,
    required this.home_team,
    required this.away_team,
    required this.home_goals,
    required this.away_goals,
    required this.home_shots,
    required this.away_shots,
    required this.home_svg,
    required this.away_svg,
    required this.home_xg,
    required this.away_xg    
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      game_date: json['game_date'],
      home_team: json['home_team'],
      away_team: json['away_team'],
      home_goals: json['home_goals'],
      away_goals: json['away_goals'],
      home_shots: json['home_shots'],
      away_shots: json['away_shots'],
      home_svg: json['home_svg'],
      away_svg: json['away_svg'],
      home_xg: json['home_xg'],
      away_xg: json['away_xg']
    );
  }



}
