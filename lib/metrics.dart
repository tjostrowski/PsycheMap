import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:psyche_map/db.dart';
import 'package:psyche_map/localizations.dart';

import 'commons.dart';
import 'metrics_chart.dart';

class QuestionnairePage extends StatelessWidget {
  QuestionnairePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(MyLocalizations.of(context).questionnaire),
        ),
        body: QuestionnaireTab());
  }
}

class QuestionnaireTab extends StatefulWidget {
  QuestionnaireTab({Key key}) : super(key: key);

  State<StatefulWidget> createState() => _QuestionnaireTabState();
}

class ChartsPage extends StatelessWidget {
  final Metric metric;

  ChartsPage(this.metric, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(MyLocalizations.of(context).getMetricName(metric)),
        ),
        body: ChartsTab(metric: metric));
  }
}

class ChartsTab extends StatefulWidget {
  final Metric metric;

  ChartsTab({this.metric, Key key}) : super(key: key);

  State<StatefulWidget> createState() => _ChartsTabState();
}

class ConfigurationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(MyLocalizations.of(context).settings),
        ),
        body: DefaultTabController(
            length: 2,
            child: Builder(
                builder: (BuildContext context) => Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: [
                      TabPageSelector(),
                      Expanded(
                          child: IconTheme(
                        data: IconThemeData(
                            size: 128.0, color: Theme.of(context).accentColor),
                        child: TabBarView(children: [
                          ConfigurationTab(),
                          Column(
                            children: [
                              RaisedButton(
                                child: Text(MyLocalizations.of(context).reset),
                                onPressed: () {
                                  DbProvider.db.resetDb();
                                },
                              ),
                            ],
                          )
                        ]),
                      ))
                    ])))));
  }
}

class ConfigurationTab extends StatefulWidget {
  ConfigurationTab({Key key}) : super(key: key);

  State<StatefulWidget> createState() => _ConfigurationTabState();
}

class _QuestionnaireTabState extends State<QuestionnaireTab> {
  bool enabled = true;

  DateTime _now;

  _QuestionnaireTabState() {
    _now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MetricValue>>(
        future: DbProvider.db.getEnabledMetricValues(_now, 3),
        builder:
            (BuildContext context, AsyncSnapshot<List<MetricValue>> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            List<MetricValue> metricValues = snapshot.data;
            List<String> sliderNames = metricValues
                .map((mv) =>
                    MyLocalizations.of(context).getMetricName(mv.metric))
                .toList();
            return SlidersList(metricValues, sliderNames, enabled);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class SlidersList extends StatefulWidget {
  final List<MetricValue> metricValues;
  final List<String> sliderNames;
  final bool enabled;

  SlidersList(this.metricValues, this.sliderNames, this.enabled, {Key key})
      : super(key: key);

  State<StatefulWidget> createState() => _SlidersListState();
}

class _SlidersListState extends State<SlidersList> {
  List<int> sliderValues;
  List<TextEditingController> commentControllers = [];
  DateTime _now;
  bool enabled;

  @override
  void initState() {
    sliderValues = widget.metricValues.map((mv) => mv.value).toList();
    for (int i = 0; i < widget.metricValues.length; i++) {
      commentControllers.add(TextEditingController());
      commentControllers[i].text = widget.metricValues[i].comment;
    }
    enabled = widget.enabled;
    _now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: boxDecoration(),
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: sliderValues.length,
              itemBuilder: (context, index) {
                MetricValue mv = widget.metricValues[index];
                Metric m = mv.metric;

                return Card(
                    child: Column(
                  children: [
                    m.isRangeOneToFive
                        ? Slider(
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
                          )
                        : Switch(
                            value: sliderValues[index] == 1,
                            onChanged: !enabled
                                ? null
                                : (bool value) {
                                    setState(() {
                                      sliderValues[index] = value ? 1 : 0;
                                    });
                                  },
                          ),
                    ExpansionTile(
                      title: Text(widget.sliderNames[index]),
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextFormField(
                              enabled: enabled,
                              controller: commentControllers[index],
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                  hintText:
                                      MyLocalizations.of(context).comment),
                            ))
                      ],
                    ),
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
                    onPressed: () async {
                      if (enabled) {
                        List<MetricValue> updatedMetricValues = [];
                        for (int i = 0; i < widget.metricValues.length; i++) {
                          MetricValue mv = widget.metricValues[i];
                          updatedMetricValues.add(MetricValue(
                              mv.metric, sliderValues[i], _now,
                              comment: commentControllers[i].text));
                        }
                        await DbProvider.db.saveOrUpdateMetricValues(
                            updatedMetricValues, _now);
                      }
                      setState(() {
                        enabled = !enabled;
                      });
                    })),
          ],
        ));
  }
}

