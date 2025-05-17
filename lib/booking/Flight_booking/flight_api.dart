import 'dart:convert';
import 'package:http/http.dart' as http;

class AirportService {
  static const String apiUrl = "https://sky-scanner3.p.rapidapi.com/flights/airports";
  static const String entityApiUrl = "https://sky-scanner3.p.rapidapi.com/flights/auto-complete";

  static const Map<String, String> headers = {
    "X-RapidAPI-Host": "sky-scanner3.p.rapidapi.com",
    "X-RapidAPI-Key": "33284aa385msh5ad80224e01157ep1fc26ejsnf54fb12c0dcf"
  };

  /// **Fetches all Indian airports**
  Future<List<String>> fetchIndianAirports() async {
    try {
      print("🔍 Fetching airports...");

      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode != 200) throw Exception("Failed to load airports");

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (!responseData.containsKey('data')) throw Exception("Invalid API response");

      List<String> indianAirports = [];
      for (var airport in responseData['data']) {
        if (airport is Map<String, dynamic> && airport.containsKey('location')) {
          String location = airport['location'];
          if (location.contains("India")) {
            indianAirports.add("${airport['name']} (${airport['iata']})");
          }
        }
      }
      print("✅ Found ${indianAirports.length} Indian airports.");
      return indianAirports;
    } catch (e) {
      print("❌ Error fetching airports: $e");
      return [];
    }
  }

  /// **Fetches Entity ID using IATA Code**
  Future<String?> fetchIATACode(String airportQuery) async {
    try {
      // Directly return the IATA code without fetching the entity ID
      String iataCode = airportQuery.contains("(")
          ? airportQuery.split("(").last.replaceAll(")", "").trim()
          : airportQuery;

      print("✅ Returning IATA Code: $iataCode");
      return iataCode;
    } catch (e) {
      print("❌ Exception: $e");
      return null;
    }
  }
}
class FlightSearchService {
  static const String baseUrl = "https://sky-scanner3.p.rapidapi.com/flights";
  static const Map<String, String> headers = {
    "X-RapidAPI-Host": "sky-scanner3.p.rapidapi.com",
    "X-RapidAPI-Key": "33284aa385msh5ad80224e01157ep1fc26ejsnf54fb12c0dcf"
  };

  final AirportService _airportService = AirportService();

  Future<List<Map<String, dynamic>>> searchFlights({
    required String tripType,
    required String departure,
    required String destination,
    required String startDate,
    String? returnDate,
    required String seatType,
  }) async {
    try {
      print("🔍 Fetching IATA codes for $departure → $destination...");

      String? departureIATA = await _airportService.fetchIATACode(departure);
      String? destinationIATA = await _airportService.fetchIATACode(destination);

      if (departureIATA == null || destinationIATA == null) {
        print("❌ ERROR: Missing IATA Code. Departure: $departureIATA, Destination: $destinationIATA");
        return [];
      }

      print("✅ Departure IATA Code: $departureIATA");
      print("✅ Destination IATA Code: $destinationIATA");

      String formattedDate = _formatDate(startDate);
      String? formattedReturnDate = returnDate != null ? _formatDate(returnDate) : null;

      // ✅ Validate returnDate for round-trip flights
      if (tripType.toLowerCase() == "round-trip" && (formattedReturnDate == null || formattedReturnDate.isEmpty)) {
        print("❌ ERROR: Return date is required for round-trip flights.");
        return [];
      }

      String searchApiUrl = tripType.toLowerCase() == "round-trip"
          ? "$baseUrl/search-roundtrip"
          : "$baseUrl/search-one-way";

      String apiUrl = "$searchApiUrl?"
          "fromEntityId=$departureIATA"
          "&toEntityId=$destinationIATA"
          "&departDate=$formattedDate"
          "&cabinClass=${seatType.toLowerCase()}"
          "&adults=1"
          "&currency=INR"
          "&market=IN"
          "&includeOriginNearbyAirports=false"
          "&includeDestinationNearbyAirports=false";

      if (tripType.toLowerCase() == "round-trip") {
        apiUrl += "&returnDate=$formattedReturnDate";
      }

      print("🔗 Final API Request: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      final responseData = json.decode(response.body);

      print("📜 Raw API Response: ${jsonEncode(responseData)}");

      if (responseData.containsKey('errors')) {
        print("❌ API Error: ${jsonEncode(responseData['errors'])}");
        return [];
      }

      if (responseData.containsKey('context') && responseData['context']['status'] == 'incomplete') {
        print("⚠️ API returned 'incomplete' status. Fetching full data...");
        return await fetchIncompleteResults(responseData['context']['searchId']);
      }

      if (responseData.containsKey('data') && responseData['data'] != null) {
        if (responseData['data'].containsKey('itineraries') &&
            responseData['data']['itineraries'] is List) {

          List<Map<String, dynamic>> flights =
          List<Map<String, dynamic>>.from(responseData['data']['itineraries']);

          print("✈️ Found ${flights.length} flights!");
          return flights;
        } else {
          print("⚠️ No valid flight data found.");
          return [];
        }
      }

      print("⚠️ Unexpected API response format: 'data' key missing.");
      return [];
    } catch (e) {
      print("❌ Error fetching flights: $e");
      return [];
    }
  }


  String _formatDate(String date) {
    List<String> dateParts = date.split('-');
    return "${dateParts[0]}-${dateParts[1].padLeft(2, '0')}-${dateParts[2].padLeft(2, '0')}";
  }

  Future<List<Map<String, dynamic>>> fetchIncompleteResults(String searchId) async {
    try {
      String incompleteApiUrl = "$baseUrl/flights/search-incomplete?searchId=$searchId";
      final response = await http.get(Uri.parse(incompleteApiUrl), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('context') && responseData['context']['status'] == 'incomplete') {
          print("⚠️ Still incomplete. Trying again...");
          return await fetchIncompleteResults(searchId);
        }

        if (responseData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      }
    } catch (e) {
      print("❌ Error fetching incomplete results: $e");
    }
    return [];
  }
}