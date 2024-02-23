import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'main.dart';
import 'home.dart';
import 'add_details.dart';
class MyRoutes extends StatelessWidget {
  final String  userId;
 
  const MyRoutes({Key? key, required this.userId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => MyHomePage(),
        '/auth': (context) =>  AuthGate(),
       
      },
    );
  }
}