import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PostDetailsScreen extends StatelessWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  Future<void> _subscribeAndStoreTopic(User user) async {
    // Subscribe to the 'all' topic
    await FirebaseMessaging.instance.subscribeToTopic('all');

    // Store subscription details in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'subscribedToTopic': 'all'});
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user!.uid;
    _subscribeAndStoreTopic(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFF1E1E1E), // Set the background color for the entire screen
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Post not found'));
            }

            final postData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (postData['imageUrl'] != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          postData['imageUrl'],
                          fit: BoxFit.cover,
                          height: 250,
                          width: double.infinity,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Center(
                        child: Text(
                          'No Image Available',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  // Description Section
                  _buildDetailSection(
                    title: 'Description',
                    content: postData['description'] ?? 'No description provided',
                  ),

                  const SizedBox(height: 20),
                  _buildDetailSection(
                    title: 'Location',
                    content: postData['location'] ?? 'No location provided',
                  ),
                  
                  // const SizedBox(height: 20),
                  // _buildDetailSection(
                  //   title: 'Latitude',
                  //   content: postData['latitude'].toString()  ?? 'No latitude provided',
                  // ),
                  
                  // const SizedBox(height: 20),
                  // _buildDetailSection(
                  //   title: 'Longitude',
                  //   content: postData['longitude'].toString()  ?? 'No longitude provided',
                  // ),

                  const SizedBox(height: 20),
                  _buildDetailSection(
                    title: 'Date & Time',
                    content: postData['dateTime'] ?? 'No date/time provided',
                  ),

                  const SizedBox(height: 20),
                  _buildDetailSection(
                    title: 'Number of Injured Persons',
                    content: postData['injuredPersons'] != null
                        ? '${postData['injuredPersons']}'
                        : 'Not specified',
                  ),
                ],
              ),
            );
          },
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

  // Method to build each detail section with better alignment and styling
  Widget _buildDetailSection({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222).withOpacity(0.8), // Semi-transparent dark box
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purpleAccent, // Accent color for titles
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70, // Muted white for content
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
