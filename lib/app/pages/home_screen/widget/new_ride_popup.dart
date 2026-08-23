import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/theme/colors_value.dart';
import 'package:bam_bam_vendor/app/theme/styles.dart';
import 'package:bam_bam_vendor/domain/services/audio_service.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/home_controller.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/home_presenter.dart';
import 'package:bam_bam_vendor/app/utils/asset_constants.dart';
import 'package:bam_bam_vendor/app/utils/utility.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/screen/Bam_Bam_Hub/ride_detiles_screen.dart';
import 'package:bam_bam_vendor/domain/domain.dart';
import 'package:bam_bam_vendor/data/data.dart';

class NewRidePopup extends StatefulWidget {
  final Map<String, dynamic> rideData;
  final String vendorRequestId;

  // Global tracker to prevent duplicate popups for the same ride across all services
  static final Set<String> activeBookingIds = {};

  const NewRidePopup({
    super.key,
    required this.rideData,
    required this.vendorRequestId,
  });

  @override
  State<NewRidePopup> createState() => _NewRidePopupState();
}

class _NewRidePopupState extends State<NewRidePopup> with TickerProviderStateMixin {
  Map<String, dynamic>? _fullRideData; // Fetched from API
  bool _isFetchingDetails = true;
  bool _isAccepting = false;
  bool _isRejecting = false;

  // Countdown Timer (15 seconds)
  late AnimationController _timerController;
  int _secondsRemaining = 15;
  Timer? _countdownTimer;

