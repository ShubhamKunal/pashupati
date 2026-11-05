import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/theme.dart';
import '../providers/tracking_provider.dart';

class LiveSosTrackingScreen extends ConsumerStatefulWidget {
  final String sosId;

  const LiveSosTrackingScreen({super.key, required this.sosId});

  @override
  ConsumerState<LiveSosTrackingScreen> createState() => _LiveSosTrackingScreenState();
}

class _LiveSosTrackingScreenState extends ConsumerState<LiveSosTrackingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _beaconController;

  @override
  void initState() {
    super.initState();
    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _beaconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingProviderFamily(widget.sosId));
    final notifier = ref.read(trackingProviderFamily(widget.sosId).notifier);
    final sos = trackingState.detail?.sos;

    return Scaffold(
      backgroundColor: PashupatiColors.ivoryCanvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _beaconController,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PashupatiColors.emergencyCoral,
                    boxShadow: [
                      BoxShadow(
                        color: PashupatiColors.emergencyCoral.withOpacity(0.6 * _beaconController.value),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              sos?.caseNumber ?? '#SOS-BLR-8921',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: PashupatiColors.darkForest,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: PashupatiColors.emergencyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                sos?.status == 'RESOLVED' ? 'RESOLVED' : 'Active Emergency',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PashupatiColors.emergencyRed),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: PashupatiColors.darkForest),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency dispatch link copied to clipboard.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // High-Priority Urgent Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sos?.status == 'RESOLVED' ? PashupatiColors.forestGreen : PashupatiColors.emergencyCoral,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (sos?.status == 'RESOLVED' ? PashupatiColors.forestGreen : PashupatiColors.emergencyCoral).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sos?.status == 'RESOLVED' ? 'MISSION COMPLETED' : 'PRIORITY TRIAGE ACTIVE',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sos?.status == 'RESOLVED' ? 'RESCUE RESOLVED' : 'RESPONDER EN ROUTE',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sos?.status != 'RESOLVED')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              '${sos?.primaryResponderEtaMinutes ?? 6} MINS',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Live Map Telematics & Trajectory Card
              Container(
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
                  children: [
                    // Simulated Interactive Map Canvas
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            color: Color(0xFFE5ECE8),
                          ),
                          child: CustomPaint(
                            painter: MapGridPainter(),
                          ),
                        ),
                        // Rescuer Bike Pin
                        Positioned(
                          left: 60,
                          top: 50,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PashupatiColors.forestGreen,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.two_wheeler_rounded, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Dr. Rohan (1.4 km)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.location_on, size: 28, color: PashupatiColors.forestGreen),
                            ],
                          ),
                        ),
                        // Distress Incident Pin
                        Positioned(
                          right: 70,
                          bottom: 40,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PashupatiColors.emergencyCoral,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                                  ],
                                ),
                                child: const Text('Incident Site', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              AnimatedBuilder(
                                animation: _beaconController,
                                builder: (context, child) {
                                  return Icon(
                                    Icons.location_on,
                                    size: 32 + (4 * _beaconController.value),
                                    color: PashupatiColors.emergencyCoral,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Telemetry Pill Overlay
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.near_me_rounded, size: 12, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  '1.4 km away • Smooth traffic',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Address and Directions bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: PashupatiColors.softGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.pin_drop_rounded, color: PashupatiColors.forestGreen, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sos?.address ?? 'Indiranagar 12th Main',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sos?.landmark ?? 'Near Corner House Ice Cream, 100ft Rd Corner',
                                  style: const TextStyle(fontSize: 12, color: PashupatiColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: PashupatiColors.surfaceElevation,
                              foregroundColor: PashupatiColors.darkForest,
                              minimumSize: const Size(0, 38),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.navigation_rounded, size: 16),
                            label: const Text('Directions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Assigned Primary Responder Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: PashupatiColors.softGreen,
                              backgroundImage: NetworkImage(
                                sos?.primaryResponderAvatar ??
                                    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=256&q=80',
                              ),
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
                                child: const Icon(Icons.verified, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sos?.primaryResponderName ?? 'Dr. Rohan Verma',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Verified Rescuer • 48 rescues completed',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PashupatiColors.forestGreen),
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                children: [
                                  Icon(Icons.volunteer_activism_rounded, size: 13, color: PashupatiColors.secondaryText),
                                  SizedBox(width: 4),
                                  Text(
                                    'Blue Cross Volunteer Partner',
                                    style: TextStyle(fontSize: 11, color: PashupatiColors.secondaryText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Aid loadout note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PashupatiColors.warmIvory,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: PashupatiColors.softGreen),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.medical_services_rounded, size: 18, color: PashupatiColors.forestGreen),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Contributing: Bringing first-aid kit & sterilized gauze, animal transport crate.',
                              style: TextStyle(fontSize: 12, color: PashupatiColors.darkForest, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Direct Action Buttons (Call / Chat)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: PashupatiColors.forestGreen,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () async {
                              final uri = Uri.parse('tel:${sos?.primaryResponderPhone ?? "+919876543211"}');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            icon: const Icon(Icons.call, size: 18),
                            label: const Text('Call Responder', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening secure in-app responder chat...')),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                            label: const Text('In-App Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Case Milestones Timeline (Vertical Live Stepper)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_toggle_off_rounded, color: PashupatiColors.forestGreen, size: 20),
                            SizedBox(width: 8),
                            Text('Case Milestones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest)),
                          ],
                        ),
                        Text('REAL-TIME LOG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: PashupatiColors.secondaryText)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Milestone Nodes
                    _buildMilestoneNode(
                      title: 'SOS Reported by you',
                      time: '11:42 AM',
                      description: 'Emergency alert filed with photo and pinpoint telemetry.',
                      isCompleted: true,
                    ),
                    _buildMilestoneNode(
                      title: 'Broadcasted to volunteers',
                      time: '11:43 AM',
                      description: 'Notified 18 certified volunteers within 3 km radius.',
                      isCompleted: true,
                    ),
                    _buildMilestoneNode(
                      title: 'Dr. Rohan dispatched',
                      time: '11:44 AM',
                      description: 'Responder en route on motorcycle. Estimated arrival 6 mins.',
                      isActive: sos?.status != 'RESOLVED',
                      isCompleted: sos?.status == 'RESOLVED',
                    ),
                    _buildMilestoneNode(
                      title: 'Arrival & Treatment / Transport',
                      time: sos?.status == 'RESOLVED' ? '11:55 AM' : 'Pending',
                      description: 'Clinical triage on-site followed by stabilization.',
                      isLast: true,
                      isCompleted: sos?.status == 'RESOLVED',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Operational Safeguards & Actions
              if (sos?.status != 'RESOLVED') ...[
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: PashupatiColors.forestGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: trackingState.isActionInProgress
                      ? null
                      : () async {
                          final success = await notifier.markAssistanceReceived();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('🎉 Rescue successfully resolved! Thank you for saving a life.')),
                            );
                          }
                        },
                  icon: const Icon(Icons.task_alt_rounded),
                  label: const Text('Mark Assistance Received', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Update situation dialog opened.')),
                    );
                  },
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Update Situation / Add Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _confirmCancel(context, notifier),
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: PashupatiColors.emergencyCoral),
                    label: const Text(
                      'CANCEL SOS REQUEST',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: PashupatiColors.emergencyCoral),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PashupatiColors.softGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '🎉 Rescue Completed and Animal Stabilized',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: PashupatiColors.forestGreen),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneNode({
    required String title,
    required String time,
    required String description,
    bool isCompleted = false,
    bool isActive = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator column with connecting vertical line
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? PashupatiColors.forestGreen
                      : (isActive ? PashupatiColors.emergencyCoral : Colors.white),
                  border: Border.all(
                    color: isCompleted
                        ? PashupatiColors.forestGreen
                        : (isActive ? PashupatiColors.emergencyCoral : PashupatiColors.outlineVariant),
                    width: 3,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    color: isCompleted ? PashupatiColors.forestGreen : PashupatiColors.outlineVariant.withOpacity(0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isCompleted || isActive ? PashupatiColors.darkForest : PashupatiColors.secondaryText,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PashupatiColors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: PashupatiColors.secondaryText, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, TrackingNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel SOS Request?'),
        content: const Text(
          'Are you sure you want to cancel this emergency? Responders currently en route will be notified immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Active'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PashupatiColors.emergencyCoral),
            onPressed: () async {
              Navigator.pop(ctx);
              await notifier.cancelSos('Animal no longer in distress / false alarm');
            },
            child: const Text('Yes, Cancel SOS'),
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4DDD7)
      ..strokeWidth = 2.0;

    // Draw stylized road networks
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.6), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.7, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.3), paint);

    // Minor path
    final minorPaint = Paint()
      ..color = const Color(0xFFC7D4CB)
      ..strokeWidth = 4.0;
    canvas.drawLine(Offset(60, 50), Offset(size.width - 70, size.height - 40), minorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

