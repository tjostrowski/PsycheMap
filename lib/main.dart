import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:path/path.dart';
import 'package:psyche_map/initialize_i18n.dart' show initializeI18n;
import 'package:psyche_map/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:psyche_map/constants.dart' show languages;
import 'package:psyche_map/metrics.dart';
import 'package:sqflite/sqflite.dart';

import 'commons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, dynamic>> localizedValues = await initializeI18n();
  final String dbName = 'psyche_map_db.db';
  bool dbExists = await databaseExists(join(await getDatabasesPath(), dbName));
  if (!dbExists) {
    runApp(IntroductoryWizard(localizedValues));
  } else {
    runApp(MyApp(localizedValues));
  }  
}

class IntroductoryWizard extends StatelessWidget {
  final Map<String, Map<String, dynamic>> localizedValues;

  IntroductoryWizard(this.localizedValues);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Psyche Map',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: IntroductoryPage(),
      localizationsDelegates: [
        MyLocalizationsDelegate(localizedValues),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: languages.map((language) => Locale(language, '')),
    );
  }
}

class IntroductoryPage extends StatefulWidget {
  @override
  _IntroductoryPageState createState() => _IntroductoryPageState();
}

class _IntroductoryPageState extends State<IntroductoryPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "PsycheAid",
          body: MyLocalizations.of(context).introText1,
          // image: _buildImage('img1'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: MyLocalizations.of(context).metricsTitle,
          bodyWidget: ConfigurationTab(),          
          // image: _buildImage('img1'),
          decoration: pageDecoration,
        ),    
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text(MyLocalizations.of(context).skip),
      next: Icon(Icons.arrow_forward),
      done: Text(MyLocalizations.of(context).done, style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  final Map<String, Map<String, dynamic>> localizedValues;

  MyApp(this.localizedValues);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsycheAid',
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
    List<dynamic> metrics = MyLocalizations.of(context).metrics;

    return Scaffold(
      appBar: AppBar(
        title: Text("PsycheAid"),
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
      body: Column(children: [
        Flexible(
            flex: 5,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MetricsPage()));
              },
              child: Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  decoration: boxDecoration(),
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: GridView.builder(
                    // padding:
                    //     EdgeInsets.only(left: 5.0, right: 5.0, top: 5, bottom: 5),
                    shrinkWrap: false,
                    itemCount: metrics.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: _aspectRatio(context)),
                    itemBuilder: (context, index) {
                      final item = metrics[index];
                      return Card(
                        child: ListTile(
                          title: Text(item),
                          trailing: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: (index % 3 == 0) ? Colors.red : Theme.of(context).primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                          ),
                        ),
                        elevation: 0.5,
                      );
                    },
                  )),
            )),
        Flexible(
          flex: 2,
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 5, 20, 10),
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: boxDecoration(),
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: ListView(children: [
                      SizedBox(height: 30),
                      Icon(Icons.question_answer),
                      Center(
                          child: Text(
                        'Ankieta',
                        textScaleFactor: 1.6,
                      )),
                      Center(
                          child: Text(
                        '27-10-2020',
                      )),
                    ]),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: boxDecoration(),                    
                    child: ListView(children: [
                      SizedBox(height: 30),
                      Icon(Icons.settings),
                      Center(
                          child: Text(
                        'Ustawienia',
                        textScaleFactor: 1.6,
                      )),                      
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  double _aspectRatio(BuildContext context) {
    double crossAxisSpacing = 8;
    double screenWidth = MediaQuery.of(context).size.width;
    double crossAxisCount = 1;
    double width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
        crossAxisCount;
    double cellHeight = 70;
    return width / cellHeight;
  }
}
