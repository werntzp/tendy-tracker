import "package:flutter/material.dart";
import 'package:tendytracker/summary_screen.dart';
import 'package:tendytracker/shots_screen.dart';
import "settings_screen.dart";
import "goals_screen.dart";
import "help_screen.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:path_provider/path_provider.dart";
import "dart:io";
import "shared.dart";
import "package:intl/intl.dart";
import "storage.dart";
import "history_screen.dart";
import 'games_model.dart';

class GameScreen extends StatefulWidget {
  GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  enumPeriodType _period = enumPeriodType.one;
  int _homeGoals = 0;
  int _awayGoals = 0;
  int _homeShots = 0;
  int _awayShots = 0;
  double _homeSvg = 100.00;
  double _awaySvg = 100.00;
  String _homeDisplaySvg = "100.00";
  String _awayDisplaySvg = "100.00";
  String _homeTeamName = "Team 1";
  String _awayTeamName = "Team 2";
  String _displayPeriod = "1";
  String _path = "";
  Image _defaultLogoImage =
      new Image(image: AssetImage(DEFAULT_LOGO), height: 100, width: 100);
  Directory _directory = new Directory("/");
  File? _homeLogoFile = null;
  File? _awayLogoFile = null;
  List<Goal> _goals = <Goal>[];
  bool? _calcHomeGoaliexG = false;
  bool? _calcAwayGoaliexG = false;
  bool? _getHomeGoalieExtra = false;
  bool? _getAwayGoalieExtra = false;
  DateTime _gameDate = DateTime.now();
  Map<enumPeriodType, int> _homeShotsMap = {
    enumPeriodType.one: 0,
    enumPeriodType.two: 0,
    enumPeriodType.three: 0,
    enumPeriodType.ot: 0,
    enumPeriodType.so: 0
  };
  Map<enumPeriodType, int> _awayShotsMap = {
    enumPeriodType.one: 0,
    enumPeriodType.two: 0,
    enumPeriodType.three: 0,
    enumPeriodType.ot: 0,
    enumPeriodType.so: 0
  };
  Map<enumShotLocation, int> _homeShotLocationMap = {
    enumShotLocation.low: 0,
    enumShotLocation.medium: 0,
    enumShotLocation.high: 0
  };
  Map<enumShotLocation, int> _awayShotLocationMap = {
    enumShotLocation.low: 0,
    enumShotLocation.medium: 0,
    enumShotLocation.high: 0
  };
  enumShotLocation _lastHomeShot = enumShotLocation.low;
  enumShotLocation _lastAwayShot = enumShotLocation.low;
  String _homexGRange = "";
  String _awayxGRange = "";
  String _homexGLabel = "";
  String _awayxGLabel = "";
  final _storage = JsonStorage(SAVED_GAMES_FILE);
  

  String _buildxGRange(enumTeamType team) {
    int low = 0;
    int medium = 0;
    int high = 0;
    double lowxg = 0.0;
    double highxg = 0.0;
    String value = "";

    if (team == enumTeamType.away) {
      low = _awayShotLocationMap[enumShotLocation.low] ?? 0;
      medium = _awayShotLocationMap[enumShotLocation.medium] ?? 0;
      high = _awayShotLocationMap[enumShotLocation.high] ?? 0;
    } else {
      low = _homeShotLocationMap[enumShotLocation.low] ?? 0;
      medium = _homeShotLocationMap[enumShotLocation.medium] ?? 0;
      high = _homeShotLocationMap[enumShotLocation.high] ?? 0;
    }

    // old: .01-.05, .06-.12, .13-2
    // maybe? .01-.09, .1-.19, .2-.3
    lowxg = (low * 0.01) + (medium * 0.08) + (high * .2);
    highxg = (low * 0.06) + (medium * 0.16) + (high * .3);
    // value = lowxg.toStringAsFixed(1) + " - " + highxg.toStringAsFixed(1);
    value = ((lowxg + highxg) / 2).toStringAsFixed(1);
    return value;
  }

  // don't let goals or shots go above 99 or below 0
  int restrictNumber(direction, counter) {
    if (direction == UP) {
      counter++;
      if (counter > 99) {
        counter = 99;
      }
    } else {
      counter--;
      if (counter < 0) {
        counter = 0;
      }
    }
    return counter;
  }

