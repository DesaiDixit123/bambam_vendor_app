import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleHistoryScreen extends StatelessWidget {
  const VehicleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final List bookings =
            controller.vehicleHistoryData?['bookings']?['list'] ?? [];
        final tripSummary =
            controller.vehicleHistoryData?['tripSummary'] ?? {};

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Vehicle History",
          ),
          body: controller.isVehicleHistoryLoading && bookings.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => controller.fetchVehicleHistory(),
                  child: ListView(
                    padding: Dimens.edgeInsets20,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      // ── Summary Cards ──────────────────────────────────
                      Row(
                        children: [
                          _summaryCard("Total Trips",
                              "${tripSummary['totalTrips'] ?? 0}",
                              ColorsValue.g1txtColor),
                          Dimens.boxWidth12,
                          _summaryCard("Completed",
                              "${tripSummary['completedTrips'] ?? 0}",
                              const Color(0xFF12724A)),
                          Dimens.boxWidth12,
                          _summaryCard("Cancelled",
                              "${tripSummary['cancelledTrips'] ?? 0}",
                              Colors.red),
                        ],
                      ),
                      Dimens.boxHeight20,

                      // ── Filter Row ─────────────────────────────────────
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
                                  controller.vehicleHistoryDate =
                                      Utility.getFormatedTime(
                                          picked.toString(), 'yyyy-MM-dd');
                                  controller.fetchVehicleHistory();
                                }
                              },
                              child: Container(
                                padding: Dimens.edgeInsets12,
                                decoration: BoxDecoration(
                                  color: ColorsValue.whiteColor,
                                  borderRadius:
                                      BorderRadius.circular(Dimens.eight),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.vehicleHistoryDate.isNotEmpty
                                            ? controller.vehicleHistoryDate
                                            : "Filter by Date",
                                        style:
                                            controller.vehicleHistoryDate.isNotEmpty
                                                ? Styles.g1txtColor60014
                                                : Styles.g7txtColor40014,
                                      ),
                                    ),
                                    Icon(Icons.calendar_today,
                                        size: 16, color: ColorsValue.l4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (controller.vehicleHistoryDate.isNotEmpty ||
                          controller.vehicleHistoryStatus.isNotEmpty) ...[
                        Dimens.boxHeight8,
                        TextButton(
                          onPressed: () {
                            controller.vehicleHistoryDate = "";
                            controller.vehicleHistoryStatus = "";
                            controller.fetchVehicleHistory();
                          },
                          child:
                              Text("Clear Filters", style: Styles.appColor60014),
                        ),
                      ],

                      Dimens.boxHeight20,

                      // ── Booking List ───────────────────────────────────
                      if (bookings.isEmpty && !controller.isVehicleHistoryLoading)
                        Center(
                          child: Padding(
                            padding: Dimens.edgeInsets40,
                            child: Column(
                              children: [
                                Icon(Icons.history,
                                    size: 64, color: ColorsValue.l4),
                                Dimens.boxHeight12,
                                Text("No Trip History Found",
                                    style: Styles.g7txtColor40016),
                              ],
                            ),
                          ),
                        )
                      else
                        ...bookings.map((item) => _buildBookingCard(item)),

                      Dimens.boxHeight20,
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _summaryCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: Dimens.edgeInsets12,
        decoration: BoxDecoration(
          color: ColorsValue.whiteColor,
          borderRadius: BorderRadius.circular(Dimens.twelve),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Styles.g7txtColor40012),
            Dimens.boxHeight4,
            Text(value,
                style: Styles.g1txtColor60020.copyWith(color: valueColor)),
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
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.vehicleHistoryStatus.isEmpty
              ? ""
              : controller.vehicleHistoryStatus,
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
            controller.vehicleHistoryStatus = value ?? "";
            controller.fetchVehicleHistory();
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> item) {
    final travelDetails = item['travelDetailsId'] ?? {};
    final explore = travelDetails['exploreId'] ?? {};
    final vehicle = item['vehicle_id'] ?? {};
    final status = item['booking_status'] ?? '';

    Color statusBg;
    Color statusTextColor;
    if (status == "Confirmed") {
      statusBg = const Color(0xFFFFF4E3);
      statusTextColor = const Color(0xFFFBB03B);
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorsValue.l4,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      child: Padding(
        padding: Dimens.edgeInsets16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row – key fields
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _field("Booking ID", "${item['booking_id'] ?? '-'}"),
                _field(
                  "Booking Date",
                  item['createdAt'] != null
                      ? Utility.getFormatedTime(
                          item['createdAt'], 'dd-MM-yyyy')
                      : '-',
                ),
                _field("Booking Type",
                    "${explore['trip_type'] ?? '-'}"),
                _field(
                  "Pickup",
                  explore['city'] != null
                      ? "${explore['city']}"
                      : "${explore['from'] ?? '-'}",
                ),
                _field(
                  "Pickup Date",
                  explore['pickup_date'] != null
                      ? Utility.getFormatedTime(
                          explore['pickup_date'], 'dd-MM-yyyy')
                      : '-',
                ),
                _field("Car",
                    "${vehicle['brand_name'] ?? '-'} (${vehicle['vehicle_type']?['name'] ?? '-'})"),
                _field("Total Fare",
                    "₹${item['total_payment'] ?? '-'}"),
              ],
            ),
            Dimens.boxHeight8,
            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(status,
                  style: Styles.g1txtColor60012.copyWith(
                      color: statusTextColor)),
            ),
            // Customer info
            if (travelDetails['traveler_name'] != null) ...[
              Dimens.boxHeight12,
              Divider(color: ColorsValue.l2, height: 0),
              Dimens.boxHeight12,
              Text("Customer Details", style: Styles.appColor60014),
              Dimens.boxHeight8,
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _field("Name",
                      "${travelDetails['traveler_name'] ?? '-'}"),
                  _field("Mobile",
                      "${travelDetails['traveler_mobile'] ?? '-'}"),
                  if (travelDetails['pickup_address'] != null)
                    _field("Pickup Address",
                        "${travelDetails['pickup_address']}"),
                  if (travelDetails['drop_address'] != null)
                    _field("Drop Address",
                        "${travelDetails['drop_address']}"),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Styles.g7txtColor40012),
        Dimens.boxHeight2,
        Text(value, style: Styles.g1txtColor60014),
      ],
    );
  }
}
