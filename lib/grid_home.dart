import 'package:flutter/material.dart';

class TopicGridView extends StatelessWidget {
  final List<String> topics = ['astronomy', 'physics', 'chemistry', 'biology', 'math'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What do you want to learn?'),
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child:
       GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 8.0, // Spacing between columns
          mainAxisSpacing: 8.0, // Spacing between rows
        ),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Handle topic selection here
              print('Selected topic: ${topics[index]}');
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // You can use different icons for each topic
                  Icon(
                    _getIconForTopic(topics[index]),
                    size: 48.0,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    topics[index],
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    )
    );
  }

  IconData _getIconForTopic(String topic) {
    switch (topic) {
      case 'astronomy':
        return Icons.nights_stay;
      case 'physics':
        return Icons.lightbulb;
      case 'chemistry':
        return Icons.science;
      case 'biology':
        return Icons.eco;
      default:
        return Icons.category;
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: TopicGridView(),
  ));
}
