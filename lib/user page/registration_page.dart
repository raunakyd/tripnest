import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripnest/home%20page/homepage.dart';
import 'package:tripnest/user%20page/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Uint8List? _image;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  Color _buttonColor = Colors.blueAccent;
  bool _passwordsMatch = false;
  bool _showValidationErrors = false;
  bool _showPasswordError = false; // Flag to indicate password mismatch

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  void _validateFields() {
    setState(() {
      bool allFieldsFilled = _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;

      _passwordsMatch = _passwordController.text == _confirmPasswordController.text;
      _showPasswordError = !_passwordsMatch; // Show error only when clicking Register
      _buttonColor = (allFieldsFilled && _passwordsMatch) ? Colors.green : Colors.blueAccent;
    });
  }


  Future<void> selectimage() async {
    Uint8List img = await pickImage(ImageSource.gallery); // Pick image

    setState(() {
      _image = img;  // Save the image directly
    });

    _saveImageToPrefs(img); // Store image in SharedPreferences
  }

  Future<void> _saveImageToPrefs(Uint8List image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String base64Image = base64Encode(image); // Convert image to Base64 string
    await prefs.setString('userImage', base64Image);
    print("✅ Profile Image Saved to SharedPreferences!");
  }



  void _register() async {
    setState(() {
      _isLoading = true; // Show loader
      _showValidationErrors = true;
      _showPasswordError = !_passwordsMatch;
    });

    print("🟢 Registration started...");

    bool allFieldsFilled = _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordsMatch &&
        _image != null; // Ensure image is selected

    if (!allFieldsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Validation Failed: Some fields are empty or passwords don't match."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      print("✅ Fetching last user ID from Firestore...");

      // Get the last used user ID from Firestore
      DocumentReference counterRef = FirebaseFirestore.instance.collection('metadata').doc('userCounter');
      DocumentSnapshot counterSnapshot = await counterRef.get();

      int lastUserId = counterSnapshot.exists
          ? (counterSnapshot['lastUserId'] as int)
          : 1000; // Default start ID

      int newUserId = lastUserId + 1; // Increment user ID

      print("🆕 New User ID Assigned: $newUserId");

      print("✅ Creating user in Firebase Authentication...");
      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String firebaseUid = userCredential.user!.uid;

      // Store user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(firebaseUid).set({
        'userId': newUserId,  // Store as number
        'firebaseUid': firebaseUid,
        'name': _nameController.text,
        'email': _emailController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update the counter in Firestore
      await counterRef.set({'lastUserId': newUserId});

      print("✅ Firestore updated with new user ID: $newUserId");

      // Save user details locally
      await prefs.setInt('userId', newUserId);
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userEmail', _emailController.text);

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Registration Successful"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text("OK"),
            ),
          ],
        ),
      );

    } catch (e) {
      print("❌ Registration Error: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }

    setState(() => _isLoading = false);
  }


  @override
  void dispose() {
    _controller.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text("Register"), backgroundColor: Colors.blueAccent),
      body: Stack(
        children:[ Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 300,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade400, offset: Offset(5, 5), blurRadius: 10),
                          BoxShadow(color: Colors.grey.shade400, offset: Offset(-5, -5), blurRadius: 10),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
        
                              ),
                              padding: EdgeInsets.all(15), // Adjust padding to match the look
                              child:Stack(
                                children: [
                                  _image !=null?
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: MemoryImage(_image!),
                                      ):
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: AssetImage('assets/images/user.jpg'),
                                  ),
                                  Positioned(child:IconButton(
                                    onPressed: selectimage,
                                    icon:const Icon(Icons.add_a_photo),) ,
                                    bottom: -11,
                                    left: 47,
                                  ),
        
                                ],
                              )
                            ),
                            SizedBox(height: 10),
                            _buildTextField("Full Name", _nameController, Icons.person, false, _nameFocus),
                            SizedBox(height: 20),
                            _buildTextField("Email", _emailController, Icons.email, false, _emailFocus),
                            SizedBox(height: 20),
                            _buildTextField("Password", _passwordController, Icons.lock, true, _passwordFocus),
                            SizedBox(height: 20),
                            _buildTextField("Confirm Password", _confirmPasswordController, Icons.lock, true, _confirmPasswordFocus),
                            SizedBox(height: 20),
                            _buildRegisterButton(),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an account? "),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text("Login", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          // Show Loader in the Middle of the Screen
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
    ]
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon, bool isPassword, FocusNode focusNode) {
    bool isPasswordMismatchField = (controller == _confirmPasswordController) && _showPasswordError;

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (_showValidationErrors && controller.text.isEmpty)
              BoxShadow(
                color: Colors.red.withOpacity(0.7), // Red glow if empty
                blurRadius: 6,
                //spreadRadius: 5,
                offset: Offset(3, 3),
              )
            else if (isPasswordMismatchField)
              BoxShadow(
                color: Colors.red.withOpacity(0.7), // Red shadow for password mismatch
                blurRadius: 6,
               // spreadRadius: 5,
                offset: Offset(3, 3),
              )
            else if (focusNode.hasFocus)
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.7), // Blue glow when focused
                  blurRadius: 6,
                 // spreadRadius: 5,
                  offset: Offset(3, 3),
                )
              else
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7), // Normal shadow otherwise
                  blurRadius: 6,
                 // spreadRadius: 2,
                  offset: Offset(3,3),
                ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: focusNode.hasFocus ? Colors.blueAccent : Colors.grey),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          onTap: () {
            focusNode.requestFocus();
          },
          onChanged: (value) {
            _validateFields();
          },
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap:  _register, // Disable button while loading
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: _buttonColor, offset: Offset(2, 2), blurRadius: 5),
          ],
        ),
        child: Center(
          child: Text(
            "Register",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

}
