import 'package:flutter/material.dart';

class Db {
  static Db of(BuildContext context) {
    return new Db();
  }

  List<DrugPortion> getCurrentDrugs() {
    return [
      DrugPortion('Abilify', '50mg', 2),
      DrugPortion('Zolafren', '20mg', 1),
      DrugPortion('Absenor', '20mg', 1),
      DrugPortion('Acatar', '20mg', 1),
      DrugPortion('Acespargin', '20mg', 1),
      DrugPortion('Acidolac', '20mg', 1),
      DrugPortion('Acidolit', '20mg', 1),
      DrugPortion('Aflavic', '40mg', 1),
      DrugPortion('Aflegan', '40mg', 1),
      DrugPortion('Afugin', '40mg', 1),
    ];
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

class DrugPortion {
  String drugName;
  String drugDose;
  int count;

  // e.g. Abilify 50mg 2
  DrugPortion(this.drugName, this.drugDose, this.count);
}

class MetricValue {
  final Metric metric;
  final double value;
  final DateTime date;

  MetricValue(this.metric, this.value, this.date);
}

class Metric {
  final int metricId = 0;
  final String metricName;

  Metric(this.metricName);
}
