import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PostDataWidget extends StatefulWidget {
  @override
  _PostDataWidgetState createState() => _PostDataWidgetState();
}

class _PostDataWidgetState extends State<PostDataWidget> {
   final _secureStorage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  late File _selectedFile;
  String _title = '';
  String _topic = 'astronomy'; // Default topic
  String _description = '';
  String _type = 'image';
  String fileExtension = '';
   // Default type

  Future<void> _uploadFile() async {
    try {
    String? userId = await _secureStorage.read(key: 'userId');
      String fileName = _selectedFile.path.split('/').last;

      // Upload file to Firebase Storage
      Reference storageReference =
      FirebaseStorage.instance.ref().child('posts/$userId/$fileName');
      UploadTask uploadTask = storageReference.putFile(_selectedFile, SettableMetadata(contentType: '$_type/$fileExtension'));
      await uploadTask.whenComplete(() => null);

      // Get the URL of the uploaded file
      String fileUrl = await storageReference.getDownloadURL();

      // Save post details to Firestore
      CollectionReference posts = FirebaseFirestore.instance.collection('posts');
      posts.add({
        'userId': userId,
        'title': _title,
        'topic': _topic,
        'description': _description,
        'type': _type,
        'fileUrl': fileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate to a different screen or perform any other action after successful upload
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => YourNextScreen()));
    } catch (e) {
      // Handle errors
      print(e.toString());
    }
    //Make form empty after submit
    _formKey.currentState!.reset();
    //Show snackbar after submit
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Post uploaded successfully'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text('Create Post'),
  ),
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
            onSaved: (value) {
              _title = value!;
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField(
            value: _topic,
            items: ['astronomy', 'biology', 'chemistry', 'physics','computer','others']
                .map((topic) => DropdownMenuItem(
                      value: topic,
                      child: Text(topic),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _topic = value.toString();
              });
            },
            decoration: InputDecoration(
              labelText: 'Topic',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
            onSaved: (value) {
              _description = value!;
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Type:'),
              SizedBox(width: 16),
              DropdownButton(
                value: _type,
                items: ['image', 'video']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value.toString();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style:  ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 20), // Increase vertical padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    minimumSize: Size(double.infinity, 0), // Set width to full
  ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
                if (result != null) {
                  setState(() {
                    _selectedFile = File(result.files.single.path!);
                    fileExtension = _selectedFile.path.split('.').last;
                  });
                }
              }
            },
            child: Text('Select File'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                _uploadFile();
              }
            },
            style:ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 20), // Increase vertical padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    minimumSize: Size(double.infinity, 0), // Set width to full
  ),
            child: Text('Upload'),
          ),
        ],
      ),
    ),
  ),
);
  }
  
}
