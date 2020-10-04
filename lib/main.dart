import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:psyche_map/initialize_i18n.dart' show initializeI18n;
import 'package:psyche_map/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:psyche_map/constants.dart' show languages;
import 'package:psyche_map/metrics.dart';
import 'package:psyche_map/metrics_indicators.dart';

import 'commons.dart';
import 'db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, dynamic>> localizedValues = await initializeI18n();
  bool wizardNotNecessary = await DbProvider.db.exists() &&
      await DbProvider.db.areMetricsConfigured();
  if (wizardNotNecessary) {
    runApp(MyApp(localizedValues));
  } else {
    runApp(IntroductoryWizard(localizedValues));
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
      title: 'PsycheAid',
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
  final configTabState = GlobalKey<ConfigurationTabState>();

  void _onIntroEnd(context) {
    if (configTabState.currentState.selectedMetrics.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titlePadding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "PsycheAid",
          body: MyLocalizations.of(context).introText1,
          image: SvgPicture.asset(
            'assets/images/psychology.svg',
            width: 200,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: MyLocalizations.of(context).metricsTitle,
          bodyWidget: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ConfigurationTab(key: configTabState)),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: false,
      skipFlex: 0,
      nextFlex: 0,
      next: Icon(Icons.arrow_forward),
      done: Text(MyLocalizations.of(context).done,
          style: TextStyle(fontWeight: FontWeight.w600)),
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
  final _indicatorsCache =
      AsyncCache<List<MetricInidicatorValue>>(Duration(hours: 1));

  Future<List<MetricInidicatorValue>> get indicators =>
      _indicatorsCache.fetch(() {
        return MetricIndicatorsCompute().computeIndicatorValues();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("PsycheAid"),
        elevation: 0.0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu),
            color: Colors.white,
          )
        ],
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        bool isPortrait = (orientation == Orientation.portrait);
        if (isPortrait) {
          return Column(children: [
            Flexible(flex: 5, child: _metricsWidget(isPortrait)),
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 5, 20, 10),
                alignment: Alignment.center,
                child: Row(
                  children: [_questionnaire(isPortrait), _settings(isPortrait)],
                ),
              ),
            )
          ]);
        } else {
          // landscape
          return Row(
            children: [
              Flexible(flex: 5, child: _metricsWidget(isPortrait)),
              Flexible(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      _questionnaire(isPortrait),
                      _settings(isPortrait)
                    ],
                  ),
                ),
              )
            ],
          );
        }
      }),
    );
  }

  Widget _metricsWidget(bool isPortrait) {
    return Container(
        margin: isPortrait
            ? EdgeInsets.fromLTRB(20, 20, 20, 0)
            : EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: boxDecoration(),
        alignment: Alignment.center,
        padding: isPortrait
            ? EdgeInsets.fromLTRB(10, 5, 10, 5)
            : EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: FutureBuilder<List<MetricInidicatorValue>>(
            future: this.indicators,
            initialData: List(),
            builder:
                (BuildContext context, AsyncSnapshot<List<MetricInidicatorValue>> snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                List<MetricInidicatorValue> metricIndicators = snapshot.data;
                return GridView.builder(
                  shrinkWrap: false,
                  itemCount: metricIndicators.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: _aspectRatio(context, isPortrait)),
                  itemBuilder: (context, index) {
                    final metricIndicatorValue = metricIndicators[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                            MyLocalizations.of(context).getMetricName(metricIndicatorValue.metric)),
                        trailing: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              color: _getColor(metricIndicatorValue),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChartsPage(metricIndicatorValue.metric)));
                        },
                      ),
                      elevation: 0.5,
                    );
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Color _getColor(MetricInidicatorValue metricInidicatorValue) {
    int value = metricInidicatorValue.value;
    if (metricInidicatorValue.value == 20) {
      return Colors.grey;
    }
    if (value < 4) {
      return Colors.red;
    } else if (value > 6) {
      return Colors.green;
    }
    return Colors.yellow;
  }

  Widget _questionnaire(bool isPortrait) {
    return FutureBuilder<bool>(
        future: DbProvider.db.isQuestionnaireFilledForToday(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            bool filled = snapshot.data;
            return Expanded(
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuestionnairePage()))
                        .then((value) => setState(() {}));
                  },
                  child: Container(
                    decoration: boxDecoration(),
                    margin: isPortrait
                        ? EdgeInsets.fromLTRB(0, 0, 10, 0)
                        : EdgeInsets.fromLTRB(0, 5, 2, 5),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          filled
                              ? Icon(Icons.check, color: Colors.green)
                              : Icon(Icons.question_answer),
                          Center(
                              child: Text(
                            MyLocalizations.of(context).questionnaire,
                            textScaleFactor: 1.6,
                          )),
                          Center(
                              child: Text(
                            DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          )),
                        ]),
                  )),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _settings(bool isPortrait) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ConfigurationPage()))
              .then((value) => setState(() {}));
        },
        child: Container(
          decoration: boxDecoration(),
          margin: isPortrait
              ? EdgeInsets.fromLTRB(0, 0, 0, 0)
              : EdgeInsets.fromLTRB(0, 0, 2, 5),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.settings),
                Center(
                    child: Text(
                  MyLocalizations.of(context).settings,
                  textScaleFactor: 1.6,
                )),
              ]),
        ),
      ),
    );
  }

  double _aspectRatio(BuildContext context, bool isPortrait) {
    double crossAxisSpacing = 8;
    double screenWidth = MediaQuery.of(context).size.width;
    double crossAxisCount = 1;
    double width = (screenWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
        crossAxisCount;
    double cellHeight = 70;
    return width / cellHeight;
  }
}
