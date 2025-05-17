import 'package:flutter/material.dart';

class TourFeatures extends StatelessWidget {
  final List<String> leftFeatures;
  final List<String> rightFeatures;
  final String price;

  const TourFeatures({
    Key? key,
    required this.leftFeatures,
    required this.rightFeatures,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **Tour Features in Two Columns**
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Left Column**
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: leftFeatures.map((feature) => _buildFeature(feature)).toList(),
                ),
              ),

              // **Right Column**
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rightFeatures.map((feature) => _buildFeature(feature)).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5), // Spacing

          // **Limited Time Offer + Price Row**
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Limited Time Offer in separate grey container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Limited Time Offer",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Price in separate grey container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      "₹$price/",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Icon(
                      Icons.person,
                      size: 12,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }

  // Helper method to create each bullet-pointed feature
  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Text("• ", style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
