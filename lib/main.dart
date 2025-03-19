import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trivia_world/screens/enter_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    home: EnterScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

