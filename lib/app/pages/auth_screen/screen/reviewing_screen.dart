import 'dart:convert';
import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewingScreen extends StatefulWidget {
  const ReviewingScreen({super.key});

  @override
  State<ReviewingScreen> createState() => _ReviewingScreenState();
}

class _ReviewingScreenState extends State<ReviewingScreen> {
  bool _isRefreshing = false;
  String _approvalStatus = 'pending';
  String _rejectedReason = '';
  String _rejectedDescription = '';
  String _registerType = 'company';

  @override
  void initState() {
    super.initState();
    _loadStoredStatus();
    _checkStatusSilently();
  }

  void _loadStoredStatus() {
    final repo = Get.find<Repository>();
    setState(() {
      _approvalStatus = (repo.getStringValue(LocalKeys.vendorApprovalStatus)).toLowerCase();
      if (_approvalStatus.isEmpty) _approvalStatus = 'pending';
      _rejectedReason = repo.getStringValue(LocalKeys.vendorRejectedReason);
      _rejectedDescription = repo.getStringValue(LocalKeys.vendorRejectedDescription);
      _registerType = repo.getStringValue(LocalKeys.vendorRegisterType);
      if (_registerType.isEmpty) _registerType = 'company';
    });
  }

  Future<void> _checkStatusSilently() async {
    try {
      final controller = Get.find<AuthController>();
      final res = await controller.authPresenter.fetchVendorProfile(isLoading: false);
      if (!res.hasError) {
        final decoded = jsonDecode(res.data);
        if (decoded['IsSuccess'] == true && decoded['Data'] != null) {
          final data = decoded['Data'];
          final status = (data['approval_status'] ?? '').toString().toLowerCase();
          final reason = (data['rejected_reason'] ?? '').toString();
          final desc = (data['rejected_reason_description'] ?? '').toString();
          final regType = (data['register_type'] ?? '').toString();

          final repo = Get.find<Repository>();
          repo.saveValue(LocalKeys.vendorApprovalStatus, status);
          repo.saveValue(LocalKeys.vendorRejectedReason, reason);
          repo.saveValue(LocalKeys.vendorRejectedDescription, desc);
          if (regType.isNotEmpty) {
            repo.saveValue(LocalKeys.vendorRegisterType, regType);
          }

          if (mounted) {
            setState(() {
              _approvalStatus = status.isNotEmpty ? status : 'pending';
              _rejectedReason = reason;
              _rejectedDescription = desc;
              if (regType.isNotEmpty) _registerType = regType;
            });
          }

          if (status == 'approved') {
            Utility.snacBar(
              "Your profile has been approved! Welcome to BamBam Cabs.",
              ColorsValue.greenColor,
            );
            RouteManagement.gotoHomeScreen();
          }
        }
      }
    } catch (e) {
      debugPrint("Silent profile check failed: $e");
    }
  }

  Future<void> _manualRefresh() async {
    setState(() => _isRefreshing = true);
    await _checkStatusSilently();
    setState(() => _isRefreshing = false);
    if (_approvalStatus != 'approved') {
      Utility.snacBar("Status checked. Currently: $_approvalStatus", ColorsValue.appColor);
    }
  }

