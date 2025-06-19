import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'utilitarios/tema_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'agua_channel',
        channelName: 'Lembretes de Água',
        channelDescription: 'Notificações para lembrar de beber água',
        defaultColor: Color(0xFF6C63FF),
        importance: NotificationImportance.High,
      )
    ],
    debug: true,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => TemaProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final temaProvider = Provider.of<TemaProvider>(context);

    return MaterialApp(
      title: 'Vita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
      darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
      themeMode: temaProvider.modoEscuro ? ThemeMode.dark : ThemeMode.light,
      home: Home(),
    );
  }
}
