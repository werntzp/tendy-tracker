import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "shared.dart";
import "dart:io";

class SummaryScreen extends StatelessWidget {
  final Summary summary;
  final File homeImage;
  final File awayImage;
  SummaryScreen(
      {Key? key,
      required this.summary,
      required this.homeImage,
      required this.awayImage})
      : super(key: key);

  // return table with goals, or just text if nothing this period
  Widget _renderGoals() {
    List<Goal> goals = summary.goals;
    List<TableRow> rows = [];
    DateTime? dt;
    String time = "";
    String team = "";
    String type = "";
    String period = "";
    DateFormat fmt = new DateFormat('H:mm');

    rows.add(TableRow(children: [
      Text(
        "Period",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "Team",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "Time",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "Type",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ]));

    for (var i = 0; i < goals.length; i++) {
      if (goals[i].period == enumPeriodType.one) {
        period = "1";
      } else if (goals[i].period == enumPeriodType.two) {
        period = "2";
      } else if (goals[i].period == enumPeriodType.three) {
        period = "3";
      } else if (goals[i].period == enumPeriodType.ot) {
        period = "OT";
      } else {
        period = "SO";
      }

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
        Text(period),
        Text(team),
        Text(time),
        Text(type),
      ]));
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.0),
        child: Table(
          border: TableBorder(horizontalInside: BorderSide()),
          children: rows,
        ));
  }

  // return richtext with shots, or just text if nothing this period
  Widget _renderShots() {
    Map homeShotsMap = summary.homeShots;
    Map awayShotsMap = summary.awayShots;
    List<TableRow> rows = [];

    rows.add(TableRow(children: [
      Text(
        "Team",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "P1",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "P2",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "P3",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "OT",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "SO",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ]));

    rows.add(TableRow(children: [
      Text("Home"),
      Text(homeShotsMap[enumPeriodType.one].toString()),
      Text(homeShotsMap[enumPeriodType.two].toString()),
      Text(homeShotsMap[enumPeriodType.three].toString()),
      Text(homeShotsMap[enumPeriodType.ot].toString()),
      Text(homeShotsMap[enumPeriodType.so].toString()),
    ]));

    rows.add(TableRow(children: [
      Text("Away"),
      Text(awayShotsMap[enumPeriodType.one].toString()),
      Text(awayShotsMap[enumPeriodType.two].toString()),
      Text(awayShotsMap[enumPeriodType.three].toString()),
      Text(awayShotsMap[enumPeriodType.ot].toString()),
      Text(awayShotsMap[enumPeriodType.so].toString()),
    ]));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.0),
      child: Table(
        border: TableBorder(horizontalInside: BorderSide()),
        children: rows,
      ),
    );
  }

  // main build function
  @override
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
                    padding: const EdgeInsets.all(12.0),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(summary.homeTeam + " (H)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22)),
                        Text("vs",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Text(summary.awayTeam + " (A)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22)),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Image.file(
                          this.homeImage,
                          width: 100,
                          height: 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                        ),
                        Image.file(
                          this.awayImage,
                          width: 100,
                          height: 100,
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(DateFormat('MM/dd').format(DateTime.now()),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22))
                      ]),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                  ),
                  Text(
                    "Shots",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  _renderShots(),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                  ),
                  Text(
                    "Goals",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  _renderGoals(),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
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
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            ))));
  }
}
