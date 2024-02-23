import 'package:bytelearn/swipe_video.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:swipe_cards/swipe_cards.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  AuthGate(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String userId;
  MyHomePage({Key? key, required this.userId}) : super(key: key);
  final storageRef = FirebaseStorage.instance.ref();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<DocumentSnapshot>(future: users.doc(userId).get(),
     builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
       if (snapshot.connectionState == ConnectionState.done) {
         if (snapshot.hasData) {
           return Scaffold(appBar: AppBar(),
             body: SwipeView(),
             bottomNavigationBar: BottomNavigationBar(
               items: const <BottomNavigationBarItem>[
                 BottomNavigationBarItem(
                   icon: Icon(Icons.home),
                   label: 'Home',
                 ),
                 BottomNavigationBarItem(
                   icon: Icon(Icons.business),
                   label: 'Business',
                 ),
                 BottomNavigationBarItem(
                   icon: Icon(Icons.person),
                   label: 'School',

                 ),
               ],
             )
            );
         } else if (snapshot.hasError) {
           return Text('Error: ${snapshot.error}');
         }
       }
       return Center(child: CircularProgressIndicator());
     }
    );

  }
}
