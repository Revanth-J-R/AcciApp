import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'Nominee_screen.dart';
import 'create_post_screen.dart';
import 'posts/posts_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

    _subscribeAndStoreTopic(user); // Subscribe and store in Firestore

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              print("Logging out");
              Provider.of<AuthService>(context, listen: false).logout();
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent, // Make Scaffold background transparent
      body: Container(
        width: double.infinity, // Ensures the gradient covers the full width
        height: double.infinity, // Ensures the gradient covers the full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Something went wrong",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (!snapshot.data!.exists) {
              return const Center(
                child: Text(
                  "User data not found",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 18),
                  Text(
                    "Hi ${data['name']} ✨",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // Row with two square buttons from TestScreen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to AI Sense screen
                          },
                          child: Text('AI Sense'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Traffic Alert screen
                          },
                          child: Text('Traffic Alert'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Single large button for Track Your Nominees
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Track Your Nominees screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NomineeScreen(),
                              ),
                            );
                    },
                    child: Text('Track Your Nominees'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Row with two square buttons for Rescue and Posts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Rescue screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostsListScreen(condition: "rescue"),
                              ),
                            );
                          },
                          child: Text('Rescue'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Posts screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostsListScreen(condition: "posts"),
                              ),
                            );
                          },
                          child: Text('Posts'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  // Create Post Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePostScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.create, color: Colors.black),
                    label: const Text(
                      'Create a Post',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  

                ],

              ),

            );

          },
        ),

      ),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
        }
      ),

    );
  }
}
