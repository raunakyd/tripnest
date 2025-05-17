import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripnest/package%20page/tourpage.dart';
import 'package:tripnest/home%20page/mytrip.dart';
import 'package:tripnest/home%20page/hotel.dart';
import 'package:tripnest/user%20page/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int indexs = 0;
  bool isNavVisible = true;
  ScrollController _scrollController = ScrollController();
  double lastOffset = 0;
  Timer? _visibilityTimer;
  late String userName ="";
  late String userEmail="";
  double profileSize = 50;
  bool _showDetails = false; // Animation trigger
  Uint8List? userImage;
  bool _isSubmitting = false;
  String selectedPackageName = "";
  int? numericUserId;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserData(); // ✅ Ensure this is called to load user data after login

// Set status bar color when home page loads
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2196F3), // Blue color (same as login page)
      statusBarIconBrightness: Brightness.light, // Light icons
    ));

    // Fetch numeric user ID from Firestore based on Firebase UID
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      getNumericUserId(user.uid).then((id) {
        setState(() {
          numericUserId = id;
        });
      });
    }
    // Delay animation start
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showDetails = true;
      });
    });
  }



  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('userName') ?? "User";
    String email = prefs.getString('userEmail') ?? "user@example.com";
    String? base64Image = prefs.getString('userImage');
    Uint8List? image = base64Image != null ? base64Decode(base64Image) : null;

    setState(() {
      userName = name;
      userEmail = email;
      userImage = image;
    });
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _visibilityTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    double currentOffset = _scrollController.offset;
    _visibilityTimer?.cancel();

    setState(() {
      isNavVisible = currentOffset <= lastOffset;
    });

    _visibilityTimer = Timer(Duration(milliseconds: 500), () {
      setState(() => isNavVisible = true);
    });

    lastOffset = currentOffset;
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear stored user data

    // Navigate to Login Page
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
// Ensure '/login' route is set up in your app
  }


  Future<int?> getNumericUserId(String firebaseUid) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users') // Your Firestore collection
          .where('firebaseUid', isEqualTo: firebaseUid) // Match Firebase UID
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first['userId']; // Assuming 'userId' is numeric
      }
    } catch (e) {
      print("Error fetching user ID: $e");
    }
    return null;
  }


  void _showContactForm() {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    bool isButtonEnabled = false;

    FocusNode nameFocus = FocusNode();
    FocusNode emailFocus = FocusNode();
    FocusNode descriptionFocus = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _validateFields() {
              setState(() {
                isButtonEnabled = nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty;
              });
            }

            void _submitForm() async {
              if (numericUserId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: User ID not found!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (nameController.text != userName || emailController.text != userEmail) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Entered Name or Email does not match registered details!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Prepare Firestore data
              Map<String, dynamic> contactData = {
                "userId": numericUserId,  // Store the numeric user ID
                "name": nameController.text,
                "email": emailController.text,
                "description": descriptionController.text,
                "timestamp": FieldValue.serverTimestamp(),
              };

              try {
                await FirebaseFirestore.instance.collection("contact_forms").add(contactData);
                Navigator.pop(context); // Close the dialog

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Message sent successfully!"))
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to send message! Try again."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }


            Widget buildTextField(String hint, TextEditingController controller, FocusNode focusNode,
                {TextInputType? keyboardType, int maxLines = 1}) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: focusNode.hasFocus
                      ? [
                    BoxShadow(color: Colors.blueAccent, offset: Offset(5, 5), blurRadius: 6),
                    BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
                  ]
                      : [
                    BoxShadow(color: Colors.grey.shade600, offset: Offset(5, 5), blurRadius: 6),
                    BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hint, // Replaces labelText
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none, // Removes purple outline
                    contentPadding: EdgeInsets.all(12), // Proper spacing
                  ),
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  onChanged: (_) => _validateFields(),
                  onTap: () {
                    setState(() {}); // Refresh UI to update focus state
                  },
                ),
              );
            }


            return AlertDialog(
              title: Text("Contact Us"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildTextField("Name", nameController, nameFocus),
                  SizedBox(height: 10),
                  buildTextField("Email", emailController, emailFocus, keyboardType: TextInputType.emailAddress),
                  SizedBox(height: 10),
                  buildTextField("Description", descriptionController, descriptionFocus, maxLines: 3),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: Colors.black)),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () async {
                      setState(() => _isSubmitting = true);
                      await Future.delayed(Duration(seconds: 2)); // Simulating API call
                      _submitForm();
                      setState(() => _isSubmitting = false);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled ? Colors.blue : Colors.grey, // Change button color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Submit"),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = _showDetails ? screenWidth * 10 : profileSize+10;

    final items = <Widget>[
      Icon(Icons.tour, size: 30, color: Colors.black),
      Icon(Icons.home_filled, size: 30, color: Colors.black),
      Icon(Icons.bookmark, size: 30, color: Colors.black),
      //Icon(Icons.commute, size: 30, color: Colors.black),

    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(profileSize ),
        child: Column(
          children: [
            Container(
              height: 30,
              width: containerWidth,
              color: Colors.blueAccent,
            ),
            Stack(
              children: [
                AnimatedContainer(
                  duration: Duration(seconds: 7),
                  curve: Curves.easeInOut,
                  width: containerWidth,
                  height: profileSize ,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(30),
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(30)
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  alignment: Alignment.centerLeft,
                  child: Flexible(
                    child: Row(

                      children: [
                        // Profile Image touching the left
                        ClipRRect(
                          borderRadius: BorderRadius.circular(profileSize),

                          child: userImage != null
                              ? Image.memory(
                            userImage!,
                            width: profileSize,
                            height: profileSize,
                            fit: BoxFit.cover,
                          ) :
                          Image.asset(
                            'assets/images/user.jpg',
                            width: profileSize,
                            height: profileSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),

                        if (_showDetails)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                userEmail,
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 40,
                  top: 15,
                  child: GestureDetector(
                    onTap: _logout, // Calls the logout function
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),


                Positioned(
                  right: 5,
                  top: 15,
                  child:  GestureDetector(
                    onTap: _showContactForm, // Call the function to show form
                    child: Icon(Icons.contact_mail, color: Colors.black, size: 24),
                  ),
                )
              ],
            ),
          ],
        ),
      ),

      extendBody: true,
      body: IndexedStack(
        index: indexs,
        children: [
          TourPage(
            scrollController: _scrollController,
            onBookNow: (String packageName) {
              setState(() {
                indexs = 1; // ✅ Navigate to DetailPage
                selectedPackageName = packageName; // ✅ Store package or offer title
              });
            },
          ),
          HotelPage(packageName: selectedPackageName,),
          TripPage(),
          //TravelPage( ),  // ✅ Pass the stored package name
        ],
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: isNavVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: SafeArea(
          child: CurvedNavigationBar(
            color: Colors.blueAccent,
            backgroundColor: Colors.transparent,
            buttonBackgroundColor: Colors.white,
            height: 60,
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 300),
            index: indexs,
            items: items,
            onTap: (index) {
              setState(() => indexs = index);
            },
          ),
        ),
      ),
    );
  }
}
