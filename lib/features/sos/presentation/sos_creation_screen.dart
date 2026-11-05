import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../providers/sos_provider.dart';

class SosCreationScreen extends ConsumerStatefulWidget {
  const SosCreationScreen({super.key});

  @override
  ConsumerState<SosCreationScreen> createState() => _SosCreationScreenState();
}

class _SosCreationScreenState extends ConsumerState<SosCreationScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _landmarkController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final sosState = ref.read(sosCreationProvider);
    _landmarkController = TextEditingController(text: sosState.landmarkNotes);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosCreationProvider);
    final notifier = ref.read(sosCreationProvider.notifier);

    return Scaffold(
      backgroundColor: PashupatiColors.ivoryCanvas,
      appBar: AppBar(
        title: const Text('Report Animal Emergency'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => _handlePublish(context),
              style: TextButton.styleFrom(
                backgroundColor: PashupatiColors.softGreen,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Fast Submit',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: PashupatiColors.forestGreen),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Bar (Step 2 of 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: PashupatiColors.ivoryCanvas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Step 2 of 3 • Animal & Situation',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PashupatiColors.darkForest),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: PashupatiColors.softGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('66%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PashupatiColors.forestGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.66,
                      minHeight: 4,
                      backgroundColor: PashupatiColors.surfaceElevation,
                      valueColor: AlwaysStoppedAnimation<Color>(PashupatiColors.forestGreen),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Location Pin Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PashupatiColors.forestGreen.withOpacity(0.2)),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_on, color: PashupatiColors.forestGreen, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: PashupatiColors.forestGreen,
                                            boxShadow: [
                                              BoxShadow(
                                                color: PashupatiColors.forestGreen.withOpacity(0.6 * _pulseController.value),
                                                blurRadius: 4,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    const Flexible(
                                      child: Text(
                                        'LIVE GPS LOCKED (±5m)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: PashupatiColors.forestGreen,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  sosState.location.formattedAddress,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PashupatiColors.darkForest),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_location_alt_rounded, size: 16, color: PashupatiColors.forestGreen),
                            label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PashupatiColors.forestGreen)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 1: Animal Category (5-Column Grid)
                    const Text(
                      '1. Animal Category',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildAnimalCard('Dog', 'DOG', Icons.pets_rounded, sosState.selectedAnimal == 'DOG', () => notifier.selectAnimal('DOG')),
                          const SizedBox(width: 8),
                          _buildAnimalCard('Cat', 'CAT', Icons.cruelty_free_rounded, sosState.selectedAnimal == 'CAT', () => notifier.selectAnimal('CAT')),
                          const SizedBox(width: 8),
                          _buildAnimalCard('Cattle', 'CATTLE', Icons.agriculture_rounded, sosState.selectedAnimal == 'CATTLE', () => notifier.selectAnimal('CATTLE')),
                          const SizedBox(width: 8),
                          _buildAnimalCard('Bird', 'BIRD', Icons.flutter_dash_rounded, sosState.selectedAnimal == 'BIRD', () => notifier.selectAnimal('BIRD')),
                          const SizedBox(width: 8),
                          _buildAnimalCard('Other', 'OTHER', Icons.category_rounded, sosState.selectedAnimal == 'OTHER', () => notifier.selectAnimal('OTHER')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Emergency Situation (Triage Mode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            '2. Emergency Situation',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: PashupatiColors.emergencyLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 14, color: PashupatiColors.emergencyRed),
                              SizedBox(width: 4),
                              Text('Triage Mode', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: PashupatiColors.emergencyRed)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSituationChip(
                          label: 'Road Accident / Hit & Run',
                          code: 'ROAD_ACCIDENT',
                          isSelected: sosState.selectedEmergency == 'ROAD_ACCIDENT',
                          isDanger: true,
                          onTap: () => notifier.selectEmergency('ROAD_ACCIDENT'),
                        ),
                        _buildSituationChip(
                          label: 'Injured / Bleeding',
                          code: 'INJURED',
                          isSelected: sosState.selectedEmergency == 'INJURED',
                          isDanger: true,
                          onTap: () => notifier.selectEmergency('INJURED'),
                        ),
                        _buildSituationChip(
                          label: 'Trapped / In Danger',
                          code: 'TRAPPED',
                          isSelected: sosState.selectedEmergency == 'TRAPPED',
                          onTap: () => notifier.selectEmergency('TRAPPED'),
                        ),
                        _buildSituationChip(
                          label: 'Abandoned / Sick',
                          code: 'ABANDONED',
                          isSelected: sosState.selectedEmergency == 'ABANDONED',
                          onTap: () => notifier.selectEmergency('ABANDONED'),
                        ),
                        _buildSituationChip(
                          label: 'Extreme Abuse',
                          code: 'EXTREME_ABUSE',
                          isSelected: sosState.selectedEmergency == 'EXTREME_ABUSE',
                          onTap: () => notifier.selectEmergency('EXTREME_ABUSE'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section 3: Photo / Evidence Upload
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            '3. Photo / Evidence Upload',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '1 photo + 1 voice note',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PashupatiColors.secondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: PashupatiColors.softGreen,
                                    child: const Icon(Icons.pets, color: PashupatiColors.forestGreen),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle, size: 16, color: PashupatiColors.forestGreen),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'photo_stray_dog_indira.jpg',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: PashupatiColors.softGreen,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Paw injury visible', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PashupatiColors.forestGreen)),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_a_photo_rounded, color: PashupatiColors.forestGreen),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          // Voice memo bar
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: PashupatiColors.softGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.graphic_eq_rounded, color: PashupatiColors.forestGreen, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Voice memo attached (12s)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PashupatiColors.darkForest)),
                                    Text('"Dog is calm, breathing normally"', style: TextStyle(fontSize: 11, color: PashupatiColors.secondaryText)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.play_circle_fill_rounded, color: PashupatiColors.forestGreen, size: 28),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 4: What is needed immediately?
                    const Text(
                      '4. What is needed immediately?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildRequirementChip('First-aid supplies', 'FIRST_AID', sosState.selectedRequirements.contains('FIRST_AID'), () => notifier.toggleRequirement('FIRST_AID')),
                        _buildRequirementChip('Transportation to clinic', 'TRANSPORTATION', sosState.selectedRequirements.contains('TRANSPORTATION'), () => notifier.toggleRequirement('TRANSPORTATION')),
                        _buildRequirementChip('Physical assistance', 'PHYSICAL_ASSISTANCE', sosState.selectedRequirements.contains('PHYSICAL_ASSISTANCE'), () => notifier.toggleRequirement('PHYSICAL_ASSISTANCE')),
                        _buildRequirementChip('Temporary shelter', 'TEMPORARY_SHELTER', sosState.selectedRequirements.contains('TEMPORARY_SHELTER'), () => notifier.toggleRequirement('TEMPORARY_SHELTER')),
                        _buildRequirementChip('Animal carrier', 'CARRIER', sosState.selectedRequirements.contains('CARRIER'), () => notifier.toggleRequirement('CARRIER')),
                        _buildRequirementChip('Not sure', 'UNSURE', sosState.selectedRequirements.contains('UNSURE'), () => notifier.toggleRequirement('UNSURE')),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section 5: Field Landmark / Clues
                    const Text(
                      '5. Field Landmark / Clues (Optional)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _landmarkController,
                      maxLines: 3,
                      onChanged: (val) => notifier.setLandmarkNotes(val),
                      decoration: const InputDecoration(
                        hintText: 'Describe exact spot (e.g. under tea stall, next to pharmacy)...',
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Community Radar Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: PashupatiColors.softGreen),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.radar_rounded, color: PashupatiColors.forestGreen, size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('14 active volunteers within 2.5 km', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PashupatiColors.darkForest)),
                                Text('Live Radar active • Immediate notification broadcast', style: TextStyle(fontSize: 11, color: PashupatiColors.secondaryText)),
                              ],
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: PashupatiColors.forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Action Bar
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: PashupatiColors.emergencyCoral,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: sosState.isSubmitting ? null : () => _handlePublish(context),
                      icon: sosState.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.crisis_alert_rounded, size: 22),
                      label: Text(
                        sosState.isSubmitting ? 'BROADCASTING RESCUE ALERT...' : 'PUBLISH SOS ALERT NOW',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active_rounded, size: 14, color: PashupatiColors.secondaryText),
                          SizedBox(width: 4),
                          Text('Notifies 14 nearby rescuers', style: TextStyle(fontSize: 11, color: PashupatiColors.secondaryText)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded, size: 14, color: PashupatiColors.secondaryText),
                          SizedBox(width: 4),
                          Text('Phone masked for privacy', style: TextStyle(fontSize: 11, color: PashupatiColors.secondaryText)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalCard(String label, String code, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? PashupatiColors.forestGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? PashupatiColors.forestGreen : PashupatiColors.outlineVariant.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: PashupatiColors.forestGreen.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : PashupatiColors.darkForest, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : PashupatiColors.darkForest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSituationChip({
    required String label,
    required String code,
    required bool isSelected,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: isDanger ? PashupatiColors.emergencyCoral : PashupatiColors.forestGreen,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isSelected ? Colors.white : PashupatiColors.darkForest,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? (isDanger ? PashupatiColors.emergencyCoral : PashupatiColors.forestGreen)
              : PashupatiColors.outlineVariant.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildRequirementChip(String label, String code, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: PashupatiColors.forestGreen,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : PashupatiColors.darkForest,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? PashupatiColors.forestGreen : PashupatiColors.outlineVariant.withOpacity(0.4),
        ),
      ),
    );
  }

  Future<void> _handlePublish(BuildContext context) async {
    final sos = await ref.read(sosCreationProvider.notifier).publishSos();
    if (sos != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚨 SOS Alert ${sos.caseNumber} broadcasted to nearby responders!'),
          backgroundColor: PashupatiColors.forestGreen,
        ),
      );
      context.go('/sos/track/${sos.id}');
    }
  }
}
