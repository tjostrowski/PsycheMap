import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider {
  static final String _dbName = 'psyche_map_db.db';
  static final DbProvider db = DbProvider._();

  static Database _database;

  DbProvider._();

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDb();
    return _database;
  }

  Future<Database> initDb() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE metrics_config" +
              "(id INTEGER PRIMARY KEY AUTOINCREMENT," +
              "metric_alias TEXT," +
              "range_one_to_five INTEGER DEFAULT 1 NOT NULL,"
                  "enabled INTEGER DEFAULT 0 NOT NULL)",
        );
        Batch batch = db.batch();
        List<Metric> configs = Metric.config;
        configs.forEach((cfg) {
          batch.insert('metrics_config', {
            'metric_alias': cfg.metricAlias,
            'range_one_to_five': cfg.isRangeOneToFive ? 1 : 0,
            'enabled': 0
          });
        });
        batch.commit();
      },
      version: 1,
    );
  }

  Future<List<Metric>> getMetrics() async {
    final Database database = await this.database;

    final List<Map<String, dynamic>> configs =
        await database.query('metrics_config');

    stdout.writeln('Configs size: ' + configs.length.toString());    

    return List.generate(
        configs.length,
        (i) => Metric(
            configs[i]['metric_alias'], _toBool(configs[i]['range_one_to_five']),
            isEnabled: _toBool(configs[i]['enabled']), id: configs[i]['id']));
  }

  Future<List<Metric>> getEnabledMetrics() async {
    final Database database = await this.database;

    final List<Map<String, dynamic>> configs =
        await database.query('metrics_config', where: "enabled = 1");

    return List.generate(
        configs.length,
        (i) => Metric(
            configs[i]['metric_alias'], _toBool(configs[i]['range_one_to_five']),
            isEnabled: _toBool(configs[i]['enabled']), id: configs[i]['id']));
  }

  bool _toBool(int sqliteValue) {
    return sqliteValue == 1; 
  }

  Future<void> enableMetric(Metric config, bool enable) async {
    final Database database = await this.database;

    await database.update('metrics_config', {'enabled': enable ? 1 : 0},
        where: "id = ?", whereArgs: [config.id]);
  }

  List<MetricValue> getMetricValuesForLastWeek(Metric metric) {
    final now = DateTime.now();
    return [
      MetricValue(metric, 1.0, now.subtract(Duration(days: 6))),
      MetricValue(metric, 1.0, now.subtract(Duration(days: 5))),
      MetricValue(metric, 3.0, now.subtract(Duration(days: 3))),
      MetricValue(metric, 3.0, now.subtract(Duration(days: 1))),
    ];
  }

  List<MetricValue> getMetricValuesForLastMonth(Metric metric) {
    final now = DateTime.now();
    return [
      MetricValue(metric, 1.0, now.subtract(Duration(days: 20))),
      MetricValue(metric, 1.0, now.subtract(Duration(days: 15))),
      MetricValue(metric, 1.0, now.subtract(Duration(days: 10))),
      MetricValue(metric, 3.0, now.subtract(Duration(days: 5))),
      MetricValue(metric, 5.0, now.subtract(Duration(days: 1))),
    ];
  }
}

class Metric {
  final int id;
  final String metricAlias;
  final bool isRangeOneToFive;
  final bool isEnabled;

  Metric(this.metricAlias, this.isRangeOneToFive,
      {this.isEnabled = false, this.id});

  static List<Metric> get config {
    return [
      Metric("DREAM", true),
      Metric("MOOD", true),
      Metric("AGGRESSION_LEVEL", true),
      Metric("ACTIVITY", true),
      Metric("SOCIALIZATION", true),
      Metric("STRESS_LEVEL", true),
      Metric("SUICIDE_THOUGHTS", false),
      Metric("DELUSIONS", false),
      Metric("OTHERS", true)
    ];
  }
}

class MetricValue {
  final Metric metric;
  final double value;
  final DateTime date;

  MetricValue(this.metric, this.value, this.date);
}
