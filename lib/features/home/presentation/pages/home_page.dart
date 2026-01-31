import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/segmented_tab_header.dart';
import 'nearby_tab.dart';
import 'discover_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSaveLocation();
    });
  }

  Future<void> _checkAndSaveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateLocation(
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            SegmentedTabHeader(
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              onNotificationTap: () {
                // TODO: Navigate to notifications
              },
            ),
            // Tab Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTabIndex == 0
                    ? const NearbyTab(key: ValueKey('nearby'))
                    : const DiscoverTab(key: ValueKey('discover')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
