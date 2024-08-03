import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import "package:shared_preferences/shared_preferences.dart";
import "package:path_provider/path_provider.dart";
import "dart:io";
import "shared.dart";

// class used to populate the listview

// main class
class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final homeTeamController = TextEditingController();
  final awayTeamController = TextEditingController();
  Image _defaultLogoImage =
      new Image(image: AssetImage(DEFAULT_LOGO), height: 100, width: 100);
  File? _homeLogoFile = null;
  File? _awayLogoFile = null;
  File? _origHomeLogoFile = null;
  File? _origAwayLogoFile = null;
  String _path = "";
  Directory _directory = new Directory("/");
  String _homeTeamName = "Team 1";
  String _awayTeamName = "Team 2";
  bool? _calcHomeGoaliexG = false;
  bool? _calcAwayGoaliexG = false;
  bool? _getHomeGoalieExtra = false;
  bool? _getAwayGoalieExtra = false;

  // get a handle to the home team's logo
  Future<File> get _getHomeTeamlogoFile async {
    return File("$_path/$HOME_TEAM_LOGO");
  }

  // get a handle to the away team's logo
  Future<File> get _getAwayTeamlogoFile async {
    return File("$_path/$AWAY_TEAM_LOGO");
  }

  // load any custom details
  void _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _directory = await getApplicationDocumentsDirectory();
    _path = _directory.path;

    // home team logo
    if (await File("$_path/$HOME_TEAM_LOGO").exists() == true) {
      _homeLogoFile = await _getHomeTeamlogoFile;
      _origHomeLogoFile = _homeLogoFile;
    } else {
      _homeLogoFile = null;
      _origHomeLogoFile = null;
    }

    // away team logo
    if (await File("$_path/$AWAY_TEAM_LOGO").exists() == true) {
      _awayLogoFile = await _getAwayTeamlogoFile;
      _origAwayLogoFile = _awayLogoFile;
    } else {
      _awayLogoFile = null;
      _origAwayLogoFile = null;
    }

    setState(() {
      // custom team names (if set)
      _homeTeamName = (prefs.getString(HOME_TEAM_NAME) ?? "Team 1");
      _awayTeamName = (prefs.getString(AWAY_TEAM_NAME) ?? "Team 2");

      // shot locations
      _calcHomeGoaliexG = (prefs.getBool("homexg") ?? false);
      _calcAwayGoaliexG = (prefs.getBool("awayxg") ?? false);

      // extra goal info
      _getHomeGoalieExtra = (prefs.getBool("homeextra") ?? false);
      _getAwayGoalieExtra = (prefs.getBool("awayextra") ?? false);
    });
  }

  // save the team names and/or logos
  void _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Text tempHomeTeamName = Text(homeTeamController.text);
    Text tempAwayTeamName = Text(awayTeamController.text);
    String? homeName = tempHomeTeamName.data;
    String? awayName = tempAwayTeamName.data;
    String extra = "";

    // shot location
    prefs.setBool("homexg", (_calcHomeGoaliexG ?? false));
    prefs.setBool("awayxg", (_calcAwayGoaliexG ?? false));

    // extra goal info
    prefs.setBool("homeextra", (_getHomeGoalieExtra ?? false));
    prefs.setBool("awayextra", (_getAwayGoalieExtra ?? false));

    // custom home team name
    if (homeName == "") {
      homeName = _homeTeamName;
    }
    prefs.setString(HOME_TEAM_NAME, homeName != null ? homeName : "Team 1");

    // custom away team name
    if (awayName == "") {
      awayName = _awayTeamName;
    }
    prefs.setString(AWAY_TEAM_NAME, awayName != null ? awayName : "Team 2");

    // custom home team logo
    if ((_homeLogoFile != null) && (_homeLogoFile != _origHomeLogoFile)) {
      try {
        await File("$_path/$HOME_TEAM_LOGO").delete();
      } on Exception catch (e) {
        // do nothing; probably no file to delete
        print("error caught trying to delete file: $e");
      }
      try {
        await _homeLogoFile?.copy("$_path/$HOME_TEAM_LOGO");
      } on Exception catch (e) {
        // do nothing; probably no file to delete
        print("error caught trying to copy file: $e");
      }
    }

    // custom away team logo
    if ((_awayLogoFile != null) && (_awayLogoFile != _origAwayLogoFile)) {
      try {
        await File("$_path/$AWAY_TEAM_LOGO").delete();
      } on Exception catch (e) {
        // do nothing; probably no file to delete
        print("error caught trying to delete file: $e");
      }
      try {
        await _awayLogoFile?.copy("$_path/$AWAY_TEAM_LOGO");
      } on Exception catch (e) {
        // do nothing; probably no file to delete
        print("error caught trying to copy file: $e");
      }
    }

    // go back
    Navigator.pop(context, "saved");
  }

  // home team image logo picker
  Future _pickHomeImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _homeLogoFile = File(image.path);
      });
    }
  }

  // home team image logo picker
  Future _pickAwayImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _awayLogoFile = File(image.path);
      });
    }
  }

  // swap back to default logo
  void _clearHomeImage() async {
    setState(() {
      _homeLogoFile = null;
    });
    try {
      await File("$_path/$HOME_TEAM_LOGO").delete();
    } on Exception catch (e) {
      // do nothing; probably no file to delete
      print("error caught trying to delete file: $e");
    }
  }

  // swap back to default logo
  void _clearAwayImage() async {
    setState(() {
      _awayLogoFile = null;
    });
    try {
      await File("$_path/$AWAY_TEAM_LOGO").delete();
    } on Exception catch (e) {
      // do nothing; probably no file to delete
      print("error caught trying to delete file: $e");
    }
  }

  File? determineLogoFileToUse(enumTeamType team) {
    if (team == enumTeamType.home) {
      return _homeLogoFile;
    } else {
      return _awayLogoFile;
    }
  }

  // render image for home team
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

  // override the init function to see if there's anything custom stored
  @override
  void initState() {
    super.initState();
    _load();
  }

  // release the controller resources
  @override
  void dispose() {
    homeTeamController.dispose();
    awayTeamController.dispose();
    super.dispose();
  }

  // main build function
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Text(
                "Home Team Name & Logo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      maxLength: 12,
                      controller: homeTeamController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "$_homeTeamName",
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickHomeImage,
                      onLongPress: _clearHomeImage,
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: _homeTeamLogo(),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Text(
                "Away Team Name & Logo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      maxLength: 12,
                      controller: awayTeamController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "$_awayTeamName",
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickAwayImage,
                      onLongPress: _clearAwayImage,
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: _awayTeamLogo(),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Text(
                "Get Extra Goal Information for",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Material(
                child: CheckboxListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  tileColor: Colors.white,
                  title:
                      const Text('Home goalie', style: TextStyle(fontSize: 16)),
                  value: _getHomeGoalieExtra,
                  onChanged: (bool? value) {
                    setState(() {
                      _getHomeGoalieExtra = value;
                    });
                  },
                ),
              ),
              Material(
                child: CheckboxListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  tileColor: Colors.white,
                  title:
                      const Text('Away goalie', style: TextStyle(fontSize: 16)),
                  value: _getAwayGoalieExtra,
                  onChanged: (bool? value) {
                    setState(() {
                      _getAwayGoalieExtra = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
              ),
              Text(
                "Calculate xG Model for",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Material(
                child: CheckboxListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  tileColor: Colors.white,
                  title:
                      const Text('Home goalie', style: TextStyle(fontSize: 16)),
                  value: _calcHomeGoaliexG,
                  onChanged: (bool? value) {
                    setState(() {
                      _calcHomeGoaliexG = value;
                    });
                  },
                ),
              ),
              Material(
                child: CheckboxListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  tileColor: Colors.white,
                  title:
                      const Text('Away goalie', style: TextStyle(fontSize: 16)),
                  value: _calcAwayGoaliexG,
                  onChanged: (bool? value) {
                    setState(() {
                      _calcAwayGoaliexG = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FloatingActionButton(
                        heroTag: "fab8",
                        onPressed: _save,
                        backgroundColor: Colors.black,
                        tooltip: "Save",
                        mini: true,
                        child: Icon(Icons.save, color: Colors.white)),
                    FloatingActionButton(
                        heroTag: "fab1",
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                        backgroundColor: Colors.black,
                        tooltip: "Cancel",
                        mini: true,
                        child: Icon(
                          Icons.cancel,
                          color: Colors.white,
                        ))
                  ])
            ],
          ),
        ),
      ),
    ));
  }
}
