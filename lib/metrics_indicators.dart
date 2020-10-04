import 'db.dart';

class MetricIndicatorsCompute {
  Future<List<MetricInidicatorValue>> computeIndicatorValues() async {
    List<Metric> enabledMetrics = await DbProvider.db.getEnabledMetrics();
    DateTime now = DateTime.now();
    List<MetricInidicatorValue> metricIndicatorValues = [];
    for (Metric metric in enabledMetrics) {
      List<MetricValue> metricValues = await DbProvider.db
          .getMetricValuesBetween(
              metric, now.subtract(Duration(days: 14)), now);
      if (metricValues.isNotEmpty) {
        int valuesSum =
            metricValues.map((v) => v.value).reduce((a, b) => a + b);
        List<int> maxValues = metric.isRangeOneToFive
            ? List.filled(metricValues.length, 5)
            : List.filled(metricValues.length, 1);
        int maxValuesSum = maxValues.reduce((a, b) => a + b);

        if (!metric.isIncreasesDanger) {
          metricIndicatorValues.add(MetricInidicatorValue(
              metric, (valuesSum / maxValuesSum * 10.0).round()));
        } else {
          metricIndicatorValues.add(MetricInidicatorValue(
              metric, ((1.0 - valuesSum / maxValuesSum) * 10.0).round()));
        }
      } else {
        metricIndicatorValues.add(MetricInidicatorValue(metric, 20));
      }
    }
    return Future.value(metricIndicatorValues);
  }
}
