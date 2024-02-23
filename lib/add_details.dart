import 'dart:io';

import 'package:bytelearn/my_app.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddDetails extends StatefulWidget {
  @override
  _AddDetailsState createState() => _AddDetailsState();
}

class _AddDetailsState extends State<AddDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _image;
  String? _downloadUrl;

  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  _getUserId() async {
    // Fetch the user ID from secure storage
    String? userId = await _secureStorage.read(key: 'userId');
    print('User ID: $userId');
  }

  _uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        if(Platform.isAndroid || Platform.isIOS){
_image = File(result.files.single.path!);
        }
        

        
      });

      // Upload image to Firebase Storage
      Reference ref = _storage.ref().child('profile_images/${DateTime.now().toString()}');
      UploadTask uploadTask = ref.putFile(_image!, SettableMetadata(contentType: 'image/jpeg'));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      _downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Show uploaded image on the screen
      setState(() {});

      print('Image uploaded. Download URL: $_downloadUrl');
    }
  }

  _saveDetailsToFirestore() async {
    String? userId = await _secureStorage.read(key: 'userId');
    if (userId != null) {
      // Save details to Firestore
      await _firestore.collection('users').doc(userId).set({
        'name': _nameController.text,
        'bio': _bioController.text,
        'profileUrl': _downloadUrl,
      });

      print('Details saved to Firestore');
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyRoutes(userId: userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(_image!))
                : Icon(Icons.person, size: 100),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Profile Picture'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Bio'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveDetailsToFirestore();
              },
              child: Text('Save Details'),
            ),
          ],
        ),
      ),
    );
  }
}