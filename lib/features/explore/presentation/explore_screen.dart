import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/models/organization_model.dart';
import '../../home/providers/home_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedCategory = 'ALL';
  bool _only247 = false;

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final allOrgs = homeState.emergencyCenters;

    final filteredOrgs = allOrgs.where((org) {
      if (_only247 && !org.is247) return false;
      if (_selectedCategory == 'ALL') return true;
      if (_selectedCategory == 'VET' && org.orgType == 'VET_HOSPITAL') return true;
      if (_selectedCategory == 'NGO' && org.orgType == 'NGO') return true;
      if (_selectedCategory == 'SHELTER' && org.orgType == 'SHELTER') return true;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: PashupatiColors.ivoryCanvas,
      appBar: AppBar(
        title: const Text('Animal-Care Directory'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Centers', 'ALL'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Vet Hospitals', 'VET'),
                    const SizedBox(width: 8),
                    _buildFilterChip('NGOs & Rescuers', 'NGO'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Shelters', 'SHELTER'),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('24/7 Emergency Only'),
                      selected: _only247,
                      onSelected: (val) => setState(() => _only247 = val),
                      selectedColor: PashupatiColors.emergencyCoral,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _only247 ? Colors.white : PashupatiColors.darkForest,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: filteredOrgs.isEmpty
                  ? const Center(
                      child: Text('No animal care centers match your filter.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      itemCount: filteredOrgs.length,
                      itemBuilder: (context, index) {
                        final org = filteredOrgs[index];
                        return _buildOrgCard(context, org);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String code) {
    final isSelected = _selectedCategory == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategory = code),
      selectedColor: PashupatiColors.forestGreen,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : PashupatiColors.darkForest,
      ),
    );
  }

  Widget _buildOrgCard(BuildContext context, Organization org) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PashupatiColors.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PashupatiColors.softGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  org.orgType == 'VET_HOSPITAL'
                      ? Icons.local_hospital_rounded
                      : (org.orgType == 'SHELTER' ? Icons.night_shelter_rounded : Icons.pets_rounded),
                  color: PashupatiColors.forestGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      org.description ?? org.address,
                      style: const TextStyle(fontSize: 12, color: PashupatiColors.secondaryText, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: org.is247 ? PashupatiColors.softGreen : PashupatiColors.surfaceElevation,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  org.is247 ? 'Open 24/7' : (org.operatingHours ?? 'Day Shift'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: org.is247 ? PashupatiColors.forestGreen : PashupatiColors.darkForest,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                org.formattedDistance.isNotEmpty ? org.formattedDistance : 'Indiranagar',
                style: const TextStyle(fontSize: 12, color: PashupatiColors.secondaryText),
              ),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: PashupatiColors.forestGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final uri = Uri.parse('tel:${org.emergencyPhone ?? org.phone}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

