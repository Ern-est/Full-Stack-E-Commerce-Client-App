import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // gives debugPrint

// Provider to fetch notifications
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<Map<String, dynamic>>>(
      (ref) => NotificationsNotifier(),
    );

class NotificationsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  NotificationsNotifier() : super([]) {
    fetchNotifications();
    listenToNewNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final data = await Supabase.instance.client
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      state = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      state = [];
      debugPrint('Error fetching notifications: $e');
    }
  }

  void listenToNewNotifications() {
    Supabase.instance.client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final newNotification = Map<String, dynamic>.from(
              payload.newRecord,
            );

            state = [newNotification, ...state];
          },
        )
        .subscribe();
  }
}
