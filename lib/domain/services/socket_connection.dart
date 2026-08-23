import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/home_controller.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/widget/new_ride_popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:bam_bam_vendor/data/data.dart';
import 'package:bam_bam_vendor/domain/domain.dart';
import 'package:bam_bam_vendor/domain/services/audio_service.dart';

import 'package:bam_bam_vendor/domain/services/native_overlay_service.dart';

abstract class SocketConnection {
  static IO.Socket? socket;
  static Timer? _heartbeatTimer;

  static socketDisconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    socket?.disconnect();
    socket = null;
    AudioService.stopRingtone();
  }

  /// Helper to show popup using both Get.overlayContext and Get.key (navigatorKey)
  static void _showNewRidePopup({
    required Map<String, dynamic> ride,
    required String bookingId,
    required String vendorRequestId,
    int retryCount = 0,
  }) {
    // Guard against duplicate popups
    if (bookingId.isNotEmpty) {
      if (NewRidePopup.activeBookingIds.contains(bookingId)) {
        print("🎵 [DEBUG] Socket: Popup for $bookingId already active, skipping...");
        return;
      }
      NewRidePopup.activeBookingIds.add(bookingId);
    }

    // Try Get.overlayContext first, then Get.key.currentContext as fallback
    BuildContext? ctx = Get.overlayContext ?? Get.key.currentContext;

    if (ctx == null) {
      if (retryCount < 5) {
        print("🎵 [DEBUG] Socket: Context null, retrying in 300ms (attempt ${retryCount + 1})...");
        Future.delayed(const Duration(milliseconds: 300), () {
          _showNewRidePopup(
            ride: ride,
            bookingId: bookingId,
            vendorRequestId: vendorRequestId,
            retryCount: retryCount + 1,
          );
        });
      } else {
        print("🎵 [DEBUG] Socket: Context still null after retries, giving up for $bookingId");
        if (bookingId.isNotEmpty) NewRidePopup.activeBookingIds.remove(bookingId);
      }
      return;
    }

    print("🎵 [DEBUG] Socket: Triggering native showDialog for $bookingId");
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
              rideData: ride,
              vendorRequestId: vendorRequestId,
            ),
          ),
        ),
      );
    } catch (e) {
      print("🎵 [DEBUG] Socket: Error showing dialog: $e");
      if (bookingId.isNotEmpty) NewRidePopup.activeBookingIds.remove(bookingId);
    }
  }

  static void _startHeartbeat(String vendorId) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (socket != null && socket!.connected) {
        socket!.emit('ping', {'vendorId': vendorId, 'timestamp': DateTime.now().toIso8601String()});
      } else if (socket != null && !socket!.connected) {
        print("Socket: Heartbeat detected disconnect, reconnecting...");
        socket!.connect();
      }
    });
  }

  static initSocket() {
    final repo = Get.find<Repository>();
    String? token = repo.getStringValue(LocalKeys.authToken);
    String? vendorId = repo.getStringValue(LocalKeys.vendorId);
    
    if (token.isEmpty || vendorId.isEmpty) {
      print("Socket: Cannot init socket without token and vendorId");
      return;
    }

    if (socket != null && socket!.connected) {
      print("Socket: Already connected");
      return;
    }

    print("Socket: Connecting to ${ApiWrapper.socketUrl} for vendor: $vendorId");

    socket = IO.io(ApiWrapper.socketUrl, <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'reconnection': true,
      'reconnectionAttempts': 9999,
      'reconnectionDelay': 1000,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print("Socket: Connected Successfully");
      // Join vendor room
      socket!.emit('init', {'channelid': vendorId});
      _startHeartbeat(vendorId);
    });

    socket!.on('init_success', (data) {
      print("Socket: Joined channel successfully: ${data['channelid']}");
    });

    // 🚖 1. New Ride Request Event
    socket!.on('new_ride_request', (data) async {
      print("🎵 [DEBUG] Socket: New ride request received: $data");

      // Bring app window over home screen/launcher
      NativeOverlayService.bringToForeground();

      final ride = data['rideDetails'] ?? data;
      final travel = ride['travelDetailsId'] ?? {};

      // Play Ringtone & Vibration
      final customUrl = repo.getStringValue(LocalKeys.selectedRingtoneUrl);
      final isEnabled = repo.getStringValue(LocalKeys.ringtoneEnabled) != 'false';

      if (isEnabled) {
        AudioService.playRingtone(url: customUrl.isNotEmpty ? customUrl : null);
      }

      // Show System Notification Banner with Full-Screen Call Intent
      try {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'high_importance_channel',
            title: '🚖 New Ride Request',
            body: 'A new ride from ${travel['pickup_address'] ?? 'nearby'} is available.',
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Call,
            wakeUpScreen: true,
            fullScreenIntent: true,
            criticalAlert: true,
            locked: true,
            autoDismissible: false,
            payload: {"type": "new_ride", "bookingId": ride['_id']?.toString() ?? ""},
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
        print("🎵 [DEBUG] Socket: Error showing notification: $e");
      }

      final String bookingId = ride['_id']?.toString() ?? data['bookingId']?.toString() ?? data['booking_id']?.toString() ?? "";
      final String vendorRequestId = data['vendorRequestId']?.toString() ?? data['vendor_request_id']?.toString() ?? "";

      // Show Popup with retry logic
      Future.delayed(const Duration(milliseconds: 300), () {
        _showNewRidePopup(
          ride: Map<String, dynamic>.from(data is Map ? data : {}),
          bookingId: bookingId,
          vendorRequestId: vendorRequestId,
        );
      });

      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.getRides(isLoading: false);
        homeController.getDashboardCounts(isLoading: false);
      }
    });

    // ❌ 2. Ride Cancelled / Expired Event
    socket!.on('ride_cancelled', (data) {
      print("🎵 [DEBUG] Socket: Ride cancelled: $data");
      AudioService.stopRingtone();
      final String cancelledBookingId = (data is Map ? (data['bookingId'] ?? data['_id']) : '').toString();
      if (cancelledBookingId.isNotEmpty) {
        NewRidePopup.activeBookingIds.remove(cancelledBookingId);
      }
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });

    socket!.on('ride_expired', (data) {
      print("🎵 [DEBUG] Socket: Ride expired: $data");
      AudioService.stopRingtone();
      final String expiredBookingId = (data is Map ? (data['bookingId'] ?? data['_id']) : '').toString();
      if (expiredBookingId.isNotEmpty) {
        NewRidePopup.activeBookingIds.remove(expiredBookingId);
      }
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });

    // 🚗 3. Ride Accepted By Another Driver Event
    socket!.on('ride_accepted', (data) {
      print("🎵 [DEBUG] Socket: Ride accepted event: $data");
      AudioService.stopRingtone();
      final String acceptedBookingId = (data is Map ? (data['bookingId'] ?? data['_id']) : '').toString();
      if (acceptedBookingId.isNotEmpty && NewRidePopup.activeBookingIds.contains(acceptedBookingId)) {
        NewRidePopup.activeBookingIds.remove(acceptedBookingId);
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        Utility.showInfoSnackBar(message: "Ride assigned to another driver.");
      }
    });

    // 🔴 4. Driver Offline Event
    socket!.on('driver_offline', (_) {
      print("Socket: Driver offline signal received");
      socketDisconnect();
    });

    socket!.onDisconnect((_) => print('Socket: Disconnected'));
    socket!.onConnectError((err) => print("Socket: Connect Error: $err"));
    socket!.onError((err) => print("Socket: Error: $err"));
  }
}

