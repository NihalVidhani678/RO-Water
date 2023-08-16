// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/firebase_options.dart';
import 'package:water_service/screens/admin/admin_navigator.dart';
import 'package:water_service/screens/customer/user_navigator.dart';
import 'package:water_service/screens/onboarding_screen.dart';
import 'package:water_service/screens/customer/user_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var homeScreen = prefs.getString("email") == null
      ? OnboardingScreen()
      : prefs.getBool("isAdmin") == true
          ? AdminNavigator(
              initialIndex: 0,
            )
          : UserNavigator(
              initialIndex: 0,
            );
  runApp(MyApp(
    homeScreen: homeScreen,
  ));
}

class MyApp extends StatefulWidget {
  Widget homeScreen;

  MyApp({required this.homeScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RO Water Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "DMSans",
      ),
      debugShowCheckedModeBanner: false,
      home: widget.homeScreen,
    );
  }
}
