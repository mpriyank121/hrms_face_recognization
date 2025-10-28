import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrms_face_recognization/screens/controllers/app_controller.dart';
import 'package:hrms_face_recognization/screens/controllers/location_controller.dart';
import 'package:hrms_face_recognization/screens/face_detection/face_detection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrms_face_recognization/screens/wlecome_page.dart';
import 'package:hrms_face_recognization/utils/custom_splash_screen.dart';
import 'package:hrms_face_recognization/utils/dio_client.dart';

import 'config/theme.dart';

// 🚀 Entry Point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AppController(), permanent: true);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    debugPrint('Initializing Firebase...');
    await DioClient().initialize();
    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  _initializeControllers();

  runApp(const MyApp());
}

void _initializeControllers() {
  Get.put(LocationController(), permanent: true);
}

// 🧩 Main App
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        // Force textScaleFactor = 1.0 (ignore system scaling)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.white,
          circularTrackColor: Colors.deepOrange,
        ),
      ),
      debugShowCheckedModeBanner: false,

      // 🔹 Always start with splash screen
      initialRoute: '/splash',

      getPages: [
        GetPage(name: '/face', page: () => FaceDetectionScreen(orgId: '')),
        GetPage(name: '/splash', page: () => CustomSplashScreen()),
        GetPage(name: '/welcome', page: () => WelcomePage()),
      ],
    );
  }
}