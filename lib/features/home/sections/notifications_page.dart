import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);

    try {
      // Supabase v2: select() returns List<Map<String, dynamic>>
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      setState(() => notifications = data);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      setState(() => notifications = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return ListTile(
                  leading: n['image_url'] != null && n['image_url'] != ''
                      ? Image.network(
                          n['image_url'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.notifications),
                  title: Text(n['title'] ?? '-'),
                  subtitle: Text(n['description'] ?? '-'),
                  trailing: Text(
                    n['created_at'] != null
                        ? n['created_at'].toString().substring(0, 10)
                        : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
