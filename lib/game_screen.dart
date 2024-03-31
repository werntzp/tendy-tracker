import "package:flutter/material.dart";
import 'package:tendytracker/summary_screen.dart';
import "settings_screen.dart";
import "goals_screen.dart";
import "help_screen.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:path_provider/path_provider.dart";
import "dart:io";
import "shared.dart";
import "package:intl/intl.dart";

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
  Directory _directory = new Directory('/');
  File _defaultLogoFile = new File(DEFAULT_LOGO);
  File? _homeLogoFile = new File(DEFAULT_LOGO);
  File? _awayLogoFile = new File(DEFAULT_LOGO);
  List<Goal> _goals = <Goal>[];
  bool _isSwitched = false;
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

  File determineLogoFileToUse(enumTeamType team) {
    if (team == enumTeamType.home) {
      return _homeLogoFile ?? _defaultLogoFile;
    } else {
      return _awayLogoFile ?? _defaultLogoFile;
    }
  }

  // if no custom logo, use default one for home team
  Widget _homeTeamLogo() {
    imageCache.clear();
    return Image.file(
      determineLogoFileToUse(enumTeamType.home),
      width: 100,
      height: 100,
    );
  }

  // if no custom logo, use default one for away team
  Widget _awayTeamLogo() {
    imageCache.clear();
    return Image.file(
      determineLogoFileToUse(enumTeamType.away),
      width: 100,
      height: 100,
    );
  }

  // load any custom details
  void _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _directory = await getApplicationDocumentsDirectory();
    _path = _directory.path;
    String extra = "no";

    // home team logo
    if (await File("$_path/$HOME_TEAM_LOGO").exists() == true) {
      _homeLogoFile = await _getHomeTeamlogoFile;
    } else {
      _homeLogoFile = new File('temphome');
    }

    // away team logo
    if (await File("$_path/$AWAY_TEAM_LOGO").exists() == true) {
      _awayLogoFile = await _getAwayTeamlogoFile;
    } else {
      _awayLogoFile = new File('tempaway');
    }

    // are we asking for extra goal info (time and players on ice)?
    extra = (prefs.getString("extra") ?? "no");

    setState(() {
      // custom team names (if set)
      _homeTeamName = (prefs.getString("home_team_name") ?? "Team 1");
      _awayTeamName = (prefs.getString("away_team_name") ?? "Team 2");
      // if asking for extra info, set boolean flag
      if (extra == "yes") {
        _isSwitched = true;
      } else {
        _isSwitched = false;
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

    _homeSvg = ((tmpAwayShots - _awayGoals) / tmpAwayShots) * 100.00;
    _homeDisplaySvg = _homeSvg.toStringAsFixed(2);
    _awaySvg = ((tmpHomeShots - _homeGoals) / tmpHomeShots) * 100.00;
    _awayDisplaySvg = _awaySvg.toStringAsFixed(2);
  }

  // function to go up or down in goals and shots
  void _incrementHomeShots() {
    _update(enumTeamType.home, SHOTS, UP);
  }

  void _decrementHomeShots() {
    _update(enumTeamType.home, SHOTS, DOWN);
  }

  void _addHomeGoalSimple() {
    _update(enumTeamType.home, GOALS, UP);
  }

  void _decrementHomeGoals() {
    _update(enumTeamType.home, GOALS, DOWN);
  }

  void _incrementAwayShots() {
    _update(enumTeamType.away, SHOTS, UP);
  }

  void _decrementAwayShots() {
    _update(enumTeamType.away, SHOTS, DOWN);
  }

  void _addAwayGoalSimple() {
    _update(enumTeamType.away, GOALS, UP);
  }

  void _decrementAwayGoals() {
    _update(enumTeamType.away, GOALS, DOWN);
  }

  // decide what happens when they want to add a goal (simple or get extra info)
  void _addHomeGoal() {
    if (_isSwitched) {
      _addHomeGoalExtra();
    } else {
      _addHomeGoalSimple();
    }
  }

  // decide what happens when they want to add a goal (simple or get extra info)
  void _addAwayGoal() {
    if (_isSwitched) {
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
        // add or remove goal from the list
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
        // add a new goal to the list
        Goal g = new Goal(null, who, null, _period);
        _goals.add(g);
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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(APP_TITLE),
        backgroundColor: Colors.black,
      ),
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
            padding: const EdgeInsets.all(10.0),
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
                        child: Text("Goals", style: TextStyle(fontSize: 25)),
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
                        child: Text("Shots", style: TextStyle(fontSize: 20)),
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
                              color: Colors.black54),
                        ),
                        Text(
                          "SVG%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                        Text(
                          "$_homeDisplaySvg",
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
                              color: Colors.black54),
                        ),
                        Text(
                          "SVG%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54),
                        ),
                        Text(
                          "$_awayDisplaySvg",
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                  heroTag: "fab1",
                  onPressed: _reset,
                  backgroundColor: Colors.black,
                  tooltip: "Reset",
                  mini: true,
                  child: Icon(Icons.delete)),
              FloatingActionButton(
                  heroTag: "fab2",
                  onPressed: _gameSummary,
                  backgroundColor: Colors.black,
                  tooltip: "Game Summary",
                  mini: true,
                  child: Icon(Icons.view_list)),
              FloatingActionButton(
                  heroTag: "fab3",
                  onPressed: _settings,
                  backgroundColor: Colors.black,
                  tooltip: "Settings",
                  mini: true,
                  child: Icon(Icons.settings)),
              FloatingActionButton(
                  heroTag: "fab4",
                  onPressed: _help,
                  backgroundColor: Colors.black,
                  tooltip: "Help",
                  mini: true,
                  child: Icon(Icons.help)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
          ),
        ]),
      ),
    );
  }
}
