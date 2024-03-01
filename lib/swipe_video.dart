import 'package:bytelearn/my_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:video_player/video_player.dart';

class SwipeView extends StatefulWidget {
  final String? topic;
  const SwipeView({Key? key, this.topic}) : super(key: key);

  @override
  State<SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<SwipeView> {
  late VideoPlayerController _controller;
  late List videoUrls;
  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  @override
   void initState () {
    super.initState();

     fetchUrls();

   }
   Future<void> fetchUrls() async{
   // get firebase collection reference
   CollectionReference collectionReference = FirebaseFirestore.instance.collection('posts');
   // make  query to get posts with the topic
   QuerySnapshot querySnapshot = await collectionReference.where('topic', isEqualTo: widget.topic).where('type',isEqualTo: 'video').get();
    // get the documents from the query
    List<QueryDocumentSnapshot> docs = querySnapshot.docs;
    // get the all post details from the documents


    videoUrls = docs.map((e) => e).toList();
    
  // ListResult result = await FirebaseStorage.instance.ref().listAll();

    for (int i = 0; i < videoUrls!.length; i++) {
      _swipeItems.add(SwipeItem(content: videoUrls![i]));
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(_swipeItems[0].content['fileUrl']),
    )..initialize().then((_) {
        setState(() {});
      });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Swipe to view videos'),
        //add back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>MyRoutes()));
          },
        ),
        
      ),
      body: _swipeItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          :
      SwipeCards(matchEngine: _matchEngine!,
        onStackFinished: () {
          //set index to 0 again
          
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text("Stack Finished"),
            duration: Duration(milliseconds: 500),
         ));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>MyRoutes()));
        },
        itemBuilder: 
         (BuildContext context, int index) {
          return Container(
            //make beautiful card video
            
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black,

            ),
            alignment: Alignment.center,
            //create instagram reel ui
            child: Stack(
            alignment: Alignment.center,
              children: [
                 AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                
                //add padding to the bottom of the video
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),

                      child: Text(
                        _swipeItems[index].content['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                         shadows:[Shadow(color: Colors.black,blurRadius: 7.0 )] ,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      //add text button to show description on alert dialog
                      //show animation pop up
                      
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Description'),
                                content: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Text(_swipeItems[index].content['description']),

                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                    
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child:  Text(
                          'Show Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height:2.0,
                           background: Paint()..color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ),
                  ],
                )
              ,
                
              ],
            ),

            );
        },
        itemChanged: (SwipeItem item, int index) {
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(_swipeItems[index].content['fileUrl']),
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
