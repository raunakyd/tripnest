import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import '../hotel_booking//api_service.dart';
import '../hotel_booking//hotel_widget.dart';

class HotelPage extends StatefulWidget {
  final String? packageName;
  HotelPage({this.packageName});

  @override
  _HotelPageState createState() => _HotelPageState();
}

class _HotelPageState extends State<HotelPage> {
  final TextEditingController _cityController = TextEditingController();
  String? selectedState;
  String? selectedCity;
  bool isReadOnly = false;

  int roomCount = 1;
  int adultCount = 1;
  int childCount = 1;

  DateTime? checkInDate;
  DateTime? checkOutDate;

  bool isLoading = false; // ✅ Fix: Declare isLoading
  List<Map<String, dynamic>> hotels = []; // ✅ Fix: Declare hotels list

  String apiKey = "WDdzME1QeFRTeTk5dGlMbmNNUlF3ZG9ORDBIakNzY1hVZmpJWjFidg=="; // Your API Key
  String country = "IN"; // Default Country (India)

  List<Map<String, String>> statesData = [];
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    _fetchStates().then((_) {
      if (widget.packageName != null && widget.packageName!.isNotEmpty) {
        /// Try to match the package name with a state
        var matchedState = statesData.firstWhere(
                (state) => state['name'] == widget.packageName!,
            orElse: () => {"name": "", "code": ""}
        );

        if (matchedState["name"]!.isNotEmpty) {
          setState(() {
            selectedState = matchedState["name"];
            isReadOnly = true; // Make it read-only
          });
          _fetchCities(selectedState!);
        }
      }
    });
  }


  /// Fetch list of states
  Future<void> _fetchStates() async {
    final response = await http.get(
      Uri.parse("https://api.countrystatecity.in/v1/countries/$country/states"),

      headers: {"X-CSCAPI-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      setState(() {
        statesData = data.map<Map<String, String>>((state) {
          return {"name": state['name'].toString(), "code": state['iso2'].toString()};
        }).toList();
      });
    } else {
      print("Failed to fetch states: ${response.statusCode}");
    }
  }

  /// Fetch list of cities for a selected state
  Future<void> _fetchCities(String stateName) async {
    String? stateCode = statesData.firstWhere((state) => state['name'] == stateName, orElse: () => {"code": ""})["code"];

    if (stateCode == null || stateCode.isEmpty) {
      print("Invalid State Code");
      return;
    }

    final response = await http.get(
      Uri.parse("https://api.countrystatecity.in/v1/countries/$country/states/$stateCode/cities"),
      headers: {"X-CSCAPI-KEY": apiKey},
    );

    print("City API Response: ${response.body}");

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      setState(() {
        cities = data.map<String>((city) => city['name'].toString()).toList();
      });
    } else {
      print("Failed to fetch cities: ${response.statusCode}");
    }
  }

  /// Show date picker
  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    DateTime initialDate = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.05;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "  Book your hotel for ${widget.packageName ?? "your tour"} ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),

              /// State Dropdown
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: DropdownSearch<String>(
                    enabled: !isReadOnly, // Disable dropdown if read-only
                    asyncItems: (String filter) async {
                      return statesData.map((state) => state['name']!).toList();
                    },
                    selectedItem: selectedState,
                    onChanged: isReadOnly
                        ? null // Prevent changes if read-only
                        : (value) {
                      setState(() {
                        selectedState = value;
                        selectedCity = null;
                        cities.clear();
                      });
                      _fetchCities(value!);
                    },
                    popupProps: PopupProps.menu(showSearchBox: true),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "Select State",
                        prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 5),

              /// City Dropdown (Depends on Selected State)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: DropdownSearch<String>(
                    items: cities,
                    selectedItem: selectedCity,
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                    popupProps: PopupProps.menu(showSearchBox: true),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "Select City",
                        prefixIcon: Icon(Icons.location_city, color: Colors.blueAccent),
                        border: InputBorder.none, // Removes default border
                        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),

              /// Date Pickers
              Row(
                children: [
                  DatePicker(label: "Check-in Date", date: checkInDate, onTap: () => _selectDate(context, true)),
                  SizedBox(width: 5),
                  DatePicker(label: "Check-out Date", date: checkOutDate, onTap: () => _selectDate(context, false)),
                ],
              ),
              SizedBox(height: 5),

              /// Room, Adult, Child Counters
              Row(
                children: [
                  CounterWidget(label: "Room", count: roomCount, increment: () => setState(() => roomCount++), decrement: () => setState(() => roomCount > 1 ? roomCount-- : 1)),
                  SizedBox(width: 5),
                  CounterWidget(label: "Adult", count: adultCount, increment: () => setState(() => adultCount++), decrement: () => setState(() => adultCount > 1 ? adultCount-- : 1)),
                  SizedBox(width: 5),
                  CounterWidget(label: "Child", count: childCount, increment: () => setState(() => childCount++), decrement: () => setState(() => childCount > 1 ? childCount-- : 1)),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("• ", style: TextStyle(fontSize: 16)), // Bullet point
                      Expanded(child: Text("Only 4 People Are Allowed in 1 Room")),
                    ],
                  ),
                  Row(
                    children: [
                      Text("• ", style: TextStyle(fontSize: 16)), // Bullet point
                      Expanded(child: Text("Child up to 8 years Allowed")),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5,),
              /// Search Button
              SearchButton(
                onTap: () async {
                  if (selectedCity == null || checkInDate == null || checkOutDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select a city and dates"))
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true; // Show loader while fetching
                  });

                  try {
                    // Step 1: Fetch Destination ID for the selected city
                    String? destId = await HotelApiService.getDestinationId(selectedCity!);
                    print("🌍 Destination ID for ${selectedCity}: $destId");

                    if (destId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("City not found in Booking.com API"))
                      );
                      setState(() => isLoading = false);
                      return;
                    }

                    // Step 2: Fetch Hotels using Destination ID
                    List<dynamic> hotelResults = await HotelApiService.searchHotels(
                      destId: destId,
                      checkIn: DateFormat('yyyy-MM-dd').format(checkInDate!),
                      checkOut: DateFormat('yyyy-MM-dd').format(checkOutDate!),
                      roomCount: roomCount,
                      adultCount: adultCount,
                      childCount: childCount,
                    );

                    if (hotelResults.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("No hotels found for this city. Try another location."))
                      );
                    }

                    setState(() {
                      hotels = List<Map<String, dynamic>>.from(hotelResults);
                      isLoading = false;
                    });

                  } catch (e) {
                    print("❌ Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to fetch hotels. Please check your network and API key."))
                    );
                    setState(() => isLoading = false);
                  }
                },
              ),

              if (isLoading)
                Center(child: CircularProgressIndicator()),

              if (hotels.isNotEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
                  child: ListView.builder(
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      return HotelCard(
                          hotel: hotels[index],
                          roomCount: roomCount, // Pass selected room count
                          packageName: widget.packageName, // ✅ Pass packageName
                        checkInDate: checkInDate, // ✅ Pass optional
                        checkOutDate: checkOutDate, // ✅ Pass optional
                      ); // Use HotelCard widget
                    },
                  ),
                ),
              //const HotelReels()
            ],
          ),
        ),
      ),
    );
  }
}
