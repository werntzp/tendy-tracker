import "package:flutter/material.dart";
import "shared.dart";

class ShotsScreen extends StatelessWidget {
  final enumTeamType team;
  ShotsScreen({Key? key, required this.team}) : super(key: key);

  void _addShotLocation(enumShotLocation location, BuildContext context) {
    // send back a ShotLocation class
    ShotLocation sl = new ShotLocation(this.team, location);
    Navigator.pop(context, sl);
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 30.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
              ),
              Text(
                "Shot Location",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const Text(
                  "Use the image below to identify where a shot came from and pick High, Medium, or Low. You can \"upgrade\" a Low to a Medium and a Medium to High if the shot was off a rebound or came from a rush (within 4 seconds of zone entry).\r\n\r\nThe app will compute an Expected Goal (xG) range based off shot locations and display the average. This can give you a better sense of how a goalie is performing than just raw save percentage."),
              Image(
                  image: AssetImage('images/xg_rink_zones.png'),
                  height: 175,
                  width: 275),
              ElevatedButton(
                  onPressed: () {
                    _addShotLocation(enumShotLocation.low, context);
                  },
                  child: const Text("Low Danger")),
              Padding(
                padding: const EdgeInsets.all(3.0),
              ),
              ElevatedButton(
                  onPressed: () {
                    _addShotLocation(enumShotLocation.medium, context);
                  },
                  child: const Text("Medium Danger")),
              Padding(
                padding: const EdgeInsets.all(3.0),
              ),
              ElevatedButton(
                  onPressed: () {
                    _addShotLocation(enumShotLocation.high, context);
                  },
                  child: const Text("High Danger")),
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Center(
                child: FloatingActionButton(
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
                    )),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
