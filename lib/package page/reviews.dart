import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:typed_data';

class ReviewPage extends StatefulWidget {
  final String packageName;

  ReviewPage({required this.packageName});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController reviewController = TextEditingController();
  double rating = 3.0;
  String userName = "User"; // Default name
  Uint8List? userImageBytes; // Profile image placeholder
  String userId = ""; // Store Firebase UID

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch user details from Firebase Auth & Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userId = user.uid; // Store Firebase UID
        userName = userDoc['name'] ?? user.displayName ?? "Unknown User";
        userImageBytes = null; // Update this if you have user profile images
      });
    }
    setState(() {}); // Force UI refresh to load new data

  }

  // Submit review to Firestore
  Future<void> submitReview(String packageName, double rating, String reviewText) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String userName = userDoc['name'] ?? "Unknown User";
          int userId = userDoc['userId']; // Fetch the numeric userId

          await FirebaseFirestore.instance.collection('reviews').add({
            'packageName': packageName,
            'rating': rating,
            'review': reviewText,
            'timestamp': FieldValue.serverTimestamp(),
            'userName': userName,
            'userId': userId, // Store the correct numeric userId
          });

          print("Review submitted successfully!");
        } else {
          print("User data not found in Firestore.");
        }
      } else {
        print("User is not logged in.");
      }
    } catch (e) {
      print("Error submitting review: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reviews - ${widget.packageName}")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            // Rating Bar
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) => setState(() => rating = value),
            ),
            SizedBox(height: 10),

            // Review Text Field
            TextField(
              controller: reviewController,
              decoration: InputDecoration(
                hintText: "Write your review here",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),

            // Submit Button
            ElevatedButton(
              onPressed: () => submitReview(widget.packageName, rating, reviewController.text),
              child: Text("Submit Review"),
            ),

            Divider(thickness: 1, height: 30),

            // Others' Reviews Section
            Text("Others' Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Expanded(
              child:StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .where('packageName', isEqualTo: widget.packageName)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No reviews yet!"));
                  }

                  var reviews = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      var reviewData = reviews[index].data() as Map<String, dynamic>;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: reviewData['profileImage'] != null
                              ? NetworkImage(reviewData['profileImage'])
                              : AssetImage("assets/images/user.jpg") as ImageProvider,
                        ),
                        title: Text(reviewData['userName'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reviewData['review']),
                            RatingBarIndicator(
                              rating: reviewData['rating'].toDouble(),
                              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              )

            ),
          ],
        ),
      ),
    );
  }
}
