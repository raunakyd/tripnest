import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class HotelApiService {
  static const String apiKey = "33284aa385msh5ad80224e01157ep1fc26ejsnf54fb12c0dcf"; // Replace with your API key
  static const String apiHost = "booking-com.p.rapidapi.com";

  /// Check Internet Connectivity before making API calls
  static Future<void> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("❌ No Internet Connection!");
      throw Exception("No internet connection. Please check your network.");
    } else {
      print("✅ Internet is Available!");
    }
  }

  /// Fetches the Destination ID (`dest_id`) for the given city name
  static Future<String?> getDestinationId(String cityName) async {
    await checkInternet(); // Check internet before API call

    final url = Uri.https(apiHost, '/v1/hotels/locations', {
      "name": cityName,
      "locale": "en-gb", // English locale
    });

    print("Fetching Destination ID for: $cityName");
    print("Request URL: $url");

    final response = await http.get(url, headers: {
      "X-RapidAPI-Key": apiKey,
      "X-RapidAPI-Host": apiHost,
    });

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        print("Destination ID Found: ${data[0]["dest_id"]}");
        return data[0]["dest_id"];
      } else {
        print("No Destination ID found for: $cityName");
      }
    } else {
      print("API Error: ${response.statusCode}");
    }

    return null;
  }

  /// Fetches hotels using the Destination ID (`dest_id`)
  static Future<List<dynamic>> searchHotels({
    required String destId,
    required String checkIn,
    required String checkOut,
    required int roomCount,
    required int adultCount,
    required int childCount,
  }) async {
    await checkInternet(); // Check internet before searching hotels

    final url = Uri.https(apiHost, '/v1/hotels/search', {
      "dest_id": destId,
      "dest_type": "city",
      "checkin_date": checkIn,
      "checkout_date": checkOut,
      "room_number": roomCount.toString(),
      "adults_number": adultCount.toString(),
      "children_number": childCount.toString(),
      "order_by": "popularity",
      "locale": "en-gb",
      "currency": "INR",
      "filter_by_currency": "INR",
      "units": "metric",
    });

    print("🔍 Requesting Hotels: $url");

    final response = await http.get(url, headers: {
      "X-RapidAPI-Key": apiKey,
      "X-RapidAPI-Host": apiHost,
    });

    print("📩 Response Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("📜 Full Response: ${json.encode(data)}"); // Print the entire response for debugging

      if (data.containsKey('result')) {
        List<dynamic> hotels = data['result'];
        print("✅ Hotels Found: ${hotels.length}");

        // Debugging: Print details of the first 3 hotels (if available)
        for (int i = 0; i < hotels.length && i < 3; i++) {
          print("🏨 Hotel ${i + 1}");
          print("   🏷 Name: ${hotels[i]['hotel_name'] ?? 'N/A'}");
          print("   🖼 Image: ${hotels[i]['main_photo_url'] ?? 'N/A'}");
          print("   💰 Price: ${hotels[i]['min_total_price'] ?? 'N/A'}");
          print("   📍 Address: ${hotels[i]['address'] ?? 'N/A'}");
          print("   ⭐ Rating: ${hotels[i]['review_score'] ?? 'N/A'}");
        }

        return hotels; // ✅ Extract and return the hotel list
      } else {
        print("❌ No hotels found in the response!");
        return [];
      }
    } else {
      print("🚨 Error: Failed to load hotels. Response Code: ${response.statusCode}");
      print("📜 Error Response: ${response.body}");
      throw Exception("Failed to load hotels");
    }
  }


  /// Fetches reviews for a specific hotel
  static Future<List<dynamic>> fetchHotelReviews(String hotelId) async {
    await checkInternet(); // Ensure internet connectivity

    final url = Uri.https(apiHost, '/v1/hotels/reviews', {
      "hotel_id": hotelId,
      "locale": "en-gb",
      "sort_type": "SORT_SCORE_DESC"
    });

    print("🔍 Fetching Reviews for Hotel ID: $hotelId");
    print("Request URL: $url");

    final response = await http.get(url, headers: {
      "X-RapidAPI-Key": apiKey,
      "X-RapidAPI-Host": apiHost,
    });

    print("📩 Response Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("📜 Full Response: ${json.encode(data)}");

      if (data.containsKey('result')) {
        List<dynamic> reviews = data['result'];
        print("✅ Reviews Found: ${reviews.length}");

        // Debugging: Print details of the first 3 reviews (if available)
        for (int i = 0; i < reviews.length && i < 3; i++) {
          print("💬 Review ${i + 1}");
          print("   👤 Author: ${reviews[i]['author'] ?? 'Anonymous'}");
          print("   ⭐ Rating: ${reviews[i]['average_score'] ?? 'N/A'}");
          print("   📝 Comment: ${reviews[i]['title'] ?? 'No comment'}");
        }

        return reviews; // ✅ Extract and return the reviews list
      } else {
        print("❌ No reviews found in the response!");
        return [];
      }
    } else {
      print("🚨 Error: Failed to load reviews. Response Code: ${response.statusCode}");
      print("📜 Error Response: ${response.body}");
      throw Exception("Failed to load reviews");
    }
  }

}




