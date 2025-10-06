import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import "package:shared_preferences/shared_preferences.dart";
import "package:path_provider/path_provider.dart";
import "dart:io";
import 'dart:typed_data';
import "shared.dart";
import 'package:flutter/services.dart';

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
  String _path = "";
  Directory _directory = new Directory("/");
  String _homeTeamName = "Team 1";
  String _awayTeamName = "Team 2";
  String _tempTeamName = "Temp";
  bool? _calcHomeGoaliexG = false;
  bool? _calcAwayGoaliexG = false;
  bool? _getHomeGoalieExtra = false;
  bool? _getAwayGoalieExtra = false;
  Uint8List? _homeImageData;
  Uint8List? _awayImageData;
  Uint8List? _tempImageData;
  Uint8List? _defaultImageData;

  // load any custom details
  Future<void> _load() async {
    // this is where files will be stored for the team images
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _directory = await getApplicationDocumentsDirectory();
    _path = _directory.path;

    // tell flutter not to render until we're ready
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.deferFirstFrame();

    // local file vars
    File? hf = null;
    File? af = null;

    // always load up the default image
    ByteData byteData = await rootBundle.load(DEFAULT_LOGO);
    _defaultImageData = byteData.buffer.asUint8List();

    // load the home team logo into memory from the local file
    if (await File("$_path/$HOME_TEAM_LOGO").exists()) {
      hf = await File("$_path/$HOME_TEAM_LOGO");
      _homeImageData = await hf.readAsBytes();
    } else {
      // use the default logo
      _homeImageData = _defaultImageData;
    }

    // now away team logo
    if (await File("$_path/$AWAY_TEAM_LOGO").exists() == true) {
      af = await File("$_path/$AWAY_TEAM_LOGO");
      _awayImageData = await af.readAsBytes();
    } else {
      _awayImageData = await _defaultImageData;
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

    // ready after images have been loaded
    WidgetsBinding.instance.allowFirstFrame();
  }

  // save the team names and/or logos
  void _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Text tempHomeTeamName = Text(homeTeamController.text);
    Text tempAwayTeamName = Text(awayTeamController.text);
    String? homeName = tempHomeTeamName.data;
    String? awayName = tempAwayTeamName.data;

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

    // persist the home team logo image to file
    File? hf = null;
    File? af = null;

    // home team logo
    try {
      await File("$_path/$HOME_TEAM_LOGO").delete();
    } on Exception catch (e) {
      // do nothing; probably no file to delete
      print("error deleting home team logo file: $e");
    }
    try {
      hf = File("$_path/$HOME_TEAM_LOGO");
      await hf.writeAsBytes(_homeImageData!);
    } on Exception catch (e) {
      // do nothing; probably no file to delete
      print("error saving home team logo file: $e");
    }

    // home team logo
    try {
      await File("$_path/$AWAY_TEAM_LOGO").delete();
    } on Exception catch (e) {
      // do nothing; probably no file to delete
      print("error deleting away team logo file: $e");
    }
    try {
      af = File("$_path/$AWAY_TEAM_LOGO");
      await af.writeAsBytes(_awayImageData!);
    } on Exception catch (e) {
      // do nothing; probably no file to delete
      print("error saving away team logo file: $e");
    }

    // go back
    Navigator.pop(context, "saved");
  }

  void _swap() async {
    // grab text info
    String swapName;

    // now swap around the home and visitor names
    setState(() {
      // swap logos
      imageCache.clear();
      imageCache.clearLiveImages();
      _tempImageData = _homeImageData;
      _homeImageData = _awayImageData;
      _awayImageData = _tempImageData;

      // swamp text
      swapName = _homeTeamName;
      _homeTeamName = _awayTeamName;
      _awayTeamName = swapName;
    });
  }

  // home team image logo picker
  Future<void> _pickHomeImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      _homeImageData = await image.readAsBytes();
    }
    setState(() {
      // force a re-draw
    });
  }

  // home team image logo picker
  Future<void> _pickAwayImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      _awayImageData = await image.readAsBytes();
    }
    setState(() {
      // force a re-draw
    });
  }

  // swap back to default logo
  void _clearHomeImage() async {
    setState(() {
      _homeImageData = _defaultImageData;
    });
    try {
      await File("$_path/$HOME_TEAM_LOGO").delete();
    } on Exception catch (e) {
      // do nothing; probably no file to delete
      print("error caught trying to delete home team file: $e");
    }
  }

  // swap back to default logo
  void _clearAwayImage() async {
    setState(() {
      _awayImageData = _defaultImageData;
    });
    try {
      await File("$_path/$AWAY_TEAM_LOGO").delete();
    } on Exception catch (e) {
      // do nothing; probably no file to delete
      print("error caught trying to delete away team file: $e");
    }
  }

  // render image for home team
  Widget _homeTeamLogo() {
    imageCache.clear();
    // if we haven't loaded it up yet, use from the asset bundle
    if (_defaultImageData == null) {
      return Image.asset(
        DEFAULT_LOGO,
        width: 100,
        height: 100,
      );
    } else {
      return Image.memory(
        _homeImageData ?? _defaultImageData!,
        width: 100,
        height: 100,
      );
    }
  }

  Widget _awayTeamLogo() {
    imageCache.clear();
    // if we haven't loaded it up yet, use from the asset bundle
    if (_defaultImageData == null) {
      return Image.asset(
        DEFAULT_LOGO,
        width: 100,
        height: 100,
      );
    } else {
      return Image.memory(
        _awayImageData ?? _defaultImageData!,
        width: 100,
        height: 100,
      );
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
                padding: const EdgeInsets.all(3.0),
              ),
              Center(
                child: FloatingActionButton(
                    heroTag: "fab3",
                    onPressed: _swap,
                    backgroundColor: Colors.black,
                    tooltip: "Swap",
                    mini: true,
                    child: Icon(
                      Icons.swap_vert,
                      color: Colors.white,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
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
