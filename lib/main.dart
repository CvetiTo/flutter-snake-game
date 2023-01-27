import 'package:flutter/material.dart';
import 'package:snake_game/home_page.dart';

import 'package:firebase_core/firebase_core.dart';

Future  main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCPyijYHkEC_03l656JUUbhEuZDzxINJbc",
      authDomain: "snakegame-3147e.firebaseapp.com",
      projectId: "snakegame-3147e",
      storageBucket: "snakegame-3147e.appspot.com",
      messagingSenderId: "556751008795",
      appId: "1:556751008795:web:f507cae31982dea96074be",
      measurementId: "G-4F06DXQV97"
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ignore: prefer_const_constructors
      home: HomePage(),
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
