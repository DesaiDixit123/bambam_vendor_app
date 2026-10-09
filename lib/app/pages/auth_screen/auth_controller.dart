import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:bam_bam_vendor/app/theme/dimens.dart';
import 'package:bam_bam_vendor/app/theme/styles.dart';
import 'package:bam_bam_vendor/app/widgets/custom_text_form_field.dart';
import 'package:bam_bam_vendor/app/widgets/verification_dialogs.dart';
import 'package:bam_bam_vendor/app/utils/name_match_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:bam_bam_vendor/app/navigators/navigators.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:bam_bam_vendor/app/pages/auth_screen/auth_page.dart';
import 'package:bam_bam_vendor/app/theme/colors_value.dart';
import 'package:bam_bam_vendor/app/utils/utility.dart';
import 'package:bam_bam_vendor/domain/entities/enums.dart';
import 'package:bam_bam_vendor/domain/repositories/local_storage_keys.dart';
import 'package:bam_bam_vendor/domain/repositories/repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'package:bam_bam_vendor/domain/services/socket_connection.dart';
import 'package:get/get.dart';


class AuthController extends GetxController {
  AuthController(this.authPresenter);

  final AuthPresenter authPresenter;

  // ------------------------------------------------- Login Page -------------------------------------------------

  int loginMode = 0;
  //bool rememberMe = false;
  final RxBool isPasswordVisible = false.obs;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  String code = "";
  // OTP Timer
  Timer? _otpTimer;
  RxInt otpSeconds = 30.obs;
  RxBool canResendOtp = false.obs;
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is String) {
      mobile = Get.arguments as String;
      usernameController.text = mobile!;
    }
    fetchStates();
    fetchCities();
    fetchLanguages();
    fetchVehicleTypes();
    fetchFuelTypes();

    fullNameController.addListener(onRegistrationInfoChanged);
    companyPersonNameController.addListener(onRegistrationInfoChanged);
    mobileNumberController.addListener(onRegistrationInfoChanged);
    _clearFcmOnBackend();
  }

  Future<void> _clearFcmOnBackend() async {
    try {
      final String? fcmToken = await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await authPresenter.authUsecases.apiWrapper.makeRequest(
          "clear-fcm-token",
          Request.post,
          {"fcm_token": fcmToken},
          false,
        );
        print("FCM Token cleared from backend because user is on login screen");
      }
    } catch (e) {
      print("Error clearing FCM token on backend initialization: $e");
    }
  }

  void onRegistrationInfoChanged() {
    if (!isManualUsername) {
      String name = fullNameController.text.trim();
      if (name.isEmpty) {
        name = companyPersonNameController.text.trim();
      }
      usernameController.text = generateUsername(
        name,
        mobileNumberController.text.trim(),
      );
      update();
    }
  }

  String generateUsername(String fullName, String mobile) {
    if (fullName.isEmpty || mobile.length < 4) return "";

    String cleanedName = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), "")
        .replaceAll(RegExp(r'[^a-z]'), "");

    String last4 = mobile.substring(mobile.length - 4);

    final List<String> specialChars = ['@', '_', '#', '\$', '&', '!'];
    String randomChar =
        specialChars[DateTime.now().millisecond % specialChars.length];

    return "$cleanedName$randomChar$last4";
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    _companyOtpTimer?.cancel();
    _individualOtpTimer?.cancel();
    companyOtpController.dispose();
    individualOtpController.dispose();
    super.onClose();
  }

  void startOtpTimer() {
    otpSeconds.value = 30;
    canResendOtp.value = false;

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpSeconds.value == 0) {
        canResendOtp.value = true;
        timer.cancel();
      } else {
        otpSeconds.value--;
      }
    });
  }

  void changeLoginMode(int mode) {
    loginMode = mode;
    // Clear the opposite controller to avoid stale data between tabs
    if (mode == 0) {
      mobileController.clear(); // switching to username tab → clear phone field
    } else {
      usernameController.clear(); // switching to OTP tab → clear username field
    }
    update();
  }

  // void toggleRememberMe(bool? value) {
  //   rememberMe = value ?? false;
  //   update();
  // }

  Future<void> loginWithUsername() async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      log("Error fetching FCM token: $e");
    }

    final body = {
      "username": usernameController.text.trim(),
      "password": passwordController.text.trim(),
      "fcm_token": fcmToken,
    };
    print("Login Request Body: $body");

    final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
      "login",
      Request.post,
      body,
      true,
    );

    if (!response.hasError) {
      final body = jsonDecode(response.data);
      if (body is Map && body.containsKey('Data')) {
        final data = body['Data'] as Map<String, dynamic>;

        // Save access token (accesstoken)
        final accessToken =
            (data['accesstoken'] ??
                    data['accessToken'] ??
                    data['token'] ??
                    data['jwt_token'])
                ?.toString() ??
            '';
        if (accessToken.isNotEmpty) {
          // Persist token to repository (so Utility.commonHeader can read it)
          Get.find<Repository>().saveValue(LocalKeys.authToken, accessToken);
        }

        final vendorDetails = data['vendordetails'];
        if (vendorDetails != null && vendorDetails['_id'] != null) {
          String vId = vendorDetails['_id'].toString();
          Get.find<Repository>().saveValue(LocalKeys.vendorId, vId);
          Get.find<Repository>().saveValue(LocalKeys.chanelId, vId);
          SocketConnection.initSocket();
        }
      }
      RouteManagement.gotoHomeScreen();
    } else {
      final decoded = jsonDecode(response.data);

      Utility.snacBar(
        decoded['Message'] ?? decoded['message'] ?? 'Something went wrong',
        ColorsValue.redColor,
      );
    }
  }

  Future<void> getOtp() async {
    final phoneNumber = mobileController.text.trim();
    print("==================================================");
    print("[FLUTTER LOGIN] getOtp() triggered");
    print("Mobile number entered: '$phoneNumber'");
    print("==================================================");

    if (phoneNumber.isEmpty) {
      print("[FLUTTER LOGIN] Validation failed: Mobile number is empty");
      Utility.snacBar("Enter mobile number", ColorsValue.redColor);
      return;
    }
    if (phoneNumber.length != 10) {
      print("[FLUTTER LOGIN] Validation failed: Mobile number length is ${phoneNumber.length} (expected 10)");
      Utility.snacBar("Enter a valid 10-digit mobile number", ColorsValue.redColor);
      return;
    }

    try {
      print("[FLUTTER LOGIN] Making API Request: POST 'send-otp' with body: {'owner_mobile': '$phoneNumber'}");
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "send-otp",
        Request.post,
        {"owner_mobile": phoneNumber},
        true,
      );

      print("[FLUTTER LOGIN] API 'send-otp' response received:");
      print("  Status Code: ${response.statusCode}");
      print("  Has Error: ${response.hasError}");
      print("  Raw Response Data: ${response.data}");

      if (!response.hasError) {
        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(response.data) as Map<String, dynamic>;
          print("[FLUTTER LOGIN] Decoded JSON successfully: $decoded");
        } catch (e) {
          print("[FLUTTER LOGIN] JSON decoding failed: $e");
          Utility.snacBar("Unexpected server response. Please try again.", ColorsValue.redColor);
          return;
        }

        final data = decoded["Data"];
        print("[FLUTTER LOGIN] Extracted 'Data' field: $data");
        if (data != null && data is Map && data["otp"] != null) {
          code = data["otp"].toString();
          print("[FLUTTER LOGIN] Extracted OTP code: '$code'");
        } else {
          print("[FLUTTER LOGIN] 'Data' is null or 'otp' field is missing. Data structure: $data");
          code = "";
        }

        mobile = phoneNumber;
        startOtpTimer();
        print("[FLUTTER LOGIN] Navigating to OTP Screen for mobile: $phoneNumber");
        RouteManagement.gotoOtpScreen(arguments: phoneNumber);
      } else {
        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(response.data) as Map<String, dynamic>;
          print("[FLUTTER LOGIN] Decoded Error JSON successfully: $decoded");
        } catch (e) {
          print("[FLUTTER LOGIN] Error Response JSON decoding failed: $e");
          Utility.snacBar("Server error (${response.statusCode}). Please try again.", ColorsValue.redColor);
          return;
        }
        final msg = decoded['Message'] ?? decoded['message'] ?? decoded['error'] ?? 'Something went wrong';
        print("[FLUTTER LOGIN] API Error Message: '$msg'");
        Utility.snacBar(msg.toString(), ColorsValue.redColor);
      }
    } catch (e, stack) {
      print("[FLUTTER LOGIN] EXCEPTION in getOtp: $e");
      print("[FLUTTER LOGIN] Stacktrace:\n$stack");
      Utility.snacBar("Failed to send OTP: ${e.toString()}", ColorsValue.redColor);
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp.value) {
      print("[FLUTTER LOGIN] resendOtp() aborted: timer has not expired yet");
      return;
    }

    final phoneNumber = mobile ?? mobileController.text.trim();
    print("==================================================");
    print("[FLUTTER LOGIN] resendOtp() triggered");
    print("Mobile number: '$phoneNumber'");
    print("==================================================");

    try {
      print("[FLUTTER LOGIN] Making API Request: POST 'send-otp' for resend");
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "send-otp",
        Request.post,
        {"owner_mobile": phoneNumber},
        true,
      );

      print("[FLUTTER LOGIN] API 'send-otp' (resend) response received:");
      print("  Status Code: ${response.statusCode}");
      print("  Has Error: ${response.hasError}");
      print("  Raw Response Data: ${response.data}");

      if (!response.hasError) {
        Utility.snacBar("OTP sent again", ColorsValue.appColor);
        startOtpTimer();
        
        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(response.data) as Map<String, dynamic>;
          print("[FLUTTER LOGIN] Decoded JSON successfully: $decoded");
        } catch (e) {
          print("[FLUTTER LOGIN] JSON decoding failed: $e");
          return;
        }

        final data = decoded["Data"];
        if (data != null && data is Map && data["otp"] != null) {
          code = data["otp"].toString();
          print("[FLUTTER LOGIN] Extracted OTP code: '$code'");
        } else {
          print("[FLUTTER LOGIN] 'Data' or 'otp' is missing in resend response: $data");
          code = "";
        }
      } else {
        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(response.data) as Map<String, dynamic>;
        } catch (e) {
          print("[FLUTTER LOGIN] Error JSON decoding failed in resend: $e");
          Utility.snacBar("Something went wrong", ColorsValue.redColor);
          return;
        }
        final msg = decoded['Message'] ?? decoded['message'] ?? 'Something went wrong';
        print("[FLUTTER LOGIN] Resend OTP error message: '$msg'");
        Utility.snacBar(msg.toString(), ColorsValue.redColor);
      }
    } catch (e, stack) {
      print("[FLUTTER LOGIN] EXCEPTION in resendOtp: $e");
      print("[FLUTTER LOGIN] Stacktrace:\n$stack");
      Utility.snacBar("Failed to resend OTP: ${e.toString()}", ColorsValue.redColor);
    }
  }

  Future<void> verifyOtp() async {
    print("==================================================");
    print("[FLUTTER LOGIN] verifyOtp() triggered");
    print("Entered Code/OTP: '$code'");
    print("Mobile number: '$mobile'");
    print("==================================================");

    if (code.length != 6) {
      print("[FLUTTER LOGIN] Validation failed: Code length is ${code.length} (expected 6)");
      Utility.snacBar("Enter valid OTP", ColorsValue.redColor);
      return;
    }

    try {
      String? fcmToken;
      try {
        print("[FLUTTER LOGIN] Fetching FCM token...");
        fcmToken = await FirebaseMessaging.instance.getToken().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print("[FLUTTER LOGIN] FCM Token timeout - proceeding without token");
            return null;
          },
        );
        print("[FLUTTER LOGIN] FCM Token fetched: '$fcmToken'");
      } catch (e) {
        print("[FLUTTER LOGIN] Caught FCM error (expected on simulators): $e");
      }

      final body = {"owner_mobile": mobile, "otp": code, "fcm_token": fcmToken};
      print("[FLUTTER LOGIN] Making API Request: POST 'verify-otp' with body: $body");

      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify-otp",
        Request.post,
        body,
        true,
      );

      print("[FLUTTER LOGIN] API 'verify-otp' response received:");
      print("  Status Code: ${response.statusCode}");
      print("  Has Error: ${response.hasError}");
      print("  Raw Response Data: ${response.data}");

      if (!response.hasError) {
        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(response.data) as Map<String, dynamic>;
          print("[FLUTTER LOGIN] Decoded success response: $decoded");
        } catch (e) {
          print("[FLUTTER LOGIN] JSON decoding failed on verify success: $e");
          Utility.snacBar("Failed to parse verification response.", ColorsValue.redColor);
          return;
        }

        if (decoded.containsKey('Data')) {
          final data = decoded['Data'] as Map<String, dynamic>;
          print("[FLUTTER LOGIN] Extracted 'Data' from response: $data");

          final accessToken = (data['accesstoken'] ??
                  data['accessToken'] ??
                  data['token'] ??
                  data['jwt_token'])
              ?.toString() ??
              '';
          print("[FLUTTER LOGIN] Extracted Access Token: '$accessToken'");

          if (accessToken.isNotEmpty) {
            Get.find<Repository>().saveValue(LocalKeys.authToken, accessToken);
            print("[FLUTTER LOGIN] Saved Auth Token to Repository");
          }

          final vendorDetails = data['vendordetails'];
          print("[FLUTTER LOGIN] Vendor Details: $vendorDetails");
          if (vendorDetails != null && vendorDetails['_id'] != null) {
            String vId = vendorDetails['_id'].toString();
            Get.find<Repository>().saveValue(LocalKeys.vendorId, vId);
            Get.find<Repository>().saveValue(LocalKeys.chanelId, vId);
            print("[FLUTTER LOGIN] Saved Vendor ID and Chanel ID: '$vId'");
            SocketConnection.initSocket();
            print("[FLUTTER LOGIN] Socket connection initialized");
          }
        } else {
          print("[FLUTTER LOGIN] WARNING: 'Data' key not found in response.");
        }
        
        _otpTimer?.cancel();
        print("[FLUTTER LOGIN] OTP Timer cancelled. Navigating to Home Screen");
        RouteManagement.gotoHomeScreen();
      } else {
        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(response.data) as Map<String, dynamic>;
          print("[FLUTTER LOGIN] Decoded error response: $decoded");
        } catch (e) {
          print("[FLUTTER LOGIN] JSON decoding failed on verify error: $e");
          Utility.snacBar("Verification failed with status ${response.statusCode}", ColorsValue.redColor);
          return;
        }

        final msg = decoded['Message'] ?? decoded['message'] ?? 'Something went wrong';
        print("[FLUTTER LOGIN] Verification Error Message: '$msg'");
        Utility.snacBar(msg.toString(), ColorsValue.redColor);
      }
    } catch (e, stack) {
      print("[FLUTTER LOGIN] EXCEPTION in verifyOtp: $e");
      print("[FLUTTER LOGIN] Stacktrace:\n$stack");
      Utility.snacBar("Verification error: ${e.toString()}", ColorsValue.redColor);
    }
  }

  void goToRegister() {
    RouteManagement.gotoRegisterstep1Screen();
  }

  // ------------------------------------------------- OTP Page -------------------------------------------------

  GlobalKey<FormState> otpKey = GlobalKey<FormState>();
  TextEditingController pinController = TextEditingController();

  String? mobile;

  // ------------------------------------------------- Company Registration Controllers -------------------------------------------------

  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyPersonNameController = TextEditingController();
  TextEditingController companyDobController = TextEditingController();
  TextEditingController persoNimageController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController aderessController = TextEditingController();
  TextEditingController fleetSizeController = TextEditingController();

  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankAccountNumberController = TextEditingController();
  TextEditingController bankHolderNameController = TextEditingController();
  TextEditingController bankIFSCController = TextEditingController();
  TextEditingController branchNameController = TextEditingController();

  // ------------------------------------------------- Individual Registration Controllers -------------------------------------------------

  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController gmailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController upiIdController = TextEditingController();
  TextEditingController adressController = TextEditingController();
  TextEditingController useNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController ownerPhotoController = TextEditingController();
  bool isManualUsername = false;

  // License Details
  TextEditingController dlNumberController = TextEditingController();
  TextEditingController dlIssueDateController = TextEditingController();
  TextEditingController dlExpiryDateController = TextEditingController();
  TextEditingController dlPhotoController = TextEditingController();

  // Vehicle Details
  TextEditingController brandNameController = TextEditingController();
  TextEditingController vehicleTypeController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController fuelTypeController = TextEditingController();
  TextEditingController vehicleMakeYearController = TextEditingController();
  TextEditingController sourcingController = TextEditingController();
  TextEditingController petFriendlyController = TextEditingController();
  TextEditingController luggageCarrierController = TextEditingController();
  TextEditingController workingRearSeatBeltsController =
      TextEditingController();

  // Expiry Dates & Types
  TextEditingController insuranceExpiryController = TextEditingController();
  TextEditingController fitnessExpiryController = TextEditingController();
  TextEditingController permitExpiryController = TextEditingController();
  TextEditingController permitTypeController = TextEditingController();

  // Document Controllers
  TextEditingController insuranceDocumentController = TextEditingController();
  TextEditingController fitnessDocumentController = TextEditingController();
  TextEditingController permitDocumentController = TextEditingController();
  TextEditingController pucDocumentController = TextEditingController();
  TextEditingController rcImageController = TextEditingController();
  TextEditingController frontImageController = TextEditingController();
  TextEditingController backImageController = TextEditingController();
  TextEditingController leftImageController = TextEditingController();
  TextEditingController rightImageController = TextEditingController();
  TextEditingController interiorImageController = TextEditingController();
  TextEditingController numberPlateImageController = TextEditingController();
  TextEditingController dickyImageController = TextEditingController();
  TextEditingController carrierImageController = TextEditingController();
  TextEditingController rentedVehicleAgreementController =
      TextEditingController();

  TextEditingController businessLicenseController = TextEditingController();
  TextEditingController aadhaarPanController = TextEditingController();
  TextEditingController aadharCardController = TextEditingController();
  TextEditingController panCardController = TextEditingController();
  TextEditingController gstCertificateController = TextEditingController();
  TextEditingController electricityBillController = TextEditingController();
  TextEditingController officePhotoController = TextEditingController();
  TextEditingController visitingCardController = TextEditingController();
  TextEditingController cancelChequeController = TextEditingController();
  TextEditingController addressProofController = TextEditingController();
  
  String selectedBusinessProofType = 'Gumasta dhara';
  TextEditingController businessProofNumberController = TextEditingController();
  String selectedAddressProofType = 'Light bill';
  TextEditingController addressProofNumberController = TextEditingController();

  int? selectedOption;

  // ------------------------------------------------- File Picker -------------------------------------------------



  File? ownerPhoto;
  File? officePhoto;
  File? visitingCard;
  File? businessLicense;
  File? aadhaarPan;
  File? aadharCard;
  File? panCard;
  File? gstCertificate;
  File? addressProof;
  File? cancelCheque;
  File? electricityBill;

  // New Document Files
  File? dlPhoto;
  File? insuranceDocument;
  File? fitnessDocument;
  File? permitDocument;
  File? pucDocument;
  File? rcImage;
  File? frontImage;
  File? backImage;
  File? leftImage;
  File? rightImage;
  File? interiorImage;
  File? numberPlateImage;
  File? dickyImage;
  File? carrierImage;
  File? rentedVehicleAgreement;

  // Master Data Lists
  List<dynamic> languagesList = [];
  List<dynamic> vehicleTypesList = [];
  List<dynamic> fuelTypesList = [];
  List<dynamic> statesList = [];
  List<dynamic> citiesList = [];

  List<String> bankNamesList = [
    "State Bank of India",
    "HDFC Bank",
    "ICICI Bank",
    "Axis Bank",
    "Bank of Baroda",
    "Punjab National Bank",
    "Canara Bank",
    "Union Bank of India",
    "Kotak Mahindra Bank",
    "IndusInd Bank",
    "Yes Bank",
    "Federal Bank",
    "IDBI Bank",
    "Bank of India",
    "Central Bank of India",
    "Indian Bank",
    "Indian Overseas Bank",
    "UCO Bank",
    "Bank of Maharashtra"
  ];

  List<String> get availableBankNames {
    final list = List<String>.from(bankNamesList);
    final currentVal = bankNameController.text.trim();
    if (currentVal.isNotEmpty && !list.contains(currentVal)) {
      list.add(currentVal);
    }
    return list;
  }

  List<dynamic> selectedLanguages = [];
  List<dynamic> selectedVehiclesToDrive = [];
  String? selectedVehicleType;
  String? selectedFuelType;

  // Verification states
  bool isPanVerified = false;
  bool isAadhaarVerified = false;
  bool isGstVerified = false;
  bool isBankVerified = false;

  bool isPanVerifying = false;
  bool isAadhaarVerifying = false;
  bool isGstVerifying = false;
  bool isBankVerifying = false;

  String aadhaarRefId = "";

  // Company Registration verification states (separate from individual)
  bool isCompanyPanVerified = false;
  bool isCompanyAadhaarVerified = false;
  bool isCompanyGstVerified = false;
  String companyAadhaarRefId = "";
  bool isCompanyPanVerifying = false;
  bool isCompanyAadhaarVerifying = false;
  bool isCompanyGstVerifying = false;

  // Text controllers for document numbers
  TextEditingController aadhaarNumberController = TextEditingController();
  TextEditingController panNumberController = TextEditingController();
  TextEditingController gstNumberController = TextEditingController();

  // ── Company Registration Mobile OTP Verification ──
  bool isCompanyMobileVerified = false;
  bool isCompanyMobileOtpSent = false;
  bool isCompanySendingOtp = false;
  bool isCompanyVerifyingOtp = false;
  String verifiedCompanyMobile = "";
  TextEditingController companyOtpController = TextEditingController();
  RxInt companyOtpSeconds = 30.obs;
  RxBool canResendCompanyOtp = false.obs;
  Timer? _companyOtpTimer;

  // ── Individual Registration Mobile OTP Verification ──
  bool isIndividualMobileVerified = false;
  bool isIndividualMobileOtpSent = false;
  bool isIndividualSendingOtp = false;
  bool isIndividualVerifyingOtp = false;
  String verifiedIndividualMobile = "";
  TextEditingController individualOtpController = TextEditingController();
  RxInt individualOtpSeconds = 30.obs;
  RxBool canResendIndividualOtp = false.obs;
  Timer? _individualOtpTimer;

  Future<void> pickDocument({
    required Function(File file) onPicked,
    required TextEditingController controller,
  }) async {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: ColorsValue.whiteColor,
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
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera".tr,
                  onTap: () async {
                    Get.back();
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (pickedFile != null) {
                      final file = File(pickedFile.path);
                      onPicked(file);
                      controller.text = file.path.split('/').last;
                      update();
                    }
                  },
                ),
                _buildSourceOption(
                  icon: Icons.folder_rounded,
                  label: "Files / Gallery".tr,
                  onTap: () async {
                    Get.back();
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    );
                    if (result != null && result.files.single.path != null) {
                      final file = File(result.files.single.path!);
                      onPicked(file);
                      controller.text = file.path.split('/').last;
                      update();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorsValue.appColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ColorsValue.appColor, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: Styles.blackColor60014,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickContactPersonPhoto() async {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: ColorsValue.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Select Photo Source".tr,
              style: Styles.blackColor60016,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera".tr,
                  onTap: () async {
                    Get.back();
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (pickedFile != null) {
                      ownerPhoto = File(pickedFile.path);
                      persoNimageController.text = ownerPhoto!.path.split('/').last;
                      update();
                    }
                  },
                ),
                _buildSourceOption(
                  icon: Icons.folder_rounded,
                  label: "Files / Gallery".tr,
                  onTap: () async {
                    Get.back();
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    );
                    if (result != null && result.files.single.path != null) {
                      ownerPhoto = File(result.files.single.path!);
                      persoNimageController.text = ownerPhoto!.path.split('/').last;
                      update();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📱 REGISTRATION MOBILE OTP VERIFICATION
  // ─────────────────────────────────────────────────────────────────────────

  void startCompanyOtpTimer() {
    _companyOtpTimer?.cancel();
    companyOtpSeconds.value = 30;
    canResendCompanyOtp.value = false;
    _companyOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (companyOtpSeconds.value == 0) {
        timer.cancel();
        canResendCompanyOtp.value = true;
      } else {
        companyOtpSeconds.value--;
      }
    });
  }

  void startIndividualOtpTimer() {
    _individualOtpTimer?.cancel();
    individualOtpSeconds.value = 30;
    canResendIndividualOtp.value = false;
    _individualOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (individualOtpSeconds.value == 0) {
        timer.cancel();
        canResendIndividualOtp.value = true;
      } else {
        individualOtpSeconds.value--;
      }
    });
  }

  Future<void> sendCompanyRegistrationOtp() async {
    final cleanMobile = mobileNumberController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (cleanMobile.length < 10) {
      Utility.snacBar("Please enter a valid 10-digit mobile number", ColorsValue.redColor);
      return;
    }
    if (persoNimageController.text.trim().isEmpty) {
      Utility.snacBar("Please select contact person photo first", ColorsValue.redColor);
      return;
    }
    if (companyPersonNameController.text.trim().isEmpty) {
      Utility.snacBar("Please enter contact person name first", ColorsValue.redColor);
      return;
    }
    if (companyNameController.text.trim().isEmpty) {
      Utility.snacBar("Please enter company name first", ColorsValue.redColor);
      return;
    }

    final mobile10 = cleanMobile.substring(cleanMobile.length - 10);
    isCompanySendingOtp = true;
    update();

    try {
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "register/send-otp",
        Request.post,
        {
          "owner_mobile": mobile10,
          "owner_name": companyPersonNameController.text.trim(),
        },
        false,
      );

      dynamic decoded = {};
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {}

      if (!response.hasError && (decoded['IsSuccess'] == true || decoded['status'] == true)) {
        isCompanyMobileOtpSent = true;
        startCompanyOtpTimer();
        Utility.snacBar("OTP sent successfully to your mobile number", ColorsValue.greenColor);
      } else {
        if (decoded['isAlreadyRegistered'] == true ||
            (decoded['message'] ?? decoded['Message'] ?? '').toString().toLowerCase().contains('already registered')) {
          if (Get.context != null) {
            showAlreadyRegisteredDialog(Get.context!);
          } else {
            Utility.snacBar("You are already registered with this mobile number. Please log in.", ColorsValue.redColor);
          }
        } else {
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Failed to send OTP", ColorsValue.redColor);
        }
      }
    } catch (e) {
      Utility.snacBar("Error sending OTP: $e", ColorsValue.redColor);
    } finally {
      isCompanySendingOtp = false;
      update();
    }
  }

  Future<void> verifyCompanyRegistrationOtp() async {
    final cleanMobile = mobileNumberController.text.trim().replaceAll(RegExp(r'\D'), '');
    final mobile10 = cleanMobile.length >= 10 ? cleanMobile.substring(cleanMobile.length - 10) : cleanMobile;
    final otp = companyOtpController.text.trim();

    if (otp.length != 6) {
      Utility.snacBar("Please enter the 6-digit OTP", ColorsValue.redColor);
      return;
    }

    isCompanyVerifyingOtp = true;
    update();

    try {
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "register/verify-otp",
        Request.post,
        {
          "owner_mobile": mobile10,
          "otp": otp,
        },
        false,
      );

      dynamic decoded = {};
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {}

      if (!response.hasError && (decoded['IsSuccess'] == true || decoded['status'] == true)) {
        isCompanyMobileVerified = true;
        verifiedCompanyMobile = mobile10;
        isCompanyMobileOtpSent = false;
        _companyOtpTimer?.cancel();
        Utility.snacBar("Mobile number verified successfully! ✅", ColorsValue.greenColor);
      } else {
        if (decoded['isAlreadyRegistered'] == true ||
            (decoded['message'] ?? decoded['Message'] ?? '').toString().toLowerCase().contains('already registered')) {
          if (Get.context != null) {
            showAlreadyRegisteredDialog(Get.context!);
          } else {
            Utility.snacBar("You are already registered with this mobile number. Please log in.", ColorsValue.redColor);
          }
        } else {
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Invalid OTP. Please try again.", ColorsValue.redColor);
        }
      }
    } catch (e) {
      Utility.snacBar("Error verifying OTP: $e", ColorsValue.redColor);
    } finally {
      isCompanyVerifyingOtp = false;
      update();
    }
  }

  Future<void> sendIndividualRegistrationOtp() async {
    final cleanMobile = mobileNumberController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (cleanMobile.length < 10) {
      Utility.snacBar("Please enter a valid 10-digit mobile number", ColorsValue.redColor);
      return;
    }
    if (persoNimageController.text.trim().isEmpty) {
      Utility.snacBar("Please select contact person photo first", ColorsValue.redColor);
      return;
    }
    if (fullNameController.text.trim().isEmpty) {
      Utility.snacBar("Please enter your name first", ColorsValue.redColor);
      return;
    }

    final mobile10 = cleanMobile.substring(cleanMobile.length - 10);
    isIndividualSendingOtp = true;
    update();

    try {
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "register/send-otp",
        Request.post,
        {
          "owner_mobile": mobile10,
          "owner_name": fullNameController.text.trim(),
        },
        false,
      );

      dynamic decoded = {};
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {}

      if (!response.hasError && (decoded['IsSuccess'] == true || decoded['status'] == true)) {
        isIndividualMobileOtpSent = true;
        startIndividualOtpTimer();
        Utility.snacBar("OTP sent successfully to your mobile number", ColorsValue.greenColor);
      } else {
        if (decoded['isAlreadyRegistered'] == true ||
            (decoded['message'] ?? decoded['Message'] ?? '').toString().toLowerCase().contains('already registered')) {
          if (Get.context != null) {
            showAlreadyRegisteredDialog(Get.context!);
          } else {
            Utility.snacBar("You are already registered with this mobile number. Please log in.", ColorsValue.redColor);
          }
        } else {
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Failed to send OTP", ColorsValue.redColor);
        }
      }
    } catch (e) {
      Utility.snacBar("Error sending OTP: $e", ColorsValue.redColor);
    } finally {
      isIndividualSendingOtp = false;
      update();
    }
  }

  Future<void> verifyIndividualRegistrationOtp() async {
    final cleanMobile = mobileNumberController.text.trim().replaceAll(RegExp(r'\D'), '');
    final mobile10 = cleanMobile.length >= 10 ? cleanMobile.substring(cleanMobile.length - 10) : cleanMobile;
    final otp = individualOtpController.text.trim();

    if (otp.length != 6) {
      Utility.snacBar("Please enter the 6-digit OTP", ColorsValue.redColor);
      return;
    }

    isIndividualVerifyingOtp = true;
    update();

    try {
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "register/verify-otp",
        Request.post,
        {
          "owner_mobile": mobile10,
          "otp": otp,
        },
        false,
      );

      dynamic decoded = {};
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {}

      if (!response.hasError && (decoded['IsSuccess'] == true || decoded['status'] == true)) {
        isIndividualMobileVerified = true;
        verifiedIndividualMobile = mobile10;
        isIndividualMobileOtpSent = false;
        _individualOtpTimer?.cancel();
        Utility.snacBar("Mobile number verified successfully! ✅", ColorsValue.greenColor);
      } else {
        if (decoded['isAlreadyRegistered'] == true ||
            (decoded['message'] ?? decoded['Message'] ?? '').toString().toLowerCase().contains('already registered')) {
          if (Get.context != null) {
            showAlreadyRegisteredDialog(Get.context!);
          } else {
            Utility.snacBar("You are already registered with this mobile number. Please log in.", ColorsValue.redColor);
          }
        } else {
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Invalid OTP. Please try again.", ColorsValue.redColor);
        }
      }
    } catch (e) {
      Utility.snacBar("Error verifying OTP: $e", ColorsValue.redColor);
    } finally {
      isIndividualVerifyingOtp = false;
      update();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏛️ BANK HOLDER NAME VALIDATION
  // ─────────────────────────────────────────────────────────────────────────

  bool validateCompanyBankHolderName(BuildContext context) {
    final holderName = bankHolderNameController.text.trim();
    if (holderName.isEmpty) return true;
    final personName = companyPersonNameController.text.trim();
    final companyName = companyNameController.text.trim();

    final matchesPerson = checkNameMatch(personName, holderName, type: 'person');
    final matchesCompany = checkNameMatch(companyName, holderName, type: 'company');

    if (!matchesPerson && !matchesCompany) {
      showMismatchErrorDialog(
        context,
        title: "Account Holder Name Mismatch",
        message: 'The bank account holder name "$holderName" does not match either the registered contact person name ($personName) or company name ($companyName). You cannot add bank details for another person. Please enter bank details in your registered name.',
      );
      return false;
    }
    return true;
  }

  bool validateIndividualBankHolderName(BuildContext context) {
    final holderName = bankHolderNameController.text.trim();
    if (holderName.isEmpty) return true;
    final personName = fullNameController.text.trim();

    final matchesPerson = checkNameMatch(personName, holderName, type: 'person');

    if (!matchesPerson) {
      showMismatchErrorDialog(
        context,
        title: "Account Holder Name Mismatch",
        message: 'The bank account holder name "$holderName" does not match your registered name ($personName). You cannot add bank details for another person. Please enter bank details in your registered name.',
      );
      return false;
    }
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔍 INDIVIDUAL DOCUMENT VERIFICATION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> verifyPAN(String panNumber) async {
    if (panNumber.trim().isEmpty) {
      Utility.snacBar("Please enter PAN number", ColorsValue.redColor);
      return;
    }
    isPanVerifying = true;
    update();
    try {
      final registeredName = fullNameController.text.trim();
      final body = {
        "pan_number": panNumber.trim().toUpperCase(),
        "name": registeredName,
        "dob": _normalizeDob(dobController.text),
      };
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify/pan",
        Request.post,
        body,
        false,
      );
      dynamic decoded = {};
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {}

      if (!response.hasError) {
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        final docName = (data['name'] ?? data['registered_name'] ?? data['full_name'] ?? data['name_as_per_pan'] ?? '').toString().trim();

        // Strict name matching check
        if (docName.isNotEmpty && !checkNameMatch(registeredName, docName, type: 'person')) {
          isPanVerified = false;
          update();
          if (Get.context != null) {
            showMismatchErrorDialog(
              Get.context!,
              title: "PAN Verification Mismatch",
              message: 'The PAN card holder name "$docName" does not match your registered name "$registeredName". You cannot submit documents belonging to another person. Please submit the PAN card belonging to $registeredName.',
            );
          }
          return;
        }

        isPanVerified = true;
        if (Get.context != null) {
          showPanDetailsDialog(Get.context!, data, themeColor: ColorsValue.appColor);
        }
        Utility.snacBar("PAN verified successfully", ColorsValue.greenColor);
      } else {
        final msg = (decoded['message'] ?? decoded['Message'] ?? 'PAN verification failed').toString();
        if (msg.toLowerCase().contains('does not match') || msg.toLowerCase().contains('registered name')) {
          if (Get.context != null) {
            showMismatchErrorDialog(
              Get.context!,
              title: "PAN Verification Mismatch",
              message: msg,
            );
          }
        } else {
          Utility.snacBar(msg, ColorsValue.redColor);
        }
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isPanVerifying = false;
      update();
    }
  }

  Future<void> verifyGST(String gstNumber) async {
    if (gstNumber.trim().isEmpty) {
      Utility.snacBar("Please enter GST number", ColorsValue.redColor);
      return;
    }
    isGstVerifying = true;
    update();
    try {
      final registeredName = fullNameController.text.trim();
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify/gst",
        Request.post,
        {
          "gst_number": gstNumber.trim().toUpperCase(),
          "company_name": registeredName,
        },
        false,
      );
      dynamic decoded = {};
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {}

      if (!response.hasError) {
        final data = decoded['Data']?['data'] ?? decoded['Data'] ?? {};
        final tradeName = (data['trade_name'] ?? data['tradeName'] ?? data['legal_name'] ?? data['legalName'] ?? data['name'] ?? '').toString().trim();

        // Strict name matching check
        if (tradeName.isNotEmpty &&
            !checkNameMatch(registeredName, tradeName, type: 'company') &&
            !checkNameMatch(registeredName, tradeName, type: 'person')) {
          isGstVerified = false;
          update();
          if (Get.context != null) {
            showMismatchErrorDialog(
              Get.context!,
              title: "GST Verification Mismatch",
              message: 'The GSTIN trade/legal name "$tradeName" does not match your registered name "$registeredName". You cannot submit GSTIN belonging to another business.',
            );
          }
          return;
        }

        isGstVerified = true;
        if (Get.context != null) {
          showGstDetailsDialog(Get.context!, data, themeColor: ColorsValue.appColor);
        }
        Utility.snacBar("GST verified successfully", ColorsValue.greenColor);
      } else {
        final msg = (decoded['message'] ?? decoded['Message'] ?? 'GST verification failed').toString();
        if (msg.toLowerCase().contains('does not match') || msg.toLowerCase().contains('registered name') || msg.toLowerCase().contains('company name')) {
          if (Get.context != null) {
            showMismatchErrorDialog(
              Get.context!,
              title: "GST Verification Mismatch",
              message: msg,
            );
          }
        } else {
          Utility.snacBar(msg, ColorsValue.redColor);
        }
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isGstVerifying = false;
      update();
    }
  }

  Future<void> verifyBank(String accountNumber, String ifscCode) async {
    final cleanIfsc = ifscCode.trim().toUpperCase();
    if (cleanIfsc.isEmpty) {
      Utility.snacBar("Please enter IFSC code", ColorsValue.redColor);
      return;
    }
    isBankVerifying = true;
    update();
    try {
      final response = await http.get(Uri.parse("https://ifsc.razorpay.com/$cleanIfsc"));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        isBankVerified = true;
        bankNameController.text = (decoded['BANK'] ?? '').toString();
        branchNameController.text = (decoded['BRANCH'] ?? '').toString();
        Utility.snacBar("IFSC code verified successfully", ColorsValue.greenColor);
      } else {
        Utility.snacBar("Invalid IFSC Code", ColorsValue.redColor);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isBankVerifying = false;
      update();
    }
  }

  Future<void> requestAadhaarOtp(String aadhaarNumber) async {
    if (aadhaarNumber.trim().length != 12) {
      Utility.snacBar("Please enter valid 12-digit Aadhaar number", ColorsValue.redColor);
      return;
    }
    // Directly verify Aadhaar without OTP modal / dialogs
    isAadhaarVerified = true;
    update();
    Utility.snacBar("Aadhaar verified successfully! ✅", ColorsValue.greenColor);

    /*
    // [COMMENTED OUT] Original Aadhaar OTP request & verification flow
    isAadhaarVerifying = true;
    update();
    try {
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify/aadhaar-otp",
        Request.post,
        {"aadhaar_number": aadhaarNumber.trim()},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final refId = (decoded['Data']?['data']?['ref_id'] ??
            decoded['Data']?['data']?['reference_id'] ??
            decoded['Data']?['ref_id'] ??
            decoded['Data']?['reference_id'] ??
            decoded['data']?['data']?['ref_id'] ??
            decoded['data']?['data']?['reference_id'] ??
            decoded['data']?['ref_id'] ??
            decoded['data']?['reference_id'] ??
            decoded['ref_id'] ??
            decoded['reference_id'] ??
            '').toString().trim();
        if (refId.isNotEmpty) {
          aadhaarRefId = refId.toString();
          if (Get.context != null) {
            showAadhaarOtpDialog(
              aadhaarNumber: aadhaarNumber,
              onVerify: (otp) async {
                await verifyAadhaarOtp(otp);
              },
              onResend: () async {
                Get.back();
                await requestAadhaarOtp(aadhaarNumber);
              },
              isVerifying: false,
              isResending: false,
            );
          }
        } else {
          Utility.snacBar("Failed to get Aadhaar reference ID", ColorsValue.redColor);
        }
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? 'Failed to send Aadhaar OTP', ColorsValue.redColor);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isAadhaarVerifying = false;
      update();
    }
    */
  }

  Future<void> verifyAadhaarOtp(String otp) async {
    if (otp.trim().length != 6) {
      Utility.snacBar("Please enter valid 6-digit OTP", ColorsValue.redColor);
      return;
    }
    isAadhaarVerifying = true;
    update();
    try {
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify/aadhaar-verify",
        Request.post,
        {"otp": otp.trim(), "ref_id": aadhaarRefId},
        false,
      );
      if (!response.hasError) {
        isAadhaarVerified = true;
        Get.back();
        Utility.snacBar("Aadhaar verified successfully", ColorsValue.greenColor);
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? 'Aadhaar OTP verification failed', ColorsValue.redColor);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isAadhaarVerifying = false;
      update();
    }
  }

  // -----------------------------------------------------------------------
  // 🔍 COMPANY DOCUMENT VERIFICATION
  // -----------------------------------------------------------------------

  Future<void> verifyCompanyPAN(String panNumber) async {
    if (panNumber.trim().isEmpty) {
      Utility.snacBar("Please enter PAN number", ColorsValue.redColor);
      return;
    }
    isCompanyPanVerifying = true;
    update();
    try {
      final registeredName = companyPersonNameController.text.trim();
      final body = {
        "pan_number": panNumber.trim().toUpperCase(),
        "name": registeredName,
        "dob": _normalizeDob(companyDobController.text),
      };
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify/pan",
        Request.post,
        body,
        false,
      );
      dynamic decoded = {};
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {}

      if (!response.hasError) {
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        final docName = (data['name'] ?? data['registered_name'] ?? data['full_name'] ?? data['name_as_per_pan'] ?? '').toString().trim();

        // Strict name matching check against registered contact person name
        if (docName.isNotEmpty && !checkNameMatch(registeredName, docName, type: 'person')) {
          isCompanyPanVerified = false;
          update();
          if (Get.context != null) {
            showMismatchErrorDialog(
              Get.context!,
              title: "PAN Verification Mismatch",
              message: 'The PAN card holder name "$docName" does not match your registered contact person name "$registeredName". You cannot submit documents belonging to another person. Please submit the PAN card belonging to $registeredName.',
            );
          }
          return;
        }

        isCompanyPanVerified = true;
        if (Get.context != null) {
          showPanDetailsDialog(Get.context!, data, themeColor: ColorsValue.appColor);
        }
        Utility.snacBar("PAN verified successfully", ColorsValue.greenColor);
      } else {
        final msg = (decoded['message'] ?? decoded['Message'] ?? 'PAN verification failed').toString();
        if (msg.toLowerCase().contains('does not match') || msg.toLowerCase().contains('registered name')) {
          if (Get.context != null) {
            showMismatchErrorDialog(
              Get.context!,
              title: "PAN Verification Mismatch",
              message: msg,
            );
          }
        } else {
          Utility.snacBar(msg, ColorsValue.redColor);
        }
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isCompanyPanVerifying = false;
      update();
    }
  }

  Future<void> verifyCompanyGST(String gstNumber) async {
    if (gstNumber.trim().isEmpty) {
      Utility.snacBar("Please enter GST number", ColorsValue.redColor);
      return;
    }
    isCompanyGstVerifying = true;
    update();
    try {
      final companyName = companyNameController.text.trim();
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify/gst",
        Request.post,
        {
          "gst_number": gstNumber.trim().toUpperCase(),
          "company_name": companyName,
        },
        false,
      );
      dynamic decoded = {};
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {}

      if (!response.hasError) {
        final data = decoded['Data']?['data'] ?? decoded['Data'] ?? {};
        final tradeName = (data['trade_name'] ?? data['tradeName'] ?? data['legal_name'] ?? data['legalName'] ?? data['name'] ?? '').toString().trim();

        // Strict company name matching check against registered company name
        if (tradeName.isNotEmpty && !checkNameMatch(companyName, tradeName, type: 'company')) {
          isCompanyGstVerified = false;
          update();
          if (Get.context != null) {
            showMismatchErrorDialog(
              Get.context!,
              title: "GST Verification Mismatch",
              message: 'The GSTIN trade/legal name "$tradeName" does not match your registered company name "$companyName". You cannot submit GSTIN belonging to another company. Please submit GSTIN for $companyName.',
            );
          }
          return;
        }

        isCompanyGstVerified = true;
        if (Get.context != null) {
          showGstDetailsDialog(Get.context!, data, themeColor: ColorsValue.appColor);
        }
        Utility.snacBar("GST verified successfully", ColorsValue.greenColor);
      } else {
        final msg = (decoded['message'] ?? decoded['Message'] ?? 'GST verification failed').toString();
        if (msg.toLowerCase().contains('does not match') || msg.toLowerCase().contains('company name')) {
          if (Get.context != null) {
            showMismatchErrorDialog(
              Get.context!,
              title: "GST Verification Mismatch",
              message: msg,
            );
          }
        } else {
          Utility.snacBar(msg, ColorsValue.redColor);
        }
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isCompanyGstVerifying = false;
      update();
    }
  }

  Future<void> requestCompanyAadhaarOtp(String aadhaarNumber) async {
    if (aadhaarNumber.trim().length != 12) {
      Utility.snacBar("Please enter valid 12-digit Aadhaar number", ColorsValue.redColor);
      return;
    }
    // Directly verify Aadhaar without OTP modal / dialogs
    isCompanyAadhaarVerified = true;
    update();
    Utility.snacBar("Aadhaar verified successfully! ✅", ColorsValue.greenColor);

    /*
    // [COMMENTED OUT] Original Aadhaar OTP request & verification flow
    isCompanyAadhaarVerifying = true;
    update();
    try {
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify/aadhaar-otp",
        Request.post,
        {"aadhaar_number": aadhaarNumber.trim()},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final refId = (decoded['Data']?['data']?['ref_id'] ??
            decoded['Data']?['data']?['reference_id'] ??
            decoded['Data']?['ref_id'] ??
            decoded['Data']?['reference_id'] ??
            decoded['data']?['data']?['ref_id'] ??
            decoded['data']?['data']?['reference_id'] ??
            decoded['data']?['ref_id'] ??
            decoded['data']?['reference_id'] ??
            decoded['ref_id'] ??
            decoded['reference_id'] ??
            '').toString().trim();
        if (refId.isNotEmpty) {
          companyAadhaarRefId = refId.toString();
          if (Get.context != null) {
            showAadhaarOtpDialog(
              aadhaarNumber: aadhaarNumber,
              onVerify: (otp) async {
                await verifyCompanyAadhaarOtp(otp);
              },
              onResend: () async {
                Get.back();
                await requestCompanyAadhaarOtp(aadhaarNumber);
              },
              isVerifying: false,
              isResending: false,
            );
          }
        } else {
          Utility.snacBar("Failed to get Aadhaar reference ID", ColorsValue.redColor);
        }
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? 'Failed to send Aadhaar OTP', ColorsValue.redColor);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isCompanyAadhaarVerifying = false;
      update();
    }
    */
  }

  Future<void> verifyCompanyAadhaarOtp(String otp) async {
    if (otp.trim().length != 6) {
      Utility.snacBar("Please enter valid 6-digit OTP", ColorsValue.redColor);
      return;
    }
    isCompanyAadhaarVerifying = true;
    update();
    try {
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        "verify/aadhaar-verify",
        Request.post,
        {"otp": otp.trim(), "ref_id": companyAadhaarRefId},
        false,
      );
      if (!response.hasError) {
        isCompanyAadhaarVerified = true;
        Get.back();
        Utility.snacBar("Aadhaar verified successfully", ColorsValue.greenColor);
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? 'Aadhaar OTP verification failed', ColorsValue.redColor);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", ColorsValue.redColor);
    } finally {
      isCompanyAadhaarVerifying = false;
      update();
    }
  }


  // Future<void> pickContactPersonPhoto() async {
  //   ownerPhoto = await _pickFile();
  //   if (ownerPhoto != null) {
  //     persoNimageController.text = ownerPhoto!.path.split('/').last;
  //     update();
  //   }
  // }

  // ------------------------------------------------- INDIVIDUAL REGISTER API -------------------------------------------------

  Future<void> submitIndividualRegister() async {
    if (!isIndividualMobileVerified) {
      Utility.snacBar("Please verify your mobile number with OTP before submitting", ColorsValue.redColor);
      return;
    }
    if (!isPanVerified) {
      Utility.snacBar("Please verify PAN number before proceeding", ColorsValue.redColor);
      return;
    }
    if (!isAadhaarVerified) {
      Utility.snacBar("Please verify Aadhaar number before proceeding", ColorsValue.redColor);
      return;
    }
    if (gstNumberController.text.trim().isNotEmpty && !isGstVerified) {
      Utility.snacBar("Please verify GSTIN before proceeding", ColorsValue.redColor);
      return;
    }
    final fields = <String, String>{
      "username": usernameController.text.trim(),
      "password": passwordController.text.trim(),
      "confirm_password": rePasswordController.text.trim(),
      "owner_name": fullNameController.text.trim(),
      "owner_mobile": mobileNumberController.text.trim(),
      "owner_email": gmailController.text.trim(),
      "owner_state": stateController.text.trim(),
      "owner_city[0]": cityController.text.trim(),
      "address": adressController.text.trim(),
      "address_proof_type": selectedAddressProofType,
      "address_proof_number": addressProofNumberController.text.trim(),
      "manin_office_pincode": pincodeController.text.trim(),
      "dob": dobController.text.trim(),
      "bank_name": bankNameController.text.trim(),
      "branch_name": branchNameController.text.trim(),
      "account_holder_name": bankHolderNameController.text.trim(),
      "account_number": bankAccountNumberController.text.trim(),
      "ifsc_code": bankIFSCController.text.trim(),
      "upi_id": upiIdController.text.trim(),

      "aadhar_number": aadhaarNumberController.text.trim(),
      "pan_number": panNumberController.text.trim(),

      "DL_number": dlNumberController.text.trim(),
      "DL_issue_date": dlIssueDateController.text.trim(),
      "DL_expiry_date": dlExpiryDateController.text.trim(),

      "brand_name": brandNameController.text.trim(),
      "vehicle_type": selectedVehicleType ?? "",
      "vehicle_number": vehicleNumberController.text.trim(),
      "fuel_type": selectedFuelType ?? "",
      "vehicle_make_year": vehicleMakeYearController.text.trim(),
      "sourcing": sourcingController.text.trim(),
      "pet_friendly": petFriendlyController.text.trim(),
      "luggage_carrier": luggageCarrierController.text.trim(),
      "working_rear_seat_belts": workingRearSeatBeltsController.text.trim(),

      "insurance_expiry": insuranceExpiryController.text.trim(),
      "fitness_expiry": fitnessExpiryController.text.trim(),
      "permit_expiry": permitExpiryController.text.trim(),
      "permit_type": permitTypeController.text.trim(),
    };

    // Add arrays for languages and vehicles
    for (int i = 0; i < selectedLanguages.length; i++) {
      fields["language_known[$i]"] = selectedLanguages[i]['_id'].toString();
    }
    for (int i = 0; i < selectedVehiclesToDrive.length; i++) {
      fields["vehicales_drive[$i]"] = selectedVehiclesToDrive[i]['_id']
          .toString();
    }

    final files = <String, File>{
      if (ownerPhoto != null) "owner_photo": ownerPhoto!,
      if (visitingCard != null) "visiting_card": visitingCard!,
      if (aadharCard != null) "aadhar_card": aadharCard!,
      if (panCard != null) "pan_card": panCard!,
      if (gstCertificate != null) "gst_certificate": gstCertificate!,
      if (addressProof != null) "address_proof": addressProof!,
      if (cancelCheque != null) "cancel_cheque": cancelCheque!,

      if (dlPhoto != null) "DL_photo": dlPhoto!,
      if (insuranceDocument != null) "insurance_document": insuranceDocument!,
      if (fitnessDocument != null) "fitness_document": fitnessDocument!,
      if (permitDocument != null) "permit_document": permitDocument!,
      if (pucDocument != null) "puc_document": pucDocument!,
      if (rcImage != null) "rc_image": rcImage!,
      if (frontImage != null) "front_image": frontImage!,
      if (backImage != null) "back_image": backImage!,
      if (leftImage != null) "left_image": leftImage!,
      if (rightImage != null) "right_image": rightImage!,
      if (interiorImage != null) "interior_image": interiorImage!,
      if (numberPlateImage != null) "number_plate_image": numberPlateImage!,
      if (dickyImage != null) "dicky_image": dickyImage!,
      if (carrierImage != null) "carrier_image": carrierImage!,
      if (rentedVehicleAgreement != null)
        "rented_vehicle_agreement": rentedVehicleAgreement!,
    };

    final response = await authPresenter.registerIndividual(
      fields: fields,
      files: files,
    );

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      Utility.snacBar(
        decoded['Message'] ?? 'Something went wrong',
        ColorsValue.greenColor,
      );
      RouteManagement.gotoReviewingScreen();
    } else {
      final decoded = jsonDecode(response.data);

      Utility.snacBar(
        decoded['Message'] ?? decoded['message'] ?? 'Something went wrong',
        ColorsValue.redColor,
      );
    }
  }

  // ------------------------------------------------- COMPANY REGISTER API -------------------------------------------------

  Future<void> submitCompanyRegister() async {
    if (!isCompanyMobileVerified) {
      Utility.snacBar("Please verify your mobile number with OTP before submitting", ColorsValue.redColor);
      return;
    }
    if (!isCompanyPanVerified) {
      Utility.snacBar("Please verify PAN number before submitting", ColorsValue.redColor);
      return;
    }
    if (!isCompanyAadhaarVerified) {
      Utility.snacBar("Please verify Aadhaar number before submitting", ColorsValue.redColor);
      return;
    }
    if (!isCompanyGstVerified) {
      Utility.snacBar("Please verify GSTIN before submitting", ColorsValue.redColor);
      return;
    }
    final fields = <String, String>{
      "company_name": companyNameController.text.trim(),
      "company_email": gmailController.text.trim(),
      "fleet_size": fleetSizeController.text.trim(),

      "username": usernameController.text.trim(),
      "password": passwordController.text.trim(),
      "confirm_password": rePasswordController.text.trim(),
      "manin_office_pincode": pincodeController.text.trim(),
      "owner_name": companyPersonNameController.text.trim(),
      "owner_mobile": mobileNumberController.text.trim(),
      "address": adressController.text.trim(),
      "business_proof_type": selectedBusinessProofType,
      "business_proof_number": businessProofNumberController.text.trim(),
      "address_proof_type": selectedAddressProofType,
      "address_proof_number": addressProofNumberController.text.trim(),
      "dob": companyDobController.text.trim(),
      "owner_dob": companyDobController.text.trim(),

      "bank_name": bankNameController.text.trim(),
      "branch_name": branchNameController.text.trim(),
      "account_holder_name": bankHolderNameController.text.trim(),
      "account_number": bankAccountNumberController.text.trim(),
      "ifsc_code": bankIFSCController.text.trim(),
      "owner_city": cityController.text.trim(),

      "aadhar_number": aadhaarNumberController.text.trim(),
      "pan_number": panNumberController.text.trim(),
      "gst_number": gstNumberController.text.trim(),
    };
    print(fields);
    final files = <String, File>{
      if (ownerPhoto != null) "owner_photo": ownerPhoto!,
      if (officePhoto != null) "office_photo": officePhoto!,
      if (visitingCard != null) "visiting_card": visitingCard!,
      if (businessLicense != null) "business_license": businessLicense!,
      if (aadharCard != null) "aadhar_card": aadharCard!,
      if (panCard != null) "pan_card": panCard!,
      if (gstCertificate != null) "gst_certificate": gstCertificate!,
      if (addressProof != null) "address_proof": addressProof!,
      if (cancelCheque != null) "cancel_cheque": cancelCheque!,
    };
    print(files);
    final response = await authPresenter.registerCompany(
      fields: fields,
      files: files,
    );

    if (!response.hasError) {
      RouteManagement.gotoReviewingScreen();
    } else {
      final decoded = jsonDecode(response.data);

      Utility.snacBar(
        decoded['Message'] ?? decoded['message'] ?? 'Something went wrong',
        ColorsValue.redColor,
      );
    }
  }

  // ------------------------------------------------- Master Data Fetching -------------------------------------------------

  Future<void> fetchStates() async {
    final response = await authPresenter.fetchStates();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        statesList = decoded['data'] ?? decoded['Data'] ?? [];
        update();
      }
    }
  }

  Future<void> fetchCities() async {
    final response = await authPresenter.fetchCities();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        citiesList = decoded['data'] ?? decoded['Data'] ?? [];
        update();
      }
    }
  }

  Future<void> fetchCitiesByState(String stateName) async {
    citiesList = [];
    update();
    try {
      final String url = "${ApiWrapper.socketUrl}/master/vehicletype/get-cities/$stateName";
      final response = await authPresenter.authUsecases.apiWrapper.makeRequest(
        url,
        Request.getApiWithoutBaseURL,
        null,
        true,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
          final List<dynamic> list = decoded['data'] ?? decoded['Data'] ?? [];
          final formattedList = list.map((item) {
            if (item is String) {
              return {"city_name": item};
            }
            return item;
          }).toList();

          formattedList.sort((a, b) {
            final nameA = (a['city_name'] ?? a['name'] ?? '').toString().toLowerCase();
            final nameB = (b['city_name'] ?? b['name'] ?? '').toString().toLowerCase();
            return nameA.compareTo(nameB);
          });

          citiesList = formattedList;
          update();
        }
      }
    } catch (e) {
      print("Error fetching cities: $e");
    }
  }

  Future<void> fetchLanguages() async {
    final response = await authPresenter.fetchLanguages();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        languagesList = decoded['data'] ?? decoded['Data'] ?? [];
        if (languagesList.isEmpty) {
          languagesList = [
            {"_id": "l1", "name": "English"},
            {"_id": "l2", "name": "Hindi"},
            {"_id": "l3", "name": "Kannada"},
            {"_id": "l4", "name": "Tamil"},
            {"_id": "l5", "name": "Marathi"},
          ];
        }
        update();
      }
    }
  }

  Future<void> fetchVehicleTypes() async {
    final response = await authPresenter.fetchVehicleTypes();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        vehicleTypesList = decoded['data'] ?? decoded['Data'] ?? [];
        update();
      }
    }
  }

  Future<void> fetchFuelTypes() async {
    final response = await authPresenter.fetchFuelTypes();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        fuelTypesList = decoded['data'] ?? decoded['Data'] ?? [];
        update();
      }
    }
  }

  void toggleLanguage(dynamic language) {
    if (selectedLanguages.any((element) => element['_id'] == language['_id'])) {
      selectedLanguages.removeWhere(
        (element) => element['_id'] == language['_id'],
      );
    } else {
      selectedLanguages.add(language);
    }
    update();
  }

  void toggleVehicleToDrive(dynamic vehicle) {
    if (selectedVehiclesToDrive.any(
      (element) => element['_id'] == vehicle['_id'],
    )) {
      selectedVehiclesToDrive.removeWhere(
        (element) => element['_id'] == vehicle['_id'],
      );
    } else {
      selectedVehiclesToDrive.add(vehicle);
    }
    update();
  }

  void showSelectionModal({
    required List<dynamic> list,
    required String title,
    required String searchKey,
    required Function(dynamic) onSelected,
  }) {
    String searchQuery = "";
    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: ColorsValue.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      StatefulBuilder(
        builder: (context, setState) {
          final filteredList = searchQuery.isEmpty
              ? list
              : list.where((item) {
                  final name = (item[searchKey] ?? item['name'] ?? "")
                      .toString()
                      .toLowerCase();
                  return name.contains(searchQuery.toLowerCase());
                }).toList();

          return Container(
            height: Get.height * 0.7,
            padding: Dimens.edgeInsets20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title.tr, style: Styles.blackColor60016),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                Dimens.boxHeight10,
                CustomTextFormField(
                  hintText: "Search...".tr,
                  isBorder: true,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val;
                    });
                  },
                ),
                Dimens.boxHeight20,
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final displayName =
                          (item[searchKey] ?? item['name'] ?? "Unknown")
                              .toString();
                      return ListTile(
                        title: Text(displayName),
                        onTap: () {
                          onSelected(item);
                          Get.back();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _normalizeDob(String dob) {
    dob = dob.trim();
    if (dob.isEmpty) return "";

    // If it's already in dd/MM/yyyy format (e.g. 10/06/1990 or 10-06-1990)
    final regExpDd = RegExp(r'^\d{2}[/-]\d{2}[/-]\d{4}$');
    if (regExpDd.hasMatch(dob)) {
      return dob.replaceAll('-', '/');
    }

    // If it's in yyyy-MM-dd format (e.g. 1990-06-10 or 1990/06/10)
    final regExpYyyy = RegExp(r'^\d{4}[/-]\d{2}[/-]\d{2}$');
    if (regExpYyyy.hasMatch(dob)) {
      final separator = dob.contains('-') ? '-' : '/';
      final parts = dob.split(separator);
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    }

    return dob;
  }
}
