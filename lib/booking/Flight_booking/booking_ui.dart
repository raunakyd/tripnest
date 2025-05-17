import 'package:flutter/material.dart';
import 'form_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingUI extends StatefulWidget {
  final String hotelName;
  final double hotelPrice;
  final String flightName;
  final double flightPrice;
  final String tripType;
  final String? packageName;
  final String? flightLogoUrl;
  final String? hotelImage;
  final DateTime? checkInDate;  // Now DateTime
  final DateTime? checkOutDate;  // Now DateTime
  final DateTime? startDate;  // Change to DateTime
  final DateTime? returnDate;  // Change to DateTime
  final String? departurePoint;
  final String? destinationPoint;
  final String? classType;

  // Flight details
  final DateTime? departureDate1;  // Accept DateTime
  final DateTime? departureTime1;  // Accept DateTime
  final DateTime? arrivalDate1;  // Accept DateTime
  final DateTime? arrivalTime1;  // Accept DateTime
  final DateTime? departureDate2;  // Accept DateTime
  final DateTime? departureTime2;  // Accept DateTime
  final DateTime? arrivalDate2;  // Accept DateTime
  final DateTime? arrivalTime2;  // Accept DateTime

  const BookingUI({
    required this.hotelName,
    required this.hotelPrice,
    required this.flightName,
    required this.flightPrice,
    required this.tripType,
    this.packageName,
    this.hotelImage,
    this.flightLogoUrl,
    this.checkInDate,
    this.checkOutDate,
    this.startDate,  // Update to DateTime
    this.returnDate,  // Update to DateTime
    this.departurePoint,
    this.destinationPoint,
    this.classType,
    this.departureDate1,
    this.departureTime1,
    this.arrivalDate1,
    this.arrivalTime1,
    this.departureDate2,
    this.departureTime2,
    this.arrivalDate2,
    this.arrivalTime2,


    Key? key,
  }) : super(key: key);

  @override
  _BookingUIState createState() => _BookingUIState();
}

class _BookingUIState extends State<BookingUI> {
  List<Map<String, dynamic>> savedDetails = [];
  double totalCost = 0.0; // Store total cost
  double baseCost= 0.0;
  double discountAmount=0.0;
  double discountPercentage=0.0;
  /// Function to calculate the total cost
  @override
  void initState() {
    super.initState();

    print("✅ Entered BookingUI");

    print("hotelName: ${widget.hotelName}");

    print("checkInDate: ${widget.checkInDate} - Type: ${widget.checkInDate.runtimeType}");
    print("checkOutDate: ${widget.checkOutDate} - Type: ${widget.checkOutDate.runtimeType}");

    print("startDate: ${widget.startDate}");
    print("returnDate: ${widget.returnDate}");

    print("departureDate1: ${widget.departureDate1}");
    print("departureTime1: ${widget.departureTime1}");
    print("arrivalDate1: ${widget.arrivalDate1}");
    print("arrivalTime1: ${widget.arrivalTime1}");
    print("departureDate2: ${widget.departureDate2}");
    print("departureTime2: ${widget.departureTime2}");
    print("arrivalDate2: ${widget.arrivalDate2}");
    print("arrivalTime2: ${widget.arrivalTime2}");
  }


  void calculateTotalCost() {
    setState(() {
      int numberOfPersons = savedDetails.length;
      if (numberOfPersons > 0) {
        baseCost = (numberOfPersons * widget.flightPrice) + widget.hotelPrice;
      } else {
        baseCost = 0.0; // No persons, so baseCost is 0
      }
      discountPercentage = getPackageDiscount();
      discountAmount = (baseCost * discountPercentage) / 100;
      totalCost = baseCost - discountAmount;
    });
  }


  /// Function to save person details and recalculate total cost
  void _savePersonDetail(Map<String, dynamic> person) {
    setState(() {
      savedDetails.add(person);
      calculateTotalCost(); // Update total cost after saving person details
    });
  }

