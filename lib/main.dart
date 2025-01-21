import 'package:brt_mobile/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/views/auth/login_screen.dart';
import 'package:brt_mobile/views/auth/startup_screen.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/utils/app_colors.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(const MyApp());
  Jiffy.locale('fr');
  configLoading();
}


void configLoading(){
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 3000)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = AppColors.appColor
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'), // Français
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: EasyLoading.init(),
      home: const HomeScreen(),
    );
  }
}
