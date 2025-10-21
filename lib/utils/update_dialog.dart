import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showUpdateDialog(BuildContext context, {
  required String description,
  required String appLink,
  required bool mandatory,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: !mandatory, // Can't dismiss if mandatory
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => !mandatory, // Disable back button if mandatory
        child: CupertinoAlertDialog(
          title: Row(
            children: const [
              Icon(Icons.system_update, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text('Update Available'),
            ],
          ),
          content: Text(description, style: const TextStyle(fontSize: 15)),
          actions: [
            if (!mandatory)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip'),
              ),
            TextButton(
              onPressed: () async {
                if (appLink.isNotEmpty && await canLaunchUrl(Uri.parse(appLink))) {
                  await launchUrl(Uri.parse(appLink), mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid update link')),
                  );
                }
              },

              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    },
  );
}