class _ChartsTabState extends State<ChartsTab> {
  int _chartType = 1;

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
          Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              color: Colors.green[200],
              child: Text('Moje komentarze'),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20.0)), //this right here
                        child: Container(
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          'What do you want to remember?'),
                                ),
                                SizedBox(
                                  width: 320.0,
                                  child: RaisedButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Save",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: const Color(0xFF1BC0C5),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
          )
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
        .map((index, m) => MapEntry(
            index,
            DropdownMenuItem(
                child: Text(
                    MyLocalizations.of(context).getMetricName(metrics[index])),
                value: index + 1)))
        .values
        .toList();
  }
}

class _ConfigurationTabState extends State<ConfigurationTab> {
  final TextEditingController typeAheadController = TextEditingController();

  Metric currentlySelectedMetric;

  bool loadingMetrics = true;
  List<Metric> metrics = [];
  bool loadingSelectedMetrics = true;
  List<Metric> selectedMetrics = [];

  @override
  void initState() {
    DbProvider.db.getMetrics().then((metrics) {
      setState(() {
        this.metrics = metrics;
        loadingMetrics = false;
      });
    });
    DbProvider.db.getEnabledMetrics().then((metrics) {
      setState(() {
        this.selectedMetrics = metrics;
        loadingSelectedMetrics = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: selectedMetrics.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _typeAhead(loadingMetrics);
          } else if (index == 1) {
            return _addButton();
          } else {
            Metric metric = selectedMetrics[index - 2];
            return _metric(metric);
          }
        });
  }

  Widget _typeAhead(bool loadingMetrics) {
    return !loadingMetrics
        ? TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
                autofocus: true,
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(fontStyle: FontStyle.italic),
                decoration: InputDecoration(border: OutlineInputBorder()),
                controller: this.typeAheadController),
            suggestionsCallback: (pattern) async {
              return metrics.where((metric) => MyLocalizations.of(context)
                  .getMetricName(metric)
                  .toLowerCase()
                  .startsWith(pattern.toLowerCase()));
            },
            itemBuilder: (BuildContext context, Metric suggestion) {
              return ListTile(
                title:
                    Text(MyLocalizations.of(context).getMetricName(suggestion)),
              );
            },
            onSuggestionSelected: (Metric suggestion) {
              this.currentlySelectedMetric = suggestion;
              this.typeAheadController.text =
                  MyLocalizations.of(context).getMetricName(suggestion);
            },
            hideOnLoading: true,
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget _addButton() {
    return RaisedButton(
      child: Text(MyLocalizations.of(context).add),
      onPressed: () {
        if (currentlySelectedMetric == null ||
            selectedMetrics.contains(currentlySelectedMetric)) {
          return;
        }

        selectedMetrics.add(currentlySelectedMetric);
        DbProvider.db.enableMetric(currentlySelectedMetric, true);
        this.typeAheadController.text = '';
        setState(() {});
      },
    );
  }

  Widget _metric(Metric metric) {
    return Container(
      height: 50,
      margin: EdgeInsets.all(2),
      color: Colors.blue[400],
      child: Center(
        child: Text(MyLocalizations.of(context).getMetricName(metric)),
      ),
    );
  }
}
