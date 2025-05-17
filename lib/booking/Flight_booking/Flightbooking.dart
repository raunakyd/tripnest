import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_ui.dart';
import 'flight_api.dart';
import 'flight_widget.dart'; // Import the FlightCard widget

class FlightBookingPage extends StatefulWidget {
  final String transportType;
  final Color color;
  final String? hotelName;  // <-- Optional with null safety
  final double? hotelPrice; // <-- Optional with null safety
  final String? hotelImage;  // <-- Add this
  final String? packageName; // <-- Add this parameter
  final DateTime? checkInDate;
  final DateTime? checkOutDate;


  const FlightBookingPage(
      {required this.transportType,
        required this.color,
        this.hotelName,  // <-- Now optional
        this.hotelPrice, // <-- Now optional
        this.hotelImage,  // <-- Add this
        this.packageName, // <-- Add this
        this.checkInDate,
        this.checkOutDate,
        Key? key})
      : super(key: key);

  @override
  _FlightBookingPageState createState() => _FlightBookingPageState();
}

class _FlightBookingPageState extends State<FlightBookingPage> {
  TextEditingController departureController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController ReturnDateController = TextEditingController();

  String? selectedSeatType = "economy";
  String selectedTripType = "Round-trip";

  List<String> seatTypes = ['economy', 'business', 'first', 'premium_economy'];

  List<Map<String, dynamic>> flights = []; // Store fetched flights

  bool isLoading = false; // Show loading indicator
// Function to format DateTime to String (Date)
  String formatDateToString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);  // Adjust the format as needed
  }

