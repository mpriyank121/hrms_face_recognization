import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_face_recognization/utils/update_dialog.dart';
import 'package:hrms_face_recognization/utils/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/face_detection/service/module_service.dart';


class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _loadingController;

  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;

  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textScaleAnimation;

  late Animation<double> _backgroundFadeAnimation;
  late Animation<double> _loadingAnimation;

  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _initApp();
  }

  void _setupAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    _textScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeIn,
    ));

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Start background first
    _backgroundController.forward();

    // Logo animation starts immediately
    _logoController.forward();

    // Text animation starts after a delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // Show loading indicator after animations
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _showLoading = true;
        });
        _loadingController.repeat();
      }
    });
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    print("🚀 Starting app initialization...");

    try {
      print("🔍 Checking app version...");
      final isAiFaceEnabled = await ModuleService.fetchOrganizationModules();
      final versionResult = await CheckAppVersionService.checkAppVersion();
      if (versionResult != null && versionResult['check'] == 1) {
        final mandatory = versionResult['mandatory'] == '1';
        final description = versionResult['description'] ?? 'New update available';
        final appLink = versionResult['app_link'] ?? '';

        // Show update dialog
        if (mounted) {
          await showUpdateDialog(
            context,
            description: description,
            appLink: appLink,
            mandatory: mandatory,
          );
        }

        // If mandatory, stop further navigation
        if (mandatory) return;
      }

      print("🔍 Checking login status...");

      // Check login status
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print("✅ Login check completed - isLoggedIn: $isLoggedIn");

      if (!mounted) return;

      // Play exit animations
      await _exitAnimation();

      // Navigate
      if (mounted) {
        if (isLoggedIn) {
          print("📱 Navigating to Face Detection screen...");
          Get.offAllNamed('/face');
        } else {
          print("📱 Navigating to Welcome screen...");
          Get.offAllNamed('/welcome');
        }
      }
    } catch (e) {
      print("❌ Error in app initialization: $e");
      if (mounted) {
        await _exitAnimation();
        Get.offAllNamed('/welcome');
      }
    }
  }


  Future<void> _exitAnimation() async {
    _loadingController.stop();
    await Future.wait([
      _logoController.reverse(),
      _textController.reverse(),
    ]);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(_backgroundFadeAnimation.value),
                  Colors.grey.shade50.withOpacity(_backgroundFadeAnimation.value * 0.5),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  SlideTransition(
                    position: _logoSlideAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/splash_icon.png',
                            height: 120,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Animated Text Logo
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: ScaleTransition(
                      scale: _textScaleAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Image.asset(
                          'assets/images/splash_heading.png',
                          height: 60,
                          width: 180,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Animated Loading Indicator
                  AnimatedOpacity(
                    opacity: _showLoading ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        // Custom animated loading dots
                        AnimatedBuilder(
                          animation: _loadingAnimation,
                          builder: (context, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final delay = index * 0.2;
                                final animationValue = (_loadingAnimation.value - delay).clamp(0.0, 1.0);
                                final scale = 1.0 + (0.5 * (1.0 - (animationValue - 0.5).abs() * 2));

                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Loading text with fade animation
                        FadeTransition(
                          opacity: _loadingAnimation,
                          child: Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}