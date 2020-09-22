import 'package:flutter/material.dart';
import 'package:psyche_map/localizations.dart';

import 'commons.dart';

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
        Center(),
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
                    icon: Icon(Icons.save),
                    label: Text(MyLocalizations.of(context).submit))),
          ],
        ));
  }
}