  // Pulse Animation for Header
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup 15-second countdown timer
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _countdownTimer?.cancel();
            _onTimeout();
          }
        });
      }
    });

    // 2. Setup Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Fetch full ride details from API
    _fetchFullDetails();
  }

  void _onTimeout() async {
    print("🕒 [DEBUG] NewRidePopup timed out after 15s: ${widget.vendorRequestId}");
    AudioService.stopRingtone();

    String vrId = _getVendorRequestId();
    if (vrId.isNotEmpty) {
      try {
        final homeController = _getHomeController();
        await homeController.homePresenter.rejectRequest({"vendorRequestId": vrId});
      } catch (e) {
        print("Error sending auto-reject: $e");
      }
    }

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  String _getVendorRequestId() {
    String vrId = widget.vendorRequestId;
    if (vrId.isEmpty) {
      vrId = (widget.rideData['vendorRequestId'] ??
              widget.rideData['vendor_request_id'] ??
              widget.rideData['_id'] ??
              "")
          .toString();
    }
    return vrId;
  }

  HomeController _getHomeController() {
    return Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController(HomePresenter(HomeUsecases(ApiWrapper()))));
  }

  Future<void> _fetchFullDetails() async {
    String vrId = _getVendorRequestId();
    if (vrId.isEmpty) {
      if (mounted) setState(() => _isFetchingDetails = false);
      return;
    }
    try {
      final homeController = _getHomeController();
      final res = await homeController.homePresenter.fetchVendorRideDetails(vrId);
      if (res.hasError || res.data == null) {
        if (mounted) setState(() => _isFetchingDetails = false);
        return;
      }
      final decoded = jsonDecode(res.data!);
      final dataBlock = decoded['Data'];
      Map<String, dynamic>? fullData;
      if (dataBlock is Map) {
        final booking = dataBlock['bookingDetails'] ?? dataBlock['booking'] ?? dataBlock['vendorRequest'];
        if (booking is Map) {
          fullData = Map<String, dynamic>.from(booking);
        } else {
          fullData = Map<String, dynamic>.from(dataBlock);
        }
      }
      if (mounted) {
        setState(() {
          _fullRideData = fullData;
          _isFetchingDetails = false;
        });
      }
    } catch (e) {
      print("🗓️ [DATE] fetchFullDetails error: $e");
      if (mounted) setState(() => _isFetchingDetails = false);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _timerController.dispose();
    _pulseController.dispose();

    // Clean up global tracker
    final String bookingId = widget.rideData['_id']?.toString() ??
        widget.rideData['bookingId']?.toString() ??
        widget.rideData['booking_id']?.toString() ?? "";
    if (bookingId.isNotEmpty) {
      NewRidePopup.activeBookingIds.remove(bookingId);
    }

    // Stop sound & vibration when dialog is closed
    AudioService.stopRingtone();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    if (_isAccepting || _isRejecting) return;

    setState(() => _isAccepting = true);
    _countdownTimer?.cancel();
    AudioService.stopRingtone();

    String vrId = _getVendorRequestId();
    final String bId = (widget.rideData['bookingId'] ??
            widget.rideData['booking_id'] ??
            widget.rideData['_id'] ??
            "")
        .toString();

    try {
      final homeController = _getHomeController();
      final res = await homeController.homePresenter.confirmRequest({"vendorRequestId": vrId});

      if (res.hasError) {
        setState(() => _isAccepting = false);
        String errorMsg = "Failed to accept ride";
        if (res.data != null) {
          try {
            final decoded = jsonDecode(res.data!);
            errorMsg = decoded['message'] ?? decoded['Message'] ?? errorMsg;
          } catch (_) {}
        }
        Utility.showErrorSnackBar(message: errorMsg);
        return;
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await homeController.getRideDetails(vrId, bookingId: bId);
      Get.to(() => const RideDetilesScreen(), arguments: vrId.isNotEmpty ? vrId : bId);
    } catch (e) {
      if (mounted) setState(() => _isAccepting = false);
      Utility.showErrorSnackBar(message: "Accept failed: $e");
    }
  }

  Future<void> _handleReject() async {
    if (_isAccepting || _isRejecting) return;

    setState(() => _isRejecting = true);
    _countdownTimer?.cancel();
    AudioService.stopRingtone();

    String vrId = _getVendorRequestId();
    if (vrId.isNotEmpty) {
      try {
        final homeController = _getHomeController();
        await homeController.homePresenter.rejectRequest({"vendorRequestId": vrId});
      } catch (e) {
        print("Error rejecting request: $e");
      }
    }

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      SystemNavigator.pop();
    }
  }

  String _buildCityRoute(Map<String, dynamic> travel) {
    final String tripType = (travel['trip_type'] ?? '').toString().toLowerCase();
    final bool isLocal = tripType.contains('local');
    final String from = Utility.getDisplayFrom(travel);

    if (isLocal) {
      return from;
    }

    final dynamic toVal = travel['to'];
    if (toVal is List && toVal.isNotEmpty) {
      final List<String> cities = toVal
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      if (cities.isNotEmpty) {
        return '$from → ${cities.join(' → ')}';
      }
    }

    final String to = Utility.getDisplayTo(travel);
    if (to.isNotEmpty && to != '-') {
      return '$from → $to';
    }

    return from;
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingDetails) {
      return Center(
        child: Image.asset(
          AssetConstants.loaderGif,
          width: 200,
          fit: BoxFit.contain,
        ),
      );
    }

    Map<String, dynamic> resolvedData;
    if (_fullRideData != null) {
      resolvedData = _fullRideData!;
    } else {
      resolvedData = Map<String, dynamic>.from(widget.rideData);
      if (resolvedData['bookingDetails'] != null && resolvedData['bookingDetails'] is Map) {
        resolvedData = Map<String, dynamic>.from(resolvedData['bookingDetails']);
      } else if (resolvedData['rideDetails'] != null) {
        final details = resolvedData['rideDetails'];
        if (details is String) {
          try { resolvedData = jsonDecode(details); } catch (e) {}
        } else if (details is Map) {
          resolvedData = Map<String, dynamic>.from(details);
        }
      }
    }

    final dynamic travelRaw = resolvedData['travelDetailsId'] ?? resolvedData['travel'] ?? resolvedData['travelDetails'];
    final Map<String, dynamic> travel = (travelRaw is Map)
        ? Map<String, dynamic>.from(travelRaw)
        : <String, dynamic>{};

    final String source = travel['pickup_address'] ?? resolvedData['source_city'] ?? resolvedData['source'] ?? "N/A";
    final dynamic dropData = travel['drop_address'];
    final String destination = (dropData is List && dropData.isNotEmpty)
        ? dropData[0].toString()
        : (dropData?.toString() ?? resolvedData['destination_city'] ?? resolvedData['destination'] ?? "N/A");

    final dynamic exploreIdData = travel['exploreId'];
    final Map<String, dynamic>? exploreObj = (exploreIdData is Map)
        ? Map<String, dynamic>.from(exploreIdData)
        : null;

    dynamic rawDateDynamic = travel['pickup_date'] ??
        travel['date'] ??
        travel['pickupDate'] ??
        exploreObj?['pickup_date'] ??
        exploreObj?['date'] ??
        resolvedData['pickup_date'] ??
        resolvedData['date'] ??
        resolvedData['booking_date'] ??
        widget.rideData['pickup_date'] ??
        resolvedData['createdAt'];

    String rawDate = "N/A";
    if (rawDateDynamic != null &&
        rawDateDynamic.toString().trim().isNotEmpty &&
        rawDateDynamic.toString().trim() != 'null') {
      String dateStr = rawDateDynamic.toString().trim();
      if (dateStr.contains("T")) {
        dateStr = dateStr.split("T")[0];
      }
      try {
        final parts = dateStr.split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            rawDate = "${parts[2]}/${parts[1]}/${parts[0]}";
          } else {
            rawDate = "${parts[0]}/${parts[1]}/${parts[2]}";
          }
        } else {
          rawDate = dateStr;
        }
      } catch (_) {
        rawDate = dateStr;
      }
    }

    final String time = (travel['pickup_time'] ??
        exploreObj?['pickup_time'] ??
        resolvedData['pickup_time'] ??
        widget.rideData['pickup_time'] ??
        "").toString().trim();

    final String date = (time.isNotEmpty && time != 'null') ? "$rawDate at $time" : rawDate;

    String rawFare = '0';
    if (resolvedData['payment_summary'] != null && resolvedData['payment_summary']['final_trip_fare'] != null) {
      rawFare = resolvedData['payment_summary']['final_trip_fare'].toString();
    } else if (resolvedData['total_fare'] != null) {
      rawFare = resolvedData['total_fare'].toString();
    } else if (travel['fare_summary'] != null && travel['fare_summary']['total_fare'] != null) {
      rawFare = travel['fare_summary']['total_fare'].toString();
    } else if (travel['base_fare'] != null) {
      rawFare = travel['base_fare'].toString();
    }
    final String fare = "₹$rawFare";

    final String tripType = (travel['trip_type'] ?? '').toString().replaceAll('_', ' ');
    final bool isLocal = (travel['trip_type'] ?? '').toString().toLowerCase().contains('local');
    final bool isRoundTrip = (travel['trip_type'] ?? '').toString().toLowerCase().contains('round');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header with Animated Pulsing Ring & Circular Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ColorsValue.orangeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColorsValue.orangeColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "INCOMING RIDE",
                            style: Styles.g1txtColor60018.copyWith(
                              color: ColorsValue.orangeColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 15s Circular Countdown Badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: AnimatedBuilder(
                          animation: _timerController,
                          builder: (context, child) {
                            return CircularProgressIndicator(
                              value: 1.0 - _timerController.value,
                              strokeWidth: 4,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _secondsRemaining <= 5 ? Colors.red : ColorsValue.orangeColor,
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        "$_secondsRemaining",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _secondsRemaining <= 5 ? Colors.red : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Driver Earning Banner (Uber/Ola Style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorsValue.orangeColor.withOpacity(0.15),
                      ColorsValue.orangeColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorsValue.orangeColor.withOpacity(0.3), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DRIVER EARNING",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        if (tripType.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              tripType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: ColorsValue.orangeColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      fare,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: ColorsValue.orangeColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. City Route Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildCityRouteWidgets(travel, isLocal, isRoundTrip),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Pickup & Drop Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.my_location_rounded, "PICKUP LOCATION", source, dotColor: Colors.green),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 18,
                          child: VerticalDivider(color: Colors.grey, thickness: 1.2),
                        ),
                      ),
                    ),
                    _buildInfoRow(Icons.location_on_rounded, "DROP LOCATION", destination, dotColor: Colors.red),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.calendar_month_rounded, "DATE & TIME", date),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. Bottom Action Buttons (ACCEPT / REJECT)
              Row(
                children: [
                  // Reject Button
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: (_isAccepting || _isRejecting) ? null : _handleReject,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade400, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: Colors.red.shade50,
                        ),
                        child: _isRejecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                              )
                            : Text(
                                "DECLINE",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.red.shade700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Accept Button
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_isAccepting || _isRejecting) ? null : _handleAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.orangeColor,
                          elevation: 4,
                          shadowColor: ColorsValue.orangeColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isAccepting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "ACCEPT RIDE",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCityRouteWidgets(Map<String, dynamic> travel, bool isLocal, bool isRoundTrip) {
    final String from = Utility.getDisplayFrom(travel);

    if (isLocal) {
      return [_cityChip(from, isStart: true)];
    }

    final dynamic toVal = travel['to'];
    List<String> toCities = [];

    if (toVal is List && toVal.isNotEmpty) {
      toCities = toVal
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      final String to = Utility.getDisplayTo(travel);
      if (to.isNotEmpty && to != '-') {
        toCities = [to];
      }
    }

    if (toCities.isEmpty) {
      return [_cityChip(from, isStart: true)];
    }

    final List<Widget> widgets = [_cityChip(from, isStart: true)];
    for (final city in toCities) {
      widgets.add(_arrowIcon());
      widgets.add(_cityChip(city));
    }
    return widgets;
  }

  Widget _cityChip(String city, {bool isStart = false}) {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 120),
        child: Text(
          city,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isStart ? ColorsValue.orangeColor : Colors.black87,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _arrowIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 16,
        color: ColorsValue.orangeColor,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? dotColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: dotColor ?? ColorsValue.appColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
