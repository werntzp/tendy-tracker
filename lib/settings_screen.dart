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
  File _defaultLogoFile = new File(DEFAULT_LOGO);
  File? _homeLogoFile = new File(DEFAULT_LOGO);
  File? _awayLogoFile = new File(DEFAULT_LOGO);
  File? _origHomeLogoFile = new File(DEFAULT_LOGO);
  File? _origAwayLogoFile = new File(DEFAULT_LOGO);
  String _path = "";
  Directory _directory = new Directory("/");
  bool _isSwitched = false;
  String _homeTeamName = "Team 1";
  String _awayTeamName = "Team 2";

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
    String extra = "no";

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

    // are we asking for extra goal info (time and players on ice)?
    extra = (prefs.getString("extra") ?? "no");

    setState(() {
      // custom team names (if set)
      _homeTeamName = (prefs.getString(HOME_TEAM_NAME) ?? "Team 1");
      _awayTeamName = (prefs.getString(AWAY_TEAM_NAME) ?? "Team 2");
      // if asking for extra info, set boolean flag
      if (extra == "yes") {
        _isSwitched = true;
      } else {
        _isSwitched = false;
      }
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

    if (_isSwitched) {
      extra = "yes";
    } else {
      extra = "no";
    }
    prefs.setString("extra", extra);

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

  File determineLogoFileToUse(enumTeamType team) {
    if (team == enumTeamType.home) {
      return _homeLogoFile ?? _defaultLogoFile;
    } else {
      return _awayLogoFile ?? _defaultLogoFile;
    }
  }

  // render image for home team
  Widget _homeTeamLogo() {
    imageCache.clear();
    return Image.file(
      determineLogoFileToUse(enumTeamType.home),
      width: 100,
      height: 100,
    );
  }

  // render image for away team
  Widget _awayTeamLogo() {
    imageCache.clear();
    return Image.file(
      determineLogoFileToUse(enumTeamType.away),
      width: 100,
      height: 100,
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.black,
      ),
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
                "Home Team Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Container(
                height: 60.0,
                child: TextField(
                  maxLength: 12,
                  controller: homeTeamController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "$_homeTeamName",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Text(
                "Home Team Logo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              GestureDetector(
                onTap: _pickHomeImage,
                onLongPress: _clearHomeImage,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: _homeTeamLogo(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Text(
                "Away Team Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Container(
                height: 60.0,
                child: TextField(
                  maxLength: 12,
                  controller: awayTeamController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "$_awayTeamName",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Text(
                "Team logo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              GestureDetector(
                onTap: _pickAwayImage,
                onLongPress: _clearAwayImage,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: _awayTeamLogo(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Extra Goal Info",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                    ),
                    Switch(
                      value: _isSwitched,
                      onChanged: (value) {
                        setState(() {
                          _isSwitched = value;
                        });
                      },
                    ),
                  ]),
              Text(
                "Time of goal and goal type.",
                style: TextStyle(fontSize: 15),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Center(
                child: FloatingActionButton(
                    heroTag: "fab8",
                    onPressed: _save,
                    backgroundColor: Colors.black,
                    tooltip: "Save",
                    mini: true,
                    child: Icon(Icons.save)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
