import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';

class brt_mobileCard extends StatelessWidget {
  final String source;
  final String destination;
  final String departureDate;
  final String returnDate;
  final String status;
  final Color statusColor;
  final String buttonText;
  final Color buttonColor;
  final String description;

  brt_mobileCard({
    required this.source,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.status,
    required this.statusColor,
    required this.buttonText,
    required this.buttonColor,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flight_takeoff, color: AppColors.appColor),
                    SizedBox(width: 8.0),
                    Text('$source', style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(Icons.swap_horiz, color: AppColors.appColor), // Flèche aller-retour
                    Spacer(),
                    SizedBox(width: 8.0),
                    Text('$destination', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.appColor, size: 16.0),
                    SizedBox(width: 4.0),
                    Text('$departureDate'),
                    Spacer(),
                    SizedBox(width: 4.0),
                    Text('$returnDate'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Détails de la réservation'),
                          content: Text(description),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('FERMER'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
