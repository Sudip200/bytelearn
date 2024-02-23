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
       
        User user = snapshot.data!;
        String userId = user.uid;
        String email = user.email!;
        CollectionReference users = FirebaseFirestore.instance.collection('users');

        users.doc(userId).get().then((DocumentSnapshot documentSnapshot) {
          storage.write(key: 'userId', value: userId).then((value) => print('userId saved'));
          if (documentSnapshot.exists) {
                  print('here2'); 
                  print(documentSnapshot.get('profileUrl'));
            if(documentSnapshot.get('profileUrl') != null){
              print('profile exists');
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyRoutes()));
            }else{
              print('profile does not exist');
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddDetails()));
            } 
          } else {
            users.doc(userId).set({
            'email': email,
            'profileUrl': null,
            'name': null,
            'bio': null,
          });
          print('here3');
          storage.write(key: 'userId', value: userId).then((value) => print('userId saved'));
          return AddDetails();
          }

        });
        print('here4');
      return Center(child: CircularProgressIndicator());
        
    }
    );
  }
}