import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider {
  static final String _dbName = 'psyche_map_db.db';
  static final DbProvider db = DbProvider._();

  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

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
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion == 1 && newVersion == 2) {
          db.execute("DROP TABLE IF EXISTS metrics_values");
          db.execute("CREATE TABLE metrics_values" +
              "(metric_id INTEGER NOT NULL," +
              "value INTEGER NOT NULL," +
              "timestamp TEXT NOT NULL," +
              "PRIMARY KEY (metric_id, timestamp)," +
              "FOREIGN KEY (metric_id) REFERENCES metrics_config(id))");
        }
        if (oldVersion == 2 && newVersion == 3) {
          db.execute("DROP TABLE IF EXISTS config");
          db.execute("CREATE TABLE config" +
              "(send_notifications INTEGER NOT NULL DEFAULT 1)");
        }
        if (oldVersion == 3 && newVersion == 4) {
          db.execute("ALTER TABLE metrics_values ADD COLUMN comment TEXT");
        }
        if (oldVersion == 4 && newVersion == 5) {
          db.execute(
              "ALTER TABLE metrics_config ADD COLUMN increases_danger INTEGER NOT NULL DEFAULT 0");
          Batch batch = db.batch();
          List<Metric> configs = Metric.config;
          configs.forEach((cfg) {
            batch.update(
                'metrics_config',
                {
                  'increases_danger': cfg.isIncreasesDanger ? 1 : 0,
                },
                where: "metric_alias = ?",
                whereArgs: [cfg.metricAlias]);
          });
          batch.commit();
        }
      },
      version: 5,
    );
  }

  Future<List<Metric>> getMetrics() async {
    final Database database = await this.database;

    final List<Map<String, dynamic>> configs =
        await database.query('metrics_config');

    return List.generate(
        configs.length,
        (i) => Metric(
            configs[i]['metric_alias'],
            _toBool(configs[i]['range_one_to_five']),
            _toBool(configs[i]['increases_danger']),
            isEnabled: _toBool(configs[i]['enabled']),
            id: configs[i]['id']));
  }

  Future<List<Metric>> getEnabledMetrics() async {
    final Database database = await this.database;

    final List<Map<String, dynamic>> configs =
        await database.query('metrics_config', where: "enabled = 1");

    return List.generate(
        configs.length,
        (i) => Metric(
            configs[i]['metric_alias'],
            _toBool(configs[i]['range_one_to_five']),
            _toBool(configs[i]['increases_danger']),
            isEnabled: _toBool(configs[i]['enabled']),
            id: configs[i]['id']));
  }

  Future<List<MetricValue>> getEnabledMetricValues(DateTime dateTime) async {
    final Database database = await this.database;

    String formattedDate = _toDateFormatted(dateTime);
    final List<Map<String, dynamic>> values = await database.rawQuery(
        '''SELECT mc.metric_alias, mc.id, mc.range_one_to_five, mc.increases_danger, mv.value, mv.timestamp, mv.comment 
          FROM metrics_config mc LEFT JOIN metrics_values mv ON mv.metric_id = mc.id          
          WHERE mv.timestamp = "$formattedDate" AND mc.enabled = 1''');

    if (values.length == 0) {
      List<Metric> metrics = await getEnabledMetrics();
      return Future<List<MetricValue>>.value(metrics
          .map((metric) =>
              MetricValue(metric, _getDefaultValue(metric), dateTime))
          .toList());
    }

    return List.generate(values.length, (i) {
      Metric metric = Metric(
          values[i]['metric_alias'],
          _toBool(values[i]['range_one_to_five']),
          _toBool(values[i]['increases_danger']),
          isEnabled: _toBool(values[i]['enabled']),
          id: values[i]['id']);
      return MetricValue(
          metric, values[i]['value'] ?? _getDefaultValue(metric), dateTime,
          comment: values[i]['comment']);
    });
  }

  int _getDefaultValue(Metric metric) {
    return metric.isRangeOneToFive ? 3 : 0;
  }

  Future<void> saveOrUpdateMetricValues(
      List<MetricValue> values, DateTime dateTime) async {
    final Database database = await this.database;
    String formattedDate = _toDateFormatted(dateTime);

    for (MetricValue val in values) {
      final int updated = await database.update(
          'metrics_values', {'value': val.value, 'comment': val.comment},
          where: "timestamp = ? AND metric_id = ?",
          whereArgs: [formattedDate, val.metric.id]);
      if (updated == 0) {
        await database.insert(
            'metrics_values',
            {
              'metric_id': val.metric.id,
              'value': val.value,
              'timestamp': formattedDate,
              'comment': val.comment
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  bool _toBool(int sqliteValue) {
    return sqliteValue == 1;
  }

  String _toDateFormatted(DateTime dateTime) {
    return _formatter.format(dateTime);
  }

  DateTime _fromDateFormatted(String dateTimeStr) {
    return _formatter.parse(dateTimeStr);
  }

  Future<void> enableMetric(Metric metric, bool enable) async {
    final Database database = await this.database;

    await database.update('metrics_config', {'enabled': enable ? 1 : 0},
        where: "id = ?", whereArgs: [metric.id]);
  }

  Future<bool> exists() async {
    return databaseExists(join(await getDatabasesPath(), _dbName));
  }

  Future<void> resetDb() async {
    final Database database = await this.database;

    await database.update('metrics_config', {'enabled': 0});
    await database.delete('metrics_values');
    await database.update('config', {'send_notifications': 1});
  }

  Future<bool> areMetricsConfigured() async {
    final Database database = await this.database;

    int enabledMetricsCount = Sqflite.firstIntValue(await database
        .rawQuery("SELECT COUNT(*) FROM metrics_config WHERE enabled = 1"));

    return Future.value(enabledMetricsCount >= 1);
  }

  Future<bool> isQuestionnaireFilledForToday() async {
    final Database database = await this.database;

    String formattedDate = _toDateFormatted(DateTime.now());
    int numMetricsForToday = Sqflite.firstIntValue(await database.rawQuery(
        'SELECT COUNT(*) FROM metrics_values WHERE timestamp ="$formattedDate"'));

    return Future.value(numMetricsForToday >= 1);
  }

  Future<List<MetricValue>> getMetricValuesBetween(
      Metric metric, DateTime fromDate, DateTime toDate) async {
    final Database database = await this.database;

    String fromFormattedDate = _toDateFormatted(fromDate);
    String toFormattedDate = _toDateFormatted(toDate);

    final List<Map<String, dynamic>> values = await database.rawQuery(
        '''SELECT mc.metric_alias, mc.id, mc.range_one_to_five, mc.increases_danger, mv.value, mv.timestamp, mv.comment 
          FROM metrics_values mv INNER JOIN metrics_config mc ON mv.metric_id = mc.id          
          WHERE mv.timestamp >= "$fromFormattedDate" AND mv.timestamp <= "$toFormattedDate" AND mc.id = ${metric.id} AND mc.enabled = 1
          ORDER BY mv.timestamp''');

    return List.generate(
        values.length,
        (i) => MetricValue(
            Metric(
                values[i]['metric_alias'],
                _toBool(values[i]['range_one_to_five']),
                _toBool(values[i]['increases_danger']),
                isEnabled: _toBool(values[i]['enabled']),
                id: values[i]['id']),
            values[i]['value'],
            _fromDateFormatted(values[i]['timestamp']),
            comment: values[i]['comment']));
  }

  List<MetricValue> getMetricValuesForLastWeek(Metric metric) {
    final now = DateTime.now();
    return [
      MetricValue(metric, 1, now.subtract(Duration(days: 6))),
      MetricValue(metric, 1, now.subtract(Duration(days: 5))),
      MetricValue(metric, 3, now.subtract(Duration(days: 3))),
      MetricValue(metric, 3, now.subtract(Duration(days: 1))),
    ];
  }

  List<MetricValue> getMetricValuesForLastMonth(Metric metric) {
    final now = DateTime.now();
    return [
      MetricValue(metric, 1, now.subtract(Duration(days: 20))),
      MetricValue(metric, 1, now.subtract(Duration(days: 15))),
      MetricValue(metric, 1, now.subtract(Duration(days: 10))),
      MetricValue(metric, 3, now.subtract(Duration(days: 5))),
      MetricValue(metric, 5, now.subtract(Duration(days: 1))),
    ];
  }
}

class Metric {
  final int id;
  final String metricAlias;
  final bool isRangeOneToFive;
  final bool isEnabled;
  final bool isIncreasesDanger;

  Metric(this.metricAlias, this.isRangeOneToFive, this.isIncreasesDanger,
      {this.isEnabled = false, this.id});

  static List<Metric> get config {
    return [
      Metric("DREAM", true, false),
      Metric("MOOD", true, false),
      Metric("AGGRESSION_LEVEL", true, true),
      Metric("ACTIVITY", true, false),
      Metric("SOCIALIZATION", true, false),
      Metric("STRESS_LEVEL", true, true),
      Metric("SUICIDE_THOUGHTS", false, true),
      Metric("DELUSIONS", false, true),
      Metric("OTHERS", true, false)
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Metric && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MetricValue {
  final Metric metric;
  final int value;
  final DateTime date;
  final String comment;

  MetricValue(this.metric, this.value, this.date, {this.comment});
}

class MetricInidicatorValue {
  final Metric metric;
  final int value; // 0-10, or 20-undefined

  MetricInidicatorValue(this.metric, this.value);
}
