import 'dart:async';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String _allTripsValue = '__all_trips__';

class DriverAllocatehomeScreen extends StatelessWidget {
  const DriverAllocatehomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,

          body: RefreshIndicator(
            onRefresh: () async {
              await controller.getDriverAllocations(page: 1);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: Dimens.edgeInsets20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Allocate Driver & Vehicle for Booking",
                    style: Styles.g1txtColor60020,
                  ),
                  Dimens.boxHeight16,

                  // Filters Section
                  Row(
                    children: [
                      // Search Field
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            onChanged: (value) {
                              controller.allocationSearchText = value;
                            },
                            decoration: InputDecoration(
                              hintText: "Search",
                              prefixIcon: Icon(
                                Icons.search,
                                color: ColorsValue.g7txtColor,
                              ),
                              filled: true,
                              fillColor: ColorsValue.whiteColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimens.eight),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Dimens.boxWidth16,

                      // Trip Type Dropdown
                      Expanded(child: _buildTripTypeDropdown(controller)),
                    ],
                  ),
                  Dimens.boxHeight16,

                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  controller.allocationStartDate ??
                                  DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              controller.allocationStartDate = date;
                              controller.update();
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsValue.whiteColor,
                              borderRadius: BorderRadius.circular(Dimens.eight),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.allocationStartDate != null
                                        ? Utility.getFormatedTime(
                                            controller.allocationStartDate
                                                .toString(),
                                            'dd/MM/yyyy',
                                          )
                                        : "Start Date",
                                    style:
                                        controller.allocationStartDate != null
                                        ? Styles.g1txtColor60014
                                        : Styles.g7txtColor40014,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: ColorsValue.l4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Dimens.boxWidth16,

                      // End Date
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  controller.allocationEndDate ??
                                  DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              controller.allocationEndDate = date;
                              controller.update();
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsValue.whiteColor,
                              borderRadius: BorderRadius.circular(Dimens.eight),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.allocationEndDate != null
                                        ? Utility.getFormatedTime(
                                            controller.allocationEndDate
                                                .toString(),
                                            'dd/MM/yyyy',
                                          )
                                        : "End Date",
                                    style: controller.allocationEndDate != null
                                        ? Styles.g1txtColor60014
                                        : Styles.g7txtColor40014,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: ColorsValue.l4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Dimens.boxHeight16,

                  // Apply Filter Button
                  Row(
                    children: [
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.filterAllocations();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsValue.appColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimens.eight),
                            ),
                          ),
                          child: Text(
                            "Apply Filters",
                            style: Styles.whiteColorW60016,
                          ),
                        ),
                      ),
                      Dimens.boxWidth12,
                      TextButton(
                        onPressed: () {
                          controller.clearAllocationFilters();
                        },
                        child: Text("Clear", style: Styles.appColor60014),
                      ),
                    ],
                  ),
                  Dimens.boxHeight16,

                  // Table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorsValue.whiteColor,
                        borderRadius: BorderRadius.circular(Dimens.twelve),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table Header
                          Container(
                            decoration: BoxDecoration(
                              color: ColorsValue.l2,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(Dimens.twelve),
                                topRight: Radius.circular(Dimens.twelve),
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Booking ID",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Booking Date",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Booking Type",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Trip Itinerary",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Pickup Date & Time",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Return Date",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 250,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Vehicle",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Status",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Vendor Fare",
                                        style: Styles.g1txtColor60014,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: const Color(0xffD8E2EF),
                                  ),
                                  SizedBox(
                                    width: 170,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Actions",
                                        style: Styles.g1txtColor60014,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Table Content Rows / Loading / Empty State
                          if (controller.isAllocationsLoading &&
                              controller.driverAllocationsList.isEmpty)
                            Container(
                              width: 1599,
                              padding: const EdgeInsets.only(
                                left: 24,
                                top: 40,
                                bottom: 40,
                              ),
                              alignment: Alignment.centerLeft,
                              child: const CircularProgressIndicator(),
                            )
                          else if (controller.driverAllocationsList.isEmpty)
                            Container(
                              width: 1599,
                              padding: const EdgeInsets.only(
                                left: 24,
                                top: 40,
                                bottom: 40,
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "No Data Available",
                                style: Styles.g7txtColor40016,
                              ),
                            )
                          else
                            ...controller.driverAllocationsList.map((item) {
                              final booking = item['booking'] ?? {};
                              final travel = item['travelDetails'] ?? {};

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: ColorsValue.l2,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // 1. Booking ID
                                      SizedBox(
                                        width: 150,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: Text(
                                            "${booking['booking_id'] != null ? '#' : ''}${booking['booking_id'] ?? ''}",
                                            style: Styles.g7txtColor40014,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 2. Booking Date
                                      SizedBox(
                                        width: 120,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: Text(
                                            Utility.getFormatedTime(
                                              booking['createdAt'] ??
                                                  travel['date'] ??
                                                  DateTime.now().toString(),
                                              'dd/MM/yyyy',
                                            ),
                                            style: Styles.g7txtColor40014,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 3. Booking Type
                                      SizedBox(
                                        width: 120,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: Text(
                                            "${travel['trip_type'] ?? ''}",
                                            style: Styles.g7txtColor40014,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 4. Trip Itinerary
                                      SizedBox(
                                        width: 200,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: Text(
                                            "${Utility.getDisplayFrom(travel)} → ${Utility.getDisplayTo(travel)}",
                                            style: Styles.g7txtColor40014,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 5. Pickup Date & Time
                                      SizedBox(
                                        width: 200,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: Text(
                                            "${Utility.getFormatedTime(travel['date'] ?? DateTime.now().toString(), 'dd/MM/yyyy')} ${(travel['pickup_time'] ?? '')}",
                                            style: Styles.g7txtColor40014,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 6. Return Date
                                      SizedBox(
                                        width: 120,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: Text(
                                            (travel['trip_type']?.toString().toLowerCase().contains('round') == true &&
                                                    travel['return_date'] != null &&
                                                    travel['return_date'].toString().isNotEmpty &&
                                                    travel['return_date'].toString() != 'null')
                                                ? Utility.getFormatedTime(
                                                    travel['return_date'].toString(),
                                                    'dd/MM/yyyy',
                                                  )
                                                : "-",
                                            style: Styles.g7txtColor40014,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 7. Vehicle
                                      SizedBox(
                                        width: 250,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: _buildVehicleCell(item, booking, travel),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 8. Status
                                      SizedBox(
                                        width: 180,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: _buildStatusBadge(
                                            item,
                                            booking,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 9. Vendor Fare
                                      SizedBox(
                                        width: 130,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 16.0,
                                          ),
                                          child: Builder(builder: (_) {
                                            final fareVal = double.tryParse((travel['fare_summary']?['total_fare'] ?? travel['total_fare'] ?? booking['payment_summary']?['total_fare'] ?? booking['payment_summary']?['final_trip_fare'] ?? 0).toString()) ?? 0;
                                            return Text(
                                              "₹${fareVal.round()}",
                                              style: Styles.g1txtColor60014.copyWith(
                                                color: ColorsValue.greenColor,
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color: const Color(0xffD8E2EF),
                                      ),
                                      // 10. Actions
                                      SizedBox(
                                        width: 170,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 10.0,
                                          ),
                                          child: Center(
                                            child: _AssignmentActionCell(
                                              item: item,
                                              booking: booking,
                                              travel: travel,
                                              controller: controller,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),

                  Dimens.boxHeight20,

                  // Pagination
                  if (controller.driverAllocationsList.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // First Page
                        IconButton(
                          onPressed: controller.allocationCurrentPage > 1
                              ? () => controller.changeAllocationPage(1)
                              : null,
                          icon: Icon(Icons.first_page),
                          color: ColorsValue.appColor,
                        ),

                        // Previous Page
                        IconButton(
                          onPressed: controller.allocationCurrentPage > 1
                              ? () => controller.changeAllocationPage(
                                  controller.allocationCurrentPage - 1,
                                )
                              : null,
                          icon: Icon(Icons.chevron_left),
                          color: ColorsValue.appColor,
                        ),

                        // Current Page Indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: ColorsValue.appColor,
                            borderRadius: BorderRadius.circular(Dimens.eight),
                          ),
                          child: Text(
                            "${controller.allocationCurrentPage}",
                            style: Styles.whiteColorW60016,
                          ),
                        ),

                        // Next Page
                        IconButton(
                          onPressed:
                              controller.allocationCurrentPage <
                                  controller.allocationTotalPages
                              ? () => controller.changeAllocationPage(
                                  controller.allocationCurrentPage + 1,
                                )
                              : null,
                          icon: Icon(Icons.chevron_right),
                          color: ColorsValue.appColor,
                        ),

                        // Last Page
                        IconButton(
                          onPressed:
                              controller.allocationCurrentPage <
                                  controller.allocationTotalPages
                              ? () => controller.changeAllocationPage(
                                  controller.allocationTotalPages,
                                )
                              : null,
                          icon: Icon(Icons.last_page),
                          color: ColorsValue.appColor,
                        ),

                        Dimens.boxWidth20,

                        // Items per page
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 0,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsValue.whiteColor,
                              borderRadius: BorderRadius.circular(Dimens.eight),
                              border: Border.all(color: ColorsValue.l2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: controller.allocationLimit,
                                items: [10, 20, 50, 100].map((limit) {
                                  return DropdownMenuItem(
                                    value: limit,
                                    child: Text("$limit"),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.allocationLimit = value;
                                    controller.update();
                                    controller.filterAllocations();
                                  }
                                },
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
      },
    );
  }

  Widget _buildTripTypeDropdown(HomeController controller) {
    final hasTripType = controller.selectedTripType.isNotEmpty;

    return SizedBox(
      height: 48,
      child: DropdownButtonFormField<String>(
        initialValue: hasTripType ? controller.selectedTripType : _allTripsValue,
        isExpanded: true,
        menuMaxHeight: 280,
        borderRadius: BorderRadius.circular(Dimens.eight),
        dropdownColor: ColorsValue.whiteColor,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: ColorsValue.appColor,
        ),
        style: Styles.g1txtColor60014,
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorsValue.whiteColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 10),
            child: Icon(
              Icons.alt_route_rounded,
              color: hasTripType ? ColorsValue.appColor : ColorsValue.g7txtColor,
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimens.eight),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimens.eight),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimens.eight),
            borderSide: BorderSide.none,
          ),
        ),
        items: const [
          DropdownMenuItem<String>(
            value: _allTripsValue,
            child: Text("All Trips"),
          ),
          DropdownMenuItem<String>(value: "Oneway", child: Text("Oneway")),
          DropdownMenuItem<String>(value: "Roundtrip", child: Text("Roundtrip")),
          DropdownMenuItem<String>(value: "Airport", child: Text("Airport")),
          DropdownMenuItem<String>(
            value: "Local Rental Trip",
            child: Text("Local Rental Trip"),
          ),
        ],
        onChanged: (value) {
          controller.selectedTripType = value == _allTripsValue
              ? ""
              : value ?? "";
          controller.update();
        },
      ),
    );
  }

  String _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    final trimmed = path.trim();
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }

    // Strip "uploads/" prefix if present to avoid duplicating it with ApiWrapper.imageUrl
    String cleanPath = trimmed;
    if (cleanPath.startsWith("uploads/")) {
      cleanPath = cleanPath.substring("uploads/".length);
    } else if (cleanPath.startsWith("/uploads/")) {
      cleanPath = cleanPath.substring("/uploads/".length);
    }

    return "${ApiWrapper.imageUrl}$cleanPath";
  }

  Widget _buildVehicleCell(Map item, Map booking, Map travel) {
    final vehicle = item['vehicleId'] ?? item['vehicle_id'] ?? item['vehicle'] ??
        booking['vehicleId'] ?? booking['vehicle_id'] ?? booking['vehicle'] ??
        travel['vehicleId'] ?? travel['vehicle_id'] ?? travel['vehicle'];

    final bool hasVehicle = BambamHubScreen.isValidObject(vehicle);

    if (!hasVehicle) {
      return const Text("-", style: TextStyle(color: Color(0xFF757575), fontSize: 14));
    }

    final brandName = (vehicle is Map)
        ? (vehicle['brand_name'] ?? vehicle['brand'] ?? vehicle['vehicle_name'] ?? '-')
        : '-';
    final vehicleType = (vehicle is Map) ? (vehicle['vehicle_type'] ?? {}) : {};
    final String? photoUrl = (vehicleType is Map ? vehicleType['vehicle_photo'] : null) ??
        (vehicle is Map ? vehicle['vehicle_photo'] : null);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: (photoUrl != null && photoUrl.isNotEmpty)
              ? Image.network(
                  _resolveImageUrl(photoUrl),
                  height: 30,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    AssetConstants.carpng,
                    height: 30,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                )
              : Image.asset(
                  AssetConstants.carpng,
                  height: 30,
                  width: 50,
                  fit: BoxFit.contain,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            brandName.toString(),
            style: Styles.g7txtColor40014,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(dynamic item, dynamic booking) {
    final style = BambamHubScreen.getStatusStyle(item, booking);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style['bg'] as Color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        style['label'] as String,
        style: Styles.g1txtColor60014.copyWith(
          color: style['text'] as Color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AssignmentActionCell extends StatefulWidget {
  final Map item;
  final Map booking;
  final Map travel;
  final HomeController controller;

  const _AssignmentActionCell({
    Key? key,
    required this.item,
    required this.booking,
    required this.travel,
    required this.controller,
  }) : super(key: key);

  @override
  State<_AssignmentActionCell> createState() => _AssignmentActionCellState();
}

class _AssignmentActionCellState extends State<_AssignmentActionCell> {
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

  DateTime? _getPickupDateTime() {
    try {
      final dateStr = widget.travel['date'] ?? widget.travel['pickup_date'];
      final timeStr = widget.travel['pickup_time'];
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

  @override
  Widget build(BuildContext context) {
    final driverObj = widget.item['driverId'] ?? widget.item['driver_id'] ?? widget.item['driver'] ??
        widget.booking['driverId'] ?? widget.booking['driver_id'] ?? widget.booking['driver'];
    final vehicleObj = widget.item['vehicleId'] ?? widget.item['vehicle_id'] ?? widget.item['vehicle'] ??
        widget.booking['vehicleId'] ?? widget.booking['vehicle_id'] ?? widget.booking['vehicle'];

    final bool hasDriver = BambamHubScreen.isValidObject(driverObj);
    final bool hasVehicle = BambamHubScreen.isValidObject(vehicleObj);

    final pickupDt = _getPickupDateTime();
    final now = DateTime.now();

    double diffHours = 0;
    if (pickupDt != null) {
      diffHours = pickupDt.difference(now).inSeconds / 3600.0;
    }

    final bool isReEnabled = widget.item['vendor_assignment_re_enabled'] == true || widget.booking['vendor_assignment_re_enabled'] == true;

    String allocationState = 'ALLOWED';
    if (pickupDt != null) {
      if (diffHours > 5) {
        allocationState = 'TOO_EARLY';
      } else if (diffHours < 1 && !isReEnabled) {
        allocationState = 'EXPIRED';
      }
    }

    final bool isPastPickup = pickupDt != null && diffHours <= 0;

    // Top Badge Helper
    Widget? topBadge;
    if (hasDriver && hasVehicle) {
      topBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check, size: 12, color: Color(0xFF16A34A)),
            SizedBox(width: 2),
            Text(
              "Allocated",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
            ),
          ],
        ),
      );
    } else if (hasDriver) {
      topBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: const Text(
          "Driver Assigned",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
        ),
      );
    } else if (hasVehicle) {
      topBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: const Text(
          "Vehicle Assigned",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
        ),
      );
    }

    void openAssignScreen() async {
      widget.controller.selectedRideDetails = {
        'vendorRequest': widget.item,
        'bookingDetails': widget.booking,
        'travelDetails': widget.travel,
      };
      await widget.controller.getAllocationDrivers(widget.item['_id']);
      RouteManagement.gotoDriverAllocateScreen();
    }

    // ── TOO EARLY STATE (> 5 Hours before pickup) ──
    if (allocationState == 'TOO_EARLY') {
      final unlockTime = pickupDt!.subtract(const Duration(hours: 5));
      final rem = unlockTime.difference(now);

      final days = rem.inDays;
      final hours = rem.inHours % 24;
      final mins = rem.inMinutes % 60;
      final secs = rem.inSeconds % 60;

      String countdownStr = "";
      if (days > 0) countdownStr += "${days}d ";
      if (hours > 0 || days > 0) countdownStr += "${hours.toString().padLeft(2, '0')}h ";
      countdownStr += "${mins.toString().padLeft(2, '0')}m ${secs.toString().padLeft(2, '0')}s";

      String btnLabel = "Assign";
      if (hasDriver && hasVehicle) btnLabel = "Allocated";
      else if (hasDriver) btnLabel = "Assign Vehicle";
      else if (hasVehicle) btnLabel = "Assign Driver";

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (topBadge != null) ...[topBadge, const SizedBox(height: 4)],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  btnLabel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
                ),
                Text(
                  countdownStr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("⏳ ", style: TextStyle(fontSize: 10)),
                Flexible(
                  child: Text(
                    "Opens 5 Hrs Before Pickup",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ── EXPIRED STATE (< 1 Hour before pickup & not re-enabled) ──
    if (allocationState == 'EXPIRED') {
      String btnLabel = "Assign";
      if (hasDriver && hasVehicle) btnLabel = "Allocated";
      else if (hasDriver) btnLabel = "Assign Vehicle";
      else if (hasVehicle) btnLabel = "Assign Driver";

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (topBadge != null) ...[topBadge, const SizedBox(height: 4)],
          if (!hasDriver || !hasVehicle)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                btnLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
              ),
            ),
          if (!isPastPickup) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Column(
                children: const [
                  Text("📞 Call Admin", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFBE123C))),
                  Text("+91 92744 53826", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9F1239))),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // ── ALLOWED STATE (Between 1 and 5 hours remaining) ──
    // If fully allocated — show only the top badge, NO extra button
    if (hasDriver && hasVehicle) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (topBadge != null) topBadge,
        ],
      );
    }

    // Still needs assignment — show the action button
    String actionText = "Assign";
    if (hasDriver) {
      actionText = "Assign Vehicle";
    } else if (hasVehicle) {
      actionText = "Assign Driver";
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (topBadge != null) ...[topBadge, const SizedBox(height: 4)],
        ElevatedButton(
          onPressed: openAssignScreen,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsValue.appColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: Text(
            actionText,
            style: Styles.whiteColorW60012,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
