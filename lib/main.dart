import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bam_bam_vendor/domain/services/audio_service.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/widget/new_ride_popup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/data.dart';
import 'package:bam_bam_vendor/device/device.dart';
import 'package:bam_bam_vendor/domain/domain.dart';

import 'package:bam_bam_vendor/domain/services/native_overlay_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('[FCM] Background message received: ${message.messageId}, data: ${message.data}');

  // Guard: check if user is logged in
  try {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>('Bam Bam Partner');
    final String? authToken = box.get('authToken') as String?;
    final String? vendorId = box.get('vendorId') as String?;
    if (authToken == null || authToken.isEmpty || vendorId == null || vendorId.isEmpty) {
      print('[FCM] Background message ignored (user not logged in)');
      return;
    }
  } catch (e) {
    print('[FCM] Background guard check error: $e');
  }

  final String type = (message.data['type'] ?? '').toString();
  final bool isRideMessage = type == 'new_ride' ||
      type == 'new_ride_request' ||
      type.contains('ride') ||
      message.data.containsKey('bookingId') ||
      message.data.containsKey('booking_id') ||
      message.data.containsKey('vendorRequestId') ||
      message.data.containsKey('vendor_request_id');

  if (isRideMessage) {
    NativeOverlayService.bringToForeground();
    AudioService.playRingtone();
    
    // Show Full-Screen Call/Ride Notification in background/killed state (Android + iOS)
    try {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: message.notification?.title ?? message.data['title'] ?? '🚖 New Ride Request',
          body: message.notification?.body ?? message.data['body'] ?? 'A new ride request is available in your area.',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Call,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          autoDismissible: false,
          locked: true,
          payload: message.data.map((key, value) => MapEntry(key, value.toString())),
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'ACCEPT',
            label: 'ACCEPT RIDE',
            color: Colors.green,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'REJECT',
            label: 'DECLINE',
            color: Colors.red,
            autoDismissible: true,
            actionType: ActionType.DismissAction,
          ),
        ],
      );
    } catch (e) {
      print('[FCM] Error creating background notification: $e');
    }
  }
}

/// Shows FCM popup with retry logic if context is not yet ready.
void _showFcmPopup({
  required Map<String, dynamic> rideData,
  required String bookingId,
  required String vendorRequestId,
  int retryCount = 0,
}) {
  // Guard against duplicate popups
  if (bookingId.isNotEmpty) {
    if (NewRidePopup.activeBookingIds.contains(bookingId)) {
      print('🎵 [DEBUG] FCM: Popup for $bookingId already active, skipping...');
      return;
    }
    NewRidePopup.activeBookingIds.add(bookingId);
  }

  // Try Get.overlayContext first, then Get.key.currentContext as fallback
  BuildContext? ctx = Get.overlayContext ?? Get.key.currentContext;

  if (ctx == null) {
    if (retryCount < 10) {
      print('🎵 [DEBUG] FCM: Context null, retrying in 300ms (attempt ${retryCount + 1})...');
      // Remove from active set so retry can add it again
      if (bookingId.isNotEmpty) NewRidePopup.activeBookingIds.remove(bookingId);
      Future.delayed(const Duration(milliseconds: 300), () {
        _showFcmPopup(
          rideData: rideData,
          bookingId: bookingId,
          vendorRequestId: vendorRequestId,
          retryCount: retryCount + 1,
        );
      });
    } else {
      print('🎵 [DEBUG] FCM: Context still null after retries, giving up for $bookingId');
      if (bookingId.isNotEmpty) NewRidePopup.activeBookingIds.remove(bookingId);
    }
    return;
  }

  print('🎵 [DEBUG] FCM: Triggering native showDialog for $bookingId');
  try {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Material(
          type: MaterialType.transparency,
          child: NewRidePopup(
            rideData: rideData,
            vendorRequestId: vendorRequestId,
          ),
        ),
      ),
    );
  } catch (e) {
    print('🎵 [DEBUG] FCM: Error showing native dialog: $e');
    if (bookingId.isNotEmpty) NewRidePopup.activeBookingIds.remove(bookingId);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ CRITICAL: Background handler MUST be registered before runApp()
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await initServices();
  runApp(const MyApp());
}

