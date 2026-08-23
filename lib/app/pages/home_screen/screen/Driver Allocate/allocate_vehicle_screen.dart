import 'dart:async';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class AllocateVehicleScreen extends StatelessWidget {
  const AllocateVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Allocate Vehicle",
            actions: [
              Dimens.boxWidth10,
              SvgPicture.asset(AssetConstants.search),
              Dimens.boxWidth20,
            ],
          ),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () async {
                final travelDetails = controller.allocationVehiclesData?['travelDetails'] ?? {};
                final pickupDt = _PickupCountdownBannerState.parsePickupDateTime(travelDetails);
                if (pickupDt != null) {
                  final diffHours = pickupDt.difference(DateTime.now()).inSeconds / 3600.0;
                  if (diffHours > 5) {
                    Utility.snacBar("Cannot assign vehicle before 5 hours of pickup.", Colors.red);
                    return;
                  }
                }

                if (controller.selectedVehicalrIndex != -1 &&
                    controller.allocationVehiclesData != null) {
                  final vehicles =
                      controller.allocationVehiclesData!['vehicles'] as List?;
                  if (vehicles != null &&
                      controller.selectedVehicalrIndex < vehicles.length) {
                    final selectedVehicle =
                        vehicles[controller.selectedVehicalrIndex];
                    final vehicleId = selectedVehicle['_id'];
                    final vendorRequestId = controller.currentAllocationId;

                    if (vehicleId != null && vendorRequestId != null) {
                      await controller.assignVehicleRealToAllocation(
                        vendorRequestId,
                        vehicleId,
                      );
                    } else {
                      Utility.snacBar("Missing required IDs", Colors.red);
                    }
                  }
                } else {
                  Utility.snacBar("Please select a vehicle first", Colors.red);
                }
              },
              text: "Save & Assign",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: controller.isAllocationVehiclesLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.allocationVehiclesData == null
              ? const Center(child: Text("No vehicle data available"))
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
                                      "${controller.allocationVehiclesData!['booking']?['booking_id'] ?? ''}",
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
                                      Utility.getFormatedTime(controller.allocationVehiclesData!['travelDetails']?['date'] ?? DateTime.now().toString(), 'dd-MM-yyyy'),
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
                                      "${Utility.getFormatedTime(controller.allocationVehiclesData!['travelDetails']?['date'] ?? DateTime.now().toString(), 'dd-MM-yyyy')} / ${controller.allocationVehiclesData!['travelDetails']?['pickup_time'] ?? ''}",
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
                                      "${controller.allocationVehiclesData!['travelDetails']?['trip_type'] ?? ''}",
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Dimens.boxHeight16,

                    _PickupCountdownBanner(
                      travelDetails: controller.allocationVehiclesData!['travelDetails'] ?? {},
                      booking: controller.allocationVehiclesData!['booking'],
                    ),

                    ...(controller.allocationVehiclesData!['vehicles'] as List? ?? []).asMap().entries.map((
                      entry,
                    ) {
                      int index = entry.key;
                      dynamic vehicle = entry.value;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (controller.selectedVehicalrIndex == index) {
                                controller.selectedVehicalrIndex = -1;
                              } else {
                                controller.selectedVehicalrIndex = index;
                              }
                              controller.update();
                              // controller.selectedVehicleId = vehicle['_id'];
                              // controller.vehicleHistoryData = null;
                              // controller.vehicleHistoryStatus = "";
                              // controller.vehicleHistoryDate = "";
                              // controller.fetchVehicleHistory();
                              // RouteManagement.gotoVehicleHistoryScreen();
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
                                          "${vehicle['vehicle_number'] ?? ''}",
                                          style: Styles.g1txtColor60016,
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          height: Dimens.sixteen,
                                          child: Checkbox(
                                            value:
                                                controller
                                                    .selectedVehicalrIndex ==
                                                index,
                                            checkColor: Colors.white,
                                            fillColor:
                                                WidgetStateProperty.resolveWith<
                                                  Color
                                                >((states) {
                                                  if (states.contains(
                                                    WidgetState.selected,
                                                  )) {
                                                    return ColorsValue.appColor;
                                                  }
                                                  return Colors.transparent;
                                                }),
                                            side: BorderSide(
                                              color: ColorsValue.appColor,
                                              width: 2,
                                            ),
                                            onChanged: (value) {
                                              if (value == true) {
                                                controller
                                                        .selectedVehicalrIndex =
                                                    index;
                                              } else {
                                                controller
                                                        .selectedVehicalrIndex =
                                                    -1;
                                              }
                                              controller.update();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Dimens.boxHeight12,
                                    Divider(color: ColorsValue.l2),
                                    ListTile(
                                      contentPadding: Dimens.edgeInsets0,
                                      leading:
                                          vehicle['vehicle_type'] != null &&
                                              vehicle['vehicle_type']['vehicle_photo'] !=
                                                  null
                                          ? Image.network(
                                              vehicle['vehicle_type']['vehicle_photo'],
                                              height: Dimens.sixty,
                                              width: Dimens.eighty,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Image.asset(
                                                    AssetConstants.carpng,
                                                    height: Dimens.sixty,
                                                    width: Dimens.eighty,
                                                  ),
                                            )
                                          : Image.asset(
                                              AssetConstants.carpng,
                                              height: Dimens.sixty,
                                              width: Dimens.eighty,
                                            ),
                                      title: Text(
                                        "${vehicle['brand_name'] ?? ''}",
                                        style: Styles.g1txtColor60016,
                                      ),
                                      subtitle: Text(
                                        "${vehicle['vehicle_type']?['name'] ?? ''}",
                                        style: Styles.g7txtColor40014,
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
