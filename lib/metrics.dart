import 'package:flutter/material.dart';
import 'package:psyche_map/localizations.dart';

class MetricsPage extends StatefulWidget {
  MetricsPage({Key key}) : super(key: key);

  State<StatefulWidget> createState() => _MetricsPageState();
}

class _MetricsPageState extends State<MetricsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  static const _kTabPages = [
    Center(),
    Center(),
    Center(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _kTabPages.length,
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
      body: TabBarView(children: _kTabPages, controller: _tabController),
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
