import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../home/providers/home_provider.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final incidents = homeState.incidents;

    return Scaffold(
      backgroundColor: PashupatiColors.ivoryCanvas,
      appBar: AppBar(
        title: const Text('My Rescue Activity'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: PashupatiColors.forestGreen,
          unselectedLabelColor: PashupatiColors.secondaryText,
          indicatorColor: PashupatiColors.forestGreen,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active (2)'),
            Tab(text: 'Assisted (1)'),
            Tab(text: 'Resolved (4)'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Active Tab
            ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final item = incidents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.caseNumber,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: PashupatiColors.darkForest),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.status == 'OPEN' ? PashupatiColors.emergencyLight : PashupatiColors.softGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.status == 'OPEN' ? PashupatiColors.emergencyRed : PashupatiColors.forestGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item.emergencyType} • ${item.animalType}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description ?? item.address,
                          style: const TextStyle(fontSize: 13, color: PashupatiColors.secondaryText),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.push('/sos/track/${item.id}'),
                          child: const Text('View Live Coordination'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Assisted Tab
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volunteer_activism_rounded, size: 48, color: PashupatiColors.forestGreen),
                    const SizedBox(height: 12),
                    const Text('Dr. Rohan en route to #SOS-BLR-8921', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Transport crate and medical gauze provided.', textAlign: TextAlign.center, style: TextStyle(color: PashupatiColors.secondaryText)),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => context.push('/sos/track/c0000000-0000-0000-0000-000000000001'),
                      child: const Text('Inspect Case'),
                    ),
                  ],
                ),
              ),
            ),

            // Resolved Tab
            ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _buildResolvedCard('SOS-BLR-8890', 'Injured Street Pup', 'Fractured paw stabilized and placed in foster care.', '3 days ago'),
                _buildResolvedCard('SOS-BLR-8812', 'Kitten Abandoned on Flyover', 'Safe transfer completed to CUPA Trauma Centre.', '1 week ago'),
                _buildResolvedCard('SOS-BLR-8740', 'Kite with Manja Tangled', 'Rehabilitated and released with PFA wildlife rescue unit.', '2 weeks ago'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolvedCard(String caseNum, String title, String notes, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(caseNum, style: const TextStyle(fontWeight: FontWeight.bold, color: PashupatiColors.darkForest)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PashupatiColors.softGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('RESOLVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PashupatiColors.forestGreen)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 3),
            Text(notes, style: const TextStyle(fontSize: 12, color: PashupatiColors.secondaryText)),
            const SizedBox(height: 6),
            Text(time, style: const TextStyle(fontSize: 11, color: PashupatiColors.secondaryText)),
          ],
        ),
      ),
    );
  }
}

