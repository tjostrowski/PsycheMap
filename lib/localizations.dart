import 'dart:async' show Future;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:psyche_map/constants.dart';
import 'package:psyche_map/db.dart';

class MyLocalizations {
  final Map<String, Map<String, dynamic>> localizedValues;
  MyLocalizations(this.locale, this.localizedValues);

  final Locale locale;

  static MyLocalizations of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  String get hello {
    return localizedValues[locale.languageCode]['hello'];
  }

  String getMetricName(Metric metric) {
    Map<String, dynamic> metrics = localizedValues[locale.languageCode]['metrics'];
    if (metrics.containsKey(metric.metricAlias)) {
      return metrics[metric.metricAlias];
    }
    return "";
  }

  String get questionnaire {
    return localizedValues[locale.languageCode]['questionnaire'];
  }

  String get stats {
    return localizedValues[locale.languageCode]['stats'];
  }

  String get settings {
    return localizedValues[locale.languageCode]['settings'];
  }

  String get metricsTitle {
    return localizedValues[locale.languageCode]['metricsTitle'];
  }

  String get submit {
    return localizedValues[locale.languageCode]['submit'];
  }

  String get weekly {
    return localizedValues[locale.languageCode]['weekly'];
  }

  String get monthly {
    return localizedValues[locale.languageCode]['monthly'];
  }

  String get searchMetric {
    return localizedValues[locale.languageCode]['searchMetric'];
  }

  String get add {
    return localizedValues[locale.languageCode]['add'];
  }

  String get change {
    return localizedValues[locale.languageCode]['change'];
  }

  String get introText1 {
    return localizedValues[locale.languageCode]['introText1'];
  }

  String get skip {
    return localizedValues[locale.languageCode]['skip'];
  }

  String get done {
    return localizedValues[locale.languageCode]['done'];
  }

  String get reset {
    return localizedValues[locale.languageCode]['reset'];
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  Map<String, Map<String, dynamic>> localizedValues;

  MyLocalizationsDelegate(this.localizedValues);

  @override
  bool isSupported(Locale locale) => languages.contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(
        MyLocalizations(locale, localizedValues));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
