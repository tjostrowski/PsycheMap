import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:psyche_map/constants.dart' show languages;

Future<String> loadJsonFromAsset(String language) async {
  return await rootBundle.loadString('assets/i18n/' + language + '.json');
}

Map<String, dynamic> convertValue(Map obj) {
  Map<String, dynamic> result = {};
  obj.forEach((key, value) {
    result[key] = value;
  });
  return result;
}

Future<Map<String, Map<String, dynamic>>> initializeI18n() async {
  Map<String, Map<String, dynamic>> values = {};
  for (String language in languages) {
    Map<String, dynamic> translation =
        json.decode(await loadJsonFromAsset(language));
    values[language] = convertValue(translation);
  }
  return values;
}
