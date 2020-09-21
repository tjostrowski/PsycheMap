import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:psyche_map/db.dart';
import 'package:psyche_map/initialize_i18n.dart' show initializeI18n;
import 'package:psyche_map/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:psyche_map/constants.dart' show languages;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, dynamic>> localizedValues = await initializeI18n();
  runApp(MyApp(localizedValues));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, dynamic>> localizedValues;
  MyApp(this.localizedValues);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Psyche Map',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'PsycheMap'),
      localizationsDelegates: [
        MyLocalizationsDelegate(localizedValues),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: languages.map((language) => Locale(language, '')),
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
    List<DrugPortion> currentDrugPortions = Db.of(context).getCurrentDrugs();
    List<dynamic> metrics = MyLocalizations.of(context).metrics;

    return Scaffold(
      appBar: AppBar(
        title: Text(MyLocalizations.of(context).hello),
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
          flex: 2,
          child: Container(
              margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
              decoration: _boxDecoration(),
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: GridView.builder(
                // padding:
                //     EdgeInsets.only(left: 5.0, right: 5.0, top: 5, bottom: 5),
                shrinkWrap: false,
                itemCount: metrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: _aspectRatio(context)),
                itemBuilder: (context, index) {
                  final item = metrics[index];
                  return Card(
                    child: ListTile(
                      title: Text(item),
                      trailing: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                      ),
                      onTap: () {},
                    ),
                    elevation: 0.5,
                  );
                },
              )),
        ),
        Flexible(
          flex: 3,
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: _boxDecoration(),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: ListView.builder(
                      itemCount: currentDrugPortions.length,
                      itemBuilder: (context, index) {
                        DrugPortion portion = currentDrugPortions[index];
                        return Card(
                            child: ListTile(
                          leading: Icon(Icons.healing),
                          title: Text(portion.drugName),
                          subtitle: Text(portion.drugDose),
                          trailing: Text(portion.count.toString()),
                        ));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 5, 20, 10),
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                    decoration: _boxDecoration(),
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    // child: LayoutBuilder(
                    //   builder: (context, constraints) => Card(
                          // child: Container(
                          //     height: constraints.maxHeight,
                              child: Column(
                                children: [
                                Icon(Icons.person),
                                Text(
                                  'dr Cichocki',
                                  textScaleFactor: 1.2,
                                ),
                                SizedBox(width: 0, height: 20),
                                Text('27-10-2020')
                              ]),
                    // ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: _boxDecoration(),
                    child: LayoutBuilder(
                      builder: (context, constraints) => Card(
                          child: Container(
                              height: constraints.maxHeight,
                              child: Column(children: [
                                Icon(Icons.people),
                                Text(
                                  'Grupa wsparcia',
                                  textScaleFactor: 1.2,
                                ),
                                SizedBox(width: 0, height: 20),
                                Text('28-10-2020')
                              ]))),
                    ),
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

  double _aspectRatio(BuildContext context) {
    double crossAxisSpacing = 8;
    double screenWidth = MediaQuery.of(context).size.width;
    double crossAxisCount = 2;
    double width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
        crossAxisCount;
    double cellHeight = 70;
    return width / cellHeight;
  }
}
