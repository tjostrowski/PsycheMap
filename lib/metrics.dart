import 'package:flutter/material.dart';
import 'package:psyche_map/localizations.dart';

import 'commons.dart';
import 'metrics_chart.dart';

class MetricsPage extends StatefulWidget {
  MetricsPage({Key key}) : super(key: key);

  State<StatefulWidget> createState() => _MetricsPageState();
}

class _MetricsPageState extends State<MetricsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyLocalizations.of(context).metricsTitle),
      ),
      body: TabBarView(children: [
        QuestionnaireTab(),
        ChartsTab(),
        Center(),
      ], controller: _tabController),
      bottomNavigationBar: Material(
          color: Colors.green,
          child: TabBar(
            tabs: [
              Tab(
                  icon: Icon(Icons.question_answer),
                  text: MyLocalizations.of(context).questionnaire),
              Tab(
                  icon: Icon(Icons.show_chart),
                  text: MyLocalizations.of(context).stats),
              Tab(
                  icon: Icon(Icons.settings),
                  text: MyLocalizations.of(context).settings)
            ],
            controller: _tabController,
          )),
    );
  }
}

class QuestionnaireTab extends StatefulWidget {
  QuestionnaireTab({Key key}) : super(key: key);

  State<StatefulWidget> createState() => _QuestionnaireTabState();
}

class ChartsTab extends StatefulWidget {
  ChartsTab({Key key}) : super(key: key);

  State<StatefulWidget> createState() => _ChartsTabState();
}

class _QuestionnaireTabState extends State<QuestionnaireTab> {
  // Map<String, int> _questionnaires = new Map();
  List<int> sliderValues = [3, 3, 3, 3, 3, 3, 3];

  @override
  Widget build(BuildContext context) {
    List<dynamic> metrics = MyLocalizations.of(context).metrics;
    return Container(
        decoration: boxDecoration(),
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                String metric = metrics[index];
                // _questionnaires[metric] = 3;
                return Card(
                    child: Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: 5.0,
                      divisions: 5,
                      value: sliderValues[index].toDouble(),
                      label: sliderValues[index].toString(),
                      onChanged: (double value) {
                        setState(() {
                          sliderValues[index] = value.round();
                        });
                      },
                    ),
                    Text(metric),
                  ],
                ));
              },
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                    backgroundColor: Colors.lightBlue[300],
                    icon: Icon(Icons.save),
                    label: Text(MyLocalizations.of(context).submit))),
          ],
        ));
  }
}

class _ChartsTabState extends State<ChartsTab> {
  int _chartType = 1;
  int _metric = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: DropdownButton(
                  value: _chartType,
                  items: [
                    DropdownMenuItem(
                      child: Text(MyLocalizations.of(context).weekly),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text(MyLocalizations.of(context).monthly),
                      value: 2,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _chartType = value;
                    });
                  })),
          DropdownButton(
              value: _metric,
              items: _generateMetricItems(),
              onChanged: (value) {
                setState(() {
                  _metric = value;
                });
              }),
        ]),
        _getChart(),
      ],
    );
  }

  Widget _getChart() {
    return (this._chartType == 1)
        ? weeklyChart(context, "Test")
        : monthlyChart(context, "Test");
  }

  List<DropdownMenuItem> _generateMetricItems() {
    List<dynamic> metrics = MyLocalizations.of(context).metrics;
    return metrics
        .asMap()
        .map((index, m) =>
            MapEntry(index, DropdownMenuItem(child: Text(m), value: index + 1)))
        .values
        .toList();
  }
}
