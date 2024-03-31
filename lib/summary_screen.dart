import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "shared.dart";

class SummaryScreen extends StatelessWidget {
  final Summary summary;
  SummaryScreen({Key? key, required this.summary}) : super(key: key);

  // return table with goals, or just text if nothing this period
  Widget _renderGoals(p) {
    List<Goal> goals = summary.goals;
    int counter = 0;
    List<TableRow> rows = [];
    DateTime? dt;
    String time = "";
    String team = "";
    String type = "";
    DateFormat fmt = new DateFormat('H:mm');

    rows.add(TableRow(children: [
      Text(
        "Time",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "Team",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "Type",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ]));

    for (var i = 0; i < goals.length; i++) {
      if (goals[i].period == p) {
        counter++;
        if (goals[i].team == enumTeamType.home) {
          team = " H";
        } else {
          team = " A";
        }
        if (goals[i].type == enumGoalType.es) {
          type = " ES";
        } else if (goals[i].type == enumGoalType.pp) {
          type = " PP";
        } else if (goals[i].type == enumGoalType.ps) {
          type = " PS";
        } else if (goals[i].type == enumGoalType.sh) {
          type = " SH";
        } else if (goals[i].type == enumGoalType.en) {
          type = " EN";
        } else {
          type = "";
        }
        // ternary operator to decide how to return time of goal
        dt = goals[i].time;
        dt == null ? time = "" : time = " " + fmt.format(dt);

        rows.add(TableRow(children: [
          Text(time),
          Text(team),
          Text(type),
        ]));
      }
    }

    // if there are goals this period, return the table
    if (counter > 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.0),
        child: Table(
          border: TableBorder.all(),
          children: rows,
        ),
      );
    } else {
      return Text(
        "No goals.",
        style: TextStyle(fontSize: 16),
      );
    }
  }

  Widget _renderSpace(p) {
    Map homeShotsMap = summary.homeShots;
    Map awayShotsMap = summary.awayShots;
    int h = homeShotsMap[p];
    int a = awayShotsMap[p];

    if ((h > 0) & (a > 0)) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(1.0),
      );
    }
  }

  // return richtext with shots, or just text if nothing this period
  Widget _renderShots(p) {
    Map homeShotsMap = summary.homeShots;
    Map awayShotsMap = summary.awayShots;
    int h = homeShotsMap[p];
    int a = awayShotsMap[p];

    if ((h > 0) | (a > 0)) {
      return RichText(
        text: TextSpan(
          text: "",
          style: TextStyle(color: Colors.black, fontSize: 16),
          children: <TextSpan>[
            TextSpan(
                text: "Shots: ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: "Home " + h.toString()),
            TextSpan(text: ", "),
            TextSpan(text: "Away " + a.toString()),
          ],
        ),
      );
    } else {
      return Text(
        "No shots.",
        style: TextStyle(fontSize: 16),
      );
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text(APP_TITLE),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
            child: Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Center(
                child: Text(
                    summary.homeTeam + " (H) vs " + summary.awayTeam + " (A)",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              Center(
                child: Text(DateFormat('MM/dd').format(DateTime.now()),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Text(
                "1st Period",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              _renderShots(enumPeriodType.one),
              _renderSpace(enumPeriodType.one),
              _renderGoals(enumPeriodType.one),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Text(
                "2nd Period",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              _renderShots(enumPeriodType.two),
              _renderSpace(enumPeriodType.two),
              _renderGoals(enumPeriodType.two),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Text(
                "3rd Period",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              _renderShots(enumPeriodType.three),
              _renderSpace(enumPeriodType.three),
              _renderGoals(enumPeriodType.three),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Text(
                "Overtime",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              _renderShots(enumPeriodType.ot),
              _renderSpace(enumPeriodType.ot),
              _renderGoals(enumPeriodType.ot),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Text(
                "Shootout",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              _renderShots(enumPeriodType.so),
              _renderSpace(enumPeriodType.so),
              _renderGoals(enumPeriodType.so),
              Padding(
                padding: const EdgeInsets.all(12.0),
              ),
              Center(
                child: FloatingActionButton(
                    heroTag: "fab9",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.black,
                    tooltip: "Back",
                    mini: true,
                    child: Icon(Icons.arrow_back)),
              ),
            ],
          ),
        )));
  }
}
