import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/models/notification_model.dart';
import '../../authentication/providers/auth_provider.dart';

final notificationsFutureProvider = FutureProvider<List<AppNotification>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.getNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsFutureProvider);

    return Scaffold(
      backgroundColor: PashupatiColors.ivoryCanvas,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: PashupatiColors.forestGreen)),
          error: (err, _) => Center(child: Text('Error loading alerts: $err')),
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text('No new notifications.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.category == 'EMERGENCY' ? PashupatiColors.emergencyLight : PashupatiColors.softGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.category == 'EMERGENCY' ? Icons.crisis_alert_rounded : Icons.notifications_active_rounded,
                        color: item.category == 'EMERGENCY' ? PashupatiColors.emergencyRed : PashupatiColors.forestGreen,
                        size: 20,
                      ),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(item.body, style: const TextStyle(fontSize: 12, color: PashupatiColors.secondaryText)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: PashupatiColors.secondaryText),
                    onTap: () {
                      context.push('/sos/track/c0000000-0000-0000-0000-000000000001');
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
