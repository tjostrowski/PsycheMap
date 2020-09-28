import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';

import 'db.dart';

Widget weeklyChart(BuildContext context, String metricName) {
  final toDate = DateTime.now();
  final fromDate = toDate.subtract(Duration(days: 7));
  final List<MetricValue> metricValues = DbProvider.db.getMetricValuesForLastWeek(null);

  return _plotDailyChart(metricValues, fromDate, toDate, context, metricName);
}

Widget monthlyChart(BuildContext context, String metricName) {
  final toDate = DateTime.now();
  final fromDate = toDate.subtract(Duration(days: 30));
  final List<MetricValue> metricValues = DbProvider.db.getMetricValuesForLastMonth(null);
  
  return _plotDailyChart(metricValues, fromDate, toDate, context, metricName);
}

Widget _plotDailyChart(List<MetricValue> metricValues, DateTime fromDate, DateTime toDate, BuildContext context, String metricName) {
  final List<DataPoint<DateTime>> dataPoints = metricValues.map((mv) => DataPoint<DateTime>(value: mv.value, xAxis: mv.date)).toList();
  return Center(
    child: Container(
      color: Colors.green[50],
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      child: BezierChart(
        fromDate: fromDate,
        bezierChartScale: BezierChartScale.WEEKLY,
        toDate: toDate,
        selectedDate: toDate,
        series: [
          BezierLine(
            label: metricName,            
            data: dataPoints,
            onMissingValue: (dateTime) {
              int i;
              for (i = 0; i < metricValues.length; ++i) {
                if (metricValues[i].date.isAfter(dateTime)) {
                  break;
                }              
              }
              if (i == 0) {
                return metricValues[0].value;
              } else if (i < metricValues.length) {
                double val1 = metricValues[i - 1].value;
                double val2 = metricValues[i].value;

                int deltaAll = metricValues[i].date.difference(metricValues[i - 1].date).inDays;
                int delta1 = dateTime.difference(metricValues[i - 1].date).inDays;

                return val1 + (val2-val1)*delta1/deltaAll;                  
              } else {
                return metricValues.last.value;
              }
            },
          ),          
        ],        
        config: BezierChartConfig(
          displayDataPointWhenNoValue: false,
          verticalIndicatorStrokeWidth: 3.0,
          verticalIndicatorColor: Colors.black26,
          showVerticalIndicator: true,
          verticalIndicatorFixedPosition: false,
          backgroundColor: Colors.red,
          footerHeight: 30.0,          
        ),
      ),
    ),
  );
}