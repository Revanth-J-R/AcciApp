import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'post_details_screen.dart';
import 'rescue_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage

class PostsListScreen extends StatelessWidget {

  final String condition;
  const PostsListScreen({Key? key, required this.condition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid; // Get the current user's UID

    return Scaffold(
      appBar: AppBar(title: Text(condition == 'rescue' ? 'Rescues' : 'Posts')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          // Get the user's name
          final String userName = snapshot.data!['name'] as String;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('createdBy',     
                  isEqualTo: condition == 'posts' ? userName : null,
                  isNotEqualTo: condition == 'rescue' ? userName : null,
)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No posts available.'));
              }

              final posts = snapshot.data!.docs;

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final description = post['description'] as String;
                  final injuredPersons = post['injuredPersons'] as int? ?? 0; // Handle potential null
                  final location = post['location'] as String;
                  final imageUrl = post['imageUrl'] as String;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to PostDetailsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => condition=="posts" ? PostDetailsScreen(postId: post.id) : RescueDetailsScreen(postId: post.id), // Pass postId
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Injured Persons: $injuredPersons'),
                            Text('Location: $location'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePost(context, post.id),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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

  void _deletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Fetch the post details
              final postSnapshot = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
              if (postSnapshot.exists) {
                final postData = postSnapshot.data();
                final imageUrl = postData?['imageUrl'];

                // Delete the image from Firebase Storage
                if (imageUrl != null) {
                  final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
                  await storageRef.delete();
                }
              // Perform the deletion
              await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
              Navigator.of(context).pop(); // Close the dialog
              // Optionally show a snackbar or alert to confirm deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post deleted successfully!')),
              );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
