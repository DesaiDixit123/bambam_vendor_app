import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class FineboardDetilesScreen extends StatelessWidget {
  const FineboardDetilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final data = controller.selectedFineDetails is Map
            ? Map<String, dynamic>.from(controller.selectedFineDetails!)
            : <String, dynamic>{};
        final fine = _asMap(data['fine']);
        final apiDriver = _asMap(data['driver']);
        final driver = apiDriver;
        final apiVehicle = _asMap(data['vehicle']);
        final vehicle = apiVehicle;
        final driverPhoto = _safeText(driver['driver_photo'], fallback: "");

        return Scaffold(
          appBar: AppBarWidget(
            onTapBack: Get.back,
            title: "Driver Penalty Details",
          ),
          backgroundColor: ColorsValue.appBg,
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const BouncingScrollPhysics(),
            children: [
              // Fine Details Box
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Booking ID", style: Styles.g7txtColor40014),
                                Text(_safeText(fine['booking_id']), style: Styles.g1txtColor60016),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Penalty Date", style: Styles.g7txtColor40014),
                                Text(_safeText(fine['created_date']), style: Styles.g1txtColor60016),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Dimens.boxHeight16,
                      Text("Penalty Description", style: Styles.g7txtColor40014),
                      Dimens.boxHeight4,
                      Text(
                        _safeText(fine['penalty_description'], fallback: "No description"),
                        style: Styles.g1txtColor60016,
                      ),
                      Dimens.boxHeight16,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Penalty Amount", style: Styles.g7txtColor40014),
                              Text(
                                "₹${_safeText(fine['penalty_amount'], fallback: '0')}",
                                style: Styles.g1txtColor60016.copyWith(
                                  color: ColorsValue.redColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Status", style: Styles.g7txtColor40014),
                              Text(
                                _safeText(fine['penalty_status'], fallback: 'Pending'),
                                style: Styles.g1txtColor60016.copyWith(
                                  color: fine['penalty_status'] == 'Paid'
                                      ? Colors.green
                                      : fine['penalty_status'] == 'Cancelled'
                                          ? Colors.red
                                          : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (fine['penalty_photo'] != null && fine['penalty_photo'].toString().isNotEmpty) ...[
                        Dimens.boxHeight16,
                        Text("Penalty Attachment", style: Styles.g7txtColor40014),
                        Dimens.boxHeight8,
                        GestureDetector(
                          onTap: () => _showImageZoom(context, "Penalty Attachment", _imageUrl(fine['penalty_photo'].toString())),
                          child: Container(
                            width: Dimens.eighty,
                            height: Dimens.eighty,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimens.eight),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimens.eight),
                              child: Image.network(
                                _imageUrl(fine['penalty_photo'].toString()),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Rejection Reason — shown only when Cancelled
                      if (fine['penalty_status'] == 'Cancelled' &&
                          fine['cancel_reason'] != null &&
                          fine['cancel_reason'].toString().trim().isNotEmpty) ...[
                        Dimens.boxHeight16,
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0),
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Rejection Reason",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      fine['cancel_reason'].toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFB71C1C),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,

              // Vehicle Info (if vehicle exists)
              if (vehicle.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: ColorsValue.whiteColor,
                    borderRadius: BorderRadius.circular(Dimens.twelve),
                  ),
                  child: Padding(
                    padding: Dimens.edgeInsets16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Vehicle Number",
                                  style: Styles.g7txtColor40014,
                                ),
                                Text(
                                  _safeText(vehicle['vehicle_number']),
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                            Image.asset(
                              AssetConstants.carpng,
                              height: Dimens.fourtyEight,
                            ),
                          ],
                        ),
                        if (vehicle['fuel_type'] != null) ...[
                          Dimens.boxHeight16,
                          Row(
                            children: [
                              SvgPicture.asset(
                                AssetConstants.ic_gasStation,
                                colorFilter: ColorFilter.mode(
                                  ColorsValue.appColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Dimens.boxWidth4,
                              Text(
                                _formatFuelType(vehicle['fuel_type']),
                                style: Styles.g5txtColor40012,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Dimens.boxHeight16,
              ],

              // Driver Profile & Document Details Card
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Driver Profile", style: Styles.appColor60016),
                      Dimens.boxHeight16,
                      Row(
                        children: [
                          CircleAvatar(
                            radius: Dimens.thirty,
                            backgroundColor: ColorsValue.l4,
                            backgroundImage: driverPhoto.isNotEmpty
                                ? NetworkImage(_imageUrl(driverPhoto))
                                : const AssetImage(AssetConstants.person) as ImageProvider,
                          ),
                          Dimens.boxWidth12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _safeText(driver['driver_name'], fallback: "Unknown Driver"),
                                  style: Styles.g1txtColor60018,
                                ),
                                Dimens.boxHeight4,
                                Text(
                                  "Mobile: ${_safeText(driver['driver_mobile'])}",
                                  style: Styles.g7txtColor40014,
                                ),
                                Dimens.boxHeight4,
                                Text(
                                  "DOB: ${_formatDate(driver['dob'])}",
                                  style: Styles.g7txtColor40014,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Dimens.boxHeight24,
                      Text("Driver Documents", style: Styles.appColor60016),
                      Dimens.boxHeight16,
                      
                      // DL Info & Image
                      _documentItem(
                        context,
                        title: "Driving License (DL)",
                        number: _safeText(driver['DL_number']),
                        photoPath: _safeText(driver['DL_photo'], fallback: ""),
                      ),
                      Dimens.boxHeight16,
                      
                      // PAN Info & Image
                      _documentItem(
                        context,
                        title: "PAN Card",
                        number: _safeText(driver['pan_number']),
                        photoPath: _safeText(driver['pan_photo'], fallback: ""),
                      ),
                      Dimens.boxHeight16,
                      
                      // Aadhar Info & Image
                      _documentItem(
                        context,
                        title: "Aadhaar Card",
                        number: _safeText(driver['aadhar_number']),
                        photoPath: _safeText(driver['aadhar_photo'], fallback: ""),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: fine['penalty_status'] == 'Pending'
              ? Container(
                  padding: Dimens.edgeInsets16,
                  color: ColorsValue.whiteColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showRejectReasonDialog(
                            context,
                            controller,
                            fine['_id'] ?? fine['fine_id'] ?? data['fine_id'],
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: Dimens.twelve),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimens.eight),
                            ),
                          ),
                          child: const Text(
                            "Reject",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Dimens.boxWidth12,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _confirmAndAction(
                            context,
                            controller,
                            fine['_id'] ?? fine['fine_id'] ?? data['fine_id'],
                            'Paid',
                            "Are you sure you want to Resolve this Fine?",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: Dimens.twelve),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimens.eight),
                            ),
                          ),
                          child: const Text(
                            "Resolve",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _documentItem(
    BuildContext context, {
    required String title,
    required String number,
    required String photoPath,
  }) {
    final bool hasImage = photoPath.isNotEmpty;
    final String fullUrl = _imageUrl(photoPath);

    return Container(
      width: double.infinity,
      padding: Dimens.edgeInsets12,
      decoration: BoxDecoration(
        color: ColorsValue.appBg,
        borderRadius: BorderRadius.circular(Dimens.eight),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.g1txtColor60014),
          Dimens.boxHeight4,
          Text("No: $number", style: Styles.g7txtColor40014),
          Dimens.boxHeight8,
          if (hasImage)
            GestureDetector(
              onTap: () => _showImageZoom(context, title, fullUrl),
              child: Container(
                width: double.infinity,
                height: 150.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.eight),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.eight),
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: Dimens.fifty,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(Dimens.eight),
              ),
              child: Text(
                "No attachment uploaded",
                style: Styles.g7txtColor40014.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageZoom(BuildContext context, String title, String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(Dimens.ten),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.twelve),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: ColorsValue.whiteColor,
                      padding: Dimens.edgeInsets20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          Dimens.boxHeight10,
                          const Text("Failed to load image", style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: Dimens.ten,
              right: Dimens.ten,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: Get.back,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectReasonDialog(
    BuildContext context,
    HomeController controller,
    dynamic fineId,
  ) {
    final TextEditingController reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reject Fine",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "This action cannot be undone",
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reason for Rejection *",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Please enter the reason for rejecting this fine...",
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This reason will be shared with both the driver and your account.",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        Get.snackbar(
                          "Required",
                          "Please enter a reason for rejection",
                          backgroundColor: Colors.red.shade50,
                          colorText: Colors.red,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      Get.back();
                      controller.updateVendorFineStatus(
                        fineId.toString(),
                        'Cancelled',
                        cancelReason: reason,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Confirm Reject",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _confirmAndAction(
    BuildContext context,
    HomeController controller,
    dynamic fineId,
    String status,
    String message,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text("Confirm Action"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateVendorFineStatus(fineId.toString(), status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Paid' ? Colors.green : Colors.red,
            ),
            child: Text(
              status == 'Paid' ? "Resolve" : "Reject",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _safeText(dynamic value, {String fallback = "N/A"}) {
    if (value == null) return fallback;
    if (value is String && value.trim().isEmpty) return fallback;
    return value.toString();
  }

  String _formatDate(dynamic value, {String format = 'dd/MM/yyyy'}) {
    if (value == null) return "N/A";
    final raw = value.toString();
    if (raw.isEmpty) return "N/A";

    try {
      return Utility.getFormatedTime(raw, format);
    } catch (_) {
      return raw;
    }
  }

  String _formatFuelType(dynamic value) {
    if (value is List) {
      final fuelTypes = value
          .map((item) {
            if (item is Map) return item['name']?.toString() ?? "";
            return item?.toString() ?? "";
          })
          .where((item) => item.isNotEmpty)
          .join(", ");

      return fuelTypes.isEmpty ? "Fuel" : fuelTypes;
    }

    return _safeText(value, fallback: "Fuel");
  }

  String _imageUrl(String imagePath) {
    if (imagePath.isEmpty) return "";
    String cleanPath = imagePath;
    if (cleanPath.startsWith("undefined/")) {
      cleanPath = cleanPath.replaceFirst("undefined/", "");
    }
    if (cleanPath.startsWith("http")) return cleanPath;
    return "${ApiWrapper.imageUrl}$cleanPath";
  }
}
