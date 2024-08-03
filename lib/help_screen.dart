import "package:flutter/material.dart";
import 'package:webview_flutter/webview_flutter.dart';
import "shared.dart";

class HelpScreen extends StatelessWidget {
  HelpScreen({Key? key}) : super(key: key);

  final _controller = WebViewController()..loadFlutterAsset('assets/help.html');

  // main build function
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: null,
            body: Center(
                child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                  ),
                  Center(
                    child: Text("How to Use Tendy Tracker",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 25)),
                  ),
                  Container(
                    child: WebViewWidget(
                      controller: _controller,
                    ),
                    height: 400.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                  ),
                  Center(
                    child: Text("$APP_TITLE",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  Center(
                    child: Text("$APP_VERSION", style: TextStyle(fontSize: 15)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                  ),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.asset(
                        "$SDS_LOGO",
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                  ),
                  Center(
                    child: FloatingActionButton(
                        heroTag: "fab1",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.black,
                        tooltip: "Back",
                        mini: true,
                        child: Icon(Icons.arrow_back, color: Colors.white)),
                  ),
                ],
              ),
            ))));
  }
}
