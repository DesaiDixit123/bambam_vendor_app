import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class BambamHubScreen extends StatelessWidget {
  const BambamHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.getDashboardCounts();
              await controller.getRides(loadMore: false);
            },
            child: ListView(
              controller: controller.rideScrollController,
              padding: Dimens.edgeInsets20,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                /// ================= FULL WIDTH DRIVERS CARD =================
                _buildDriversCard(controller),

                Dimens.boxHeight16,

                /// ================= BOOKINGS & REVENUE CARDS =================
                Row(
                  children: [
                    _buildHalfWidthCard(
                      title: "Bookings",
                      subtitle: "Total Booking",
                      value:
                          "${_safeInt(controller.dashboardCounts['total_bookings'])}",
                      buttonText: "View Bookings",
                      onTap: () {
                        RouteManagement.gotoTriplogoHomepage();
                      },
                    ),
                    Dimens.boxWidth16,
                    _buildHalfWidthCard(
                      title: "Revenue",
                      subtitle: "Total Revenue",
                      value:
                          "₹${_safeInt(controller.dashboardCounts['total_revenue'])}",
                      buttonText: "View Revenue",
                      onTap: () {
                        Get.to(() => const EarningsVaultscreen());
                      },
                    ),
                  ],
                ),

                Dimens.boxHeight20,

                /// ================= RIDES SUMMARY (4th PLACE) =================
                ridesSummarySection(controller),

                Dimens.boxHeight24,

                /// ================= NEW RIDE REQUESTS HEADER =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "New Ride Requests (${controller.newRides.where((e) => (e['ride_status'] ?? '').toString().toLowerCase() == 'pending').length})",
                      style: Styles.g1txtColor60016,
                    ),
                  ],
                ),
                Dimens.boxHeight16,
                ...controller.newRides.map((ride) {
                  final booking = ride['booking_id'] ?? {};
                  final travel = booking['travelDetailsId'] ?? {};
                  final vendorStatus = (ride['ride_status'] ?? '').toString();
                  final bookingStatus = (booking['booking_status'] ?? '')
                      .toString()
                      .toLowerCase();
                  final isExpired =
                      vendorStatus.toLowerCase() == 'expired' ||
                      bookingStatus == 'expired';

                  final isPending =
                      (vendorStatus.isEmpty ||
                          vendorStatus.toLowerCase() == 'pending') &&
                      !isExpired;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          final vendorRequestId =
                              ride['_id']; // 👈 vendorRequest id

                          await controller.getRideDetails(vendorRequestId);

                          Get.to(() => const RideDetilesScreen());
                        },

                        child: Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: ColorsValue.whiteColor,
                            borderRadius: BorderRadius.circular(Dimens.twelve),
                          ),
                          child: Padding(
                            padding: Dimens.edgeInsets16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 🔹 BOOKING ID
                                Row(
                                  spacing: Dimens.five,
                                  children: [
                                    Text(
                                      "Booking ID:",
                                      style: Styles.g6txtColor40012,
                                    ),
                                    Text(
                                      "${booking['booking_id'] ?? ''}",
                                      style: Styles.g1txtColor60018,
                                    ),
                                  ],
                                ),

                                Dimens.boxHeight8,

                                /// 🔹 TRIP TYPE
                                Text(
                                  (travel['trip_type'] ?? '')
                                      .toString()
                                      .replaceAll('_', ' '),
                                  style: Styles.g7txtColor40014,
                                ),

                                /// 🔹 ROUTE
                                Builder(builder: (context) {
                                  final from = Utility.getDisplayFrom(travel);
                                  final to = Utility.getDisplayTo(travel);
                                  final isLocal = travel['trip_type']?.toString().toLowerCase().contains('local') == true;
                                  if (isLocal || to == '-' || to.isEmpty) {
                                    return Text(from, style: Styles.g1txtColor60014);
                                  } else {
                                    return Text("$from → $to", style: Styles.g1txtColor60014);
                                  }
                                }),

                                Dimens.boxHeight4,

                                /// 🔹 DATE & TIME
                                Builder(builder: (context) {
                                  final isRoundTrip = travel['trip_type']?.toString().toLowerCase().contains('round') == true;
                                  final rawReturnDate = travel['retunDate'] ?? travel['retun_date'] ?? travel['returnDate'] ?? travel['return_date'] ?? booking['return_date'] ?? booking['retun_date'];
                                  
                                  return Wrap(
                                    spacing: Dimens.nine,
                                    runSpacing: 4.0,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: Dimens.five,
                                        children: [
                                          SvgPicture.asset(
                                            AssetConstants.calendar,
                                          ),
                                          Text(
                                            (isRoundTrip && rawReturnDate != null && rawReturnDate.toString().isNotEmpty)
                                                ? "${formatDate(travel['date'])} → ${formatDate(rawReturnDate.toString())}"
                                                : formatDate(travel['date']),
                                            style: Styles.g6txtColor40014,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: Dimens.five,
                                        children: [
                                          SvgPicture.asset(AssetConstants.clock),
                                          Text(
                                            travel['pickup_time'] ?? '',
                                            style: Styles.g6txtColor40014,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }),

                                Dimens.boxHeight5,

                                /// 🔹 FARE
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Vendor Fare",
                                      style: Styles.g6txtColor40012,
                                    ),
                                 Builder(builder: (_) {
                                   final fb = ride['fare_breakdown'] ?? booking['fare_breakdown'] ?? travel['fare_breakdown'];
                                   final num fareVal = double.tryParse((fb?['final_payable_amount'] ?? ride['collect_cash_amount'] ?? booking['total_payment'] ?? booking['payment_summary']?['final_trip_fare'] ?? 0).toString()) ?? 0;
                                   final String displayFareStr = (fareVal % 1 == 0) ? fareVal.toInt().toString() : fareVal.toStringAsFixed(2);
                                   return Text(
                                     "₹$displayFareStr",
                                     style: Styles.g1txtColor50016.copyWith(
                                       color: ColorsValue.greenColor,
                                     ),
                                   );
                                 }),
                                  ],
                                ),

                                Dimens.boxHeight15,

                                /// 🔹 STATUS HANDLER
                                if (isExpired)
                                  _buildStatusBadge(
                                    label: "Expired",
                                    backgroundColor: ColorsValue.redColor
                                        .withValues(alpha: 0.4),
                                    textColor: ColorsValue.redColor,
                                  )
                                else if (isPending)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            controller.showRideRejectDialog(
                                              ride['_id'],
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: ColorsValue.redColor,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimens.fifty,
                                                  ),
                                            ),
                                          ),
                                          child: Text(
                                            "Reject",
                                            style: Styles.redColor50014,
                                          ),
                                        ),
                                      ),
                                      Dimens.boxWidth12,
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            controller.handleConfirmTap(
                                              context,
                                              ride: ride,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ColorsValue.greenColor,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimens.fifty,
                                                  ),
                                            ),
                                          ),
                                          child: Text(
                                            "Confirm",
                                            style: Styles.whiteColorW60016,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  _buildDynamicStatusBadge(ride, booking),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Dimens.boxHeight12,
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget ridesSummarySection(HomeController controller) {
    return Container(
      padding: Dimens.edgeInsets20,
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.twenty),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text("Rides", style: Styles.appColor60020.copyWith()),

          Dimens.boxHeight16,

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rideColumn(
                title: "Assigned Rides",
                value: _safeInt(controller.dashboardCounts['assigned_rides']),
              ),
              _rideColumn(
                title: "Ongoing Rides",
                value: _safeInt(controller.dashboardCounts['ongoing_rides']),
              ),
              _rideColumn(
                title: "Completed Rides",
                value: _safeInt(controller.dashboardCounts['completed_rides']),
              ),
              _rideColumn(
                title: "Cancel rides",
                value: _safeInt(controller.dashboardCounts['cancelled_rides']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rideColumn({required String title, required int value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Styles.g7txtColor40014.copyWith(fontWeight: FontWeight.w500),
        ),
        Dimens.boxWidth10,
        Text(value.toString(), style: Styles.g1txtColor60020),
      ],
    );
  }

  /// ================= FULL WIDTH DRIVERS CARD =================
  Widget _buildDriversCard(HomeController controller) {
    final totalDrivers = _safeInt(controller.dashboardCounts['total_drivers']);
    final assignedRides = _safeInt(controller.dashboardCounts['assigned_rides']);
    final ongoingRides = _safeInt(controller.dashboardCounts['ongoing_rides']);
    final activeRides = assignedRides + ongoingRides;

    final availableDrivers = controller.dashboardCounts.containsKey('available_drivers')
        ? _safeInt(controller.dashboardCounts['available_drivers'])
        : (totalDrivers > activeRides ? totalDrivers - activeRides : totalDrivers);

    final busyDrivers = controller.dashboardCounts.containsKey('busy_drivers')
        ? _safeInt(controller.dashboardCounts['busy_drivers'])
        : (totalDrivers > availableDrivers ? totalDrivers - availableDrivers : activeRides);

    final unavailableDrivers = controller.dashboardCounts.containsKey('unavailable_drivers')
        ? _safeInt(controller.dashboardCounts['unavailable_drivers'])
        : 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.sixteen),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Drivers",
            style: Styles.appColor60020.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: ColorsValue.appColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Total Drivers",
            style: Styles.g7txtColor40014.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$totalDrivers",
            style: Styles.g1txtColor60020.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: Colors.grey.withValues(alpha: 0.15),
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDriverStatusItem(
                dotColor: const Color(0xFF0F9D58), // Green
                count: availableDrivers,
                label: "Available",
              ),
              _buildDriverStatusItem(
                dotColor: const Color(0xFFF4B400), // Amber/Orange
                count: busyDrivers,
                label: "Busy",
              ),
              _buildDriverStatusItem(
                dotColor: const Color(0xFFDB4437), // Red
                count: unavailableDrivers,
                label: "Unavailable",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: Colors.grey.withValues(alpha: 0.15),
            height: 1,
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(Dimens.fifty),
            onTap: () {
              controller.driverSearchController.clear();
              controller.drivers.clear();
              controller.driverPage = 1;
              controller.hasMoreDrivers = true;
              controller.getDrivers();
              controller.changeDrawerIndex(6);
            },
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorsValue.appColor,
                borderRadius: BorderRadius.circular(Dimens.fifty),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Manage Drivers",
                    style: Styles.whiteColorW60016.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatusItem({
    required Color dotColor,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "$count",
          style: Styles.g1txtColor60018.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Styles.g7txtColor40012.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// ================= HALF WIDTH CARD (Bookings & Revenue) =================
  Widget _buildHalfWidthCard({
    required String title,
    required String subtitle,
    required String value,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.twelve),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: ColorsValue.whiteColor,
            borderRadius: BorderRadius.circular(Dimens.twelve),
          ),
          padding: Dimens.edgeInsets16,
          child: Column(
            children: [
              Text(title, style: Styles.appColor60020),
              Dimens.boxHeight5,
              Text(subtitle, style: Styles.g7txtColor40012),
              Dimens.boxHeight5,
              Text(
                value,
                style: Styles.g1txtColor60020.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: Dimens.twentyEight,
                ),
              ),
              Dimens.boxHeight16,
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorsValue.appColor,
                  borderRadius: BorderRadius.circular(Dimens.fifty),
                ),
                padding: Dimens.edgeInsets11,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(buttonText, style: Styles.whiteColorW60012),
                    Dimens.boxWidth6,
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';

    final dateTime = DateTime.parse(isoDate).toLocal();

    return "${dateTime.day.toString().padLeft(2, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.year}";
  }

  Widget _buildStatusBadge({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: Dimens.edgeInsets12,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      child: Text(
        label,
        style: Styles.g1txtColor60016.copyWith(color: textColor),
      ),
    );
  }

  int _safeInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    final parsed = double.tryParse(val.toString());
    return parsed?.toInt() ?? 0;
  }
  static Map<String, dynamic> getStatusStyle(dynamic ride, dynamic booking) {
    final Map rideMap = (ride is Map) ? ride : {};
    final Map bookingMap = (booking is Map) ? booking : {};

    // 1. Direct API field driver_vehicle_allocation_status (from Driver & Vehicle Allocate API)
    final String directStatus = (rideMap['driver_vehicle_allocation_status'] ??
            bookingMap['driver_vehicle_allocation_status'] ??
            '').toString().trim();

    if (directStatus.isNotEmpty && directStatus != 'null') {
      final statusLower = directStatus.toLowerCase();
      if (statusLower.contains('allocated') || statusLower.contains('d & v allocated')) {
        return {'label': directStatus, 'bg': const Color(0xFFD9FFEF), 'text': const Color(0xFF12724A)};
      } else if (statusLower.contains('cancel')) {
        return {'label': 'Cancelled', 'bg': const Color(0xFFFFEBEB), 'text': const Color(0xFFD90000)};
      } else {
        return {'label': directStatus, 'bg': const Color(0xFFFFEBEB), 'text': const Color(0xFFD90000)};
      }
    }

    final String rideStatus = (rideMap['ride_status'] ?? '').toString().toLowerCase().trim();
    final String bookingStatus = (bookingMap['booking_status'] ?? '').toString().toLowerCase().trim();
    final String vendorStatus = (bookingMap['vendor_status'] ?? '').toString().toLowerCase().trim();

    if (rideStatus.contains('cancel') || bookingStatus.contains('cancel')) {
      return {'label': 'Cancelled', 'bg': const Color(0xFFFFEBEB), 'text': const Color(0xFFD90000)};
    }
    if (rideStatus.contains('reject') || vendorStatus.contains('reject')) {
      return {'label': 'Rejected', 'bg': const Color(0xFFFFEBEB), 'text': const Color(0xFFD90000)};
    }
    if (bookingStatus.contains('expire')) {
      return {'label': 'Expired', 'bg': const Color(0xFFFFEBEB), 'text': const Color(0xFFD90000)};
    }
    if (rideStatus.contains('completed') || bookingStatus.contains('completed')) {
      return {'label': 'Completed', 'bg': const Color(0xFFD9FFEF), 'text': const Color(0xFF12724A)};
    }
    if (rideStatus.contains('ongoing') || bookingStatus.contains('ongoing')) {
      return {'label': 'Ongoing', 'bg': const Color(0xFFE6F7FF), 'text': const Color(0xFF0050B3)};
    }
    if (rideStatus.contains('arrived') || bookingStatus.contains('arrived')) {
      return {'label': 'Driver Arrived', 'bg': const Color(0xFFFFF7E6), 'text': const Color(0xFFD46B08)};
    }
    if (vendorStatus == 'pending') {
      return {'label': 'Pending', 'bg': const Color(0xFFFFF3E0), 'text': const Color(0xFFE65100)};
    }

    final dynamic driverObj = rideMap['driver'] ?? rideMap['driverId'] ?? rideMap['driver_id'] ?? bookingMap['driver'] ?? bookingMap['driverId'] ?? bookingMap['driver_id'];
    final dynamic vehicleObj = rideMap['vehicle'] ?? rideMap['vehicleId'] ?? rideMap['vehicle_id'] ?? bookingMap['vehicle'] ?? bookingMap['vehicleId'] ?? bookingMap['vehicle_id'];

    final bool hasDriver = isValidObject(driverObj);
    final bool hasVehicle = isValidObject(vehicleObj);

    if (hasDriver && hasVehicle) {
      return {'label': 'Driver & Vehicle Allocated', 'bg': const Color(0xFFD9FFEF), 'text': const Color(0xFF12724A)};
    } else if (hasDriver && !hasVehicle) {
      return {'label': 'Vehicle Pending', 'bg': const Color(0xFFFFEBEB), 'text': const Color(0xFFD90000)};
    } else if (!hasDriver && hasVehicle) {
      return {'label': 'Driver Pending', 'bg': const Color(0xFFFFEBEB), 'text': const Color(0xFFD90000)};
    } else {
      return {'label': 'Driver & Vehicle Pending', 'bg': const Color(0xFFFFEBEB), 'text': const Color(0xFFD90000)};
    }
  }

  static bool isValidObject(dynamic val) {
    if (val == null) return false;
    final str = val.toString().trim();
    if (str.isEmpty || str == 'null' || str == '{}' || str == '[]') return false;
    if (val is Map && val.isEmpty) return false;
    return true;
  }

  Widget _buildDynamicStatusBadge(dynamic ride, dynamic booking) {
    final style = getStatusStyle(ride, booking);

    return _buildStatusBadge(
      label: style['label'] as String,
      backgroundColor: style['bg'] as Color,
      textColor: style['text'] as Color,
    );
  }
}
