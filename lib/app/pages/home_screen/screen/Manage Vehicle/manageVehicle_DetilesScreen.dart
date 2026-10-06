import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'edit_vehicle_screen.dart';

class ManagevehicleDetilesscreen extends StatelessWidget {
  const ManagevehicleDetilesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Vehicle Details",
            actions: [
              if (controller.selectedVehicleDetails != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                  onPressed: () {
                    controller.initVehicleEdit(controller.selectedVehicleDetails!);
                    Get.to(() => EditVehicleScreen(vehicle: controller.selectedVehicleDetails!));
                  },
                ),
            ],
          ),

          body: RefreshIndicator(
            onRefresh: () async {
              if (controller.selectedVehicleDetails != null) {
                await controller.getVehicleDetails(
                  controller.selectedVehicleDetails!['_id'],
                );
              }
            },
            child: ListView(
              padding: Dimens.edgeInsets20,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(controller.tabsVehicalH.length, (
                        index,
                      ) {
                        final isSelected =
                            controller.selectedIndexVehicalH == index;

                        return GestureDetector(
                          onTap: () {
                            controller.selectedIndexVehicalH = index;
                            if (index == 3 &&
                                controller.selectedVehicleDetails != null) {
                              controller.fetchVehicleHistory();
                            }
                            controller.update();
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 18,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orangeAccent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orangeAccent
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              controller.tabsVehicalH[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Dimens.boxHeight20,

                if (controller.selectedIndexVehicalH == 0) ...[
                  if (controller.selectedVehicleDetails == null)
                    Center(child: Text("No Data Available"))
                  else
                    Container(
                      padding: Dimens.edgeInsets20,
                      decoration: BoxDecoration(
                        color: ColorsValue.whiteColor,
                        borderRadius: BorderRadius.circular(Dimens.twelve),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _resolveImageUrl(controller.selectedVehicleDetails!['vehicleInformation']?['front_image']),
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  final fallbackUrl = controller.selectedVehicleDetails!['vehicleInformation']?['front_image'];
                                  if (fallbackUrl != null && fallbackUrl.toString().trim().isNotEmpty) {
                                    final s3Url = fallbackUrl.toString().trim().startsWith("http")
                                        ? fallbackUrl.toString().trim()
                                        : "https://bambams3.s3.ap-south-1.amazonaws.com/${fallbackUrl.toString().trim().replaceFirst("uploads/", "")}";
                                    return Image.network(
                                      s3Url,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context2, error2, stackTrace2) =>
                                          Image.asset(AssetConstants.carpng),
                                    );
                                  }
                                  return Image.asset(AssetConstants.carpng);
                                },
                              ),
                            ),
                          ),
                          Dimens.boxHeight12,
                          Divider(color: ColorsValue.l2),
                          Dimens.boxHeight12,
                          Text("Vehicle Name", style: Styles.g7txtColor40014),
                          Dimens.boxHeight4,
                          Text(
                            "${controller.selectedVehicleDetails!['vehicleInformation']?['brand_name'] ?? 'N/A'} ${controller.selectedVehicleDetails!['vehicleInformation']?['model_name'] ?? ''}",
                            style: Styles.g1txtColor60016,
                          ),
                          Dimens.boxHeight12,
                          Divider(color: ColorsValue.l2),
                          Dimens.boxHeight12,
                          Text("Vehicle Number", style: Styles.g7txtColor40014),
                          Dimens.boxHeight4,
                          Text(
                            controller
                                    .selectedVehicleDetails!['vehicleInformation']?['vehicle_number'] ??
                                'N/A',
                            style: Styles.g1txtColor60016,
                          ),
                          Dimens.boxHeight12,
                          Divider(color: ColorsValue.l2),
                          Dimens.boxHeight12,
                          Row(
                            spacing: Dimens.sixteen,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Vehicle Owner Name",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Dimens.boxHeight4,
                                    Text(
                                      controller.selectedVehicleDetails!['vehicleInformation']?['vehicle_owner_name'] ??
                                          controller.selectedVehicleDetails!['vehicle_owner_name'] ??
                                          'N/A',
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Owner Mobile Number",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Dimens.boxHeight4,
                                    Text(
                                      controller.selectedVehicleDetails!['vehicleInformation']?['vehicle_owner_mobile'] ??
                                          controller.selectedVehicleDetails!['vehicle_owner_mobile'] ??
                                          'N/A',
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Dimens.boxHeight12,
                          Divider(color: ColorsValue.l2),
                          Dimens.boxHeight12,
                          Row(
                            spacing: Dimens.sixteen,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Fuel Type",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Dimens.boxHeight4,
                                    Text(
                                      (controller.selectedVehicleDetails!['vehicleInformation']?['fuel_type']
                                                  as List?)
                                              ?.map((e) => e['name'])
                                              .join("/") ??
                                          "N/A",
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Registration Year",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Dimens.boxHeight4,
                                    Text(
                                      controller
                                              .selectedVehicleDetails!['vehicleInformation']?['registration_year']
                                              ?.toString() ??
                                          "N/A",
                                      style: Styles.g1txtColor60016,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ] else if (controller.selectedIndexVehicalH == 1) ...[
                  if (controller.selectedVehicleDetails == null)
                    Center(child: Text("No Data Available"))
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: ColorsValue.whiteColor,
                        borderRadius: BorderRadius.circular(Dimens.twenty),
                      ),
                      child: Padding(
                        padding: Dimens.edgeInsets16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Document Details",
                              style: Styles.appColor60020,
                            ),
                            Dimens.boxHeight16,
                            Row(
                              spacing: Dimens.sixteen,
                              children: [
                                Expanded(
                                  child: documentDetilesShow(
                                    "Insurance Document",
                                    "Insurance Expiry",
                                    controller.selectedVehicleDetails!['vehicleDocuments']?['insurance_expiry'] !=
                                            null
                                        ? Utility.getFormatedTime(
                                            controller
                                                .selectedVehicleDetails!['vehicleDocuments']!['insurance_expiry'],
                                            "dd-MM-yyyy",
                                          )
                                        : "N/A",
                                    controller
                                        .selectedVehicleDetails!['vehicleDocuments']?['insurance_document'],
                                  ),
                                ),
                                Expanded(
                                  child: documentDetilesShow(
                                    "Fitness Document",
                                    "Fitness Expiry",
                                    controller.selectedVehicleDetails!['vehicleDocuments']?['fitness_expiry'] !=
                                            null
                                        ? Utility.getFormatedTime(
                                            controller
                                                .selectedVehicleDetails!['vehicleDocuments']!['fitness_expiry'],
                                            "dd-MM-yyyy",
                                          )
                                        : "N/A",
                                    controller
                                        .selectedVehicleDetails!['vehicleDocuments']?['fitness_document'],
                                  ),
                                ),
                              ],
                            ),
                            Dimens.boxHeight10,
                            Divider(color: ColorsValue.l3),
                            Dimens.boxHeight10,
                            Row(
                              spacing: Dimens.sixteen,
                              children: [
                                Expanded(
                                  child: documentDetilesShow(
                                    "Permit Document",
                                    "Permit Expiry",
                                    controller.selectedVehicleDetails!['vehicleDocuments']?['permit_expiry'] !=
                                            null
                                        ? Utility.getFormatedTime(
                                            controller
                                                .selectedVehicleDetails!['vehicleDocuments']!['permit_expiry'],
                                            "dd-MM-yyyy",
                                          )
                                        : "N/A",
                                    controller
                                        .selectedVehicleDetails!['vehicleDocuments']?['permit_document'],
                                  ),
                                ),
                                Expanded(
                                  child: documentDetilesShow(
                                    "PUC Document",
                                    "Permit Type",
                                    controller
                                            .selectedVehicleDetails!['vehicleDocuments']?['permit_type'] ??
                                        "N/A",
                                    controller
                                        .selectedVehicleDetails!['vehicleDocuments']?['puc_document'],
                                  ),
                                ),
                              ],
                            ),
                            Dimens.boxHeight10,
                            Divider(color: ColorsValue.l3),
                            Dimens.boxHeight10,
                            Row(
                              spacing: Dimens.sixteen,
                              children: [
                                Expanded(
                                  child: documentDetilesShow(
                                    "RC Image",
                                    "Registered At",
                                    controller.selectedVehicleDetails!['createdAt'] !=
                                            null
                                        ? Utility.getFormatedTime(
                                            controller
                                                .selectedVehicleDetails!['createdAt'],
                                            "dd-MM-yyyy",
                                          )
                                        : "N/A",
                                    controller
                                        .selectedVehicleDetails!['vehicleDocuments']?['rc_image'],
                                  ),
                                ),
                                if (controller.selectedVehicleDetails!['vehicleInformation']?['sourcing']
                                        ?.toString()
                                        .toLowerCase() ==
                                    "rented vehicle")
                                  Expanded(
                                    child: documentDetilesShow(
                                      "Rented Agreement",
                                      "Sourcing",
                                      "Rented",
                                      controller.selectedVehicleDetails!['vehicleInformation']?['rented_vehicle_agreement'],
                                    ),
                                  )
                                else
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                            Dimens.boxHeight10,
                            Divider(color: ColorsValue.l3),
                            Dimens.boxHeight10,
                            Row(
                              spacing: Dimens.sixteen,
                              children: [
                                Expanded(
                                  child: documentDetilesShow(
                                    "Back Image",
                                    "Vehicle Image",
                                    "Back",
                                    controller.selectedVehicleDetails!['vehicleInformation']?['back_image'],
                                  ),
                                ),
                                Expanded(
                                  child: documentDetilesShow(
                                    "Interior Image",
                                    "Vehicle Image",
                                    "Interior",
                                    controller.selectedVehicleDetails!['vehicleInformation']?['interior_image'],
                                  ),
                                ),
                              ],
                            ),
                            Dimens.boxHeight10,
                            Divider(color: ColorsValue.l3),
                            Dimens.boxHeight10,
                            Row(
                              spacing: Dimens.sixteen,
                              children: [
                                Expanded(
                                  child: documentDetilesShow(
                                    "Left Image",
                                    "Vehicle Image",
                                    "Left",
                                    controller.selectedVehicleDetails!['vehicleInformation']?['left_image'],
                                  ),
                                ),
                                Expanded(
                                  child: documentDetilesShow(
                                    "Right Image",
                                    "Vehicle Image",
                                    "Right",
                                    controller.selectedVehicleDetails!['vehicleInformation']?['right_image'],
                                  ),
                                ),
                              ],
                            ),
                            Dimens.boxHeight10,
                            Divider(color: ColorsValue.l3),
                            Dimens.boxHeight10,
                            Row(
                              spacing: Dimens.sixteen,
                              children: [
                                Expanded(
                                  child: documentDetilesShow(
                                    "Number Plate",
                                    "Vehicle Image",
                                    "Plate",
                                    controller.selectedVehicleDetails!['vehicleInformation']?['number_plate_image'],
                                  ),
                                ),
                                Expanded(
                                  child: documentDetilesShow(
                                    "Dicky Image",
                                    "Vehicle Image",
                                    "Dicky",
                                    controller.selectedVehicleDetails!['vehicleInformation']?['dicky_image'],
                                  ),
                                ),
                              ],
                            ),
                            Dimens.boxHeight4,
                          ],
                        ),
                      ),
                    ),
                ] else if (controller.selectedIndexVehicalH == 2) ...[
                  if (controller.selectedVehicleDetails == null)
                    Center(child: Text("No Data Available"))
                  else
                    Container(
                      padding: Dimens.edgeInsets20,
                      decoration: BoxDecoration(
                        color: ColorsValue.whiteColor,
                        borderRadius: BorderRadius.circular(Dimens.twelve),
                      ),
                      child: Column(
                        children: [
                          _buildPreferenceRow(
                            "Sourcing",
                            controller
                                    .selectedVehicleDetails!['vehicleInformation']?['sourcing'] ??
                                "N/A",
                          ),
                          Divider(color: ColorsValue.l2, height: Dimens.twenty),
                          _buildPreferenceRow(
                            "Working Rear Seat Belts",
                            controller
                                    .selectedVehicleDetails!['vehiclePreferences']?['working_rear_seat_belts'] ??
                                "N/A",
                          ),
                          Divider(color: ColorsValue.l2, height: Dimens.twenty),
                          _buildPreferenceRow(
                            "Pet Friendly",
                            controller
                                    .selectedVehicleDetails!['vehiclePreferences']?['pet_friendly'] ??
                                "N/A",
                          ),
                          Divider(color: ColorsValue.l2, height: Dimens.twenty),
                          _buildPreferenceRow(
                            "Luggage Carrier",
                            controller
                                    .selectedVehicleDetails!['vehiclePreferences']?['luggage_carrier'] ??
                                "N/A",
                          ),
                        ],
                      ),
                    ),
                ] else if (controller.selectedIndexVehicalH == 3) ...[
                  if (controller.isVehicleHistoryLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.vehicleHistoryData == null || 
                           controller.vehicleHistoryData!.isEmpty ||
                           (controller.vehicleHistoryData?['counts']?['total_trips'] ?? 0) == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Text(
                          "No vehicle history found",
                          style: Styles.g7txtColor40014,
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: Get.width,
                            padding: Dimens.edgeInsets16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimens.twelve),
                              color: ColorsValue.whiteColor,
                            ),
                            child: Column(
                              spacing: Dimens.sixteen,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Trips",
                                  style: Styles.g7txtColor40016.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${controller.vehicleHistoryData?['counts']?['total_trips'] ?? 0}",
                                  style: Styles.g1txtColor60014.copyWith(
                                    fontSize: Dimens.twentyFour,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Dimens.boxHeight16,
                          Row(
                            spacing: Dimens.sixteen,
                            children: [
                              Expanded(
                                child: Container(
                                  width: Get.width,
                                  padding: Dimens.edgeInsets16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.twelve,
                                    ),
                                    color: ColorsValue.whiteColor,
                                  ),
                                  child: Column(
                                    spacing: Dimens.sixteen,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Completed Trips",
                                        style: Styles.g7txtColor40016.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "${controller.vehicleHistoryData?['counts']?['completed_trips'] ?? 0}",
                                        style: Styles.g1txtColor60014.copyWith(
                                          fontSize: Dimens.twentyFour,
                                          color: ColorsValue.greenColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: Get.width,
                                  padding: Dimens.edgeInsets16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.twelve,
                                    ),
                                    color: ColorsValue.whiteColor,
                                  ),
                                  child: Column(
                                    spacing: Dimens.sixteen,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Cancelled Trips",
                                        style: Styles.g7txtColor40016.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "${controller.vehicleHistoryData?['counts']?['cancelled_trips'] ?? 0}",
                                        style: Styles.g1txtColor60014.copyWith(
                                          fontSize: Dimens.twentyFour,
                                          color: ColorsValue.redColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Dimens.boxHeight16,
                          ...((controller.vehicleHistoryData?['bookings']?['docs']
                                      as List?) ??
                                  [])
                              .map((booking) {
                            final travel = booking['travelDetailsId'] ?? {};
                            final payment = booking['payment_summary'] ?? {};

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    controller.getTripLogDetails(booking['_id']);
                                    RouteManagement.gotoTripDetilesScreen();
                                  },
                                  child: Container(
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: ColorsValue.whiteColor,
                                      borderRadius: BorderRadius.circular(
                                        Dimens.twelve,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: Dimens.edgeInsets16,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            spacing: Dimens.five,
                                            children: [
                                              Text(
                                                "Booking ID:",
                                                style: Styles.g6txtColor40012,
                                              ),
                                              Text(
                                                "${booking['booking_id'] ?? 'N/A'}",
                                                style: Styles.g1txtColor60018,
                                              ),
                                            ],
                                          ),
                                          Dimens.boxHeight8,
                                          Text(
                                            (travel['trip_type'] ?? '')
                                                .toString()
                                                .replaceAll('_', ' '),
                                            style: Styles.g7txtColor40014,
                                          ),
                                          Text(
                                            "${Utility.getDisplayFrom(travel)} → ${Utility.getDisplayTo(travel)}",
                                            style: Styles.g1txtColor60014,
                                          ),
                                          Dimens.boxHeight4,
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            spacing: Dimens.nine,
                                            children: [
                                              Row(
                                                spacing: Dimens.five,
                                                children: [
                                                  SvgPicture.asset(
                                                    AssetConstants.calendar,
                                                  ),
                                                  Text(
                                                    Utility.getFormatedTime(
                                                      travel['date'] ??
                                                          DateTime.now()
                                                              .toString(),
                                                      "dd/MM/yy",
                                                    ),
                                                    style:
                                                        Styles.g6txtColor40014,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                spacing: Dimens.five,
                                                children: [
                                                  SvgPicture.asset(
                                                    AssetConstants.clock,
                                                  ),
                                                  Text(
                                                    " ${travel['pickup_time'] ?? ''} ",
                                                    style:
                                                        Styles.g6txtColor40014,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Dimens.boxHeight5,
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Vendor Fare",
                                                style: Styles.g6txtColor40012,
                                              ),
                                              Text(
                                                "₹${payment['final_trip_fare'] ?? 0}",
                                                style: Styles.g1txtColor50016
                                                    .copyWith(
                                                      color: ColorsValue
                                                          .greenColor,
                                                    ),
                                              ),
                                            ],
                                          ),
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
                ] else
                  ...[]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreferenceRow(String label, String value) {
    return Row(
      spacing: Dimens.sixteen,
      children: [
        Expanded(child: Text(label, style: Styles.g1txtColor60016)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Styles.g6txtColor40014.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
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

  Widget documentDetilesShow(
    String documentName,
    String expiryType,
    String expirydate,
    String? imageUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(documentName, style: Styles.g1txtColor60014),
        Dimens.boxHeight4,
        Container(
          height: Dimens.hundredFifty,
          width: Dimens.hundredFifty,
          decoration: BoxDecoration(
            color: ColorsValue.l2,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _resolveImageUrl(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                if (imageUrl != null && imageUrl.trim().isNotEmpty) {
                  final s3Url = imageUrl.trim().startsWith("http")
                      ? imageUrl.trim()
                      : "https://bambams3.s3.ap-south-1.amazonaws.com/${imageUrl.trim().replaceFirst("uploads/", "")}";
                  return Image.network(
                    s3Url,
                    fit: BoxFit.cover,
                    errorBuilder: (context2, error2, stackTrace2) => Image.asset(
                      AssetConstants.driving_licence_Imge,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Image.asset(
                  AssetConstants.driving_licence_Imge,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        Dimens.boxHeight8,
        Center(child: Text(expiryType, style: Styles.g7txtColor40014)),
        Center(child: Text(expirydate, style: Styles.g1txtColor60014)),
      ],
    );
  }
}
