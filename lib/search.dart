//class to get list of all users
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'other_profile.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {

late List users;
late List finalUser;
 @override
  void initState() {
    super.initState();
    _getUserData();
  }
  //get user data from firestore
  Future<void> _getUserData() async {
       try {
        //dont show own profile
      final user = await FirebaseFirestore.instance.collection('users').where('profileUrl',isNotEqualTo: null).get();
      setState(() {
        users = user.docs;
      });
     
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
        //search bar
        

      ),
      body:  users == null
          ? Center(child: CircularProgressIndicator()) // Show a loading indicator
          : users!.isEmpty
              ? Center(child: Text('No users found')) // Show a message when no users are available
              : Container(
                  child: ListView.builder(
                    itemCount: users!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Profile(userId: users![index].id),
                            ),
                          );
                        },
                        //remove the user 
                        child: 
                        ListTile(
                          title: Text(users![index]['name'] ?? 'N/A'),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                users![index]['profileUrl'] ?? ''),
                          ),
                        )
                        
                      
                      );
                    },
                  ),
                ),
    );
  }
}