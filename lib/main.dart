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

    _controller = AnimationController(
      duration: const Duration(milliseconds:1500 ),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate after animation
    Timer(const Duration(milliseconds: 1500), () {
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
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: SizedBox.expand(
              child: Image.asset(
                "assets/tour/logo.jpg",
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
