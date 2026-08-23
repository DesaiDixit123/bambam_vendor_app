import 'dart:async';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DriverAllocateScreen extends StatelessWidget {
  const DriverAllocateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Allocate Driver",
            //
            actions: [
              Dimens.boxWidth10,
              SvgPicture.asset(AssetConstants.search),
              Dimens.boxWidth20,
            ],
          ),
          //
          // bottomNavigationBar: Padding(
          //   padding: Dimens.edgeInsets20_30_20_30,
          //   child: CustomButton(
          //     onPressed: () {
          //       RouteManagement.gotoAllocateVehicleScreen();
          //     },
          //     text: "Save & Continue",
          //     backgroundColor: ColorsValue.appColor,
          //   ),
          // ),
          body: controller.isAllocationDriversLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.allocationDriversData == null
              ? const Center(child: Text("No data available"))
              : ListView(
                  padding: Dimens.edgeInsets20,
                  physics: BouncingScrollPhysics(),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ColorsValue.whiteColor,
                        borderRadius: BorderRadius.circular(Dimens.twelve),
                      ),
                      child: Padding(
                        padding: Dimens.edgeInsets16,
                        child: Column(
                          spacing: Dimens.twelve,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Dimens.four,
                                  children: [
                                    Text(
                                      "Booking ID",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Text(
                                      "${controller.allocationDriversData!['booking']?['booking_id'] ?? ''}",
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Dimens.four,
                                  children: [
                                    Text(
                                      "Booking Date",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Text(
                                      Utility.getFormatedTime(controller.allocationDriversData!['travelDetails']?['date'] ?? DateTime.now().toString(), 'dd-MM-yyyy'),
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Dimens.four,
                                  children: [
                                    Text(
                                      "Pickup Date & Time",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Text(
                                      "${Utility.getFormatedTime(controller.allocationDriversData!['travelDetails']?['date'] ?? DateTime.now().toString(), 'dd-MM-yyyy')} / ${controller.allocationDriversData!['travelDetails']?['pickup_time'] ?? ''}",
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Dimens.four,
                                  children: [
                                    Text(
                                      "Booking Type",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Text(
                                      "${controller.allocationDriversData!['travelDetails']?['trip_type'] ?? ''}",
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: Dimens.four,
                                    children: [
                                      Text(
                                        "Vehicle",
                                        style: Styles.g7txtColor40014,
                                      ),
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: () {
                                              final travelDetails = controller.allocationDriversData!['travelDetails'] ?? {};
                                              final vehicle = travelDetails['vehicle'] ?? {};
                                              final vehicleType = vehicle['vehicle_type'] ?? {};
                                              final photoUrl = vehicleType['vehicle_photo'] ?? vehicle['vehicle_photo'] ?? '';
                                              
                                              if (photoUrl.isNotEmpty) {
                                                String resolvedUrl = photoUrl;
                                                if (!resolvedUrl.startsWith("http://") && !resolvedUrl.startsWith("https://")) {
                                                  String cleanPath = resolvedUrl;
                                                  if (cleanPath.startsWith("uploads/")) {
                                                    cleanPath = cleanPath.substring("uploads/".length);
                                                  } else if (cleanPath.startsWith("/uploads/")) {
                                                    cleanPath = cleanPath.substring("/uploads/".length);
                                                  }
                                                  resolvedUrl = "${ApiWrapper.imageUrl}$cleanPath";
                                                }
                                                
                                                return Image.network(
                                                  resolvedUrl,
                                                  height: Dimens.twentyFive,
                                                  width: Dimens.twentyFive * 1.5,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, st) {
                                                    final s3Url = photoUrl.startsWith("http")
                                                        ? photoUrl
                                                        : "https://bambams3.s3.ap-south-1.amazonaws.com/${photoUrl.replaceFirst("uploads/", "")}";
                                                    return Image.network(
                                                      s3Url,
                                                      height: Dimens.twentyFive,
                                                      width: Dimens.twentyFive * 1.5,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => Image.asset(
                                                        AssetConstants.carpng,
                                                        height: Dimens.twentyFive,
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                              return Image.asset(
                                                AssetConstants.carpng,
                                                height: Dimens.twentyFive,
                                              );
                                            }(),
                                          ),
                                          Dimens.boxWidth8,
                                          Expanded(
                                            child: Text(
                                              "${controller.allocationDriversData!['travelDetails']?['vehicle']?['brand_name'] ?? 'N/A'}",
                                              style: Styles.g1txtColor60016,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Dimens.boxHeight16,

                    _PickupCountdownBanner(
                      travelDetails: controller.allocationDriversData!['travelDetails'] ?? {},
                      booking: controller.allocationDriversData!['booking'],
                    ),

                    ...(controller.allocationDriversData!['drivers'] as List? ?? []).map((
                      driver,
                    ) {
                      final driverStatus = controller.getDriverStatus(driver);
                      final travelDetails = controller.allocationDriversData!['travelDetails'] ?? {};
                      final pickupDt = _PickupCountdownBannerState.parsePickupDateTime(travelDetails);
                      bool isWithin5Hours = true;
                      if (pickupDt != null) {
                        final diffHours = pickupDt.difference(DateTime.now()).inSeconds / 3600.0;
                        if (diffHours > 5) isWithin5Hours = false;
                      }

                      // Select button is active only for Available drivers within 5 hours of pickup.
                      final isSelectable = driverStatus.toLowerCase() == 'available' && isWithin5Hours;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              controller.selectedDriver = driver;
                              controller.update();
                              RouteManagement.gotoDriverHistoryScreen();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorsValue.whiteColor,
                                borderRadius: BorderRadius.circular(
                                  Dimens.twelve,
                                ),
                              ),
                              child: Padding(
                                padding: Dimens.edgeInsets16,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "DL Number: ",
                                          style: Styles.g6txtColor40014,
                                        ),
                                        Text(
                                          "${driver['DL_number'] ?? ''}",
                                          style: Styles.g1txtColor60016,
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    Dimens.boxHeight12,
                                    Divider(color: ColorsValue.l2),
                                    ListTile(
                                      contentPadding: Dimens.edgeInsets0,
                                      leading: ClipOval(
                                        child: () {
                                          final photoPath = driver['driver_photo'];
                                          if (photoPath != null && photoPath.toString().trim().isNotEmpty) {
                                            final String trimmed = photoPath.toString().trim();
                                            String resolvedUrl = trimmed;
                                            if (!resolvedUrl.startsWith("http://") && !resolvedUrl.startsWith("https://")) {
                                              String cleanPath = resolvedUrl;
                                              if (cleanPath.startsWith("uploads/")) {
                                                cleanPath = cleanPath.substring("uploads/".length);
                                              } else if (cleanPath.startsWith("/uploads/")) {
                                                cleanPath = cleanPath.substring("/uploads/".length);
                                              }
                                              resolvedUrl = "${ApiWrapper.imageUrl}$cleanPath";
                                            }

                                            return Image.network(
                                              resolvedUrl,
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, st) {
                                                final s3Url = trimmed.startsWith("http")
                                                    ? trimmed
                                                    : "https://bambams3.s3.ap-south-1.amazonaws.com/${trimmed.replaceFirst("uploads/", "")}";
                                                return Image.network(
                                                  s3Url,
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Image.asset(
                                                    AssetConstants.ic_driver,
                                                    height: 50,
                                                    width: 50,
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                          return Image.asset(
                                            AssetConstants.ic_driver,
                                            height: 50,
                                            width: 50,
                                          );
                                        }(),
                                      ),
                                      title: Text(
                                        "${driver['driver_name'] ?? ''}",
                                        style: Styles.g1txtColor60016,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${driver['driver_mobile'] ?? ''}",
                                            style: Styles.g7txtColor40014,
                                          ),
                                          const SizedBox(height: 6),
                                          _buildStatusChip(driverStatus),
                                        ],
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: isSelectable
                                            ? () async {
                                                final driverId = driver['_id'];
                                                final vendorRequestId =
                                                    controller.currentAllocationId;

                                                if (driverId != null &&
                                                    vendorRequestId != null) {
                                                  await controller
                                                      .assignDriverToAllocation(
                                                        vendorRequestId,
                                                        driverId,
                                                      );
                                                } else {
                                                  Utility.snacBar(
                                                    "Missing required IDs",
                                                    Colors.red,
                                                  );
                                                }
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSelectable
                                              ? ColorsValue.appColor
                                              : Colors.grey.shade300,
                                          disabledBackgroundColor: Colors.grey.shade300,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Text(
                                          "Select",
                                          style: isSelectable
                                              ? Styles.whiteColorW60016
                                              : Styles.whiteColorW60016.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Dimens.boxHeight16,
                        ],
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }

  /// Premium status badge: Active (green) | Busy (orange) | Unavailable (red)
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'busy':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupCountdownBanner extends StatefulWidget {
  final Map travelDetails;
  final Map? item;
  final Map? booking;

  const _PickupCountdownBanner({
    Key? key,
    required this.travelDetails,
    this.item,
    this.booking,
  }) : super(key: key);

  @override
  State<_PickupCountdownBanner> createState() => _PickupCountdownBannerState();
}

class _PickupCountdownBannerState extends State<_PickupCountdownBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static DateTime? parsePickupDateTime(Map travelDetails) {
    try {
      final dateStr = travelDetails['date'] ?? travelDetails['pickup_date'];
      final timeStr = travelDetails['pickup_time'];
      if (dateStr == null || timeStr == null) return null;

      final parsedDate = DateTime.tryParse(dateStr.toString());
      if (parsedDate == null) return null;

      int hour = 0;
      int minute = 0;

      final timeMatch = RegExp(r'(\d+):(\d+)\s*(AM|PM)?', caseSensitive: false).firstMatch(timeStr.toString());
      if (timeMatch != null) {
        hour = int.tryParse(timeMatch.group(1) ?? '0') ?? 0;
        minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
        final ampm = timeMatch.group(3)?.toUpperCase();
        if (ampm == 'PM' && hour < 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
      }

      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  DateTime? _getPickupDateTime() => parsePickupDateTime(widget.travelDetails);

  @override
  Widget build(BuildContext context) {
    final pickupDt = _getPickupDateTime();
    if (pickupDt == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final rem = pickupDt.difference(now);
    final diffHours = rem.inSeconds / 3600.0;

    final isReEnabled = (widget.item?['vendor_assignment_re_enabled'] == true) ||
        (widget.booking?['vendor_assignment_re_enabled'] == true);

    Color bg;
    Color border;
    Color text;
    String icon;
    String label;

    if (diffHours > 5) {
      final unlockTime = pickupDt.subtract(const Duration(hours: 5));
      final unlockRem = unlockTime.difference(now);
      final days = unlockRem.inDays;
      final hours = unlockRem.inHours % 24;
      final mins = unlockRem.inMinutes % 60;
      final secs = unlockRem.inSeconds % 60;

      String countStr = "";
      if (days > 0) countStr += "${days}d ";
      if (hours > 0 || days > 0) countStr += "${hours.toString().padLeft(2, '0')}h ";
      countStr += "${mins.toString().padLeft(2, '0')}m ${secs.toString().padLeft(2, '0')}s";

      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFCD34D);
      text = const Color(0xFFD97706);
      icon = "⏳";
      label = "Opens in $countStr (5 Hrs Before Pickup)";
    } else if (diffHours < 1 && !isReEnabled) {
      bg = const Color(0xFFFFF1F2);
      border = const Color(0xFFFCA5A5);
      text = const Color(0xFFBE123C);
      icon = "⚠️";
      label = "Time expired to assign (Contact Admin: +919274453826)";
    } else {
      final days = rem.inDays;
      final hours = rem.inHours % 24;
      final mins = rem.inMinutes % 60;
      final secs = rem.inSeconds % 60;

      String countStr = "";
      if (days > 0) countStr += "${days}d ";
      if (hours > 0 || days > 0) countStr += "${hours.toString().padLeft(2, '0')}h ";
      countStr += "${mins.toString().padLeft(2, '0')}m ${secs.toString().padLeft(2, '0')}s";

      bg = const Color(0xFFF0FDF4);
      border = const Color(0xFF86EFAC);
      text = const Color(0xFF15803D);
      icon = "⏱";
      label = "Pickup in $countStr";
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: text,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
