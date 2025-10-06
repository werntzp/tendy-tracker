const APP_TITLE = "Tendy Tracker";
const APP_VERSION = "Version 3.0, October 2025";
const DEFAULT_LOGO = "images/opp_logo.png";
const SDS_LOGO = "images/sds_logo.png";
const HOME_TEAM_LOGO = "home_logo.png";
const AWAY_TEAM_LOGO = "away_logo.png";
const int GOALS = 0;
const int SHOTS = 1;
const int UP = 0;
const int DOWN = 1;
const String HOME_TEAM_NAME = "home_team_name";
const String AWAY_TEAM_NAME = "away_team_name";
const String SAVED_GAMES_FILE = "ttgames.json";

enum enumShotLocation { high, medium, low }

enum enumTeamType { home, away }

enum enumGoalType { es, pp, en, sh, ps }

enum enumPeriodType { one, two, three, ot, so }

class ShotLocation {
  final enumTeamType team;
  final enumShotLocation location;
  ShotLocation(this.team, this.location);
}

class Goal {
  final enumGoalType? type;
  final enumTeamType team;
  final DateTime? time;
  final enumPeriodType period;
  Goal(this.type, this.team, this.time, this.period);
}

class Summary {
  final Map<enumPeriodType, int> homeShots;
  final Map<enumPeriodType, int> awayShots;
  final List<Goal> goals;
  final String homeTeam;
  final String awayTeam;
  Summary(
      this.homeShots, this.awayShots, this.goals, this.homeTeam, this.awayTeam);
}