  Future<void> _launchCall() async {
    final Uri uri = Uri(scheme: 'tel', path: '+919998877665');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Utility.snacBar("Could not launch phone dialer", ColorsValue.redColor);
    }
  }

  Future<void> _launchEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'support@bambamcabs.com',
      queryParameters: {'subject': 'Vendor Account Verification Support'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Utility.snacBar("Could not launch email client", ColorsValue.redColor);
    }
  }

  void _openReuploadBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReuploadBottomSheet(
        registerType: _registerType,
        rejectedReason: _rejectedReason,
        onSuccess: () {
          Navigator.pop(context);
          _manualRefresh();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRejected = _approvalStatus == 'rejected';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () {
            RouteManagement.gotoLogainScreen();
          },
        ),
        title: Text(
          isRejected ? "Application Rejected" : "Application Status",
          style: Styles.g1txtColor60018,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isRefreshing ? null : _manualRefresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isRejected
                      ? [const Color(0xFFDC2626), const Color(0xFFEA580C)]
                      : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isRejected ? Colors.red : Colors.orange).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isRejected ? "ACTION REQUIRED" : "UNDER REVIEW / પ્રતીક્ષા",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isRejected
                        ? "તમારી પ્રોફાઇલ એડમિન દ્વારા રિજેક્ટ કરવામાં આવી છે"
                        : "તમારી પ્રોફાઇલ હજુ વેરિફિકેશન હેઠળ પેન્ડિંગ છે",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRejected
                        ? "તમારી પ્રોફાઇલમાં કેટલીક ભૂલ છે અથવા દસ્તાવેજ સ્પષ્ટ નથી. કૃપા કરીને નીચે આપેલ કારણ તપાસો અને ફરીથી દસ્તાવેજ અપલોડ કરો."
                        : "તમારી પ્રોફાઇલ સબમિટ થઈ ગઈ છે. એડમિન ટીમ દ્વારા વેરિફિકેશન પ્રક્રિયા ચાલી રહી છે. મહેરબાની કરીને થોડી રાહ જુઓ.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRefreshing ? null : _manualRefresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _isRefreshing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh, size: 16),
                          label: Text(
                            _isRefreshing ? "Checking..." : "Refresh Status",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      if (isRejected) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openReuploadBottomSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.file_upload_outlined, size: 16),
                            label: const Text(
                              "Re-upload",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Rejected Reason Card (Only if rejected)
            if (isRejected) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                        SizedBox(width: 8),
                        Text(
                          "રિજેક્શનનું કારણ / Reason for Rejection",
                          style: TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rejectedReason.isNotEmpty
                                ? _rejectedReason
                                : "Documents incomplete or invalid.",
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_rejectedDescription.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _rejectedDescription,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _openReuploadBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(42),
                      ),
                      child: const Text(
                        "📄 Re-upload Documents Now",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Step Progress Timeline
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Verification Progress",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressStep(
                    number: "1",
                    title: "Registration Completed",
                    subtitle: "Application form submitted",
                    isDone: true,
                    isActive: false,
                  ),
                  _buildProgressStep(
                    number: "2",
                    title: isRejected ? "Action Required" : "Admin Review & KYC",
                    subtitle: isRejected
                        ? "Please update the rejected documents"
                        : "Verification in progress by Admin team",
                    isDone: false,
                    isActive: true,
                    isError: isRejected,
                  ),
                  _buildProgressStep(
                    number: "3",
                    title: "Portal Activation",
                    subtitle: "Bookings & trips will unlock",
                    isDone: false,
                    isActive: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Admin Support & Contact Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorsValue.appColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "ADMIN HELP DESK / સહાયતા કેન્દ્ર",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Need Help With Verification?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "વેરિફિકેશન અંગે કોઈપણ પ્રશ્ન હોય તો સવારે ૧૦:૦૦ થી સાંજે ૬:૦૦ વાગ્યા દરમિયાન અમારો સંપર્ક કરો.",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone contact
                  InkWell(
                    onTap: _launchCall,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.phone_outlined, color: Color(0xFF34D399), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "CALL SUPPORT",
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "+91 99988 77665",
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Email contact
                  InkWell(
                    onTap: _launchEmail,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.email_outlined, color: Color(0xFF60A5FA), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "EMAIL SUPPORT",
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "support@bambamcabs.com",
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Timing
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.access_time_outlined, color: Color(0xFFFBBF24), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "WORKING HOURS",
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "10:00 AM - 6:00 PM (Monday - Saturday)",
                              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Option
            TextButton.icon(
              onPressed: () {
                Get.find<Repository>().clear();
                RouteManagement.gotoLogainScreen();
              },
              icon: const Icon(Icons.logout, size: 18, color: Colors.red),
              label: const Text(
                "Logout from Account",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required String number,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    bool isError = false,
  }) {
    Color circleColor = const Color(0xFFE2E8F0);
    Color textColor = const Color(0xFF64748B);
    Widget icon = Text(number, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white));

    if (isDone) {
      circleColor = const Color(0xFF10B981);
      icon = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isError) {
      circleColor = const Color(0xFFDC2626);
      icon = const Icon(Icons.close, color: Colors.white, size: 16);
    } else if (isActive) {
      circleColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFF1E293B);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive || isDone ? const Color(0xFF1E293B) : textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// RE-UPLOAD BOTTOM SHEET
// -------------------------------------------------------------
class _ReuploadBottomSheet extends StatefulWidget {
  final String registerType;
  final String rejectedReason;
  final VoidCallback onSuccess;

  const _ReuploadBottomSheet({
    required this.registerType,
    required this.rejectedReason,
    required this.onSuccess,
  });

  @override
  State<_ReuploadBottomSheet> createState() => _ReuploadBottomSheetState();
}

class _ReuploadBottomSheetState extends State<_ReuploadBottomSheet> {
  final Map<String, File> _selectedFiles = {};
  bool _isUploading = false;

  Future<void> _pickFile(String key) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFiles[key] = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitReupload() async {
    if (_selectedFiles.isEmpty) {
      Utility.snacBar("Please choose at least one document to re-upload", ColorsValue.redColor);
      return;
    }

    setState(() => _isUploading = true);
    try {
      final authCtrl = Get.find<AuthController>();
      final repo = Get.find<Repository>();
      final String vendorId = repo.getStringValue(LocalKeys.vendorId);

      final Map<String, String> fields = {
        'vendor_id': vendorId,
      };

      final bool isIndividual = widget.registerType == 'individual';
      final response = isIndividual
          ? await authCtrl.authPresenter.updateIndividualVendor(
              fields: fields,
              files: _selectedFiles,
            )
          : await authCtrl.authPresenter.updateCompanyVendor(
              fields: fields,
              files: _selectedFiles,
            );

      if (!response.hasError) {
        Utility.snacBar(
          "Documents re-uploaded successfully! Profile is under review.",
          ColorsValue.greenColor,
        );
        widget.onSuccess();
      } else {
        dynamic decoded = {};
        try {
          decoded = jsonDecode(response.data);
        } catch (_) {}
        final msg = decoded['Message'] ?? decoded['message'] ?? 'Failed to re-upload';
        Utility.snacBar(msg.toString(), ColorsValue.redColor);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIndividual = widget.registerType == 'individual';

    final List<Map<String, String>> docs = isIndividual
        ? [
            {'key': 'owner_photo', 'label': 'Owner Photo'},
            {'key': 'aadhar_card', 'label': 'Aadhaar Card'},
            {'key': 'pan_card', 'label': 'PAN Card'},
            {'key': 'cancel_cheque', 'label': 'Cancelled Cheque'},
            {'key': 'DL_photo', 'label': 'Driving License (DL)'},
            {'key': 'rc_image', 'label': 'Vehicle RC Document'},
            {'key': 'insurance_document', 'label': 'Insurance Certificate'},
            {'key': 'fitness_document', 'label': 'Fitness Certificate'},
          ]
        : [
            {'key': 'owner_photo', 'label': 'Contact Person Photo'},
            {'key': 'office_photo', 'label': 'Office Photo'},
            {'key': 'visiting_card', 'label': 'Visiting Card'},
            {'key': 'business_license', 'label': 'Business License / Gumasta'},
            {'key': 'aadhar_card', 'label': 'Aadhaar Card'},
            {'key': 'pan_card', 'label': 'PAN Card'},
            {'key': 'gst_certificate', 'label': 'GST Certificate'},
            {'key': 'address_proof', 'label': 'Address Proof / Light Bill'},
            {'key': 'cancel_cheque', 'label': 'Bank Cancelled Cheque'},
          ];

    return Container(
      height: Get.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Re-upload Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          if (widget.rejectedReason.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                "Reason: ${widget.rejectedReason}",
                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const Text(
            "Select the corrected documents to submit for admin review:",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final d = docs[index];
                final key = d['key']!;
                final label = d['label']!;
                final file = _selectedFiles[key];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: file != null ? ColorsValue.appColor : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (file != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                file.path.split('/').last.split('\\').last,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ColorsValue.appColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _pickFile(key),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: file != null ? Colors.grey.shade200 : Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          file != null ? "Change" : "Choose File",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _isUploading ? null : _submitReupload,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsValue.appColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    "Submit for Review",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}
