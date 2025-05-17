import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripnest/home%20page/homepage.dart';
import 'package:tripnest/user%20page/forgot_password.dart';
import 'package:tripnest/user%20page/registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _blinkAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isButtonPressed = false;
  bool _isForgotClicked = false;
  bool _isRegisterHovered = false;
  bool _isEmailEmpty = false;
  bool _isPasswordEmpty = false;

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(_buttonController);

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _emailController.addListener(_stopBlinking);
    _passwordController.addListener(_stopBlinking);

    emailFocus.addListener(() {
      if (emailFocus.hasFocus) setState(() {});
    });

    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) setState(() {});
    });
  }

  void _stopBlinking() {
    if (_emailController.text.isNotEmpty || _passwordController.text.isNotEmpty) {
      _buttonController.stop();
      _buttonController.value = 1.0;
    } else {
      _buttonController.repeat(reverse: true);
    }
  }
  void fetchUserIdAfterLogin(String firebaseUid) async {
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(firebaseUid).get();

      if (userSnapshot.exists) {
        int userId = userSnapshot['userId']; // Get userId from Firestore

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId); // Save in SharedPreferences

        print("✅ Retrieved User ID from Firestore: $userId");
      }
    } catch (e) {
      print("❌ Error fetching userId: $e");
    }
  }




  void _validateAndLogin(BuildContext context) async {
    setState(() {
      _isEmailEmpty = _emailController.text.trim().isEmpty;
      _isPasswordEmpty = _passwordController.text.trim().isEmpty;
    });

    if (_isEmailEmpty || _isPasswordEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Please enter both email and password.")),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        print("✅ User signed in: ${user.uid}");

        // 🔹 Check if the user exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // ✅ Fetch user details from Firestore
          String userName = userDoc['name'] ?? "User";
          String userEmail = userDoc['email'] ?? "user@example.com";

          // ✅ Save details in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', userName);
          await prefs.setString('userEmail', userEmail);

          // ✅ Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Login successful! Welcome, $userName."),
              backgroundColor: Colors.green,
            ),
          );

          // ✅ Navigate to HomePage
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });

        } else {
          print("❌ User found in FirebaseAuth but not in Firestore!");

          // 🔥 Sign out the user
          await FirebaseAuth.instance.signOut();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ User not registered. Please sign up."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "❌ Login failed";

      if (e.code == 'user-not-found') {
        errorMessage = "❌ User not registered. Please sign up.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "❌ Incorrect password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "❌ Invalid email format.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "❌ User account is disabled.";
      } else {
        errorMessage = e.message ?? "❌ Login failed.";
      }

      print("❌ Error during login: ${e.code}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }



  @override
  void dispose() {
    _buttonController.dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Tripnest'),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.grey[200],
          child: Center(
            child: AnimatedContainer(
              height: 430,
              width: 300,
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade400, offset: Offset(5, 5), blurRadius: 10),
                  BoxShadow(color: Colors.grey.shade400, offset: Offset(-5, -5), blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/tour/logo1.jpg', // Replace with your image path
                        width: 100,  // Adjust the size as needed
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  _build3DTextField("Email", _emailController, emailFocus, Icons.email, false, _isEmailEmpty),
                  SizedBox(height: 10),
                  _build3DTextField("Password", _passwordController, passwordFocus, Icons.lock, true, _isPasswordEmpty),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isForgotClicked = !_isForgotClicked;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: _isForgotClicked ? Colors.red : Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isButtonPressed = true),
                    onTapUp: (_) => setState(() => _isButtonPressed = false),
                    onTap: () => _validateAndLogin(context),
                    child: AnimatedBuilder(
                      animation: _blinkAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _blinkAnimation.value,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            decoration: BoxDecoration(
                              color: _isButtonPressed ? Colors.green.shade700 : Colors.blueAccent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.blue, offset: Offset(2, 2), blurRadius: 5),
                                BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
                              ],
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? "),
                      MouseRegion(
                        onEnter: (_) => setState(() => _isRegisterHovered = true),
                        onExit: (_) => setState(() => _isRegisterHovered = false),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: _isRegisterHovered ? Colors.blueAccent : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 3D TEXT FIELD WITH VALIDATION INDICATION
  Widget _build3DTextField(String hint, TextEditingController controller, FocusNode focusNode, IconData icon, bool isPassword, bool isEmpty) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: focusNode.hasFocus
            ? [
          BoxShadow(color: isEmpty ? Colors.red : Colors.blueAccent, offset: Offset(3, 3), blurRadius: 6),
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
        ]
            : [
          BoxShadow(color: isEmpty ? Colors.red : Colors.grey.shade600, offset: Offset(3, 3), blurRadius: 6),
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          hintText: hint,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
