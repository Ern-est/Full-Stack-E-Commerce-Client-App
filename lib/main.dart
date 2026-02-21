import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import 'features/auth/pages/auth_page.dart';
import 'features/home/home_page.dart';
import 'firebase_options.dart';

/// 🔔 Local Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔔 Android Notification Channel (Required for Android 8+)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'default_channel',
  'Default Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

/// --- BACKGROUND FCM HANDLER ---
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint(
    'Background message received: ${message.messageId}, title: ${message.notification?.title}',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['MY_SUPABASE_URL']!,
    anonKey: dotenv.env['MY_SUPABASE_ANON_KEY']!,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔔 Initialize Local Notifications
  await _initializeLocalNotifications();

  // 🔔 Initialize FCM
  await _initializeFCM();

  runApp(const ProviderScope(child: MyApp()));
}

/// Initialize Local Notifications
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create notification channel (Android 8+)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

/// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryTheme,
      home: authState.when(
        data: (user) => user == null ? const AuthPage() : const HomePage(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, _) =>
            Scaffold(body: Center(child: Text('Auth Error: $err'))),
      ),
    );
  }
}

/// --- FCM Initialization ---
Future<void> _initializeFCM() async {
  final messaging = FirebaseMessaging.instance;

  // Request permission
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    debugPrint('FCM permission denied');
  }

  // Get token
  final token = await messaging.getToken();
  debugPrint('FCM Token: $token');

  // Save token to Supabase
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (token != null && user != null) {
      await supabase.from('devices').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'platform': defaultTargetPlatform
            .toString()
            .split('.')
            .last
            .toLowerCase(),
      }, onConflict: 'user_id,fcm_token');
    }
  } catch (e, st) {
    debugPrint('Error saving FCM token: $e\n$st');
  }

  /// 🔥 FOREGROUND MESSAGE HANDLING (THIS WAS MISSING)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('Foreground message: ${message.notification?.title}');

    final notification = message.notification;

    if (notification != null) {
      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
      );
    }
  });

  // Background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // When notification opens app
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint('Notification opened app: ${message.notification?.title}');
  });
}
