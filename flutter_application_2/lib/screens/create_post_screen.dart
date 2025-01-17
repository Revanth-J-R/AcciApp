import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../services/location_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'posts/post_details_screen.dart';
import 'creating_post_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _descriptionController = TextEditingController();
  final _injuredPersonsController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _dateTime;
  String? _currentAddress;
  LocationHandler _locationHandler = LocationHandler();
  
  // Speech to Text variables
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _setDateTime();
    _getLocation();
  }

  Future<void> _getLocation() async {
    await _locationHandler.getLocation();
    setState(() {
      _currentAddress = _locationHandler.currentAddress;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _setDateTime() async {
    final now = DateTime.now();
    setState(() {
      _dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    });
  }

  Future<void> _uploadPost() async {
    if (_image == null ||
        _descriptionController.text.isEmpty ||
        _injuredPersonsController.text.isEmpty ||
        _currentAddress == null) return;

        // Show loading screen while the background tasks happen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CreatingPostScreen();
      },
    );

    try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user logged in.');
      return;
    }

    final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String createdBy = 'Unknown';
    if (userSnapshot.exists) {
      createdBy = userSnapshot.data()?['name'] ?? 'Unknown';
      await _unsubscribeFromTopic(user.uid, 'all');
    }

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = storageRef.putFile(_image!);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final postRef = FirebaseFirestore.instance.collection('posts').doc();
    await postRef.set({
      'imageUrl': downloadUrl,
      'description': _descriptionController.text,
      'createdAt': FieldValue.serverTimestamp(),
      'location': _currentAddress,
      'latitude':_locationHandler.latitude,
      'longitude':_locationHandler.longitude,
      'dateTime': _dateTime,
      'injuredPersons': int.tryParse(_injuredPersonsController.text) ?? 0,
      'createdBy': createdBy,
      'uid': user.uid,
    });

    setState(() {
      _image = null;
      _descriptionController.clear();
      _injuredPersonsController.clear();
    });

    final postSnapshot = await postRef.get();
    if (postSnapshot.exists) {
      final post = postSnapshot.data() as Map<String, dynamic>;
      await _sendNotification(
        post['description'] ?? '',
        post['location'] ?? '',
        post['injuredPersons'] ?? 0,
        post['createdBy'] ?? '',
        post['dateTime'] ?? '',
        post['imageUrl'] ?? '',
      );
    } else {
      print('Post does not exist.');
    }

    Navigator.pop(context); // Remove loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsScreen(postId: postRef.id),
      ),
    );    } catch (e) {
      Navigator.pop(context); // Remove loading screen if there's an error
      print('Error uploading post: $e');
    }
  }

  Future<void> _unsubscribeFromTopic(String userId, String topic) async {
    final messaging = FirebaseMessaging.instance;

    try {
      await messaging.unsubscribeFromTopic(topic);
      print('Successfully unsubscribed from $topic topic');
    } catch (e) {
      print('Failed to unsubscribe from $topic topic: $e');
    }
  }

  Future<void> _sendNotification(String description, String location, int injuredPersons, String createdBy, String dateTime, String imageUrl) async {
    final serviceAccountFile = await _loadServiceAccount();
    final notificationData = {
      'message': {
        'topic': 'all',
        'notification': {
          'title': 'Emergency Alert 🚨',
          'body': 'Description: $description | Injured Persons: $injuredPersons\nCreated By: $createdBy | Location: $location',
        },
        'data': {
          'body': 'Description: $description | Injured Persons: $injuredPersons | Created By: $createdBy | Location: $location | Date and Time: $dateTime | Image Url: $imageUrl',
        },
        "android": {
          "notification": {
            "sound": "notification_sound",
          }
        }
      },
    };

    print('Notification Payload: ${jsonEncode(notificationData)}');

    final client = await clientViaServiceAccount(
      serviceAccountFile,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/acciaid-5925c/messages:send'),
      headers: {
        'Authorization': 'Bearer ${client.credentials.accessToken.data}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }

    client.close();
  }

  Future<ServiceAccountCredentials> _loadServiceAccount() async {
    final serviceAccountJson = await rootBundle.loadString('assets/service-key.json');
    return ServiceAccountCredentials.fromJson(serviceAccountJson);
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(onResult: (result) {
          setState(() {
            _descriptionController.text = result.recognizedWords;
          });
        });
        setState(() {
          _isListening = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post', style: TextStyle(fontFamily: 'Montserrat', fontSize: 24)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color(0xFF1D1E33),
        ),
        child: Column(
          children: <Widget>[
            _image == null
                ? const Text('No image selected', style: TextStyle(color: Color.fromARGB(255, 255, 38, 38), fontFamily: 'Montserrat', fontSize: 18))
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Pick Image', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Colors.white)),
            ),

Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Expanded(
      child: Column(
        children: [
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: const TextStyle(color: Color.fromARGB(255, 150, 150, 255)),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.3),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
    const SizedBox(width: 10), // Add spacing between the TextField and the button
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ElevatedButton(
        onPressed: _toggleListening,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(), // Makes the button round
          padding: const EdgeInsets.all(15),
          backgroundColor: _isListening ? Colors.lightBlue : Colors.blueAccent,
        ),
        child: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    ),
  ],
),


            const SizedBox(height: 10),
            TextField(
              controller: _injuredPersonsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Count of People Injured',
                labelStyle: const TextStyle(color: Color.fromARGB(255, 150, 150, 255)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.3),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 20),
_currentAddress == null
    ? const Text('Fetching location...', style: TextStyle(color: Colors.white))
    : TextField(
        decoration: InputDecoration(
          labelText: 'Location',
          labelStyle: const TextStyle(color: Color.fromARGB(255, 150, 150, 255)),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        readOnly: true,
        controller: TextEditingController(text: _currentAddress),
      ),
const SizedBox(height: 20),
ElevatedButton(
  onPressed: _uploadPost,
  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
  child: const Text('Upload', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Colors.white)),
),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
                selectedItemColor: Colors.grey, // Set selected items to gray
        unselectedItemColor: Colors.grey, // Set unselected items to gray

        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/profile');
              break;
            case 2:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
