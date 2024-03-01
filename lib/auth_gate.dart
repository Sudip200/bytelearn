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
            oauthButtonVariant: OAuthButtonVariant.icon_and_text,
             headerBuilder: (context, constraints, shrinkOffset) => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.lightbulb,size: 100.0,color: Colors.deepPurple,),),
              subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                
              );
            },
            footerBuilder:  (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            
            
          );
        }
       
        User user = snapshot.data!;
        String userId = user.uid;
        String email = user.email!;
        CollectionReference users = FirebaseFirestore.instance.collection('users');

        users.doc(userId).get().then((DocumentSnapshot documentSnapshot) {
          storage.write(key: 'userId', value: userId).then((value) => print('userId saved'));
          if (documentSnapshot.exists) {
                
            if(documentSnapshot.get('profileUrl') != null){
             
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

          storage.write(key: 'userId', value: userId).then((value) => print('userId saved'));
          return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddDetails()));
          }

        });

      return Center(child: CircularProgressIndicator());
        
    }
    );
  }
}