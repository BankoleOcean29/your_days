import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:your_days/app.dart';
import 'package:your_days/firebase_options.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/services/weekly_word_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PreferencesService.init();
  await WeeklyWordService.instance.init();

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}