Future<void> initServices() async {
  await Hive.initFlutter();

  /// CORE API WRAPPER (🔥 REQUIRED)
  Get.put<ApiWrapper>(ApiWrapper(), permanent: true);

  /// REPOSITORY
  Get.put(
    Repository(
      Get.put(DeviceRepository(), permanent: true),
      Get.put(
        DataRepository(Get.put(ConnectHelper(), permanent: true)),
        permanent: true,
      ),
    ),
    permanent: true,
  );

  /// SERVICES
  await Get.putAsync(() => CommonService().init());
  await Get.putAsync(() => DbService().init());
  await FirebaseApi.initilizeNotification();
  await FirebaseApi().initNotification();

  // Check if app opened from killed state via FCM notification
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null && message.data.isNotEmpty) {
      print('🎵 [DEBUG] App launched from terminated state via FCM: ${message.data}');
      final String type = (message.data['type'] ?? '').toString();
      final bool isRideMessage = type == 'new_ride' ||
          type == 'new_ride_request' ||
          type.contains('ride') ||
          message.data.containsKey('bookingId') ||
          message.data.containsKey('booking_id');

      if (isRideMessage) {
        NativeOverlayService.bringToForeground();
        AudioService.playRingtone();
        final String bookingId = message.data['bookingId'] ?? message.data['booking_id'] ?? "";
        final String vendorRequestId = message.data['vendorRequestId'] ?? message.data['vendor_request_id'] ?? "";
        _showFcmPopup(
          rideData: message.data,
          bookingId: bookingId,
          vendorRequestId: vendorRequestId,
        );
      }
    }
  });

  // Initialize socket if already logged in
  final repo = Get.find<Repository>();
  print("Main: Attempting socket initialization. Token: ${repo.getStringValue(LocalKeys.authToken).isNotEmpty}, VendorID: ${repo.getStringValue(LocalKeys.vendorId)}");
  
  SocketConnection.initSocket();

  // Foreground messages (app is open)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final repo = Get.find<Repository>();
    if (repo.getStringValue(LocalKeys.authToken).isEmpty || repo.getStringValue(LocalKeys.vendorId).isEmpty) {
      print('🎵 [DEBUG] FCM: Foreground message ignored (user not logged in)');
      return;
    }

    print('🎵 [DEBUG] FCM: Foreground message received: ${message.data}');

    // 1. Show System Notification Banner (Android AND iOS)
    try {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: message.notification?.title ?? message.data['title'] ?? '🚖 New Ride Request',
          body: message.notification?.body ?? message.data['body'] ?? 'A new ride is available in your area.',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Call,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          payload: message.data.map((key, value) => MapEntry(key, value.toString())),
        ),
      );
    } catch (e) {
      print('🎵 [DEBUG] FCM: Error creating notification: $e');
    }

    // 2. Play Ringtone and Show Popup for new rides
    final String type = (message.data['type'] ?? '').toString();
    final bool isRideMessage = type == 'new_ride' ||
        type == 'new_ride_request' ||
        type.contains('ride') ||
        message.data.containsKey('bookingId') ||
        message.data.containsKey('booking_id');

    if (isRideMessage) {
      NativeOverlayService.bringToForeground();
      AudioService.playRingtone();
      
      final String bookingId = message.data['bookingId'] ?? message.data['booking_id'] ?? "";
      final String vendorRequestId = message.data['vendorRequestId'] ?? message.data['vendor_request_id'] ?? "";

      // 3. Show Popup with retry logic
      Future.delayed(const Duration(milliseconds: 300), () {
        _showFcmPopup(
          rideData: message.data,
          bookingId: bookingId,
          vendorRequestId: vendorRequestId,
        );
      });

      // 4. Background Refresh (without closing dialogs)
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().getRides(isLoading: false);
      }
    }
  });
}

class DbService extends GetxService {
  Future<DbService> init() async {
    await Get.find<DeviceRepository>().init();
    return this;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: ColorsValue.appColor,
      ),
    );
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(375, 745),
      builder: (_, child) => GetMaterialApp(
        locale: const Locale('en'),
        debugShowCheckedModeBanner: false,
        title: StringConstants.appName,
        theme: themeData(context),
        darkTheme: darkThemeData(context),
        themeMode: ThemeMode.light,
        getPages: AppPages.pages,
        initialRoute: Routes.splashScreen,
        translations: TranslationsFile(),
        navigatorKey: Get.key,
        enableLog: true,
      ),
    );
  }
}
