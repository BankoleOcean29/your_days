import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:your_days/app.dart';
import 'package:your_days/firebase_options.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/services/weekly_word_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (kIsWeb) databaseFactory = databaseFactoryFfiWeb;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PreferencesService.init();
  await WeeklyWordService.instance.init();

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}
