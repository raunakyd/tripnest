import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ServicesOffersPage extends StatefulWidget {
  final void Function(String) onBookNow; // ✅ Define callback accepting a String
  ServicesOffersPage({required this.onBookNow});
  @override
  _ServicesOffersPageState createState() => _ServicesOffersPageState();
}

class _ServicesOffersPageState extends State<ServicesOffersPage> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> servicesOffers = [
    {
      "title": "Welcome Offers 12% Off",
      "image": "assets/tour/welcome.jpg",
      /*"price": "₹15,297/",
      "duration":"2D/3N",*/
      "services": [
        "RoundTrip Flight",
        "Pickup And Drop",
        "Unlimited Foods",
        "3-Star Hotel",
      ]
    },
    {
      "title": "Weekend Special 9% Off",
      "image": "assets/tour/weekend.jpg",
      /*"price": "₹19,297/",
      "duration":"4D/3N",*/
      "services": [
        "RoundTrip Flight",
        "Pickup And Drop",
        "Unlimited Meals",
        "3 Star hotel",
      ]
    },
    {
      "title": "5% off Adventure Tours",
      "image": "assets/tour/adventure.jpg",
      /*"price": "₹20,297/",
      "duration":"4D/3N",*/
      "services": [
        "RoundTrip Flight",
        "3-Star Hotel",
        "Unlimited Foods",
        "Pickup And Drop",

      ]
    },
    {
      "title": "Family Tours 8% Off",
      "image": "assets/tour/family.jpg",
      /*"price": "₹22,297/",
      "duration":"3D/2N",*/
      "services": [
        "RoundTrip Flight",
        "Pickup And Drop",
        "Family Meals Off",
        "free for child 8yr",
      ]
    },
    {
      "title": "Group Package 10% Off",
      "image": "assets/tour/group.jpg",
      /*"price": "₹24,297/",
      "duration":"5D/4N",*/
      "services": [
        "Round Trip",
        "limited Foods",
        "3 Star Hotel ",
        "Bus Transport",
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < servicesOffers.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Container(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: servicesOffers.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _build3DCard(index);
              },
            ),
          ),
          SizedBox(height: 12),

          // Smooth Page Indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: servicesOffers.length,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.blueAccent,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 5,
              dotColor: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  // 3D Card Widget with "Book Now" button in the right-bottom corner
  Widget _build3DCard(int index) {
    double scaleFactor = (_currentPage == index) ? 1.1 : 0.85; // Focus effect
    double rotationAngle = (_currentPage == index) ? 0 : 0.05; // Minor tilt

    return Transform.scale(
      scale: scaleFactor,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002) // Depth effect
          ..rotateX(rotationAngle)
          ..rotateY(rotationAngle),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Card(
            elevation: 12, // Floating effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Colors.black.withOpacity(0.3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.85, // Adjust the value (0 = fully transparent, 1 = fully visible)
                      child: Image.asset(
                        servicesOffers[index]["image"]!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Sliding Animated Container (Left-aligned, Right-side expands)
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 800),
                    left: 0, // Always touching the left side
                    top: 10,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _currentPage == index ? 220 : 120, // Expands rightward
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),

                      ),
                      child: Text(
                        servicesOffers[index]["title"]!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  // List of Services in 2-column grid layout
                  Positioned(
                    bottom: -10, // Adjust position above the button
                    left: 8,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Prevents inner scrolling
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 columns
                            childAspectRatio: 5, // Adjust row height
                            crossAxisSpacing: 8, // Horizontal spacing
                            mainAxisSpacing: 5, // Vertical spacing
                          ),
                          itemCount: (servicesOffers[index]["services"] as List?)?.length ?? 0,
                          itemBuilder: (context, serviceIndex) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.black54.withOpacity(0.2), // Semi-transparent black background for each service
                                borderRadius: BorderRadius.circular(10), // Rounded edges for each service
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      servicesOffers[index]["services"][serviceIndex],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  /// **Position Price Tag in Left-Bottom Corner**
                  /*
                  Positioned(
                    bottom: 12,
                    left: 15,
                    child: _buildPriceTag(servicesOffers[index]["price"]?.toString()),
                  ),
                  
                   */

                  // **Position Price Tag in Left-Bottom Corner**
                 /* Positioned(
                    top: 15,
                    right: 5,
                    child: _builddurationTag(servicesOffers[index]["duration"]?.toString()),
                  ),

                  */

                  // "Book Now" Button in the Bottom-Right Corner
                  Positioned(
                    bottom: 3,
                    right: 15,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                        minimumSize: Size(80, 30), // Reduced button size

                      ),
                      onPressed: () => widget.onBookNow(servicesOffers[index]["title"] ?? ''),
                      child: Text(
                        "Book Now",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/*
Widget _buildPriceTag(String? price) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.6), // Black background
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children:[ Text(
        price ?? "N/A",  // ✅ If price is null, show "N/A"
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
        Icon(
          Icons.person,
          size: 12,
          color: Colors.white,
        ),
    ]
    ),
  );
}

 */
/*
Widget _builddurationTag(String? duration) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.6), // Black background
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      duration ?? "N/A",  // ✅ If price is null, show "N/A"
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
 */


