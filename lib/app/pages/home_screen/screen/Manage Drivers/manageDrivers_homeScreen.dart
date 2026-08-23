import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';

/// ManagedriversHomescreen — always fetches fresh driver data from the backend
/// every time the screen becomes visible (on open + on return from sub-screens).
class ManagedriversHomescreen extends StatefulWidget {
  const ManagedriversHomescreen({super.key});

  @override
  State<ManagedriversHomescreen> createState() =>
      _ManagedriversHomescreenState();
}

class _ManagedriversHomescreenState extends State<ManagedriversHomescreen> {
  @override
  void initState() {
    super.initState();
    // Fresh fetch when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDrivers();
    });
  }

  /// Called every time this screen comes BACK into view after a sub-screen pop.
  void _refreshDrivers() {
    final controller = Get.find<HomeController>();
    // isLoading: false → silent background refresh (no full-screen loader)
    controller.getDrivers(isLoading: false);
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, HomeController controller, String driverId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete Driver",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this driver?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteDriverController(driverId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                controller.clearDriverForm();
                // Await navigation → refresh list when user returns from add screen
                Get.toNamed<void>(Routes.addNewdriversScreen)?.then((_) {
                  _refreshDrivers();
                });
              },
              text: "Add New Driver",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: Column(
            children: [
              /// 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.driverSearchController,
                        decoration: InputDecoration(
                          hintText: "Search driver...",
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: controller.driverSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    controller.driverSearchController.clear();
                                    controller.drivers.clear();
                                    controller.driverPage = 1;
                                    controller.hasMoreDrivers = true;
                                    controller.getDrivers();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          controller.drivers.clear();
                          controller.driverPage = 1;
                          controller.hasMoreDrivers = true;
                          controller.getDrivers();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                         controller.exportDriversData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorsValue.borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.file_download_outlined, color: Colors.green),
                            const SizedBox(width: 8),
                            Text("Export", style: Styles.g1txtColor60014),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Pull-to-refresh: always force a fresh network call
                    controller.driverSearchController.clear();
                    controller.drivers.clear();
                    controller.driverPage = 1;
                    controller.hasMoreDrivers = true;
                    await controller.getDrivers();
                  },
                  child: controller.isDriverLoading && controller.drivers.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : controller.drivers.isEmpty
                          ? ListView(
                              // Wrap in ListView so RefreshIndicator works even when empty
                              children: const [
                                SizedBox(height: 200),
                                Center(child: Text("No drivers found")),
                              ],
                            )
                          : ListView.builder(
                              padding: Dimens.edgeInsets20,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: controller.drivers.length,
                              controller: controller.driverScrollController,
                              itemBuilder: (context, index) {
                                final driver = controller.drivers[index];
                                return Column(
                                  children: [
                                    Container(
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
                                                  driver['DL_number'] ?? "",
                                                  style: Styles.g1txtColor60016,
                                                ),
                                                const Spacer(),
                                                // Edit icon
                                                InkWell(
                                                  onTap: () async {
                                                    controller.populateDriverForm(driver);
                                                    // ✅ Await edit screen — refresh when done
                                                    await Get.toNamed<void>(
                                                      Routes.addNewdriversScreen,
                                                    );
                                                    _refreshDrivers();
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: SvgPicture.asset(
                                                      AssetConstants.ic_edit,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                // Delete icon
                                                InkWell(
                                                  onTap: () {
                                                    _showDeleteConfirmationDialog(context, controller, driver['_id']);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Dimens.boxHeight12,
                                            Divider(color: ColorsValue.l2),
                                            InkWell(
                                              onTap: () async {
                                                controller.getDriverDetails(driver['_id']);
                                                // ✅ Await navigation — refresh list when user returns
                                                await Get.toNamed<void>(
                                                  Routes.driverHistorysScreen,
                                                );
                                                _refreshDrivers();
                                              },
                                              child: ListTile(
                                                contentPadding: Dimens.edgeInsets0,
                                                leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Image.network(
                                                    "${ApiWrapper.imageUrl}${driver['driver_photo']}",
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      AssetConstants.ic_driver,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  driver['driver_name'] ?? "Unknown",
                                                  style: Styles.g1txtColor60016,
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      driver['driver_mobile'] ?? "",
                                                      style: Styles.g7txtColor40014,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        _buildStatusChip(
                                                          controller.getDriverStatus(driver),
                                                        ),
                                                        const Spacer(),
                                                        SizedBox(
                                                           height: 30,
                                                           width: 50,
                                                           child: controller.togglingDrivers[driver['_id']] == true
                                                               ? Center(
                                                                   child: SizedBox(
                                                                     width: 16,
                                                                     height: 16,
                                                                     child: CircularProgressIndicator(
                                                                       strokeWidth: 2,
                                                                       valueColor: AlwaysStoppedAnimation<Color>(ColorsValue.appColor),
                                                                     ),
                                                                   ),
                                                                 )
                                                               : Switch.adaptive(
                                                                    value: controller.isDriverOnline(driver),
                                                                    activeColor: ColorsValue.greenColor,
                                                                    onChanged: controller.getDriverStatus(driver).toLowerCase() == 'busy' ? null : (bool val) {
                                                                      controller.toggleDriverStatusController(driver['_id']);
                                                                    },
                                                                  ),
                                                         ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Dimens.boxHeight16,
                                  ],
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Status badge: 🟢 Active | 🟠 Busy | 🔴 Unavailable
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available':
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
