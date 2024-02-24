import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'main.dart';
import 'home.dart';
import 'add_details.dart';
class MyRoutes extends StatelessWidget {
  
  const MyRoutes({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(useMaterial3: true),
      color: Color.fromARGB(255, 68, 22, 149),
      initialRoute: '/home',
      routes: {
        '/home': (context) => MyHomePage(),
        '/auth': (context) =>  AuthGate(),
      },
    );
  }
}