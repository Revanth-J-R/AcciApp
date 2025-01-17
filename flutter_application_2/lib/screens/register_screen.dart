import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _phone = '';
  String _residentialAddress = '';
  String _nomineeNumber = '';
  List<Map<String, String>> _nominees = [];
  String _password = '';
  bool _isLoading = false;
  String? _error;

  // Fetch the device token for FCM notifications
  Future<String?> _getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  void _register() async {
  final authService = Provider.of<AuthService>(context, listen: false);
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Fetch the device token
    String? deviceToken = await _getDeviceToken();

    // Prepare nominee data (convert to string format for Firestore)
    List<Map<String, String>> nominees = _nominees;


    String? result = await authService.register(
      name: _name,
      email: _email,
      phone: _phone,
      residentialAddress: _residentialAddress,
      nominees: nominees, // Passing nominees list to Firestore
      password: _password,
      deviceToken: deviceToken,
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      setState(() {
        _error = result;
      });
    } else {
      // Navigate to the home page on successful registration
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(    
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_error != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.amberAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.black),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Name Field
                  TextFormField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'RobotoMono',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white24,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _name = val);
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'RobotoMono',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white24,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      setState(() => _email = val);
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter an email' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'RobotoMono',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white24,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (val) {
                      setState(() => _phone = val);
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter your phone number' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'RobotoMono',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Residential Address',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white24,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _residentialAddress = val);
                    },
                    validator: (val) => val!.isEmpty
                        ? 'Please enter your residential address'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildNomineeFields(),
                  const SizedBox(height: 40),
                  // Password Field
                  TextFormField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'RobotoMono',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white24,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    obscureText: true,
                    onChanged: (val) {
                      setState(() => _password = val);
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a password' : null,
                  ),
                  const SizedBox(height: 40),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.deepPurple,
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(vertical: 15),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple,
                              ),
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add Nominee Fields
Widget _buildNomineeFields() {
  return Column(
    children: [
      for (int i = 0; i < _nominees.length; i++)
        Row(
          children: [
            // Name Field
            Expanded(
              child: TextFormField(
                initialValue: _nominees[i]['name'],
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  fillColor: Colors.white24,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _nominees[i]['name'] = val;
                  });
                },
                validator: (val) =>
                    val!.isEmpty ? 'Please enter nominee name' : null,
              ),
            ),
            const SizedBox(width: 10),
            // Number Field with Firestore Check
            Expanded(
              child: TextFormField(
                initialValue: _nominees[i]['number'],
                decoration: InputDecoration(
                  labelText: 'Number',
                  labelStyle: const TextStyle(color: Colors.white),
                  fillColor: Colors.white24,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (val) async {
                  setState(() {
                    _nominees[i]['number'] = val;
                  });

                  // Query Firestore to check if the phone number matches any user's phone field
                  try {
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('phone', isEqualTo: val)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      // If a match is found, update the id field
                      setState(() {
                        _nominees[i]['id'] = querySnapshot.docs.first.id;
                      });
                    } else {
                      // If no match is found, clear the id field
                      setState(() {
                        _nominees[i]['id'] = '';
                      });
                    }
                  } catch (error) {
                    print('Error checking phone number: $error');
                  }
                },
                validator: (val) =>
                    val!.isEmpty ? 'Please enter nominee phone number' : null,
              ),
            ),
            // Remove Nominee Button
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.white),
              onPressed: () {
                setState(() {
                  _nominees.removeAt(i);
                });
              },
            ),
          ],
        ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          setState(() {
            _nominees.add({'name': '', 'number': '', 'id': ''});
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
        ),
        child: const Text('Add Nominee'),
      ),
    ],
  );
}


}
