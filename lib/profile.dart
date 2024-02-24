
//create profile class take userId from secure store and get user data from firestore
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import  'package:video_player/video_player.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _secureStorage = FlutterSecureStorage();
  String _profilePic = '';
  String _username = '';
  String _email = '';
  String _bio = '';
  List<String> _posts = [];
  VideoPlayerController? _controller;
  

  @override
  void initState() {
    super.initState();
    _getUserData();
  }
  //get user data from firestore
  Future<void> _getUserData() async {
    try{
  String? userId = await _secureStorage.read(key: 'userId');
    print(userId);
    final user = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final posts = await FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: userId).get();
   
    

    setState(() {
      _profilePic = user['profileUrl'];
      _username = user['name'];
      _bio = user['bio'];
      _posts = posts.docs.map((doc) => doc['fileUrl']).toList().cast<String>();
    });
    
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(_posts[0]),
    )..initialize().then((_) {
      setState(() {});
    });
   
    //get posts of user
    }catch(e){
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    //Instagram like profile page
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48.0,
                  backgroundImage: NetworkImage(_profilePic),
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    
                    Text(
                      _bio,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return VideoPlayer(_controller!);
            },
          ),
        ],
      ),
    );
   
}
}