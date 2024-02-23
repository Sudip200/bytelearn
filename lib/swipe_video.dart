import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:video_player/video_player.dart';

class SwipeView extends StatefulWidget {
  const SwipeView({super.key});

  @override
  State<SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<SwipeView> {
  late VideoPlayerController _controller;
  List<String>? videoUrls;
  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  @override
   void initState () {
    super.initState();

     fetchUrls();

    
print(_swipeItems);
   
    
   }
   Future<void> fetchUrls() async{

   ListResult result = await FirebaseStorage.instance.ref().listAll();

    for (int i = 0; i < result.items.length; i++) {
      result.items[i].getDownloadURL().then((value) {
        setState(() {
          _swipeItems.add(SwipeItem(content: value));
        });
      });
    }

    // Ensure that all items are added before initializing _matchEngine and _controller
      // Ensure that all items are added before initializing _matchEngine and _controller
 await Future.delayed(Duration(seconds: 1));

    _matchEngine = MatchEngine(swipeItems: _swipeItems);

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(_swipeItems[0].content!),
    )..initialize().then((_) {
        setState(() {});
      });

    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: _swipeItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          :
      SwipeCards(matchEngine: _matchEngine!,
        onStackFinished: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Stack Finished"),
            duration: Duration(milliseconds: 500),
          ));
        },
        itemBuilder: 
         (BuildContext context, int index) {
          return Container(
            alignment: Alignment.center,
           
            child: AspectRatio(aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller))
            
          );
        },
        itemChanged: (SwipeItem item, int index) {
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(_swipeItems[index].content!),
          )..initialize().then((_) {
            // Ensure the first frame is shown after initialization
            setState(() {});
          });
          _controller.play();
        },
        leftSwipeAllowed: true,
        rightSwipeAllowed: true,
        upSwipeAllowed: false,
        fillSpace: true,

      )
    );
  }
}
