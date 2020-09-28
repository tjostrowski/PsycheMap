import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:psyche_map/db.dart';
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
        ConfigurationTab(),
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

class ConfigurationTab extends StatefulWidget {
  ConfigurationTab({Key key}) : super(key: key);

  State<StatefulWidget> createState() => _ConfigurationTabState();
}

class _QuestionnaireTabState extends State<QuestionnaireTab> {
  List<int> sliderValues;
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Metric>>(
        future: DbProvider.db.getEnabledMetrics(),
        initialData: List(),
        builder: (BuildContext context, AsyncSnapshot<List<Metric>> snapshot) {
          if (snapshot.hasData) {
            List<Metric> metrics = snapshot.data;
            sliderValues = List.filled(metrics.length, 3);
            return Container(
                decoration: boxDecoration(),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: metrics.length,
                      itemBuilder: (context, index) {
                        Metric metric = metrics[index];
                        return Card(
                            child: Column(
                          children: [
                            Slider(
                              min: 0.0,
                              max: 5.0,
                              divisions: 5,
                              value: sliderValues[index].toDouble(),
                              label: sliderValues[index].toString(),
                              onChanged: !enabled
                                  ? null
                                  : (double value) {
                                      setState(() {
                                        sliderValues[index] = value.round();
                                      });
                                    },
                            ),
                            Text(MyLocalizations.of(context)
                                .getMetricName(metric)),
                          ],
                        ));
                      },
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton.extended(
                            backgroundColor: Colors.lightBlue[300],
                            icon: Icon(Icons.save),
                            label: enabled
                                ? Text(MyLocalizations.of(context).submit)
                                : Text(MyLocalizations.of(context).change),
                            onPressed: () {
                              setState(() {
                                enabled = !enabled;
                              });
                            })),
                  ],
                ));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
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
          FutureBuilder<List<Metric>>(
              future: DbProvider.db.getMetrics(),
              initialData: List(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Metric>> snapshot) {
                if (snapshot.hasData) {
                  List<Metric> metrics = snapshot.data;
                  return DropdownButton(
                      value: _metric,
                      items: _generateMetricItems(metrics),
                      onChanged: (value) {
                        setState(() {
                          _metric = value;
                        });
                      });
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })
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

  List<DropdownMenuItem> _generateMetricItems(List<Metric> metrics) {
    return metrics
        .asMap()
        .map((index, m) =>
            MapEntry(index, DropdownMenuItem(child: Text(MyLocalizations.of(context).getMetricName(metrics[index])), value: index + 1)))
        .values
        .toList();
  }
}

class _ConfigurationTabState extends State<ConfigurationTab> {
  final TextEditingController typeAheadController = TextEditingController();

  Metric currentlySelectedMetric;

  List<Metric> selectedMetrics = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            child: new Container(
              child: FutureBuilder<List<Metric>>(
                  future: DbProvider.db.getMetrics(),
                  // initialData: List(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Metric>> snapshot) {
                    if (snapshot.hasData) {
                      List<Metric> metrics = snapshot.data;
                      return TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                            autofocus: true,
                            style: DefaultTextStyle.of(context)
                                .style
                                .copyWith(fontStyle: FontStyle.italic),
                            decoration:
                                InputDecoration(border: OutlineInputBorder()),
                            controller: this.typeAheadController),
                        suggestionsCallback: (pattern) async {
                          return metrics.where((metric) =>
                              MyLocalizations.of(context)
                                  .getMetricName(metric)
                                  .toLowerCase()
                                  .startsWith(pattern.toLowerCase()));
                        },
                        itemBuilder: (BuildContext context, Metric suggestion) {
                          return ListTile(
                            title: Text(MyLocalizations.of(context)
                                .getMetricName(suggestion)),
                          );
                        },
                        onSuggestionSelected: (Metric suggestion) {
                          this.currentlySelectedMetric = suggestion;
                          this.typeAheadController.text =
                              MyLocalizations.of(context)
                                  .getMetricName(suggestion);
                        },
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
            padding: EdgeInsets.all(16.0)),
        RaisedButton(
          child: Text(MyLocalizations.of(context).add),
          onPressed: () {
            if (currentlySelectedMetric == null ||
                selectedMetrics.contains(currentlySelectedMetric)) {
              return;
            }
            selectedMetrics.add(currentlySelectedMetric);
            DbProvider.db.enableMetric(currentlySelectedMetric, true);
            setState(() {});
          },
        ),
        OrientationBuilder(builder: (context, orientation) {
          double heightFactor =
              (orientation == Orientation.portrait) ? 0.6 : 0.25;
          return Container(
            height: min(MediaQuery.of(context).size.height * heightFactor, 300),
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: selectedMetrics.length,
                itemBuilder: (BuildContext context, int index) {
                  Metric metric = selectedMetrics[index];
                  return Container(
                    height: 50,
                    margin: EdgeInsets.all(2),
                    color: Colors.blue[400],
                    child: Center(
                      child: Text(MyLocalizations.of(context).getMetricName(metric)),
                    ),
                  );
                }),
          );
        }),
      ],
    );
  }
}
