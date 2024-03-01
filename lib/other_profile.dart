import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import  'package:video_player/video_player.dart';
import 'profile.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
class Profile extends StatefulWidget {
  final String? userId;
  const Profile({Key? key, this.userId}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _secureStorage = FlutterSecureStorage();
  String _profilePic = '';
  String _username = '';
  String _email = '';
  String _bio = '';
  int _followers = 0;
  List<String> _posts = [];
  bool isFollowing = false;
  List<Uint8List> _thumbnail = [];
  VideoPlayerController? _controller;
  

  @override
  void initState() {
    super.initState();
    //CHECK IF IT IS THE USER'S PROFILE
    _getUserData();
 
  }
  Future<void> _ifItsme() async{
    String? myuserId = await _secureStorage.read(key: 'userId');
    if(myuserId == widget.userId){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Profile()));
    }
  }
  //get user data from firestore
  Future<void> _getUserData() async {
    try{
  //String? userId = await _secureStorage.read(key: 'userId');
    //print(userId);
   String? myuserId = await _secureStorage.read(key: 'userId');

    final user = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final posts = await FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: widget.userId).get();
    final follwerdb = await FirebaseFirestore.instance.collection('follower').where('follweeId', isEqualTo: widget.userId).get();
    final follodata = await FirebaseFirestore.instance.collection('follower').where('follweeId', isEqualTo: widget.userId).where('follwerId', isEqualTo:myuserId ).get();

    
    
  if(follodata.docs.isNotEmpty){
    setState(() {
      isFollowing = true;
    });
  }
    setState(() {
      _profilePic = user['profileUrl'];
      _username = user['name'];
      _bio = user['bio'];
      _posts = posts.docs.map((doc) => doc['fileUrl']).toList().cast<String>();
      _followers = follwerdb.docs.length;
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
  //function for following user
  void followUser() async{
   String? myuserId = await _secureStorage.read(key: 'userId');
    final user = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final follwerdb = await FirebaseFirestore.instance.collection('follower');
    follwerdb.add({
      'follwerId': myuserId,
      'follweeId': widget.userId,
    });
  }
  void getThumbnail() async {
    for(int i=0;i<_posts.length;i++){
   final uint8list = await VideoThumbnail.thumbnailData(video: _posts[i], imageFormat: ImageFormat.JPEG, maxWidth: 128, quality: 75);
   setState(() {
      _thumbnail.add(uint8list!);
   });

    }
   
  }
  @override
  Widget build(BuildContext context) {
    //Instagram like profile page
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),

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
                    Text('$_followers followers', style: TextStyle(fontSize: 16.0)),
                    Text(
                      _username,
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _bio,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 8.0),
                    //check if user is following
                    isFollowing ? ElevatedButton(onPressed: (){}, child: Text('Following')) :
                    ElevatedButton(onPressed: (){
                      followUser();
                      //refresh the page
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Profile(userId: widget.userId)));
                    }, child: Text('Follow')),
                    SizedBox(height: 8.0),
                    
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
              return VideoPlayer(VideoPlayerController.networkUrl(Uri.parse(_posts[index]))..initialize().then((_) {

                setState(() {});
              }
              ));
            },
          ),
        ],
      ),
    );
   
}
}