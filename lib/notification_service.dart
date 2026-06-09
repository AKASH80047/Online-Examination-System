import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/firebase_options.dart';
import 'dart:developer' as developer;

/// Top-level function for background messages.
/// This must be a top-level function and annotated with @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  developer.log("Handling a background message: ${message.messageId}");
}

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  Future<void> initialize() async {
    // Check if Firebase is using placeholder values to avoid native crashes
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.appId.contains('APP_ID') ||
        options.apiKey.contains('API_KEY')) {
      developer.log(
        "WARNING: Firebase placeholders detected. Push notifications will not work until 'flutterfire configure' is run.",
      );
      return;
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for push notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      developer.log('User granted provisional permission');
    } else {
      developer.log('User declined or has not accepted permission');
    }

    try {
      // Get the FCM token for this device
      String? token = await messaging.getToken();
      if (token != null) developer.log("Firebase Messaging Token: $token");
    } catch (e) {
      developer.log("Error getting FCM token: $e");
    }

    // Handle messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Got a message whilst in the foreground!');
      developer.log('Message data: ${message.data}');
    });

    // Handle token refreshes
    messaging.onTokenRefresh.listen((newToken) {
      developer.log("FCM Token Refreshed: $newToken");
      // 
    });
  }
}