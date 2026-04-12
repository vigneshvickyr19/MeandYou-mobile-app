import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileSetupLoading extends StatefulWidget {
  const ProfileSetupLoading({super.key});

  @override
  State<ProfileSetupLoading> createState() => _ProfileSetupLoadingState();
}

class _ProfileSetupLoadingState extends State<ProfileSetupLoading> {
  final List<String> _loadingTexts = [
    "Setting up your profile...",
    "Optimizing your photos...",
    "Securing your data...",
    "Personalizing your experience...",
    "Almost there...",
  ];

  late final Stream<int> _textStream;

  @override
  void initState() {
    super.initState();
    _textStream = Stream.periodic(const Duration(seconds: 2), (i) => (i + 1) % _loadingTexts.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Background ambient glow
          Center(
            child: FadeIn(
              duration: const Duration(seconds: 2),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Pulse Loader
                Pulse(
                  infinite: true,
                  duration: const Duration(milliseconds: 1500),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Animated Text Switcher
                StreamBuilder<int>(
                  stream: _textStream,
                  initialData: 0,
                  builder: (context, snapshot) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _loadingTexts[snapshot.data ?? 0],
                        key: ValueKey<int>(snapshot.data ?? 0),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                
                FadeIn(
                  delay: const Duration(seconds: 1),
                  child: Text(
                    "This might take a few seconds",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
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
