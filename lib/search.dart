//class to get list of all users
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'other_profile.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
List users=[];


 @override
  void initState() {
    super.initState();
    _getUserData();
  }
  //get user data from firestore
  Future<void> _getUserData() async {
    try{
      final user = await FirebaseFirestore.instance.collection('users').get();
      print(user.docs.toString());
      setState(() {
        users = user.docs;
      });

    }
    catch(e){
      print(e.toString());
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),

      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(userId: users[index].id),
                ),
              );
            },
            child:
          ListTile(
            title: Text(users[index]['name']),
            subtitle: Text(users[index]['bio']),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(users[index]['profileUrl']),
            ),
          )
          );
        },
      ),
    );
  }
}