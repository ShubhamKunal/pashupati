import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../authentication/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  double _radiusKm = 5.0;
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: PashupatiColors.ivoryCanvas,
      appBar: AppBar(
        title: const Text('Volunteer Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: PashupatiColors.softGreen,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=256&q=80',
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: PashupatiColors.forestGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Aarav Sharma',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.phone ?? '+91 98765 43210',
                            style: const TextStyle(fontSize: 13, color: PashupatiColors.secondaryText),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: PashupatiColors.softGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Verified First Responder • 23 Rescues',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PashupatiColors.forestGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Responder Availability Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available for Emergency Dispatch', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Receive high-priority nearby alerts', style: TextStyle(fontSize: 12, color: PashupatiColors.secondaryText)),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      activeColor: PashupatiColors.forestGreen,
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Response Radius Slider
              Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Notification Radius', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('${_radiusKm.round()} km', style: const TextStyle(fontWeight: FontWeight.w800, color: PashupatiColors.forestGreen)),
                      ],
                    ),
                    Slider(
                      value: _radiusKm,
                      min: 1.0,
                      max: 25.0,
                      divisions: 24,
                      activeColor: PashupatiColors.forestGreen,
                      onChanged: (val) => setState(() => _radiusKm = val),
                    ),
                    const Text('You will be notified for cases occurring within this distance.', style: TextStyle(fontSize: 11, color: PashupatiColors.secondaryText)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Volunteer Capabilities
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registered Assistance Capabilities', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('First-Aid Kit'), avatar: Icon(Icons.medical_services_rounded, size: 16)),
                        Chip(label: Text('Two-Wheeler Transport'), avatar: Icon(Icons.two_wheeler_rounded, size: 16)),
                        Chip(label: Text('Physical Aid'), avatar: Icon(Icons.handyman_rounded, size: 16)),
                        Chip(label: Text('Dog Triage'), avatar: Icon(Icons.pets, size: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Animal Safety Guidelines Banner (Prompt Requirement 11)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PashupatiColors.warmIvory,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PashupatiColors.saffron),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_rounded, color: PashupatiColors.saffron, size: 20),
                        SizedBox(width: 8),
                        Text('Emergency Safety Advisory', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: PashupatiColors.darkForest)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Do not approach an aggressive or frightened animal directly.\n• Never put yourself in traffic danger.\n• Avoid moving animals with suspected spinal injuries.\n• Pashupati facilitates citizen rescue and does not replace professional veterinary surgery.',
                      style: TextStyle(fontSize: 12, color: PashupatiColors.darkForest, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (authState.isAuthenticated) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PashupatiColors.emergencyCoral,
                    side: const BorderSide(color: PashupatiColors.emergencyCoral),
                  ),
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) context.go('/home');
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: () => context.push('/auth'),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Log In / Register as Rescuer'),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

