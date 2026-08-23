import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/widget/new_ride_popup.dart';
import 'package:bam_bam_vendor/data/data.dart';
import 'package:bam_bam_vendor/domain/domain.dart';
import 'package:bam_bam_vendor/domain/services/audio_service.dart';

import 'package:bam_bam_vendor/domain/services/native_overlay_service.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static String? currentUuid;
  static bool isVideo = false;

  Future<void> initNotification() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    log('[FCM] Permission status: ${settings.authorizationStatus}');

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ iOS APNS token check before FCM token
    if (Platform.isIOS) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();

      if (apnsToken == null) {
        log('[FCM] APNS token not available. Skipping FCM token.');
        return;
      }

      log('[FCM] APNS token: $apnsToken');
    }

    final token = await _firebaseMessaging.getToken();
    log('[FCM] Current device token: $token');

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      log('[FCM] Token refreshed: $newToken');
      try {
        if (Get.isRegistered<Repository>()) {
          final repo = Get.find<Repository>();
          final token = repo.getStringValue(LocalKeys.authToken);
          if (token.isNotEmpty && Get.isRegistered<ApiWrapper>()) {
            await Get.find<ApiWrapper>().makeRequest(
              "update-fcm-token",
              Request.post,
              {"fcm_token": newToken},
              true,
            );
            log('[FCM] Token refresh synced to backend');
          }
        }
      } catch (e) {
        log('[FCM] Error syncing refreshed token: $e');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('[FCM] Notification tapped background: ${message.messageId}');
      handleNavigationOnNotificationBackground(message);
    });
  }

  static void onAppTerminateMode() {
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message != null) {
          log('[FCM] App opened from terminated state via notification');
          handleNavigationOnNotification(message);
        }
      },
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (receivedAction.payload != null) {
      handleNavigationOnNotification(
        RemoteMessage(data: receivedAction.payload!),
      );
    }
  }

  static void handleNavigationOnNotification(RemoteMessage message) {
    if (message.data.isEmpty) return;
    print('🎵 [DEBUG] FCM Notification tapped/action received: ${message.data}');
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

      Future.delayed(const Duration(milliseconds: 400), () {
        BuildContext? ctx = Get.overlayContext ?? Get.key.currentContext;
        if (ctx != null) {
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
                  rideData: message.data,
                  vendorRequestId: vendorRequestId,
                ),
              ),
            ),
          );
        }
      });
    }
  }

  static void handleNavigationOnNotificationBackground(RemoteMessage message) {
    handleNavigationOnNotification(message);
  }

  static Future<void> initilizeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Bambam Cabs Incoming Ride Alerts',
          channelDescription:
              'High priority full screen alerts for Bambam Cabs Partner',
          ledColor: ColorsValue.appColor,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: false,
          playSound: true,
          criticalAlerts: true,
          locked: true,
          defaultPrivacy: NotificationPrivacy.Public,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel',
          channelGroupName: 'Group 1',
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (Platform.isAndroid) {
      try {
        if (await Permission.systemAlertWindow.isDenied) {
          await Permission.systemAlertWindow.request();
        }
      } catch (e) {
        log('SystemAlertWindow permission check error: $e');
      }
    }
  }
}