  // clear out all the values
  void _reset() {
    setState(() {
      // clear all the vars
      _homeGoals = 0;
      _awayGoals = 0;
      _homeShots = 0;
      _awayShots = 0;
      _homeSvg = 100.00;
      _awaySvg = 100.00;
      _homeDisplaySvg = "100.00";
      _awayDisplaySvg = "100.00";
      _period = enumPeriodType.one;
      _displayPeriod = "1";
      _goals.clear();
      _homexGRange = "";
      _awayxGRange = "";
      // reset the maps
      _homeShotsMap[enumPeriodType.one] = 0;
      _homeShotsMap[enumPeriodType.two] = 0;
      _homeShotsMap[enumPeriodType.three] = 0;
      _homeShotsMap[enumPeriodType.ot] = 0;
      _homeShotsMap[enumPeriodType.so] = 0;
      _awayShotsMap[enumPeriodType.one] = 0;
      _awayShotsMap[enumPeriodType.two] = 0;
      _awayShotsMap[enumPeriodType.three] = 0;
      _awayShotsMap[enumPeriodType.ot] = 0;
      _awayShotsMap[enumPeriodType.so] = 0;
      _homeShotLocationMap[enumShotLocation.low] = 0;
      _homeShotLocationMap[enumShotLocation.medium] = 0;
      _homeShotLocationMap[enumShotLocation.high] = 0;
      _awayShotLocationMap[enumShotLocation.low] = 0;
      _awayShotLocationMap[enumShotLocation.medium] = 0;
      _awayShotLocationMap[enumShotLocation.high] = 0;
    });
  }

  // get a handle to the home team's logo
  Future<File> get _getHomeTeamlogoFile async {
    return File("$_path/$HOME_TEAM_LOGO");
  }

  // get a handle to the away team's logo
  Future<File> get _getAwayTeamlogoFile async {
    return File("$_path/$AWAY_TEAM_LOGO");
  }

  File? determineLogoFileToUse(enumTeamType team) {
    if (team == enumTeamType.home) {
      return _homeLogoFile;
    } else {
      return _awayLogoFile;
    }
  }

  // if no custom logo, use default one for home team
  Widget _homeTeamLogo() {
    imageCache.clear();
    File? f = determineLogoFileToUse(enumTeamType.home);
    if (f != null) {
      return Image.file(
        f,
        width: 100,
        height: 100,
      );
    } else {
      return _defaultLogoImage;
    }
  }

  // if no custom logo, use default one for away team
  Widget _awayTeamLogo() {
    imageCache.clear();
    File? f = determineLogoFileToUse(enumTeamType.away);
    if (f != null) {
      return Image.file(
        f,
        width: 100,
        height: 100,
      );
    } else {
      return _defaultLogoImage;
    }
  }

  // load any custom details
  void _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _directory = await getApplicationDocumentsDirectory();
    _path = _directory.path;

    // home team logo
    if (await File("$_path/$HOME_TEAM_LOGO").exists()) {
      _homeLogoFile = await _getHomeTeamlogoFile;
    } else {
      _homeLogoFile = null;
    }

    // away team logo
    if (await File("$_path/$AWAY_TEAM_LOGO").exists()) {
      _awayLogoFile = await _getAwayTeamlogoFile;
    } else {
      _awayLogoFile = null;
    }

    // are we asking for extra goal info (time and players on ice)?
    _getHomeGoalieExtra = (prefs.getBool("homeextra") ?? false);
    _getAwayGoalieExtra = (prefs.getBool("awayextra") ?? false);

    // are we going to track shot location
    _calcHomeGoaliexG = (prefs.getBool("homexg") ?? false);
    _calcAwayGoaliexG = (prefs.getBool("awayxg") ?? false);
    _homexGLabel = "";
    _awayxGLabel = "";

