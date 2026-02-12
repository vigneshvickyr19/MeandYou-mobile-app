import 'package:flutter/material.dart';
import '../../../../core/providers/location_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../controllers/location_permission_controller.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> with TickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _pulseController;
  late AnimationController _entranceController;
  
  late Animation<double> _titleOpacity;
  late Animation<double> _descOpacity;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slower, more 'breathing' pulse
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Title: 0.2 to 0.6 of duration
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 0.5, curve: Curves.easeOut))
    );

    // Description: 0.3 to 0.7 of duration
    _descOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 0.7, curve: Curves.easeOut))
    );

    // Buttons: 0.5 to 1.0 of duration
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut))
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _handleEnableLocation() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      final controller = LocationPermissionController();
      final success = await controller.requestLocationPermission(context);
      
      if (!mounted) return;

      if (success) {
        await context.read<LocationProvider>().refreshStatus();
        if (!mounted) return;

        final String? routeName = ModalRoute.of(context)?.settings.name;
        if (routeName == AppRoutes.locationPermission) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Error in _handleEnableLocation: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient with Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF121212),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Radar Illustration
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (int i = 1; i <= 3; i++)
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final value = (_pulseController.value + (i * 0.33)) % 1.0;
                              return Container(
                                width: 100 + (value * 150),
                                height: 100 + (value * 150),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: (1 - value) * 0.15),
                                    width: 1.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        Container(
                          padding: const EdgeInsets.all(35),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Staggered Entrance Elements
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: const Text(
                      'See Who\'s Nearby',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  FadeTransition(
                    opacity: _descOpacity,
                    child: Text(
                      'Enable your location to discover people in your area. Your distance is shown, but your exact path stays private.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const Spacer(),

                  FadeTransition(
                    opacity: _buttonOpacity,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _handleEnableLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'ENABLE LOCATION',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => _showRequiredDialog(),
                          child: Text(
                            'SKIP FOR NOW',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('Location Required', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
          'Nearby matching is the soul of this app. Without location, discovery won\'t work.',
          style: TextStyle(color: Colors.white60, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I UNDERSTAND', 
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}
