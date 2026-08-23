import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';

class DriverHistorysScreen extends StatelessWidget {
  const DriverHistorysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final driver = controller.selectedDriver;
        if (controller.isDriverDetailLoading || driver == null) {
          return Scaffold(
            backgroundColor: ColorsValue.l3,
            appBar: AppBarWidget(
              onTapBack: () => Get.back(),
              title: "Driver History",
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final bookings = controller.driverHistoryData?['bookings']?['list'] ?? [];
        final tripSummary = controller.driverHistoryData?['tripSummary'] ?? {};

        String formatDate(String? dateStr) {
          if (dateStr == null) return "N/A";
          try {
            return DateFormat("dd-MM-yyyy").format(DateTime.parse(dateStr));
          } catch (e) {
            return dateStr;
          }
        }

        String getListNames(List<dynamic>? list) {
          if (list == null || list.isEmpty) return "N/A";
          return list.map((e) => e['name'].toString()).join(", ");
        }

        int totalDocs = controller.driverHistoryTotalDocs;
        int limit = controller.driverHistoryLimit;
        int currentPage = controller.driverHistoryCurrentPage;
        int totalPages = (totalDocs / limit).ceil();
        if (totalPages == 0) totalPages = 1;

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Driver History",
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.getDriverDetails(driver['_id']);
            },
            child: ListView(
              padding: Dimens.edgeInsets20,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                // ── Section 1: Driver Information ────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: ColorsValue.whiteColor,
                    borderRadius: BorderRadius.circular(Dimens.twelve),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: Dimens.edgeInsets16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Driver Information",
                          style: Styles.appColor60020,
                        ),
                        Dimens.boxHeight16,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Driver Photo
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimens.eight),
                                  child: Image.network(
                                    "${ApiWrapper.imageUrl}${driver['driver_photo']}",
                                    height: Dimens.eighty,
                                    width: Dimens.eighty,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Image.asset(
                                          AssetConstants.person,
                                          height: Dimens.eighty,
                                          width: Dimens.eighty,
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                                ),
                                Dimens.boxHeight4,
                                Text(
                                  "Driver Photo",
                                  style: Styles.g7txtColor40012,
                                ),
                              ],
                            ),
                            Dimens.boxWidth16,
                            // DL Image
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimens.eight),
                                  child: Image.network(
                                    "${ApiWrapper.imageUrl}${driver['DL_photo']}",
                                    height: Dimens.eighty,
                                    width: Dimens.eighty,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Image.asset(
                                          AssetConstants.driving_licence_Imge,
                                          height: Dimens.eighty,
                                          width: Dimens.eighty,
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                                ),
                                Dimens.boxHeight4,
                                Text(
                                  "DL Image",
                                  style: Styles.g7txtColor40012,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Dimens.boxHeight16,
                        Divider(color: ColorsValue.l3, height: 1),
                        Dimens.boxHeight12,
                        _infoGridRow([
                          _infoField("Driver Name", driver['driver_name'] ?? "N/A"),
                          _infoField("Mobile No.", driver['driver_mobile'] != null ? "+91 ${driver['driver_mobile']}" : "N/A"),
                        ]),
                        Dimens.boxHeight12,
                        _infoGridRow([
                          _infoField("Date of Birth", formatDate(driver['dob'])),
                          _infoField("DL Number", driver['DL_number'] ?? "N/A"),
                        ]),
                        Dimens.boxHeight12,
                        _infoGridRow([
                          _infoField("DL Issue Date", formatDate(driver['DL_issue_date'])),
                          _infoField("DL Validity", formatDate(driver['DL_validity'] ?? driver['DL_expiry_date'])),
                        ]),
                        Dimens.boxHeight12,
                        _infoGridRow([
                          _infoField("Languages Known", getListNames(driver['language_known'])),
                          _infoField("Vehicles Driven", getListNames(driver['vehicales_drive'])),
                        ]),
                        Dimens.boxHeight12,
                        _infoGridRow([
                          _infoField("Register Date", formatDate(driver['created_at'])),
                          _infoField("Location", "${driver['city'] ?? ''}${driver['city'] != null && driver['state'] != null ? ', ' : ''}${driver['state'] ?? ''}"),
                        ]),
                      ],
                    ),
                  ),
                ),
                Dimens.boxHeight20,

                // ── Section 2: Trip History Analytics & Filters ─────────────────
                Text(
                  "Trip History",
                  style: Styles.g1txtColor60018.copyWith(
                    color: ColorsValue.appColor,
                    fontSize: 20,
                  ),
                ),
                Dimens.boxHeight12,

                // Summary Cards
                Row(
                  children: [
                    _summaryCard(
                      "Total Trips",
                      "${tripSummary['totalTrips'] ?? 0}",
                      ColorsValue.g1txtColor,
                    ),
                    Dimens.boxWidth12,
                    _summaryCard(
                      "Completed Trips",
                      "${tripSummary['completedTrips'] ?? 0}",
                      const Color(0xFF12724A),
                    ),
                    Dimens.boxWidth12,
                    _summaryCard(
                      "Cancelled Trips",
                      "${tripSummary['cancelledTrips'] ?? 0}",
                      const Color(0xFFFF3B30),
                    ),
                  ],
                ),
                Dimens.boxHeight16,

                // Filters Row (Dropdown + Date)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusDropdown(controller),
                    ),
                    Dimens.boxWidth12,
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            controller.driverHistoryDate =
                                Utility.getFormatedTime(picked.toString(), 'yyyy-MM-dd');
                            controller.fetchDriverHistory(page: 1);
                          }
                        },
                        child: Container(
                          padding: Dimens.edgeInsets12,
                          decoration: BoxDecoration(
                            color: ColorsValue.whiteColor,
                            borderRadius: BorderRadius.circular(Dimens.eight),
                            border: Border.all(color: ColorsValue.l2),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.driverHistoryDate.isNotEmpty
                                      ? controller.driverHistoryDate
                                      : "Filter by Date",
                                  style: controller.driverHistoryDate.isNotEmpty
                                      ? Styles.g1txtColor60014
                                      : Styles.g7txtColor40014,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: ColorsValue.g6txtColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (controller.driverHistoryDate.isNotEmpty ||
                    controller.driverHistoryStatus.isNotEmpty) ...[
                  Dimens.boxHeight8,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        controller.driverHistoryDate = "";
                        controller.driverHistoryStatus = "";
                        controller.fetchDriverHistory(page: 1, clear: true);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text("Clear Filters", style: Styles.appColor60014),
                    ),
                  ),
                ],

                Dimens.boxHeight16,

                // ── Section 3: Booking List or Empty State ────────────────────
                if (controller.isDriverHistoryLoading && bookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (bookings.isEmpty)
                  // Empty History State matching exactly the Vendor Website
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: ColorsValue.whiteColor,
                      borderRadius: BorderRadius.circular(Dimens.twelve),
                      border: Border.all(color: ColorsValue.l2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 64,
                          color: Color(0xFF748194),
                        ),
                        Dimens.boxHeight16,
                        Text(
                          "History Not Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorsValue.g1txtColor,
                          ),
                        ),
                        Dimens.boxHeight8,
                        const Text(
                          "This user does not have any Trip history",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF748194),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else ...[
                  // List of Bookings
                  ...List.generate(bookings.length, (index) {
                    final item = bookings[index];
                    final isExpanded = controller.expandedBookings[index] ?? false;
                    return _buildBookingCard(item, index, isExpanded, controller);
                  }),

                  // Pagination controls
                  Dimens.boxHeight16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentPage > 1
                            ? () => controller.fetchDriverHistory(page: currentPage - 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.appColor,
                          disabledBackgroundColor: ColorsValue.l2,
                        ),
                        child: const Text("Prev", style: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        "Page $currentPage of $totalPages",
                        style: Styles.g1txtColor60014,
                      ),
                      ElevatedButton(
                        onPressed: currentPage < totalPages
                            ? () => controller.fetchDriverHistory(page: currentPage + 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.appColor,
                          disabledBackgroundColor: ColorsValue.l2,
                        ),
                        child: const Text("Next", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
                Dimens.boxHeight20,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoGridRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children[0]),
        Dimens.boxWidth12,
        Expanded(child: children[1]),
      ],
    );
  }

  Widget _infoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Styles.g7txtColor40012,
        ),
        Dimens.boxHeight2,
        Text(
          value,
          style: Styles.g1txtColor60014,
        ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: Dimens.edgeInsets12,
        decoration: BoxDecoration(
          color: ColorsValue.whiteColor,
          borderRadius: BorderRadius.circular(Dimens.twelve),
          border: Border.all(color: ColorsValue.l2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Styles.g7txtColor40012),
            Dimens.boxHeight4,
            Text(
              value,
              style: Styles.g1txtColor60020.copyWith(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(HomeController controller) {
    const statuses = [
      "",
      "Confirmed",
      "Cancelled",
      "Completed",
      "D & V Allocated",
      "PAYMENT_PENDING",
      "PAYMENT_FAILED",
    ];
    const labels = [
      "All",
      "Confirmed",
      "Cancelled",
      "Completed",
      "D & V Allocated",
      "Payment Pending",
      "Payment Failed",
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.eight),
        border: Border.all(color: ColorsValue.l2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.driverHistoryStatus.isEmpty
              ? ""
              : controller.driverHistoryStatus,
          isExpanded: true,
          hint: Text("Filter by Status", style: Styles.g7txtColor40014),
          items: List.generate(
            statuses.length,
            (i) => DropdownMenuItem(
              value: statuses[i],
              child: Text(labels[i], style: Styles.g1txtColor60014),
            ),
          ),
          onChanged: (value) {
            controller.driverHistoryStatus = value ?? "";
            controller.fetchDriverHistory(page: 1);
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> item, int index, bool isExpanded, HomeController controller) {
    final travelDetails = item['travelDetailsId'] ?? {};
    final explore = travelDetails['exploreId'] ?? {};
    final vehicle = item['vehicle_id'] ?? {};
    final status = item['booking_status'] ?? '';

    Color statusBg;
    Color statusTextColor;
    if (status == "Confirmed") {
      statusBg = const Color(0xFFFFF2ED);
      statusTextColor = const Color(0xFFFF5A00);
    } else if (status == "Cancelled") {
      statusBg = const Color(0xFFFFE4E3);
      statusTextColor = const Color(0xFFFF3B30);
    } else if (status == "D & V Allocated") {
      statusBg = const Color(0xFFD7F8FF);
      statusTextColor = const Color(0xFF00C0E8);
    } else {
      statusBg = const Color(0xFFD9FFEF);
      statusTextColor = const Color(0xFF12724A);
    }

    final formattedBookingDate = item['createdAt'] != null
        ? Utility.getFormatedTime(item['createdAt'], 'dd-MM-yyyy')
        : '-';

    final formattedPickupDate = explore['pickup_date'] != null
        ? Utility.getFormatedTime(explore['pickup_date'], 'dd-MM-yyyy')
        : '-';

    final returnDate = explore['return_date'] != null
        ? Utility.getFormatedTime(explore['return_date'], 'dd-MM-yyyy')
        : null;

    final fareSummary = travelDetails['fare_summary'] ?? {};
    final features = travelDetails['vehicleId']?['vehicles_features'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isExpanded ? const Color(0xFFFFF2ED) : ColorsValue.l4,
        borderRadius: BorderRadius.circular(Dimens.twelve),
        border: Border.all(color: isExpanded ? ColorsValue.appColor.withOpacity(0.3) : ColorsValue.l2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Dimens.edgeInsets16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top fields grid
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    _bookingField("Booking ID", "${item['booking_id'] ?? '-'}"),
                    _bookingField("Booking Date", formattedBookingDate),
                    _bookingField("Booking Type", "${explore['trip_type'] ?? '-'}"),
                    _bookingField(
                      explore['city'] != null ? "City" : "Route",
                      explore['city'] != null
                          ? "${explore['city']}"
                          : "${explore['from'] ?? '-'} → ${(explore['to'] is List ? (explore['to'] as List).join(' → ') : explore['to'] ?? '-')}",
                    ),
                    _bookingField("Pickup Time", "$formattedPickupDate ${explore['pickup_time'] ?? ''}"),
                    if (returnDate != null) _bookingField("Return Date", returnDate),
                    _bookingField(
                      "Car",
                      "${vehicle['brand_name'] ?? '-'} (${vehicle['vehicle_type']?['name'] ?? '-'})",
                    ),
                    _bookingField("Total Fare", "₹${item['total_payment'] ?? '-'}"),
                  ],
                ),
                Dimens.boxHeight12,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: Styles.g1txtColor60012.copyWith(color: statusTextColor),
                      ),
                    ),
                    // Expand/Collapse text
                    InkWell(
                      onTap: () => controller.toggleBookingExpansion(index),
                      child: Text(
                        isExpanded ? "View Less Details" : "View More Details",
                        style: Styles.appColor60014.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (isExpanded) ...[
            Divider(color: ColorsValue.l2, height: 1),
            Container(
              color: ColorsValue.whiteColor,
              padding: Dimens.edgeInsets16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Car & Features Section
                  Text(
                    "Car & Features",
                    style: Styles.appColor60014,
                  ),
                  Dimens.boxHeight10,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (vehicle['vehicle_type']?['vehicle_photo'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "${ApiWrapper.imageUrl}${vehicle['vehicle_type']?['vehicle_photo']}",
                            height: 60,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(width: 0),
                          ),
                        ),
                      Dimens.boxWidth12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${vehicle['brand_name'] ?? 'N/A'}",
                              style: Styles.g1txtColor60016,
                            ),
                            Text(
                              "${vehicle['vehicle_type']?['name'] ?? 'N/A'}",
                              style: Styles.g7txtColor40014,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (features.isNotEmpty) ...[
                    Dimens.boxHeight10,
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: List.generate(features.length, (fIndex) {
                        final feature = features[fIndex];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (feature['logo'] != null)
                              Image.network(
                                "${ApiWrapper.imageUrl}${feature['logo']}",
                                height: 16,
                                width: 16,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(width: 0),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              "${feature['description'] ?? ''}",
                              style: Styles.g7txtColor40012,
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                  Dimens.boxHeight16,
                  Divider(color: ColorsValue.l3),
                  Dimens.boxHeight8,

                  // B. Customer Details Section
                  Text(
                    "Customer Details",
                    style: Styles.appColor60014,
                  ),
                  Dimens.boxHeight8,
                  _detailRow("Customer Name", "${travelDetails['traveler_name'] ?? 'N/A'}"),
                  _detailRow("Mobile No.", "${travelDetails['traveler_mobile'] ?? 'N/A'}"),
                  _detailRow("Pickup Address", "${travelDetails['pickup_address'] ?? 'N/A'}"),
                  if (travelDetails['drop_address'] != null)
                    _detailRow("Drop Address", "${travelDetails['drop_address']}"),
                  
                  Dimens.boxHeight16,
                  Divider(color: ColorsValue.l3),
                  Dimens.boxHeight8,

                  // C. Fare Summary Section
                  Builder(builder: (_) {
                    final fb = item['vendorRequestDetails']?['fare_breakdown'] ?? item['fare_breakdown'] ?? travelDetails['fare_summary'];
                    final bool isCompleted = status.toLowerCase().contains('complete') || status.toLowerCase() == 'payment pending';

                    String formatP(dynamic val) {
                      if (val == null) return "0";
                      final numVal = double.tryParse(val.toString()) ?? 0.0;
                      if (numVal % 1 == 0) return numVal.toInt().toString();
                      return numVal.toStringAsFixed(2);
                    }

                    if (isCompleted && fb != null && (fb['base_fare'] != null || fb['final_payable_amount'] != null)) {
                      final baseFare = fb['base_fare'] ?? 0;
                      final waitingCharge = fb['waiting_charge'] ?? 0;
                      final extraKm = fb['extra_km'] ?? 0;
                      final perKmRate = fb['per_km_price'] ?? 0;
                      final extraKmCharge = fb['extra_km_charge'] ?? 0;
                      final discount = fb['discount_amount'] ?? 0;
                      final gstAmt = fb['gst_amount'] ?? 0;
                      final gstPct = fb['gst_percent'] ?? 5;
                      final finalPayable = fb['final_payable_amount'] ?? fareSummary['total_fare'] ?? 0;
                      final actualDist = item['actual_distance_km'] ?? item['vendorRequestDetails']?['actual_distance_km'] ?? 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Fare Summary", style: Styles.appColor60014),
                          Dimens.boxHeight8,
                          if ((double.tryParse(baseFare.toString()) ?? 0) > 0)
                            _fareItem("Base Fare", "₹${formatP(baseFare)}"),
                          if ((double.tryParse(waitingCharge.toString()) ?? 0) > 0)
                            _fareItem("Waiting Charges", "₹${formatP(waitingCharge)}"),
                          if ((double.tryParse(actualDist.toString()) ?? 0) > 0)
                            _fareItem("Total Distance", "${formatP(actualDist)} km"),
                          if ((double.tryParse(extraKm.toString()) ?? 0) > 0)
                            _fareItem("Extra KM", "${formatP(extraKm)} km"),
                          if ((double.tryParse(perKmRate.toString()) ?? 0) > 0 && (double.tryParse(extraKm.toString()) ?? 0) > 0)
                            _fareItem("Per KM Rate", "₹${formatP(perKmRate)}/km"),
                          if ((double.tryParse(extraKmCharge.toString()) ?? 0) > 0)
                            _fareItem("Extra KM Charges", "₹${formatP(extraKmCharge)}"),
                          if ((double.tryParse(discount.toString()) ?? 0) > 0)
                            _fareItem("Coupon Discount", "-₹${formatP(discount)}", valueColor: const Color(0xFF12724A)),
                          if ((double.tryParse(gstAmt.toString()) ?? 0) > 0)
                            _fareItem("GST ($gstPct%)", "₹${formatP(gstAmt)}"),
                          Dimens.boxHeight8,
                          Divider(color: ColorsValue.l3),
                          Dimens.boxHeight8,
                          _fareItem(
                            "Total Fare",
                            "₹${formatP(finalPayable)}",
                            isBold: true,
                            valueColor: const Color(0xFF12724A),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fare Summary", style: Styles.appColor60014),
                        Dimens.boxHeight8,
                        _fareItem("Base Fare", "₹${fareSummary['base_fare'] ?? '0'}"),
                        if (fareSummary['gst_amount'] != null && (fareSummary['gst_amount'] as num) > 0)
                          _fareItem("GST", "₹${fareSummary['gst_amount']}"),
                        if (fareSummary['special_services'] != null && (fareSummary['special_services'] as num) > 0)
                          _fareItem("Special Services", "₹${fareSummary['special_services']}"),
                        if (fareSummary['coupon_discount'] != null && (fareSummary['coupon_discount'] as num) > 0)
                          _fareItem(
                            "Coupon Discount${travelDetails['offers_id']?['offer_code'] != null ? ' (${travelDetails['offers_id']['offer_code']})' : ''}",
                            "-₹${fareSummary['coupon_discount']}",
                            valueColor: const Color(0xFF12724A),
                          ),
                        Dimens.boxHeight8,
                        Divider(color: ColorsValue.l3),
                        Dimens.boxHeight8,
                        _fareItem(
                          "Total Fare",
                          "₹${fareSummary['total_fare'] ?? '0'}",
                          isBold: true,
                          valueColor: const Color(0xFF12724A),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _bookingField(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Styles.g7txtColor40012),
          Dimens.boxHeight2,
          Text(
            value,
            style: Styles.g1txtColor60014,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Styles.g7txtColor40014,
            ),
          ),
          Dimens.boxWidth12,
          Expanded(
            child: Text(
              value,
              style: Styles.g1txtColor60014,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fareItem(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? Styles.g1txtColor60016
                : Styles.g7txtColor40014,
          ),
          Text(
            value,
            style: isBold
                ? Styles.g1txtColor60016.copyWith(color: valueColor)
                : Styles.g1txtColor60014.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