    setState(() {
      // custom team names (if set)
      _homeTeamName = (prefs.getString("home_team_name") ?? "Team 1");
      _awayTeamName = (prefs.getString("away_team_name") ?? "Team 2");
      // labels

      if (_calcHomeGoaliexG!) {
        _homexGLabel = "xG";
      }
      if (_calcAwayGoaliexG!) {
        _awayxGLabel = "xG";
      }
    });
  }

  // move to the settings dialog page; upon return, if we made changes, need to update everything
  void _settings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
    if (result != null) {
      setState(() {
        _load();
      });
    }
  }

  // bring up the history screen
  void _history() async {

    // once saved, go over to the history page
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryScreen()),
    );

  }

  // serialize this game to the stored json list 
  void _archive() async {
    // load up history file 
    final games = await _storage.readGames();

    // turn this game into a new object 
    final newGame = Game(
          id: _storage.getUniqueID(),
          game_date: DateFormat('MM/dd/yy').format(_gameDate).toString(),
          home_team: _homeTeamName,
          away_team: _awayTeamName,
          home_goals: _homeGoals.toString(),
          home_shots: _homeShots.toString(),
          home_svg: _homeDisplaySvg,
          home_xg: _homexGRange,
          away_goals: _awayGoals.toString(),
          away_shots: _awayShots.toString(),
          away_svg: _awayDisplaySvg,
          away_xg: _awayxGRange);

    // add that to the list of games and save the whole list
    games.add(newGame);
    await _storage.saveGames(games);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Game added to the history list!")),
    );

  }

  // move to the help dialog page
  void _help() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HelpScreen()),
    );
  }

  // instead of just incrementing goal, bring up screen to get more details about it
  void _addHomeGoalExtra() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("period", _displayPeriod);
    prefs.setString("scoring_team", "home");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoalsScreen()),
    );
    if (result != null) {
      setState(() {
        _goals.add(result);
        _homeGoals = restrictNumber(UP, _homeGoals);
        if (_homeShots < _homeGoals) {
          _homeShots = _homeGoals;
        }
      });
    }
  }

  // instead of just incrementing goal, bring up screen to get more details about it
  void _addAwayGoalExtra() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("period", _displayPeriod);
    prefs.setString("scoring_team", "away");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoalsScreen()),
    );
    if (result != null) {
      setState(() {
        _goals.add(result);
        _awayGoals = restrictNumber(UP, _awayGoals);
        if (_awayShots < _awayGoals) {
          _awayShots = _awayGoals;
        }
      });
    }
  }

  // go to the game summary screen
  void _gameSummary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Summary s = new Summary(
        _homeShotsMap,
        _awayShotsMap,
        _goals,
        (prefs.getString(HOME_TEAM_NAME) ?? "Team 1"),
        (prefs.getString(AWAY_TEAM_NAME) ?? "Team 2"));
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SummaryScreen(
                summary: s,
                homeImage: _homeLogoFile!,
                awayImage: _awayLogoFile!,
              )),
    );
  }

  // cycle through values for the game period (1,2,3,OT, or SO)
  void _incrementPeriod() {
    setState(() {
      if (_period == enumPeriodType.one) {
        _period = enumPeriodType.two;
        _displayPeriod = "2";
      } else if (_period == enumPeriodType.two) {
        _period = enumPeriodType.three;
        _displayPeriod = "3";
      } else if (_period == enumPeriodType.three) {
        _period = enumPeriodType.ot;
        _displayPeriod = "OT";
      } else if (_period == enumPeriodType.ot) {
        _period = enumPeriodType.so;
        _displayPeriod = "SO";
      } else {
        _period = enumPeriodType.one;
        _displayPeriod = "1";
      }
    });
  }

  // as goals or shots change, update the goalie's save percentage
  void _updateSavePercentage() {
    int tmpHomeShots = 0;
    int tmpAwayShots = 0;

    if (_awayShots == 0) {
      tmpAwayShots = 1;
    } else {
      tmpAwayShots = _awayShots;
    }
    if (_homeShots == 0) {
      tmpHomeShots = 1;
    } else {
      tmpHomeShots = _homeShots;
    }

    setState(() {
      _homeSvg = ((tmpAwayShots - _awayGoals) / tmpAwayShots) * 100.00;
      _homeDisplaySvg = _homeSvg.toStringAsFixed(0);
      _awaySvg = ((tmpHomeShots - _homeGoals) / tmpHomeShots) * 100.00;
      _awayDisplaySvg = _awaySvg.toStringAsFixed(0);
    });
  }

  // function to go up or down in goals and shots
  void _incrementHomeShots() async {
    bool b = _calcAwayGoaliexG ?? false;
    if (b) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShotsScreen(team: enumTeamType.home)),
      ) as ShotLocation;
      try {
        _homeShotLocationMap[result.location] =
            _homeShotLocationMap[result.location]! + 1;
        _update(enumTeamType.home, SHOTS, UP);
        _lastHomeShot = result.location;
      } catch (e) {
        // do nothing;
      }
    } else {
      _update(enumTeamType.home, SHOTS, UP);
    }
    if (b) {
      setState(() {
        _awayxGRange = _buildxGRange(enumTeamType.home);
      });
    }
  }

  void _decrementHomeShots() {
    bool b = _calcAwayGoaliexG ?? false;
    if (b) {
      _homeShotLocationMap[_lastHomeShot] =
          _homeShotLocationMap[_lastHomeShot]! - 1;
    }
    _update(enumTeamType.home, SHOTS, DOWN);
    if (b) {
      setState(() {
        _awayxGRange = _buildxGRange(enumTeamType.home);
      });
    }
  }

  void _incrementAwayShots() async {
    bool b = _calcHomeGoaliexG ?? false;
    if (b) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShotsScreen(team: enumTeamType.away)),
      ) as ShotLocation;
      try {
        _awayShotLocationMap[result.location] =
            _awayShotLocationMap[result.location]! + 1;
        _update(enumTeamType.away, SHOTS, UP);
        _lastAwayShot = result.location;
      } catch (e) {
        // do nothing;
      }
    } else {
      _update(enumTeamType.away, SHOTS, UP);
    }
    if (b) {
      setState(() {
        _homexGRange = _buildxGRange(enumTeamType.away);
      });
    }
  }

  void _decrementAwayShots() {
    bool b = _calcHomeGoaliexG ?? false;
    if (b) {
      _awayShotLocationMap[_lastAwayShot] =
          _awayShotLocationMap[_lastAwayShot]! - 1;
    }
    _update(enumTeamType.away, SHOTS, DOWN);
    if (b) {
      setState(() {
        _homexGRange = _buildxGRange(enumTeamType.away);
      });
    }
  }

  void _addHomeGoalSimple() {
    _update(enumTeamType.home, GOALS, UP);
  }

  void _decrementHomeGoals() {
    _update(enumTeamType.home, GOALS, DOWN);
  }

  void _addAwayGoalSimple() {
    _update(enumTeamType.away, GOALS, UP);
  }

  void _decrementAwayGoals() {
    _update(enumTeamType.away, GOALS, DOWN);
  }

  // decide what happens when they want to add a goal (simple or get extra info)
  void _addHomeGoal() {
    if (_getAwayGoalieExtra!) {
      _addHomeGoalExtra();
    } else {
      _addHomeGoalSimple();
    }
  }

  // decide what happens when they want to add a goal (simple or get extra info)
  void _addAwayGoal() {
    if (_getHomeGoalieExtra!) {
      _addAwayGoalExtra();
    } else {
      _addAwayGoalSimple();
    }
  }

  // update number of shots or goals
  void _update(enumTeamType who, int what, int direction) {
    setState(() {
      if ((who == enumTeamType.home) & (what == SHOTS)) {
        _homeShots = restrictNumber(direction, _homeShots);
        if (direction == UP) {
          _homeShotsMap[_period] = _homeShotsMap[_period]! + 1;
        } else {
          _homeShotsMap[_period] = _homeShotsMap[_period]! - 1;
        }
      } else if ((who == enumTeamType.home) & (what == GOALS)) {
        _homeGoals = restrictNumber(direction, _homeGoals);
        if (_homeShots < _homeGoals) {
          _homeShots = _homeGoals;
          _homeShotsMap[_period] = _homeShotsMap[_period]! + 1;
        }
        // add or remove goal from the list if we're tracking
        if (_getAwayGoalieExtra!) {
          if (direction == UP) {
            Goal g = new Goal(null, who, null, _period);
            _goals.add(g);
          } else {
            // start at end of list and remove last goal that is ours
            Iterable rev = _goals.reversed;
            for (Goal g in rev) {
              if (g.team == enumTeamType.home) {
                _goals.remove(g);
                break;
              }
            }
          }
        }
      } else if ((who == enumTeamType.away) & (what == SHOTS)) {
        _awayShots = restrictNumber(direction, _awayShots);
        if (direction == UP) {
          _awayShotsMap[_period] = _awayShotsMap[_period]! + 1;
        } else {
          _awayShotsMap[_period] = _awayShotsMap[_period]! - 1;
        }
      } else {
        _awayGoals = restrictNumber(direction, _awayGoals);
        if (_awayShots < _awayGoals) {
          _awayShots = _awayGoals;
          _awayShotsMap[_period] = _awayShotsMap[_period]! + 1;
        }
        // add or remove goal from the list if we're tracking
        if (_getHomeGoalieExtra!) {
          if (direction == UP) {
            Goal g = new Goal(null, who, null, _period);
            _goals.add(g);
          } else {
            // start at end of list and remove last goal that is ours
            Iterable rev = _goals.reversed;
            for (Goal g in rev) {
              if (g.team == enumTeamType.away) {
                _goals.remove(g);
                break;
              }
            }
          }
        }
      }

      // always update the save percentage for both teams
      _updateSavePercentage();
    });
  }

  void _changeDate() async {
    final DateTime picked;
    showDatePicker(
      context: context,
      initialDate: _gameDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    ).then((picked) {
      if ((picked != null) && (picked != _gameDate)) {
        setState(() {
          _gameDate = picked;
        });
      }
    });
  }

  // override the init function to see if there's a stored team name
  @override
  void initState() {
    super.initState();
    _load();
  }

  // main build function
  Widget build(BuildContext xcontext) {
    return SafeArea(
        child: Scaffold(
      appBar: null,
      body: Center(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
          ),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Center(
                    child: Text(
                      "HOME",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ),
                ),
                Container(
                  child: GestureDetector(
                    onTap: _changeDate,
                    child: Center(
                      child: Text(DateFormat('MM/dd').format(_gameDate),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    "AWAY",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(7.0),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "$_homeTeamName",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      FittedBox(
                        fit: BoxFit.fill,
                        child: _homeTeamLogo(),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: _incrementPeriod,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                        ),
                        Text(
                          "Period",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          "$_displayPeriod",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "$_awayTeamName",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      FittedBox(
                        fit: BoxFit.fill,
                        child: _awayTeamLogo(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: Text("Goals",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.black)),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onLongPress: _decrementHomeGoals,
                            onTap: _addHomeGoal,
                            child: Text(
                              "$_homeGoals",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onLongPress: _decrementAwayGoals,
                            onTap: _addAwayGoal,
                            child: Text(
                              "$_awayGoals",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: Text("Shots",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.black)),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onLongPress: _decrementHomeShots,
                            onTap: _incrementHomeShots,
                            child: Text(
                              "$_homeShots",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 45,
                                  color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onLongPress: _decrementAwayShots,
                            onTap: _incrementAwayShots,
                            child: Text(
                              "$_awayShots",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 45,
                                  color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "Goalie",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        Text(
                          "SV% $_homeDisplaySvg",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                        Text(
                          "$_homexGLabel $_homexGRange",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Goalie",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        Text(
                          "SV% $_awayDisplaySvg",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                        Text(
                          "$_awayxGLabel $_awayxGRange",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FloatingActionButton(
                  heroTag: "fab1",
                  onPressed: _reset,
                  backgroundColor: Colors.black,
                  tooltip: "Reset",
                  mini: true,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  )),
              FloatingActionButton(
                  heroTag: "fab2",
                  onPressed: _gameSummary,
                  backgroundColor: Colors.black,
                  tooltip: "Game Summary",
                  mini: true,
                  child: Icon(
                    Icons.view_list,
                    color: Colors.white,
                  )),
              SizedBox(width: 10),                  
              FloatingActionButton(
                  heroTag: "fab4",
                  onPressed: _archive,
                  backgroundColor: Colors.black,
                  tooltip: "Save to Game History",
                  mini: true,
                  child: Icon(
                    Icons.archive,
                    color: Colors.white,
                  )),
              FloatingActionButton(
                  heroTag: "fab6",
                  onPressed: _history,
                  backgroundColor: Colors.black,
                  tooltip: "Show Game History",
                  mini: true,
                  child: Icon(
                    Icons.inventory,
                    color: Colors.white,
                  )),                  
              SizedBox(width: 10),
              FloatingActionButton(
                  heroTag: "fab3",
                  onPressed: _settings,
                  backgroundColor: Colors.black,
                  tooltip: "Settings",
                  mini: true,
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                  )),
              FloatingActionButton(
                  heroTag: "fab5",
                  onPressed: _help,
                  backgroundColor: Colors.black,
                  tooltip: "Help",
                  mini: true,
                  child: Icon(
                    Icons.help,
                    color: Colors.white,
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
          ),
        ]),
      ),
    ));
  }
}
