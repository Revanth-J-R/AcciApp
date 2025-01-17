import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'auth_gate.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_post_screen.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/view_post_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/no_internet_screen.dart';
import 'services/connectivity_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Handle background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    

    // _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   _checkInternetConnection(result);
    // });

    // // Check initial connectivity
    // _checkInternetConnection(null);

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (kDebugMode) {
          print('Foreground notification received');
          print('Message Title: ${message.notification!.title}');
          print('Message Body: ${message.notification!.body}');
        }
      }
    });

    // Handle when notification is pressed
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification pressed");
      print('Message Data: ${message.data}');
      _handleNotification(message);
    });

    // Check if the app was opened from a notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("App launched from notification");
        print('Initial Message Data: ${message.data}');
        _handleNotification(message);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();  // Don't forget to cancel the subscription
    super.dispose();
  }


  void _checkInternetConnection(ConnectivityResult? result) {
    setState(() {
      _hasInternet = result != ConnectivityResult.none;
    });

    if (!_hasInternet) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const NoInternetScreen()),
      );
    } else {
      // If already on NoInternetScreen, pop back to the previous screen
      if (navigatorKey.currentState?.canPop() == true) {
        navigatorKey.currentState?.pop();
      }
    }
  }



  // Handle notification navigation
  void _handleNotification(RemoteMessage message) {
    final notificationDataData = message.data['body'] ?? 'No notification data';
    navigatorKey.currentState?.pushNamed('/viewPost', arguments: notificationDataData);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Accident & Emergency App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorKey: navigatorKey,
        home: _hasInternet ? const AuthGate() : NoInternetScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/create_post': (context) => const CreatePostScreen(),
          '/viewPost': (context) {
            final notificationDataData = ModalRoute.of(context)!.settings.arguments as String?;
            return ViewPostScreen(notificationBody: notificationDataData);
          },
          '/profile': (context) => const ProfileScreen(), 
          '/settings': (context) => const SettingsScreen(), 
        },
      ),
    );
  }
}
