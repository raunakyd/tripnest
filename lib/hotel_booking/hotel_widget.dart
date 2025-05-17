import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/booking/Flight_booking/Flightbooking.dart';
import 'api_service.dart';

/*/// **State Input Field Widget**
class StateInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isReadOnly;

  StateInput({required this.controller, required this.isReadOnly,});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 0),
        child: TextField(
          controller: controller,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            hintText: isReadOnly ? null : "Enter State",
            prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }
}

 */
/*
/// **City Input Field Widget**
class CityInput extends StatelessWidget {
  final TextEditingController controller;

  CityInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter City",
            prefixIcon: Icon(Icons.location_city, color: Colors.blueAccent),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          ),
        ),
      ),
    );
  }
}*/

/// **Date Picker Widget**
class DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function() onTap;

  DatePicker({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    date != null ? DateFormat("yyyy-MM-dd").format(date!) : label, // Use `date!` after null check
                    style: TextStyle(fontSize: 14, color: date != null ? Colors.black : Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.blueAccent, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// **Counter Widget for Room, Adult, and Child Selection**
class CounterWidget extends StatelessWidget {
  final String label;
  final int count;
  final Function() increment;
  final Function() decrement;

  CounterWidget({required this.label, required this.count, required this.increment, required this.decrement});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "$count $label",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: increment,
                    child: Icon(Icons.keyboard_arrow_up, color: Colors.blueAccent, size: 18),
                  ),
                  SizedBox(height: 2),
                  GestureDetector(
                    onTap: decrement,
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.blueAccent, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// **Search Button Widget**
class SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  SearchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.blueAccent,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                "Search Hotels",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  final Map<String, dynamic> hotel;
  final int roomCount; // <-- Accept roomCount as a parameter
  final String? packageName; // <-- Add this parameter
  final DateTime? checkInDate; // ✅ Optional
  final DateTime? checkOutDate; // ✅ Optional

  const HotelCard(
      {Key? key, required this.hotel,
        required this.roomCount,
        this.packageName,
        this.checkInDate, // ✅ Optional parameter
        this.checkOutDate, // ✅ Optional parameter
      }) : super(key: key);
// **Show Reviews in a Bottom Sheet**
  void showReviews(BuildContext context, String hotelId) async {
    try {
      List<dynamic> reviews = await HotelApiService.fetchHotelReviews(hotelId); // Call your API function

      if (reviews.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No reviews available for this hotel.")),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Hotel Reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];

                      // Extract author name safely
                      String authorName = 'Anonymous';
                      if (review['author'] is Map && review['author']?.containsKey('name') == true) {
                        authorName = review['author']['name']?.toString() ?? 'Anonymous';
                      } else {
                        authorName = review['author']?.toString() ?? review['name']?.toString() ?? 'Anonymous';
                      }


                      // Extract comment safely
                      String comment = review['title']?.toString() ?? review['comment']?.toString() ?? 'No comment available';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "By: $authorName",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                                ),
                                SizedBox(height: 5),
                                // Display star rating correctly

                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading reviews.")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // Calculate total price based on room count
    double basePrice = (hotel['min_total_price'] ?? 0).toDouble();
    double totalPrice = basePrice * roomCount;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightBookingPage(
              transportType: "flight",
              color: Colors.blueAccent,
              hotelName: hotel['hotel_name'] ?? "Unknown Hotel",
              hotelPrice: totalPrice,
              hotelImage: hotel['main_photo_url'] ?? '',  // <-- Pass the image, // Pass the package name here
              packageName: packageName,
              checkInDate: checkInDate,  // <-- Pass it here ✅
              checkOutDate: checkOutDate, // <-- Pass it here ✅
              // <-- Pass it to FlightBookingPage
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Hotel Image with Rating Positioned at Bottom Right
            Stack(
              children: [
                /// Hotel Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    hotel['main_photo_url'] ?? '', // Hotel image URL
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
      
                /// **Top Right Corner Icon**
                /// **Clickable Icon to Show Reviews (Top Right Corner)**
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (hotel['hotel_id'] != null) {
                        showReviews(context, hotel['hotel_id'].toString());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Hotel ID not available.")),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.more_vert, // Review icon
                        color: Colors.white60,
                        size: 18,
                      ),
                    ),
                  ),
                ),
      
      
                /// Rating Badge (Positioned Bottom Right)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 16),
                        SizedBox(width: 3),
                        Text(
                          hotel['review_score']?.toString() ?? 'N/A', // Hotel rating
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      
            /// Hotel Name and Price
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Hotel Name
                  Expanded(
                    child: Text(
                      hotel['hotel_name'] ?? "Hotel Name",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
      
                  /// Hotel Price (No Decimal Points)
                  Text(
                    "₹${totalPrice.toInt()}", // Display as integer
                    style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
