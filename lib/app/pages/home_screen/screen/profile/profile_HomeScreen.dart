import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/app/widgets/custom_text_form_field.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// S3 base URL used for all vendor-uploaded documents
const String _s3BaseUrl = 'https://bambams3.s3.ap-south-1.amazonaws.com/';

class ProfileHomescreen extends StatefulWidget {
  const ProfileHomescreen({super.key});

  @override
  State<ProfileHomescreen> createState() => _ProfileHomescreenState();
}

class _ProfileHomescreenState extends State<ProfileHomescreen> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh profile every time this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<HomeController>();
      controller.getVendorProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // ── Loading State ──
        if (controller.isProfileLoading) {
          return Scaffold(
            backgroundColor: ColorsValue.l3,
            appBar: AppBarWidget(
              onTapBack: () => Get.back(),
              title: "Personal Information",
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = controller.profile;

        // ── Empty / Error State ──
        if (data == null || data.isEmpty) {
          return Scaffold(
            backgroundColor: ColorsValue.l3,
            appBar: AppBarWidget(
              onTapBack: () => Get.back(),
              title: "Personal Information",
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
                  Dimens.boxHeight16,
                  const Text("Profile data not found"),
                  Dimens.boxHeight16,
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsValue.appColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => controller.getVendorProfile(),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                  ),
                ],
              ),
            ),
          );
        }

        final bank = data['bank_details'] ?? {};

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Personal Information",
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: ColorsValue.appColor),
                onPressed: () => _openEditProfileBottomSheet(context, data),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => controller.getVendorProfile(),
            child: ListView(
              padding: Dimens.edgeInsets20,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                // ── Personal Info ──
                _personalCard(data),
                Dimens.boxHeight16,

                // ── Bank Details ──
                _card(
                  title: "Bank Details",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field("Bank Name", bank['bank_name']),
                      _field("Account Holder", bank['account_holder_name']),
                      _field("Account Number", bank['account_number']),
                      _field("IFSC Code", bank['ifsc_code'], showDivider: false),
                    ],
                  ),
                ),
                Dimens.boxHeight16,

                // ── Document Details ──
                _card(
                  title: "Document Details",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _docTile("Aadhaar Card", data['aadhar_card'] ?? data['aadhar_pan'])),
                          Dimens.boxWidth16,
                          Expanded(child: _docTile("PAN Card", data['pan_card'])),
                        ],
                      ),
                      Dimens.boxHeight12,
                      Divider(color: ColorsValue.l2),
                      Dimens.boxHeight12,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _docTile(data['address_proof_type']?.toString() ?? "Address Proof", data['address_proof'])),
                          Dimens.boxWidth16,
                          Expanded(
                            child: (data['register_type']?.toString().toLowerCase() == 'company')
                                ? _docTile(data['business_proof_type']?.toString() ?? "Business Proof", data['business_license'])
                                : _docTile("Driving License", data['DL_photo']),
                          ),
                        ],
                      ),
                      Dimens.boxHeight12,
                      Divider(color: ColorsValue.l2),
                      Dimens.boxHeight12,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _docTile("GST Certificate", data['gst_certificate'])),
                          Dimens.boxWidth16,
                          Expanded(child: _docTile("Visiting Card", data['visiting_card'])),
                        ],
                      ),
                      Dimens.boxHeight12,
                      Divider(color: ColorsValue.l2),
                      Dimens.boxHeight12,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _docTile("Cancel Cheque", data['cancel_cheque'])),
                          Dimens.boxWidth16,
                          Expanded(child: _docTile("Owner Photo", data['owner_photo'])),
                        ],
                      ),
                      if (data['register_type']?.toString().toLowerCase() == 'company' && data['office_photo'] != null) ...[
                        Dimens.boxHeight12,
                        Divider(color: ColorsValue.l2),
                        Dimens.boxHeight12,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _docTile("Office Photo", data['office_photo'])),
                            Dimens.boxWidth16,
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                      // ── Verification Numbers ──
                      Dimens.boxHeight12,
                      Divider(color: ColorsValue.l2),
                      Dimens.boxHeight12,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _field("Aadhaar Number", data['aadhar_number'])),
                          Dimens.boxWidth16,
                          Expanded(child: _field("PAN Number", data['pan_number'])),
                        ],
                      ),
                      if (data['register_type']?.toString().toLowerCase() == 'company') ...[
                        Dimens.boxHeight10,
                        _field("GST Number", data['gst_number']),
                      ],
                      Dimens.boxHeight10,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _field(data['address_proof_type']?.toString() ?? "Address Proof", data['address_proof_number'], showDivider: false)),
                          if (data['register_type']?.toString().toLowerCase() == 'company') ...[
                            Dimens.boxWidth16,
                            Expanded(child: _field(data['business_proof_type']?.toString() ?? "Business Proof", data['business_proof_number'], showDivider: false)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Dimens.boxHeight20,
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────────────

  Widget _card({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      child: Padding(
        padding: Dimens.edgeInsets16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Styles.appColor60020),
            Dimens.boxHeight16,
            child,
          ],
        ),
      ),
    );
  }

  Widget _personalCard(Map data) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      child: Padding(
        padding: Dimens.edgeInsets16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: Dimens.fourty,
                backgroundColor: ColorsValue.l2,
                child: data['owner_photo'] != null
                    ? ClipOval(
                        child: Image.network(
                          _resolveImageUrl(data['owner_photo']),
                          width: Dimens.fourty * 2,
                          height: Dimens.fourty * 2,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) {
                            final fallbackUrl = data['owner_photo'];
                            if (fallbackUrl != null && fallbackUrl.toString().trim().isNotEmpty) {
                              final s3Url = fallbackUrl.toString().trim().startsWith("http")
                                  ? fallbackUrl.toString().trim()
                                  : "$_s3BaseUrl${fallbackUrl.toString().trim().replaceFirst("uploads/", "")}";
                              return Image.network(
                                s3Url,
                                width: Dimens.fourty * 2,
                                height: Dimens.fourty * 2,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: Dimens.fourty,
                                  color: Colors.grey,
                                ),
                              );
                            }
                            return Icon(
                              Icons.person,
                              size: Dimens.fourty,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : Icon(Icons.person, size: Dimens.fourty, color: Colors.grey),
              ),
            ),
            Dimens.boxHeight10,
            Divider(color: ColorsValue.l3),
            _field("Owner Name", data['owner_name']),
            _field("Email", data['owner_email']),
            _field("Address", data['address']),
            _field("User Name", data['username']),
            Row(
              children: [
                Expanded(
                  child: _field(
                    "Mobile No.",
                    data['owner_mobile'] != null ? "+91 ${data['owner_mobile']}" : null,
                    showDivider: false,
                  ),
                ),
                Expanded(
                  child: _field(
                    "City",
                    (data['owner_city'] is List && (data['owner_city'] as List).isNotEmpty)
                        ? data['owner_city'][0].toString()
                        : data['owner_city']?.toString(),
                    showDivider: false,
                  ),
                ),
              ],
            ),
          ],
        ),
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

  /// Document image tile — uses robust image resolver with S3 fallback
  Widget _docTile(String title, String? imagePath) {
    final String resolvedUrl = _resolveImageUrl(imagePath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.g1txtColor60014),
        Dimens.boxHeight6,
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: resolvedUrl.isNotEmpty
              ? Image.network(
                  resolvedUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 120,
                      color: ColorsValue.l3,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (ctx, error, stackTrace) {
                    // Try S3 fallback
                    if (imagePath != null && imagePath.trim().isNotEmpty) {
                      final s3Url = imagePath.trim().startsWith("http")
                          ? imagePath.trim()
                          : "$_s3BaseUrl${imagePath.trim().replaceFirst("uploads/", "")}";
                      return Image.network(
                        s3Url,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx2, child2, progress2) {
                          if (progress2 == null) return child2;
                          return Container(
                            height: 120,
                            color: ColorsValue.l3,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _docPlaceholder(title),
                      );
                    }
                    return _docPlaceholder(title);
                  },
                )
              : _docPlaceholder(title),
        ),
      ],
    );
  }

  Widget _docPlaceholder(String label) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsValue.l3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file_outlined, color: Colors.grey, size: 32),
          Dimens.boxHeight4,
          Text(
            "Not uploaded",
            style: Styles.g7txtColor40012,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String? value, {bool showDivider = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Dimens.boxHeight10,
        Text(label, style: Styles.g7txtColor40014),
        Dimens.boxHeight2,
        Text(
          (value != null && value.toString().isNotEmpty) ? value.toString() : "-",
          style: Styles.g1txtColor60016,
        ),
        if (showDivider) Divider(color: ColorsValue.l3),
      ],
    );
  }

  Future<File?> _pickFile(BuildContext context) async {
    File? picked;
    await Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Select Document Source".tr,
              style: Styles.blackColor60016,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    Get.back();
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (pickedFile != null) {
                      picked = File(pickedFile.path);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorsValue.appColor.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.camera_alt_rounded, color: ColorsValue.appColor, size: 36),
                        const SizedBox(height: 8),
                        Text("Camera".tr, style: Styles.blackColor60014),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    Get.back();
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    );
                    if (result != null && result.files.single.path != null) {
                      picked = File(result.files.single.path!);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorsValue.appColor.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.folder_rounded, color: ColorsValue.appColor, size: 36),
                        const SizedBox(height: 8),
                        Text("Files / Gallery".tr, style: Styles.blackColor60014),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    return picked;
  }

  void _openEditProfileBottomSheet(BuildContext context, Map data) {
    final nameController = TextEditingController(text: data['owner_name']?.toString() ?? '');
    final emailController = TextEditingController(text: (data['company_email'] ?? data['owner_email'])?.toString() ?? '');
    final addressController = TextEditingController(text: data['address']?.toString() ?? '');
    final aadharController = TextEditingController(text: data['aadhar_number']?.toString() ?? '');
    final panController = TextEditingController(text: data['pan_number']?.toString() ?? '');
    final gstController = TextEditingController(text: data['gst_number']?.toString() ?? '');

    final bank = data['bank_details'] ?? {};
    final bankNameController = TextEditingController(text: bank['bank_name']?.toString() ?? '');
    final bankHolderController = TextEditingController(text: bank['account_holder_name']?.toString() ?? '');
    final bankAccountNumberController = TextEditingController(text: bank['account_number']?.toString() ?? '');
    final bankIfscController = TextEditingController(text: bank['ifsc_code']?.toString() ?? '');

    final registerType = data['register_type']?.toString().toLowerCase() ?? 'company';
    final isCompany = registerType == 'company';

    // Reset profile verification states when opening the bottom sheet
    final controller = Get.find<HomeController>();
    controller.isProfileAadhaarVerified = true;
    controller.isProfilePanVerified = true;
    controller.isProfileGstVerified = true;
    controller.isProfileAadhaarVerifying = false;
    controller.isProfilePanVerifying = false;
    controller.isProfileGstVerifying = false;

    final initialAddressProofType = data['address_proof_type']?.toString() ?? 'Light bill';
    final initialAddressProofNumber = data['address_proof_number']?.toString() ?? '';
    final initialBusinessProofType = data['business_proof_type']?.toString() ?? 'Gumasta dhara';
    final initialBusinessProofNumber = data['business_proof_number']?.toString() ?? '';

    String selectedAddressType = ['Light bill', 'Rent agreement', 'Phone bill'].contains(initialAddressProofType) 
        ? initialAddressProofType 
        : 'Light bill';
    final addressProofNumberController = TextEditingController(text: initialAddressProofNumber);
    
    String selectedBusinessType = ['Gumasta dhara', 'MSME Certificate'].contains(initialBusinessProofType)
        ? initialBusinessProofType
        : 'Gumasta dhara';
    final businessProofNumberController = TextEditingController(text: initialBusinessProofNumber);

    File? ownerPhotoFile;
    File? aadharCardFile;
    File? panCardFile;
    File? addressProofFile;
    File? licenseFile;
    File? gstCertificateFile;
    File? visitingCardFile;
    File? cancelChequeFile;
    File? officePhotoFile;

    Get.bottomSheet(
      GetBuilder<HomeController>(
        builder: (controller) {
          return StatefulBuilder(
            builder: (context, setStateSheet) {
          Widget docEditTile(String label, File? file, VoidCallback onTap) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ColorsValue.l3,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorsValue.borderColor, width: 0.8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: Styles.blackColor60014),
                        const SizedBox(height: 4),
                        Text(
                          file != null ? file.path.split('/').last : "Tap to replace document...",
                          style: TextStyle(
                            fontSize: 12,
                            color: file != null ? ColorsValue.appColor : Colors.grey,
                            fontWeight: file != null ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: Icon(file != null ? Icons.check_circle_outline : Icons.upload_file, size: 18),
                    label: Text(file != null ? "Selected" : "Choose"),
                    style: TextButton.styleFrom(
                      foregroundColor: file != null ? Colors.green : ColorsValue.appColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Edit Profile Information", style: Styles.blackColor60018),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: nameController,
                    title: "Owner Name",
                    hintText: "Enter owner name",
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: emailController,
                    title: isCompany ? "Company Email" : "Email",
                    hintText: "Enter email address",
                    keyboardType: TextInputType.emailAddress,
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: addressController,
                    title: "Address",
                    hintText: "Enter address",
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: aadharController,
                    title: "Aadhaar Number",
                    hintText: "Enter 12-digit Aadhaar number",
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                    onChanged: (val) {
                      final original = data['aadhar_number']?.toString() ?? '';
                      if (val.trim() != original.trim()) {
                        controller.isProfileAadhaarVerified = false;
                      } else {
                        controller.isProfileAadhaarVerified = true;
                      }
                      controller.update();
                    },
                    suffixIcon: controller.isProfileAadhaarVerifying
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                            ),
                          )
                        : controller.isProfileAadhaarVerified
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : TextButton(
                                onPressed: () {
                                  controller.requestProfileAadhaarOtp(aadharController.text);
                                },
                                child: Text("Verify".tr, style: Styles.appColor60014),
                              ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: panController,
                    title: "PAN Number",
                    hintText: "Enter PAN card number",
                    maxLength: 10,
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                    onChanged: (val) {
                      final original = data['pan_number']?.toString() ?? '';
                      if (val.trim().toUpperCase() != original.trim().toUpperCase()) {
                        controller.isProfilePanVerified = false;
                      } else {
                        controller.isProfilePanVerified = true;
                      }
                      controller.update();
                    },
                    suffixIcon: controller.isProfilePanVerifying
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                            ),
                          )
                        : controller.isProfilePanVerified
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : TextButton(
                                onPressed: () {
                                  controller.verifyProfilePAN(panController.text, nameController.text);
                                },
                                child: Text("Verify".tr, style: Styles.appColor60014),
                              ),
                  ),
                  if (isCompany) ...[
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      isTitle: true,
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      isBorder: true,
                      textEditingController: gstController,
                      title: "GST Number",
                      hintText: "Enter GSTIN number",
                      maxLength: 15,
                      titleStyle: Styles.blackColor60014,
                      hintStyle: Styles.g7txtColor40012,
                      onChanged: (val) {
                        final original = data['gst_number']?.toString() ?? '';
                        if (val.trim().toUpperCase() != original.trim().toUpperCase()) {
                          controller.isProfileGstVerified = false;
                        } else {
                          controller.isProfileGstVerified = true;
                        }
                        controller.update();
                      },
                      suffixIcon: controller.isProfileGstVerifying
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                              ),
                            )
                          : controller.isProfileGstVerified
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : TextButton(
                                  onPressed: () {
                                    controller.verifyProfileGST(gstController.text);
                                  },
                                  child: Text("Verify".tr, style: Styles.appColor60014),
                                ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text("Bank Details", style: Styles.blackColor60016),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: bankNameController,
                    title: "Bank Name",
                    hintText: "Enter bank name",
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: bankHolderController,
                    title: "Account Holder Name",
                    hintText: "Enter account holder name",
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: bankAccountNumberController,
                    title: "Account Number",
                    hintText: "Enter account number",
                    keyboardType: TextInputType.number,
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: bankIfscController,
                    title: "IFSC Code",
                    hintText: "Enter IFSC code (e.g. SBIN0001234)",
                    maxLength: 11,
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                  ),
                  const SizedBox(height: 12),
                  Text("Address Proof Type", style: Styles.blackColor60014),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedAddressType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorsValue.borderColor, width: 0.8),
                      ),
                    ),
                    items: ['Light bill', 'Rent agreement', 'Phone bill']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateSheet(() {
                          selectedAddressType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    isTitle: true,
                    filled: true,
                    fillColor: ColorsValue.fildColos,
                    isBorder: true,
                    textEditingController: addressProofNumberController,
                    title: "$selectedAddressType Number",
                    hintText: "Enter $selectedAddressType number",
                    titleStyle: Styles.blackColor60014,
                    hintStyle: Styles.g7txtColor40012,
                  ),
                  const SizedBox(height: 12),
                  docEditTile("$selectedAddressType Image", addressProofFile, () async {
                    final f = await _pickFile(context);
                    if (f != null) setStateSheet(() => addressProofFile = f);
                  }),
                  if (isCompany) ...[
                    const SizedBox(height: 12),
                    Text("Business Proof Type", style: Styles.blackColor60014),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedBusinessType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorsValue.fildColos,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: ColorsValue.borderColor, width: 0.8),
                        ),
                      ),
                      items: ['Gumasta dhara', 'MSME Certificate']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateSheet(() {
                            selectedBusinessType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      isTitle: true,
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      isBorder: true,
                      textEditingController: businessProofNumberController,
                      title: "$selectedBusinessType Number",
                      hintText: "Enter $selectedBusinessType number",
                      titleStyle: Styles.blackColor60014,
                      hintStyle: Styles.g7txtColor40012,
                    ),
                    const SizedBox(height: 12),
                    docEditTile("$selectedBusinessType Image", licenseFile, () async {
                      final f = await _pickFile(context);
                      if (f != null) setStateSheet(() => licenseFile = f);
                    }),
                  ],
                  const SizedBox(height: 20),
                  Text("Replace Uploaded Documents", style: Styles.blackColor60016),
                  const SizedBox(height: 8),
                  
                  docEditTile("Owner Photo", ownerPhotoFile, () async {
                    final f = await _pickFile(context);
                    if (f != null) setStateSheet(() => ownerPhotoFile = f);
                  }),
                  docEditTile("Aadhaar Card", aadharCardFile, () async {
                    final f = await _pickFile(context);
                    if (f != null) setStateSheet(() => aadharCardFile = f);
                  }),
                  docEditTile("PAN Card", panCardFile, () async {
                    final f = await _pickFile(context);
                    if (f != null) setStateSheet(() => panCardFile = f);
                  }),
                  if (!isCompany)
                    docEditTile("Driving License", licenseFile, () async {
                      final f = await _pickFile(context);
                      if (f != null) setStateSheet(() => licenseFile = f);
                    }),
                  docEditTile("GST Certificate", gstCertificateFile, () async {
                    final f = await _pickFile(context);
                    if (f != null) setStateSheet(() => gstCertificateFile = f);
                  }),
                  docEditTile("Visiting Card", visitingCardFile, () async {
                    final f = await _pickFile(context);
                    if (f != null) setStateSheet(() => visitingCardFile = f);
                  }),
                  docEditTile("Cancel Cheque", cancelChequeFile, () async {
                    final f = await _pickFile(context);
                    if (f != null) setStateSheet(() => cancelChequeFile = f);
                  }),
                  if (isCompany)
                    docEditTile("Office Photo", officePhotoFile, () async {
                      final f = await _pickFile(context);
                      if (f != null) setStateSheet(() => officePhotoFile = f);
                    }),
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: () async {
                      if (!controller.isProfileAadhaarVerified) {
                        Utility.snacBar("Please verify Aadhaar number first".tr, ColorsValue.redColor);
                        return;
                      }
                      if (!controller.isProfilePanVerified) {
                        Utility.snacBar("Please verify PAN number first".tr, ColorsValue.redColor);
                        return;
                      }
                      if (isCompany && !controller.isProfileGstVerified) {
                        Utility.snacBar("Please verify GST number first".tr, ColorsValue.redColor);
                        return;
                      }

                      if (addressProofNumberController.text.trim().isEmpty) {
                        Utility.snacBar("Please enter $selectedAddressType number".tr, ColorsValue.redColor);
                        return;
                      }
                      if (isCompany && businessProofNumberController.text.trim().isEmpty) {
                        Utility.snacBar("Please enter $selectedBusinessType number".tr, ColorsValue.redColor);
                        return;
                      }

                      final success = await Get.find<HomeController>().updateVendorProfile(
                        ownerName: nameController.text,
                        email: emailController.text,
                        address: addressController.text,
                        aadharNumber: aadharController.text,
                        panNumber: panController.text,
                        gstNumber: isCompany ? gstController.text : null,
                        bankName: bankNameController.text,
                        bankHolderName: bankHolderController.text,
                        bankAccountNumber: bankAccountNumberController.text,
                        bankIfsc: bankIfscController.text,
                        businessProofType: isCompany ? selectedBusinessType : null,
                        businessProofNumber: isCompany ? businessProofNumberController.text : null,
                        addressProofType: selectedAddressType,
                        addressProofNumber: addressProofNumberController.text,
                        ownerPhotoFile: ownerPhotoFile,
                        aadharCardFile: aadharCardFile,
                        panCardFile: panCardFile,
                        addressProofFile: addressProofFile,
                        licenseFile: licenseFile,
                        gstCertificateFile: gstCertificateFile,
                        visitingCardFile: visitingCardFile,
                        cancelChequeFile: cancelChequeFile,
                        officePhotoFile: officePhotoFile,
                      );
                      if (success) {
                        await Future.delayed(const Duration(milliseconds: 350));
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Get.back();
                        }
                        Get.find<HomeController>().getVendorProfile();
                      }
                    },
                    text: "Save Changes",
                    backgroundColor: ColorsValue.appColor,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
      },
    ),
    isScrollControlled: true,
    ignoreSafeArea: false,
  );
  }
}
