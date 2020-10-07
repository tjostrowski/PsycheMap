import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

BoxDecoration boxDecoration() {
  return BoxDecoration(
      color: Colors.blueGrey[100],
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [BoxShadow(blurRadius: 2.0, color: Colors.grey)]);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
