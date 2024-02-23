import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' ;
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'add_details.dart';
class AuthGate extends StatelessWidget {
  final storage = new FlutterSecureStorage();
  bool docExists = false;
  bool profileExists = false;
  AuthGate({super.key});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (context,snapshot){
      if (!snapshot.hasData) {
          return SignInScreen(
            providers: [EmailAuthProvider(),GoogleProvider(clientId: '320317641150-65u4mabh86lq6nm08ueu5e2s4n77diej.apps.googleusercontent.com')],
          );
        }
       print(snapshot.data!);
        User user = snapshot.data!;
        String userId = user.uid;
        String email = user.email!;
        CollectionReference users = FirebaseFirestore.instance.collection('users');

        users.doc(userId).get().then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            docExists = true;
          
             documentSnapshot.get('profileUrl').then((value) {
              if (value != null) {
                profileExists = true;
              }
            });
          } else {
            docExists = false;
          }
        });
        if (docExists && profileExists) {
          storage.write(key: 'userId', value: userId).then((value) => print('userId saved'));
          return MyRoutes(userId: userId);
        }else{
          storage.write(key: 'userId', value: userId).then((value) => print('userId saved'));
          return AddDetails();
        }


        // users.doc(userId).set({
        //   'email': email,
        //   'userId': userId,
        // });
        // storage.write(key: 'userId', value: userId).then((value) => print('userId saved'));
        // return MyRoutes(userId: userId, email: email);
    }
    );
  }
}