import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _residentialAddressController;
  bool _isEditing = false;
  List<Map<String, dynamic>> nominees = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _residentialAddressController = TextEditingController();
    _fetchUserData(); // Fetch user data initially
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _residentialAddressController.dispose();
    super.dispose();
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userData.exists) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _residentialAddressController.text = userData['residentialAddress'] ?? '';

          // Handle the 'nominees' field
          if (userData['nominees'] != null && userData['nominees'] is List) {
            nominees = List<Map<String, dynamic>>.from(userData['nominees']);
          } else {
            nominees = [];
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User data not found!'),
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error fetching user data!'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  // Update user data in Firestore
void _updateUserData() async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'residentialAddress': _residentialAddressController.text,
      'nominees': nominees, // Save updated nominees list
    });
    setState(() {
      _isEditing = false; // Exit editing mode after saving
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Profile updated successfully!'),
      duration: Duration(seconds: 3),
    ));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Error updating profile!'),
      duration: Duration(seconds: 3),
    ));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: _isEditing ? const Icon(Icons.save) : const Icon(Icons.edit),
            color: Colors.white, // Edit button color is white
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _updateUserData(); // Update data in Firebase
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              // User Details Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 6,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileField("Name", _nameController.text, _isEditing, _nameController),
                      _buildProfileField("Email", _emailController.text, _isEditing, _emailController),
                      _buildProfileField("Phone", _phoneController.text, _isEditing, _phoneController),
                      _buildProfileField("Address", _residentialAddressController.text, _isEditing, _residentialAddressController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Nominee Section
              // In ProfileScreen, inside the body or wherever the button for adding nominees exists
              NomineeSection(
                nominees: nominees,
                isEditing: _isEditing,
                onEditNominee: (index, name, number) {
                  setState(() {
                    nominees[index]['name'] = name;
                    nominees[index]['number'] = number;
                  });
                },
                onAddNominee: () {
                  // Add a new nominee with empty name and number fields
                  setState(() {
                    nominees.add({'name': '', 'number': '', 'id':''});
                  });
                },
                onDeleteNominee: (index) {
                  setState(() {
                    nominees.removeAt(index);
                  });
                },
              ),
            ],
          ),
        ),
      ),
            bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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

  Widget _buildProfileField(String title, String value, bool isEditing, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isEditing
          ? TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
                border: const OutlineInputBorder(),
              ),
            )
          : Text(
              "$title: $value",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}

class NomineeSection extends StatelessWidget {
  final List<Map<String, dynamic>> nominees;
  final bool isEditing;
  final Function(int, String, String) onEditNominee;
  final Function() onAddNominee;
  final Function(int) onDeleteNominee;

  const NomineeSection({
    Key? key,
    required this.nominees,
    required this.isEditing,
    required this.onEditNominee,
    required this.onAddNominee,
    required this.onDeleteNominee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nominees",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        if (nominees.isEmpty)
          const Center(
            child: Text(
              "No nominees data available",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        else
          ...nominees.map((nominee) {
            int index = nominees.indexOf(nominee);
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4,
              color: Colors.white.withOpacity(0.9),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: Text(
                  nominee['name'] ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  nominee['number'] ?? "N/A",
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: isEditing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditNomineeDialog(context, index, nominee['name'] ?? '', nominee['number'] ?? '');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              onDeleteNominee(index);
                            },
                          ),
                        ],
                      )
                    : null,
              ),
            );
          }).toList(),
        if (isEditing)
          TextButton(
            onPressed: onAddNominee,
            child: const Text(
              "Add Nominee",
              style: TextStyle(color: Colors.deepPurple, fontSize: 16),
            ),
          ),
      ],
    );
  }

  // Dialog for editing nominee
  void _showEditNomineeDialog(BuildContext context, int index, String name, String number) {
    TextEditingController nameController = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Nominee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nominee Name'),
              ),
              // Phone number remains view-only
              TextField(
                controller: TextEditingController(text: number), // Display the number, but don't allow editing
                decoration: const InputDecoration(
                  labelText: 'Nominee Phone',
                ),
                enabled: false, // Disable editing of the phone number
                style: const TextStyle(color: Colors.grey), // Make it look disabled
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                onEditNominee(index, nameController.text, number); // Only update the name
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

