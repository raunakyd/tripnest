import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripnest/user%20page/loginpage.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blueAccent, // Blue color
    statusBarIconBrightness: Brightness.light, // Light icons
  ));
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase successfully initialized!");
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print("⚠️ Firebase app already exists. Skipping initialization.");
    } else {
      print("🔥 Firebase initialization failed: ${e.message}");
    }
  } catch (e) {
    print("🔥 Unexpected error: $e");
  }

  // 🔹 Check Firebase Services


  runApp(MyApp());
}

/// ✅ Function to check Firebase services (Firestore & Auth)
/// ✅ Function to check Firebase services (Firestore & Auth)
Future<void> checkFirebaseServices() async {
  try {
    var firestore = FirebaseFirestore.instance;

    // ✅ Firestore Check: Attempt to read from an existing collection
    var snapshot = await firestore.collection('some_existing_collection').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print("✅ Firestore is working! Data exists.");
    } else {
      print("⚠️ Firestore is connected but the collection is empty.");
    }

    // ✅ Firebase Auth Check: Get Current User
    var auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      print("⚠️ No user is currently logged in.");
    } else {
      print("✅ Firebase Auth is working ");
    }

  } catch (e) {
    print("🔥 Firebase services test failed: $e");
  }
}
/// ✅ Function to store stations in Firestore only if they are not already stored



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    debugPrint("🔥 SplashScreen Initialized");

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceInOut,
    );

    Timer(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🔥 SplashScreen Built");
    return Scaffold(
      appBar: AppBar(
        title: Text("Tripnest"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Image.asset(
                "assets/images/flight.jpg",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Text("🚨 Image Not Found",
                      style: TextStyle(fontSize: 18, color: Colors.red));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
