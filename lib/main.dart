import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Psyche Map',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'PsycheMap'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0.0,
        centerTitle: true,    
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu),
            color: Colors.white,
          )
        ],
      ),
      body: Column(children: <Widget>[
        Flexible(
          flex: 1,
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
            decoration: _boxDecoration(),
            alignment: Alignment.center,
          ),
          // ),
        ),
        Flexible(
          flex: 2,
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: _boxDecoration(),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 5, 20, 10),
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: _boxDecoration(),
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: _boxDecoration(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(blurRadius: 2.0, color: Colors.grey)]);
  }
}
