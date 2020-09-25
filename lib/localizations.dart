import 'dart:async' show Future;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:psyche_map/constants.dart';

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

  List<dynamic> get metrics {
    return localizedValues[locale.languageCode]['metrics'];
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
