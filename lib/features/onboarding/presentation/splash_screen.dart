import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../authentication/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        final authState = ref.read(authNotifierProvider);
        if (authState.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/home'); // Allow browsing directly per requirement
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PashupatiColors.darkForest,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient glowing backdrop
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PashupatiColors.forestGreen.withOpacity(0.4),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PashupatiColors.saffron.withOpacity(0.12),
              ),
            ),
          ),

          // Main Hero Center Unit
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                // Center Identity Emblem & Wordmark
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tactile Logo Badge Container
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Tactile Disc
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: PashupatiColors.forestGreen.withOpacity(0.85),
                            border: Border.all(
                              color: PashupatiColors.mossGreen.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/branding/app_logo.png',
                              width: 108,
                              height: 108,
                            ),
                          ),
                        ),
                        // Micro-Accent Civic Duty Beacon Badge
                        Positioned(
                          right: 4,
                          top: 4,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: PashupatiColors.saffronLight,
                                  border: Border.all(
                                    color: PashupatiColors.darkForest,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: PashupatiColors.saffron.withOpacity(0.6 * _pulseController.value),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PashupatiColors.saffronDark,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Wordmark & Identity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'PASHUPATI',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6.0,
                            color: PashupatiColors.ivoryCanvas,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, bottom: 4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: PashupatiColors.saffron,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Provenance Ribbon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: PashupatiColors.forestGreen.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: PashupatiColors.softGreen.withOpacity(0.1),
                        ),
                      ),
                      child: const Text(
                        'STREET ANIMAL CARE & TRIAGE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                          color: PashupatiColors.softGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tagline
                    const Text(
                      'Be the reason a life survives.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: PashupatiColors.ivoryCanvas,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Loading Stepping Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final delay = (index * 0.33);
                            final val = (_pulseController.value + delay) % 1.0;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: PashupatiColors.softGreen.withOpacity(0.3 + (val * 0.7)),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),

                // Footer Trust Badge
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: PashupatiColors.forestGreen.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: PashupatiColors.softGreen.withOpacity(0.15),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: PashupatiColors.saffron,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Powered by Community & Verified Responders',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: PashupatiColors.ivoryCanvas,
                          ),
                        ),
                      ],
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

