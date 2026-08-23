import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManagevehicleHomescreen extends StatelessWidget {
  const ManagevehicleHomescreen({super.key});

  void _showMaintenanceDialog(BuildContext context, HomeController controller, Map<String, dynamic> vehicle) {
    final reasonController = TextEditingController(
      text: vehicle['maintenance_details']?['issue_description'] ?? "",
    );
    final vehicleNumber = vehicle['vehicle_number'] ?? "N/A";
    final brandName = vehicle['brand_name'] ?? "";

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.build_circle_outlined, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Request Maintenance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vehicle: $brandName ($vehicleNumber)",
              style: Styles.g1txtColor60014,
            ),
            const SizedBox(height: 12),
            const Text(
              "Reason / Issue Description *",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter reason for maintenance (e.g. Engine Servicing, Brake Repair)...",
                hintStyle: Styles.g7txtColor40012,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                Utility.snacBar("Please enter a reason for maintenance", Colors.red);
                return;
              }
              Get.back();
              controller.toggleVehicleOperationalStatus(
                vehicleId: vehicle['_id'],
                operationalStatus: "Under Maintenance",
                reason: reasonController.text.trim(),
              );
            },
            child: const Text("Submit Request", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () => RouteManagement.gotoAddvehicale1Screen(),
              text: "Add New Vehicle",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => controller.getVehicles(isLoading: false),
            child: controller.vehicles.isEmpty && !controller.isVehicleLoading
                ? Center(
                    child: Text(
                      "No Vehicles Found",
                      style: Styles.g1txtColor60016,
                    ),
                  )
                : ListView(
                    controller: controller.vehicleScrollController,
                    padding: Dimens.edgeInsets20,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Vehicles History",
                              style: Styles.g1txtColor60016,
                            ),
                          ),
                          Dimens.boxWidth12,
                        ],
                      ),
                      Dimens.boxHeight16,
                      ...List.generate(controller.vehicles.length, (index) {
                        final vehicle = controller.vehicles[index];
                        final vehicleType = vehicle['vehicle_type'];
                        final vehicleName = vehicle['brand_name'] ?? "N/A";
                        final vehicleNumber = vehicle['vehicle_number'] ?? "N/A";
                        final typeName = (vehicleType is Map) ? vehicleType['name'] : "N/A";

                        final String opStatus = vehicle['operational_status'] ??
                            (vehicle['status'] == true ? "Available" : "Inactive");
                        final bool isActive = vehicle['status'] == true;

                        Color statusColor;
                        if (opStatus == "Under Maintenance") {
                          statusColor = Colors.orange.shade800;
                        } else if (opStatus == "On Trip") {
                          statusColor = Colors.blue.shade700;
                        } else if (isActive) {
                          statusColor = Colors.green;
                        } else {
                          statusColor = Colors.red;
                        }

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                controller.getVehicleDetails(vehicle['_id']);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorsValue.whiteColor,
                                  borderRadius: BorderRadius.circular(
                                    Dimens.twelve,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: Dimens.edgeInsets16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Vehicle Number:  ",
                                            style: Styles.g6txtColor40014,
                                          ),
                                          Expanded(
                                            child: Text(
                                              vehicleNumber,
                                              style: Styles.g1txtColor60016,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            onPressed: () {
                                              Get.dialog(
                                                AlertDialog(
                                                  title: const Text("Delete Vehicle"),
                                                  content: Text("Are you sure you want to delete vehicle $vehicleNumber?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Get.back(),
                                                      child: const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Get.back();
                                                        controller.deleteVehicle(vehicle['_id']);
                                                      },
                                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Dimens.boxHeight12,
                                      // Operational Status & Active Toggle Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Status Badge with Menu
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == "Under Maintenance") {
                                                _showMaintenanceDialog(context, controller, vehicle);
                                              } else {
                                                controller.toggleVehicleOperationalStatus(
                                                  vehicleId: vehicle['_id'],
                                                  operationalStatus: value,
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: "Available",
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                                    SizedBox(width: 8),
                                                    Text("Available"),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: "Under Maintenance",
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.build_circle_outlined, color: Colors.orange, size: 18),
                                                    SizedBox(width: 8),
                                                    Text("Under Maintenance"),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: "Inactive",
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                                                    SizedBox(width: 8),
                                                    Text("Inactive"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    opStatus,
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(Icons.arrow_drop_down, color: statusColor, size: 18),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Active On/Off Toggle
                                          Row(
                                            children: [
                                              Text(
                                                isActive ? "Active" : "Inactive",
                                                style: Styles.g7txtColor40012,
                                              ),
                                              Switch(
                                                value: isActive,
                                                activeColor: ColorsValue.appColor,
                                                onChanged: (val) {
                                                  controller.toggleVehicleStatus(vehicle['_id']);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Dimens.boxHeight12,
                                      Divider(color: ColorsValue.l2),
                                      ListTile(
                                        contentPadding: Dimens.edgeInsets0,
                                        leading: Container(
                                          width: Dimens.eighty,
                                          height: Dimens.sixty,
                                          decoration: BoxDecoration(
                                            color: ColorsValue.l2,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              _resolveImageUrl(vehicle['front_image']),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                final fallbackUrl = vehicle['front_image'];
                                                if (fallbackUrl != null && fallbackUrl.toString().trim().isNotEmpty) {
                                                  final s3Url = fallbackUrl.toString().trim().startsWith("http")
                                                      ? fallbackUrl.toString().trim()
                                                      : "https://bambams3.s3.ap-south-1.amazonaws.com/${fallbackUrl.toString().trim().replaceFirst("uploads/", "")}";
                                                  return Image.network(
                                                    s3Url,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context2, error2, stackTrace2) => Image.asset(
                                                      AssetConstants.carpng,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  );
                                                }
                                                return Image.asset(
                                                  AssetConstants.carpng,
                                                  fit: BoxFit.contain,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          vehicleName,
                                          style: Styles.g1txtColor60016,
                                        ),
                                        subtitle: Text(
                                          typeName,
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
                      if (controller.isVehicleLoading)
                        Padding(
                          padding: Dimens.edgeInsets10,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  String _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    final trimmed = path.trim();
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }
    
    String cleanPath = trimmed;
    if (cleanPath.startsWith("uploads/")) {
      cleanPath = cleanPath.substring("uploads/".length);
    } else if (cleanPath.startsWith("/uploads/")) {
      cleanPath = cleanPath.substring("/uploads/".length);
    }
    
    return "${ApiWrapper.imageUrl}$cleanPath";
  }
}