// Function to format DateTime to String (Time)
  String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);  // Adjust time format as needed
  }
  DateTime _parseSafeDate(String input) {
    try {
      List<String> parts = input.split('-');
      if (parts.length != 3) throw FormatException("Invalid date format");
      String padded = "${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}";
      return DateTime.parse(padded);
    } catch (e) {
      print("❌ Invalid date input: $input, error: $e");
      return DateTime.now(); // Or handle more gracefully
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Your Flight"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Hotel Name and Price at the top
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.hotelImage != null && widget.hotelImage!.isNotEmpty
                      ? Image.network(
                    widget.hotelImage!,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[300], // Background for icon
                    child: Icon(Icons.home_filled, size: 30, color: Colors.grey[700]),
                  ),
                ),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.hotelName ?? "Hotel Not Selected"}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Check-in: ${widget.checkInDate != null ? DateFormat('yyyy-MM-dd').format(widget.checkInDate!) : 'N/A'}",
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      "Check-out: ${widget.checkOutDate != null ? DateFormat('yyyy-MM-dd').format(widget.checkOutDate!) : 'N/A'}",
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      "Hotel Price: ₹${widget.hotelPrice?.toInt() ?? 0}",
                      style: TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),

            TripTypeSelector(
              selectedTripType: selectedTripType,
              onChanged: (String newValue) {
                setState(() {
                  selectedTripType = newValue;
                  flights.clear(); // ✅ Clear flights when trip type changes
                });
              },
            ),
            const SizedBox(height: 5),

            NeumorphicAirportTextField(
              label: "Departure Airport",
              controller: departureController,
              icon: Icons.flight_takeoff,
            ),
            const SizedBox(height: 5),

            NeumorphicAirportTextField(
              label: "Destination Airport",
              controller: destinationController,
              icon: Icons.flight_land,
            ),
            const SizedBox(height: 5),

            NeumorphicDropdown(
              label: "Seat Type",
              items: seatTypes,
              selectedValue: selectedSeatType,
              icon: Icons.airline_seat_recline_normal,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSeatType = newValue;
                });
              },
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: NeumorphicTextField(
                    label: "Start Date",
                    controller: startDateController,
                    isDateField: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeumorphicTextField(
                    label: "Return Date",
                    controller: ReturnDateController,
                    isDateField: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Align(
              alignment: Alignment.centerRight,
              child: NeumorphicButton(
                text: "Search Flight",
                color: widget.color,
                onPressed: () async {
                  if (selectedTripType == "Round-trip" && ReturnDateController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select a return date for a Round-trip."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return; // Stop execution if return date is missing
                  }

                  setState(() {
                    isLoading = true; // Show loader
                    flights.clear();
                  });

                  FlightSearchService flightService = FlightSearchService();

                  try {
                    List<Map<String, dynamic>> fetchedFlights = await flightService.searchFlights(
                      tripType: selectedTripType,
                      departure: departureController.text,
                      destination: destinationController.text,
                      startDate: startDateController.text,
                      returnDate: selectedTripType == "Round-trip" ? ReturnDateController.text : null, // Fix for One-way trip
                      seatType: selectedSeatType ?? "economy",
                    );

                    setState(() {
                      flights = fetchedFlights;
                      isLoading = false;
                    });

                    if (flights.isEmpty) {
                      print("❌ No flights available.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("No flights available for the selected route."),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    print("❌ Error fetching flights: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error fetching flights. Please try again."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              ),
            ),
            const SizedBox(height: 10),

            // Show Loading Indicator
            if (isLoading) Center(child: CircularProgressIndicator()),

            // Display Flights using FlightCard
            if (flights.isNotEmpty)
              SizedBox(
                height: 300, // Set a fixed height for the scrollable list
                child: Scrollbar(
                  thumbVisibility: true, // Show scrollbar
                  child: ListView.builder(
                    itemCount: flights.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          print("🚀 onTap called");

                          String flightName = (flights[index]['legs'] != null && flights[index]['legs'].isNotEmpty)
                              ? flights[index]['legs'][0]['carriers']['marketing'][0]['name'] ?? "Unknown Airline"
                              : "Unknown Airline";

                          print("🛫 Selected flight: $flightName");

                          // Extracting flight legs
                          var leg1 = flights[index]['legs'][0];
                          var leg2 = (flights[index]['legs'].length > 1) ? flights[index]['legs'][1] : null;

                          // Parse leg1 DateTime fields
                          DateTime departureDateTime1 = DateTime.parse(leg1['departure']);
                          DateTime arrivalDateTime1 = DateTime.parse(leg1['arrival']);

                          // Parse leg2 DateTime fields if round-trip
                          DateTime? departureDateTime2 = leg2 != null ? DateTime.parse(leg2['departure']) : null;
                          DateTime? arrivalDateTime2 = leg2 != null ? DateTime.parse(leg2['arrival']) : null;

                          // Optional: format for display/logging
                          print("⏰ Flight 1 details:");
                          print("Departure Date: ${formatDateToString(departureDateTime1)}, Time: ${formatTime(departureDateTime1)}");
                          print("Arrival Date: ${formatDateToString(arrivalDateTime1)}, Time: ${formatTime(arrivalDateTime1)}");

                          if (leg2 != null) {
                            print("⏰ Flight 2 details (Return leg):");
                            print("Departure Date: ${formatDateToString(departureDateTime2!)}, Time: ${formatTime(departureDateTime2)}");
                            print("Arrival Date: ${formatDateToString(arrivalDateTime2!)}, Time: ${formatTime(arrivalDateTime2)}");
                          }

                          // Navigate to BookingUI with parsed DateTime values
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingUI(
                                  flightName: flightName,
                                  flightPrice: (flights[index]['price'] is Map)
                                      ? (flights[index]['price']['raw'] as double? ?? 0.0)
                                      : (flights[index]['price'] as double? ?? 0.0),
                                  tripType: selectedTripType,
                                  hotelName: widget.hotelName ?? "Not Selected",
                                  hotelPrice: widget.hotelPrice ?? 0,
                                  hotelImage: widget.hotelImage,
                                  packageName: widget.packageName,
                                  checkInDate: widget.checkInDate,
                                  checkOutDate: widget.checkOutDate,
                                  startDate: _parseSafeDate(startDateController.text),
                                  returnDate: _parseSafeDate(ReturnDateController.text),
                                  departurePoint: departureController.text,
                                  destinationPoint: destinationController.text,
                                  classType: selectedSeatType,
                                  departureDate1: departureDateTime1,
                                  departureTime1: departureDateTime1,
                                  arrivalDate1: arrivalDateTime1,
                                  arrivalTime1: arrivalDateTime1,
                                  departureDate2: departureDateTime2,
                                  departureTime2: departureDateTime2,
                                  arrivalDate2: arrivalDateTime2,
                                  arrivalTime2: arrivalDateTime2,
                                ),
                              ),
                            );
                            print("✅ Navigation successful");
                          } catch (e, stackTrace) {
                            print("❌ Error during navigation: $e");
                            print("Stack trace: $stackTrace");
                          }
                        },
                        child: FlightCard(
                          flight: flights[index],
                          tripType: selectedTripType,
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
