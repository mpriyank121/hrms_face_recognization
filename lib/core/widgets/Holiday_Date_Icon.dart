import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HolidayDateIcon extends StatelessWidget {
  final String holidayDate; // Format: "yyyy-MM-dd"

  HolidayDateIcon({required this.holidayDate});

  @override
  Widget build(BuildContext context) {
    DateTime date = DateFormat("yyyy-MM-dd").parse(holidayDate);
    String month = DateFormat("MMM").format(date); // "Jan", "Feb", etc.
    String day = DateFormat("d").format(date); // "1", "2", etc.

    return Container(
      width: 50, // Adjust size as needed
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFFF25922), // Header background color
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4),
            color: Color(0xFFF25922), // Top background
            child: Text(
              month.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFE6E6E6),
              alignment: Alignment.center,
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
