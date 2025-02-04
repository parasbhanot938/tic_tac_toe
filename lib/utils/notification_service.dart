import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_mario');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) => null,
    );
  }

  static showPeriodicNotification() async {
    final cron = Cron();

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel 2', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     2,
    //     'scheduled title',
    //     'scheduled body',
    //     currentTimeInIndia.add(Duration(seconds: 5)),
    //     const NotificationDetails(
    //         android: AndroidNotificationDetails(
    //             'your channel id', 'your channel name',
    //             channelDescription: 'your channel description')),
    //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //     uiLocalNotificationDateInterpretation:
    //     UILocalNotificationDateInterpretation.absoluteTime);
    //  // await flutterLocalNotificationsPlugin.periodicallyShow(2, 'repeating title',
    //  //    'repeating body', RepeatInterval.everyMinute, notificationDetails,payload: "Item y"
    //  //   );

    cron.schedule(Schedule.parse('00 08 * * *'), () async {
      await flutterLocalNotificationsPlugin.show(
          0, 'Getting bored?', 'Lets have zero kanti game', notificationDetails,
          payload: 'item x');
      print('every three minutes');
    });
  }
}
