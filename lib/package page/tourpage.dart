import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:tripnest/package%20page/reviews.dart';
import 'package:tripnest/package%20page/tourservices.dart';
import 'package:tripnest/package%20page/tour_services_data.dart';
import 'offerpackage.dart';


class TourPage extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(String) onBookNow; // ✅ Define callback accepting a String

  TourPage({required this.scrollController,required this.onBookNow});

  @override
  _TourPageState createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  List<Map<String, String>> filteredPackages = [];
  bool isBottomNavVisible = true;
  bool isSearching = false;

  final Color appBackgroundColor = Colors.white60;
  final Color containerColor = Colors.blueGrey.shade500;
  final Color buttonColor = Colors.blueAccent;

  final TextEditingController searchController = TextEditingController();

  String userName = "";  // Fetch from user session or API
  Uint8List? userImageBytes ; // Fetch user's profile image


  List<Map<String, String>> packages = [
    {"title": "Andhra Pradesh", "image": "assets/images/andhra pradesh.jpg"},
    {"title": "Arunachal Pradesh", "image": "assets/images/arunachal pradesh.jpg"},
    {"title": "Assam", "image": "assets/images/assam.jpg"},
    {"title": "Bihar", "image": "assets/images/bihar.jpg"},
    {"title": "Chhattisgarh", "image": "assets/images/chhatisgarh.jpg"},
    {"title": "Goa", "image": "assets/images/goa.jpg"},
    {"title": "Gujarat", "image": "assets/images/gujarat.jpg"},
    {"title": "Haryana", "image": "assets/images/haryana.jpg"},
    {"title": "Himachal Pradesh", "image": "assets/images/himachal pradesh.jpg"},
    {"title": "Jammu & Kasmir", "image": "assets/images/jammu.jpg"},
    {"title": "Jharkhand", "image": "assets/images/jharkhand.jpg"},
    {"title": "Karnataka", "image": "assets/images/karnataka.jpg"},
    {"title": "Kerala", "image": "assets/images/kerala.jpg"},
    {"title": "Madhya Pradesh", "image": "assets/images/madhya pradesh.jpg"},
    {"title": "Maharashtra", "image": "assets/images/maharashtra.jpg"},
    {"title": "Manipur", "image": "assets/images/manipur.jpg"},
    {"title": "Meghalaya", "image": "assets/images/meghalaya.jpg"},
    {"title": "Mizoram", "image": "assets/images/mizoram.jpg"},
    {"title": "Nagaland", "image": "assets/images/nagaland.jpg"},
    {"title": "Odisha", "image": "assets/images/odisha.jpg"},
    {"title": "Punjab", "image": "assets/images/punjab.jpg"},
    {"title": "Rajasthan", "image": "assets/images/rajashthan.jpg"},
    {"title": "Sikkim", "image": "assets/images/sikkim.jpg"},
    {"title": "Tamil Nadu", "image": "assets/images/tamil nadu.jpg"},
    {"title": "Telangana", "image": "assets/images/telangana.jpg"},
    {"title": "Uttar Pradesh", "image": "assets/images/uttar pradesh.jpg"},
    {"title": "Uttarakhand", "image": "assets/images/uttrakhand.jpg"},
    {"title": "West Bengal", "image": "assets/images/west bengal.jpg"},
  ];


  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user details
    filteredPackages = packages;
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "User";
      String? base64Image = prefs.getString('userImage');
      if (base64Image != null) {
        userImageBytes = base64Decode(base64Image);
      }
    });
  }


  void onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPackages = packages;
      } else {
        filteredPackages = packages
            .where((pkg) => pkg["title"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void clearSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      filteredPackages = packages;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search Bar - Always Visible
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (isSearching)
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: clearSearch,
                      ),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearch,
                        onTap: () => setState(() => isSearching = true),
                        decoration: InputDecoration(
                          prefixIcon: isSearching ? null : Icon(Icons.search, color: buttonColor),
                          hintText: "Search tours...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Offer Page - Show only when not searching
            if (!isSearching) ...[
              SizedBox(height: 10),
              ServicesOffersPage(
                onBookNow: (String packageName) {
                  widget.onBookNow(packageName); // Pass package name to HomePage
                },
              ),

              SizedBox(height: 20),
            ],

            // Main Content - GridView
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 80.0), // Prevents overlap with bottom nav
                child: filteredPackages.isEmpty
                    ? Center(
                  child: Text(
                    "No tours found!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                )
                    : GridView.builder(
                  controller: widget.scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: filteredPackages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 5,
                                offset: Offset(4, 4),
                              ),
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 5,
                                offset: Offset(-4, -4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Center everything inside the container
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Ensures the Column only takes necessary space
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Image
                                    Container(
                                      margin: EdgeInsets.only(top: 12),
                                      width: double.infinity,
                                      height: MediaQuery.of(context).size.height * 0.18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)), // Rounded top corners
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                        image: DecorationImage(
                                          image: AssetImage(filteredPackages[index]["image"]!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1),
                        
                                    // Title
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2), // Adjust spacing
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns text to left and icon to right
                                        children: [
                                          // Title on the left
                                          Expanded(
                                            child: Text(
                                              filteredPackages[index]["title"]!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                        
                                          // Three-dot menu on the right
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert, color: Colors.black),
                                            offset: Offset(-40, 4), // Adjust dropdown position
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12), // ✅ Make the popup rounded
                                            ),
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              PopupMenuItem<String>(
                                                value: 'Reviews',
                                                height: 20,
                                                child: SizedBox(
                                                  width: 80,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 2), // ✅ Reduce vertical padding
                                                    child: Text("Reviews", textAlign: TextAlign.center),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            onSelected: (String choice) {
                                              if (choice == 'Reviews') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ReviewPage(packageName: filteredPackages[index]["title"]!),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),


                                    TourFeatures(
                                      leftFeatures: tourFeaturesData[filteredPackages[index]["title"]]?["leftFeatures"] ?? ["Feature not available"],
                                      rightFeatures: tourFeaturesData[filteredPackages[index]["title"]]?["rightFeatures"] ?? ["Feature not available"],
                                      price: tourFeaturesData[filteredPackages[index]["title"]]?["price"] ?? "N/A",
                                    ),
                                SizedBox(height: 10,),
                                    // "Book Now" Button
                                    SizedBox(
                                      width: double.infinity, // Takes full width of the screen
                                      child: ElevatedButton(
                                        onPressed: () => widget.onBookNow(filteredPackages[index]["title"] ?? ''),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: buttonColor,
                                          foregroundColor: Colors.white,
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                          shadowColor: Colors.blueAccent.withOpacity(0.4),
                                        ),
                                        child: Text(
                                          "Book Now",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                        
                        
                        
                        
                            ],
                          ),
                        ),
                      ),

                    );

                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
