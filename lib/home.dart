import 'package:flutter/material.dart';
import 'post_data.dart';
import 'grid_home.dart';
import 'profile.dart';
import 'search.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   int _selectedIndex = 0;  
  
  static  List<Widget> _widgetOptions = <Widget>[  
     TopicGridView(),  
    SearchUser(),  
    Profile(), 
    PostDataWidget()
  ];  
  
  void _onItemTapped(int index) {  
    setState(() {  
      _selectedIndex = index;  
    });  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
       
      body: Center(  
        child: _widgetOptions.elementAt(_selectedIndex),  
      ),  
      bottomNavigationBar: BottomNavigationBar(
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,  
        items: const <BottomNavigationBarItem>[  
          BottomNavigationBarItem(  
            icon: Icon(Icons.home,
            color: Color.fromARGB(255, 68, 22, 149),),  
             label: 'Home',
            backgroundColor: Color.fromARGB(255, 244, 242, 242) ,
             
          ),  
          BottomNavigationBarItem(  
            icon: Icon(Icons.search,
            color: Color.fromARGB(255, 68, 22, 149)),  
              label: 'Search',
            backgroundColor: Color.fromARGB(255, 244, 242, 242) 
          ),  
          BottomNavigationBarItem(  
            icon: Icon(Icons.person,
            color: Color.fromARGB(255, 68, 22, 149)),  
             label: 'Profile',
            backgroundColor: Color.fromARGB(255, 244, 242, 242) ,  
          ),  
          BottomNavigationBarItem(  
            icon: Icon(Icons.upload_file,
            color: Color.fromARGB(255, 68, 22, 149)),  
             label: 'Post',
            backgroundColor: Color.fromARGB(255, 244, 242, 242) ,  
          ), 
        ],  
        type: BottomNavigationBarType.fixed,  
        currentIndex: _selectedIndex,  
        selectedItemColor: Colors.black,  
        iconSize: 40,  
        onTap: _onItemTapped,  
        elevation: 10,
        
      ),  
    );  
  }  
}