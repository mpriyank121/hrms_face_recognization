import 'package:flutter/material.dart';

import '../../config/style.dart';

class EmptyStateWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const EmptyStateWidget({
    super.key,
    required this.imagePath,
    this.title = "Empty",
    this.subtitle = "You haven't added departments and employees yet.",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style:  fontStyles.headingStyle
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style:fontStyles.subTextStyle
          ),
        ],
      ),
    );
  }
}
