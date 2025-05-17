import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripPage extends StatefulWidget {
  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> with SingleTickerProviderStateMixin {
  bool isCurrentTrip = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _animation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void switchTrip(bool isCurrent) {
    setState(() {
      isCurrentTrip = isCurrent;
    });
    _controller.reset();
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser?.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final int userId = userSnapshot.data!.get('userId');

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: tripButton(
                          title: 'Upcomming Trip',
                          icon: Icons.directions_car,
                          color: Colors.blue,
                          isActive: isCurrentTrip,
                          onTap: () => switchTrip(true),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: tripButton(
                          title: 'History Trip',
                          icon: Icons.history,
                          color: Colors.green,
                          isActive: !isCurrentTrip,
                          onTap: () => switchTrip(false),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('booking')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        DateTime now = DateTime.now();
                        DateTime today = DateTime(now.year, now.month, now.day); // Only date

                        var trips = snapshot.data!.docs;

                        // Debug: Print all trips


                        var filteredTrips = trips.where((trip) {
                          DateTime tripStart = (trip['startDate'] as Timestamp).toDate();
                          DateTime tripEnd = (trip['returnDate'] as Timestamp).toDate();

                          DateTime startDate = DateTime(tripStart.year, tripStart.month, tripStart.day);
                          DateTime endDate = DateTime(tripEnd.year, tripEnd.month, tripEnd.day);

                          return isCurrentTrip
                              ? !endDate.isBefore(today) // today or future
                              : endDate.isBefore(today);
                        }).toList();
                        if (filteredTrips.isEmpty) {
                          return Center(
                            child: Text('No ${isCurrentTrip ? '' : ''} Trips Found'),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            var trip = filteredTrips[index];
                            DateTime startDate = (trip['startDate'] as Timestamp).toDate();
                            DateTime returnDate = (trip['returnDate'] as Timestamp).toDate();

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/tour/logo.jpg',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  trip['packageName'] ?? 'Unnamed Package',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Start Date: ${DateFormat.yMMMd().format(startDate)}"),
                                    Text("End Date: ${DateFormat.yMMMd().format(returnDate)}"),
                                    Text("Total Cost: ₹${trip['totalCost']?.toStringAsFixed(2) ?? 'N/A'}"),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.print, color: Colors.grey[700]),
                                  onPressed: () {
                                    // Handle print action
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget tripButton({
    required String title,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: isActive ? _animation.value : 1.0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(icon, size: 20, color: color),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
