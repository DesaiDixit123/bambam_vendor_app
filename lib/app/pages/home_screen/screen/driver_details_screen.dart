import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverDetailsScreen extends StatelessWidget {
  const DriverDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final driver = controller.selectedDriver;

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: Get.back,
            title: "Driver Details".tr,
          ),
          body: controller.isDriverDetailLoading
              ? const Center(child: CircularProgressIndicator())
              : driver == null
                  ? const Center(child: Text("No data found"))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        /// 👤 Photo
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: driver['driver_photo'] != null && driver['driver_photo'].isNotEmpty
                ? NetworkImage("${ApiWrapper.imageUrl}${driver['driver_photo']}")
                : const AssetImage(AssetConstants.carpng) as ImageProvider,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _infoTile("Name", driver['driver_name'] ?? '-'),
                         _infoTile("Mobile", driver['driver_mobile'] ?? '-'),
                         _infoTile("City", driver['city'] ?? '-'),
                         _infoTile("State", driver['state'] ?? '-'),
                         _infoTile("DOB", _formatDate(driver['dob'] as String?)),
                         _infoTile("License No", driver['DL_number'] ?? '-'),
                         _infoTile("Approval Status", driver['approval_status'] ?? '-')
                      ],
                    ),
        );
      },
    );
  }

  Widget _infoTile(String title, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(value ?? "-", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "-";
    try {
      final dateTime = DateTime.parse(isoDate).toLocal();
      return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
    } catch (_) {
      return "-";
    }
  }
}
