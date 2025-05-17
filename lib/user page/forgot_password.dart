import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  TextEditingController emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();

  bool emailError = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    emailFocus.addListener(() => setState(() {}));
  }

  Future<void> _validateFields() async {
    setState(() {
      emailError = emailController.text.isEmpty;
    });

    if (!emailError) {
      _checkEmailExists();
    }
  }

  Future<void> _checkEmailExists() async {
    String email = emailController.text.trim();

    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) {
      _showAlert("User Not Found", "This email is not registered. Please check again.");
    } else {
      // Send a password reset email
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showAlert("Email Sent", "A password reset link has been sent to your email.");
      } catch (e) {
        _showAlert("Error", "Failed to send password reset email. Try again later.");
      }
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Forgot Password"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade400, offset: Offset(5, 5), blurRadius: 10),
              BoxShadow(color: Colors.grey.shade400, offset: Offset(-5, -5), blurRadius: 10),
            ],
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLockIcon(),
                SizedBox(height: 10),
                _build3DTextField("Enter Email", emailController, emailFocus, emailError),
                SizedBox(height: 20),
                _buildSendEmailButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/tour/logo1.jpg',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _build3DTextField(String hint, TextEditingController controller, FocusNode focusNode, bool hasError) {
    bool isFocused = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: hasError ? Colors.red : (isFocused ? Colors.blueAccent : Colors.grey.shade600), offset: Offset(3, 3), blurRadius: 6),
              BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.email, color: isFocused ? Colors.blueAccent : Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendEmailButton() {
    return GestureDetector(
      onTap: _validateFields,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 15),
        width: 300,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "Change Password",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
