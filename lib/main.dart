import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_fit/firebase_options.dart';
import 'package:get_fit/providers/set_provider.dart';
import 'package:get_fit/providers/user_workout_provider.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/providers/workout_provider.dart';
import 'package:get_fit/screens/build_workout.dart';
import 'package:get_fit/screens/home_screen.dart';
import 'package:get_fit/screens/logins/login.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProviderClass(),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkoutProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserWorkoutProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SetProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Get Fit',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/homescreen': (context) => const HomeScreen(),
        '/buildworkout': (context) => const BuildWorkout(),
      },
    );
  }
}
