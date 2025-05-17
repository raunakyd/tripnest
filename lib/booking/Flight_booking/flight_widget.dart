import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'flight_api.dart';

/// **Trip Type Selection - Radio Buttons**
class TripTypeSelector extends StatelessWidget {
  final String selectedTripType;
  final ValueChanged<String> onChanged;

  const TripTypeSelector({required this.selectedTripType, required this.onChanged, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRadioButton("One-way"),
            _buildRadioButton("Round-trip"),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: selectedTripType,
          onChanged: (String? newValue) => onChanged(newValue!),
        ),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

/// **Custom Responsive Text Field**

class NeumorphicAirportTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;

  const NeumorphicAirportTextField({
    required this.label,
    required this.controller,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  _NeumorphicAirportTextFieldState createState() => _NeumorphicAirportTextFieldState();
}

class _NeumorphicAirportTextFieldState extends State<NeumorphicAirportTextField> {
  List<String> _airportSuggestions = [];
  bool _isLoading = true;
  final AirportService _airportService = AirportService();

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  /// **Fetch Airport Data**
  Future<void> _loadAirports() async {
    try {
      print("Fetching airports..."); // Debugging
      List<String> airports = await _airportService.fetchIndianAirports();

      if (airports.isEmpty) {
        print("⚠ No airports found!");
      } else {
        print("✅ Airports fetched successfully: ${airports.length} airports found.");
      }

      setState(() {
        _airportSuggestions = airports;
        _isLoading = false;
      });

    } catch (e) {
      print("❌ Error fetching airports: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical:0),
        child: DropdownSearch<String>(
          asyncItems: (String filter) async {
            print("🔍 Filtering airports with: $filter");
            List<String> filteredAirports = _airportSuggestions
                .where((airport) => airport.toLowerCase().contains(filter.toLowerCase()))
                .toList();

            print("✈ Filtered Airports: ${filteredAirports.length} found.");
            return filteredAirports;
          },
          selectedItem: widget.controller.text.isNotEmpty ? widget.controller.text : null,
          onChanged: (value) {
            print("✅ Selected Airport: $value");
            setState(() {
              widget.controller.text = value ?? "";
            });
          },
          popupProps: PopupProps.menu(showSearchBox: true),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: widget.label,
              prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.blueAccent) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ),
    );
  }
}

// **Custom Responsive Neumorphic Text Field**

class NeumorphicTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isDateField;
  final VoidCallback? onTap; // Optional callback for date picker
  final IconData? icon; // Add an icon property

  const NeumorphicTextField({
    required this.label,
    required this.controller,
    this.isDateField = false,
    this.onTap,
    this.icon, // Initialize icon
    Key? key,
  }) : super(key: key);

  @override
  _NeumorphicTextFieldState createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: widget.isDateField
          ? () async {
        DateTime currentDate = DateTime.now();
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: currentDate, // Start from today
          firstDate: currentDate,   // Disable past dates
          lastDate: DateTime(2100), // Allow future dates
        );

        if (pickedDate != null) {
          setState(() {
            widget.controller.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
          });
        }
      }
          : null,
      child: AbsorbPointer(
        absorbing: widget.isDateField, // Prevents keyboard popup for date fields
        child: SizedBox(
          height: 45,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13),
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.label,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 2),
                  prefixIcon: widget.isDateField
                      ? null // No prefix icon for date fields
                      : (widget.icon != null ? Icon(widget.icon, color: Colors.blueAccent) : null), // Prefix icon for other fields
                  suffixIcon: widget.isDateField
                      ? const Icon(Icons.calendar_today, color: Colors.blueAccent) // Calendar icon for date fields
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// **Custom Responsive Dropdown**
class NeumorphicDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final IconData? icon; // Prefix Icon Support
  final ValueChanged<String?> onChanged;

  const NeumorphicDropdown({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Row(
          children: [
            // Show prefix icon only if provided
            if (icon != null) Icon(icon, color: Colors.blueAccent),
            SizedBox(width: icon != null ? 8.0 : 0), // Add spacing if icon exists

            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedValue,
                  hint: Text(label, style: const TextStyle(color: Colors.blueAccent)),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  dropdownColor: Colors.white,
                  menuMaxHeight: 200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// **Custom Responsive Button**
class NeumorphicButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const NeumorphicButton({required this.text, required this.color, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.4, // Reduce from 0.8 to 0.6
      height: screenWidth * 0.12,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02, horizontal: screenWidth * 0.02),
          ),
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}




class FlightCard extends StatelessWidget {
  final Map<String, dynamic> flight;
  final String tripType; // One-way or Round-trip

  const FlightCard(
      {Key? key, required this.flight,
        required this.tripType,

      })
      : super(key: key);

  DateTime parseDateTime(String dateTime) {
    return DateTime.parse(dateTime).toLocal();
  }

  String formatDate(String dateTime) {
    DateTime dt = parseDateTime(dateTime);
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String formatTime(String dateTime) {
    DateTime dt = parseDateTime(dateTime);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (flight['legs'] == null || flight['legs'].isEmpty) {
      return const Center(child: Text("No flight data available"));
    }

    var leg1 = flight['legs'][0]; // First leg (outbound flight)
    var leg2 = (flight['legs'].length > 1) ? flight['legs'][1] : null; // Return leg (if round-trip)

    var airline1 = leg1['carriers']['marketing'][0]; // Airline for outbound
    var airline2 = leg2 != null ? leg2['carriers']['marketing'][0] : airline1; // Airline for return (if exists)

    // Extract departure and arrival details for outbound flight
    String departureDate1 = formatDate(leg1['departure']);
    String departureTime1 = formatTime(leg1['departure']);
    String arrivalDate1 = formatDate(leg1['arrival']);
    String arrivalTime1 = formatTime(leg1['arrival']);

    // Extract return leg details (if round-trip)
    String departureDate2 = leg2 != null ? formatDate(leg2['departure']) : '';
    String departureTime2 = leg2 != null ? formatTime(leg2['departure']) : '';
    String arrivalDate2 = leg2 != null ? formatDate(leg2['arrival']) : '';
    String arrivalTime2 = leg2 != null ? formatTime(leg2['arrival']) : '';

    bool isRoundTrip = tripType.toLowerCase() == "round-trip";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Airline Logo & Name (Outbound)
            Row(
              children: [
                Image.network(
                  airline1['logoUrl'] ?? '',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.flight, size: 40, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Text(
                  airline1['name'] ?? 'Unknown Airline',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Departure & Arrival Details (Outbound)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leg1['origin']?['displayCode'] ?? 'Unknown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("$departureDate1 | $departureTime1"),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.blue),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      leg1['destination']?['displayCode'] ?? 'Unknown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("$arrivalDate1 | $arrivalTime1"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Round-trip return flight details (if applicable)
            if (isRoundTrip && leg2 != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leg2['destination']?['displayCode'] ?? 'Unknown',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("$arrivalDate2 | $arrivalTime2"),
                    ],
                  ),
                  Icon(Icons.arrow_back, color: Colors.blue),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        leg2['origin']?['displayCode'] ?? 'Unknown',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("$departureDate2 | $departureTime2"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Price & Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Duration: ${leg1['durationInMinutes'] ?? 'N/A'} min | Stops: ${leg1['stopCount'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  "₹${flight['price']?['raw']?.toStringAsFixed(2) ?? 'N/A'}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}