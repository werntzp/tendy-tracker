import "package:flutter/material.dart";
import "game_screen.dart";
import "shared.dart";

void main() => runApp(StatsApp());

class StatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_TITLE,
      debugShowCheckedModeBanner: false,
      home: new GameScreen(),
    );
  }
}