  Future<void> saveBooking() async {

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in.'), backgroundColor: Colors.red),
        );
        return;
      }

      // Fetch the user's document from Firestore to get the userId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // because your document ID is the UID
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found.'), backgroundColor: Colors.red),
        );
        return;
      }

      final int userId = userDoc['userId'];
      // Prepare the flight details conditionally based on trip type
      Map<String, dynamic> flightDetails = {};

      if (widget.tripType == "One-way") {
        // For one-way trips, store only the outbound flight details
        flightDetails = {
          'departureDate1': widget.departureDate1,
          'departureTime1': widget.departureTime1,
          'arrivalDate1': widget.arrivalDate1,
          'arrivalTime1': widget.arrivalTime1,
        };
      } else if (widget.tripType == "Round-trip") {
        // For round-trip, store both outbound and return flight details
        flightDetails = {
          'startdepartureDateTime1': widget.departureDate1,
          'startarrivalDateTime1': widget.arrivalDate1,
          'returndepartureDateTime2': widget.departureDate2,
          'returnarrivalDateTime2': widget.arrivalDate2,
        };
      }

      final bookingData = {
        'userId': userId,
        'packageName': widget.packageName ?? "Not Selected",
        'hotelName': widget.hotelName,
        'hotelPrice': double.parse(widget.hotelPrice.toStringAsFixed(2)), // <-- rounded
        'flightName': widget.flightName,
        'flightPrice': double.parse(widget.flightPrice.toStringAsFixed(2)), // <-- rounded
        'tripType': widget.tripType,
        'totalCost': double.parse(totalCost.toStringAsFixed(2)), // <-- rounded
        'persons': savedDetails,
        'checkInDate': widget.checkInDate != null ? Timestamp.fromDate(widget.checkInDate!) : null,
        'checkOutDate': widget.checkOutDate != null ? Timestamp.fromDate(widget.checkOutDate!) : null,
        'startDate': widget.startDate != null ? Timestamp.fromDate(widget.startDate!) : null,  // Convert to Timestamp
        'returnDate': widget.returnDate != null ? Timestamp.fromDate(widget.returnDate!) : null,  // Convert to Timestamp
        'departurePoint': widget.departurePoint,
        'destinationPoint': widget.destinationPoint,
        'classType': widget.classType,
        'flightDetails':flightDetails,
        'bookingDate': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('booking').add(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking Saved Successfully!'), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error saving booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking.'), backgroundColor: Colors.red),
      );
    }
  }
  double getPackageDiscount() {
    final Map<String, double> discountMap = {
      'welcome offers 12% off': 30.0,
      'weekend special 9% off': 15.0,
      '5% off adventure tours': 5.0,
      'family tours 8% off': 10.0,
      'group package 10% off': 20.0,
    };

    final package = widget.packageName?.toLowerCase() ?? '';

    return discountMap[package] ?? 0.0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Details"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.packageName ?? "Package Not Selected"}  ${widget.tripType}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel Detail Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Hotel Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text(widget.hotelName, style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 4),
                                  Text("Price: ₹${widget.hotelPrice.toStringAsFixed(2)}", style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: widget.hotelImage != null && widget.hotelImage!.isNotEmpty
                                  ? Image.network(
                                widget.hotelImage!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[300],
                                child: Icon(Icons.home_filled, size: 40, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Flight Detail Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Flight Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text(widget.flightName, style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 4),
                                  Text("Price/person: ₹${widget.flightPrice.toStringAsFixed(0)}", style: TextStyle(color: Colors.blue)),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:Image.asset("assets/flight/flight6.jpg",
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),
                  DetailCardWidget(
                    onSave: _savePersonDetail,
                    savedDetails: savedDetails,
                    flightPrice: widget.flightPrice,
                    hotelPrice: widget.hotelPrice,
                    calculateTotalCost: calculateTotalCost,
                  ),
                  SizedBox(height: 20),
                  ImageContainer(imagePath: 'assets/flight/flight2.jpg'),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          Container(
            height: 100,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                    Text(
                      "Base Cost:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹${baseCost.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,        // Make text bold
                        decoration: TextDecoration.lineThrough,
                        decorationStyle: TextDecorationStyle.dashed,
                        decorationColor: Colors.red,         // You can set color
                        decorationThickness: 2.5,            // <-- this controls thickness
                      ),
                    ),
                    ]
                    ),

                    SizedBox(height: 4),
                    Text(
                      "Total Cost:₹${totalCost.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: savedDetails.isNotEmpty ? saveBooking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: savedDetails.isNotEmpty ? Colors.blueAccent : Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  child: Text("Confirm Booking", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
