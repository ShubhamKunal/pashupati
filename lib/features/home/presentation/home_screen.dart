import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/models/organization_model.dart';
import '../../../shared/models/sos_model.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: PashupatiColors.ivoryCanvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: PashupatiColors.forestGreen,
          onRefresh: () => ref.read(homeNotifierProvider.notifier).loadHomeData(),
          child: CustomScrollView(
            slivers: [
              // Sticky Header Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Pashupati Brand + Pin
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: PashupatiColors.softGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: PashupatiColors.forestGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'Pashupati',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: PashupatiColors.darkForest,
                                  letterSpacing: -0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right: BLR Dispatch Live & Notifications
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: PashupatiColors.emergencyCoral,
                                        boxShadow: [
                                          BoxShadow(
                                            color: PashupatiColors.emergencyCoral.withOpacity(0.5 * _pulseController.value),
                                            blurRadius: 6,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'BLR DISPATCH LIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: PashupatiColors.darkForest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => context.push('/notifications'),
                            icon: Stack(
                              children: [
                                const Icon(Icons.notifications_none_rounded, color: PashupatiColors.darkForest, size: 26),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: PashupatiColors.emergencyCoral,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Responder Profile & Micro-Location Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: PashupatiColors.softGreen,
                                  child: const Icon(Icons.person, color: PashupatiColors.forestGreen, size: 24),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: PashupatiColors.forestGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified, size: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Namaste, ${authState.user?.name ?? 'Aarav'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: PashupatiColors.darkForest,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: homeState.isResponderActive
                                              ? PashupatiColors.forestGreen
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          homeState.isResponderActive
                                              ? 'Verified First Responder'
                                              : 'Responder Inactive',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: homeState.isResponderActive
                                                ? PashupatiColors.forestGreen
                                                : PashupatiColors.secondaryText,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.tune_rounded, color: PashupatiColors.secondaryText),
                              onPressed: () => ref.read(homeNotifierProvider.notifier).toggleResponderStatus(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Geotag Lock Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: PashupatiColors.warmIvory,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.near_me_rounded, color: PashupatiColors.mossGreen, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  homeState.location.formattedAddress,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: PashupatiColors.darkForest,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: PashupatiColors.forestGreen,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 16, color: PashupatiColors.forestGreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Level 4 Emergency SOS Trigger (Centerpiece Hero)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: PashupatiColors.emergencyCoral.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'EMERGENCY DISPATCH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: PashupatiColors.emergencyCoral,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'An animal needs help?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: PashupatiColors.darkForest,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'We mobilize nearest volunteers & medics immediately.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: PashupatiColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Giant 176px circular tactile push button with concentric glow ripples
                        GestureDetector(
                          onTap: () => context.push('/sos/create'),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Ripple 2
                                  Container(
                                    width: 220 + (14 * _pulseController.value),
                                    height: 220 + (14 * _pulseController.value),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PashupatiColors.emergencyCoral.withOpacity(0.08 * (1.0 - _pulseController.value)),
                                    ),
                                  ),
                                  // Outer Ripple 1
                                  Container(
                                    width: 196 + (10 * _pulseController.value),
                                    height: 196 + (10 * _pulseController.value),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PashupatiColors.emergencyCoral.withOpacity(0.15 * (1.0 - _pulseController.value)),
                                    ),
                                  ),
                                  // Main SOS Button
                                  Container(
                                    width: 172,
                                    height: 172,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Color(0xFFD96B58), Color(0xFFBA4836)],
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFFFDAD6).withOpacity(0.8),
                                        width: 5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFBA1A1A).withOpacity(0.42),
                                          blurRadius: 28,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.18),
                                          ),
                                          child: const Icon(
                                            Icons.crisis_alert_rounded,
                                            size: 32,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'REPORT ANIMAL SOS',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          '1-Tap Immediate Dispatch',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Secondary Quick Triggers Chips
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: PashupatiColors.surfaceElevation,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt, size: 16, color: PashupatiColors.darkForest),
                                  SizedBox(width: 4),
                                  Text(
                                    'Alerts in < 30s',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PashupatiColors.darkForest),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => context.push('/sos/create'),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: PashupatiColors.softGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_camera_rounded, size: 16, color: PashupatiColors.forestGreen),
                                    SizedBox(width: 4),
                                    Text(
                                      '1-Tap Fast Photo Report',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PashupatiColors.forestGreen),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Community Rescue Pulse Tile
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: PashupatiColors.softGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.health_and_safety_rounded, color: PashupatiColors.forestGreen, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '3 Active Rescues Nearby',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                '1 Responder currently en route to 100ft Road',
                                style: TextStyle(fontSize: 12, color: PashupatiColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PashupatiColors.secondaryText),
                      ],
                    ),
                  ),
                ),
              ),

              // Active Critical Incidents Feed Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Critical Incidents',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: PashupatiColors.emergencyLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${homeState.incidents.length} Live',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: PashupatiColors.emergencyRed),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/explore'),
                        child: const Text('Map View', style: TextStyle(color: PashupatiColors.forestGreen, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),

              // Incident Cards List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = homeState.incidents[index];
                    return _buildIncidentCard(context, item);
                  },
                  childCount: homeState.incidents.length,
                ),
              ),

              // Emergency Trauma Center (24/7) Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Emergency Trauma Centers',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: PashupatiColors.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Verified 24/7',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PashupatiColors.forestGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Trauma Centers List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final center = homeState.emergencyCenters[index];
                    return _buildHospitalCard(context, center);
                  },
                  childCount: homeState.emergencyCenters.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, SosRequest item) {
    final isEnRoute = item.status == 'HELP_ARRIVING' || item.status == 'RESPONDING';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Image.network(
                  item.media.isNotEmpty
                      ? item.media.first.url
                      : 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: PashupatiColors.surfaceElevation,
                    child: const Icon(Icons.pets, size: 48, color: PashupatiColors.secondaryText),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEnRoute ? PashupatiColors.saffron : PashupatiColors.emergencyCoral,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isEnRoute ? 'En Route' : 'Seeking Help',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.formattedDistance.isNotEmpty ? item.formattedDistance : '450m away',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.emergencyType.toLowerCase().capitalize()} ${item.animalType.toLowerCase().capitalize()}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description ?? item.address,
                  style: const TextStyle(fontSize: 13, color: PashupatiColors.secondaryText, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Meta row
                Row(
                  children: [
                    const Icon(Icons.groups_rounded, size: 16, color: PashupatiColors.forestGreen),
                    const SizedBox(width: 5),
                    Text(
                      isEnRoute ? 'Dr. Rohan en route (6m)' : 'Needed: Transport & Kit',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PashupatiColors.forestGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: PashupatiColors.forestGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => context.push('/sos/track/${item.id}'),
                        child: Text(isEnRoute ? 'View Live Tracking' : 'I Can Assist'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(BuildContext context, Organization center) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PashupatiColors.softGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: PashupatiColors.forestGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      center.description ?? 'Veterinary Trauma Care',
                      style: const TextStyle(fontSize: 12, color: PashupatiColors.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PashupatiColors.softGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  center.is247 ? 'Open 24/7' : 'Day Shift',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PashupatiColors.forestGreen),
                ),
              ),
              Text(
                center.formattedDistance.isNotEmpty ? center.formattedDistance : '2.4 km away',
                style: const TextStyle(fontSize: 12, color: PashupatiColors.secondaryText),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: PashupatiColors.emergencyCoral,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final uri = Uri.parse('tel:${center.emergencyPhone ?? center.phone}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call Emergency', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
