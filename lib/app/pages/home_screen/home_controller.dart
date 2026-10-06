import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:bam_bam_vendor/app/widgets/verification_dialogs.dart';

import 'package:bam_bam_vendor/app/navigators/routes_management.dart';
import 'package:bam_bam_vendor/app/navigators/app_pages.dart';

import 'package:bam_bam_vendor/app/theme/colors_value.dart';
import 'package:bam_bam_vendor/app/theme/dimens.dart';
import 'package:bam_bam_vendor/app/theme/styles.dart';
import 'package:bam_bam_vendor/app/utils/asset_constants.dart';
import 'package:bam_bam_vendor/app/utils/strings/string_constants.dart';
import 'package:bam_bam_vendor/app/utils/utility.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:bam_bam_vendor/domain/services/socket_connection.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bam_bam_vendor/domain/entities/enums.dart';
import 'package:bam_bam_vendor/domain/repositories/local_storage_keys.dart';
import 'package:bam_bam_vendor/domain/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:bam_bam_vendor/app/pages/pages.dart';
import 'package:bam_bam_vendor/domain/services/audio_service.dart';


class HomeController extends GetxController {
  HomeController(this.homePresenter);

  final HomePresenter homePresenter;
  static const double walletBalanceThreshold = 500.0;
  static const Duration lowWalletPopupCooldown = Duration(hours: 1);

  TextEditingController formController = TextEditingController();
  TextEditingController rideRejectReasonController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0; // default active item

  void changeDrawerIndex(int index) {
    selectedIndex = index;
    if (index == 0) {
      if (driverSearchController.text.isNotEmpty) {
        driverSearchController.clear();
      }
      getDashboardCounts(isLoading: false);
      getDrivers(isLoading: false);
    }
    update(); // refresh UI
  }

  final ScrollController driverScrollController = ScrollController();
  final ScrollController vehicleScrollController = ScrollController();
  final ScrollController rideScrollController = ScrollController();

  bool isLoading = false;
  bool isVehicleLoading = false;
  int vehiclePage = 1;
  bool hasMoreVehicles = true;
  List<Map<String, dynamic>> vehicles = [];
  Map<String, dynamic>? selectedVehicleDetails;

  /// 👤 PROFILE
  Map<String, dynamic>? profile;
  bool isProfileLoading = false;

  /// 🪙 Deposit
  Map<String, dynamic>? depositData;
  bool isDepositSubmitted = false;
  Timer? _depositTimer;
  Map<String, dynamic>? _pendingRideForConfirmation;
  bool _isLowWalletPopupVisible = false;

  Repository get _repository => Get.find<Repository>();

  void _syncDepositFromProfile(Map<String, dynamic>? profileData) {
    if (profileData == null) return;

    final deposite = profileData['deposite_amount'];
    if (deposite is Map<String, dynamic>) {
      depositData = Map<String, dynamic>.from(deposite);
    } else {
      depositData = null;
    }

    final statusVal = depositData?['status'];
    isDepositSubmitted =
        statusVal == true ||
        (statusVal is String &&
            statusVal.toString().toLowerCase().contains('paid'));
  }

  double _getDepositAmount() {
    final amountValue =
        depositData?['amount'] ??
        depositData?['deposit_amount'] ??
        depositData?['deposit_details']?['amount'] ??
        depositData?['deposit_details']?['deposit_amount'] ??
        profile?['deposite_amount']?['amount'] ??
        profile?['deposite_amount']?['deposit_amount'];
    final parsedAmount = _parseAmount(amountValue);
    log("Parsed deposit amount: $amountValue -> $parsedAmount");
    return parsedAmount;
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse("$value") ?? 0.0;
  }

  bool _isTruthy(dynamic value) {
    if (value is bool) return value;

    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'enabled';
  }

  bool _hasPendingSecurityDeposit() {
    final String profileStatus =
        profile?['deposite_amount']?['status']?.toString().toLowerCase() ?? '';
    final String fetchedStatus =
        depositData?['status']?.toString().toLowerCase() ?? '';
    final double depositAmount = _getDepositAmount();
    final bool hasPendingStatus =
        profileStatus == 'pending' || fetchedStatus == 'pending';

    return depositAmount > 0 && (hasPendingStatus || !isDepositSubmitted);
  }

  double get currentWalletBalance => _parseAmount(
    profile?['wallet_balance'] ?? earningsData?['wallet_balance'] ?? 0,
  );

  bool get isLowWalletPopupEnabled => _isTruthy(
    profile?['depositPopupEnabled'] ?? profile?['deposit_popup_enabled'],
  );

  int _getLowWalletPopupDismissedAt() {
    final storedValue = _repository.getStringValue(
      LocalKeys.lowWalletPopupLastDismissedAt,
    );
    return int.tryParse(storedValue) ?? 0;
  }

  bool _isLowWalletPopupCoolingDown() {
    final dismissedAt = _getLowWalletPopupDismissedAt();
    if (dismissedAt <= 0) return false;

    final elapsed = DateTime.now().millisecondsSinceEpoch - dismissedAt;
    return elapsed < lowWalletPopupCooldown.inMilliseconds;
  }

  void _markLowWalletPopupDismissed() {
    _repository.saveValue(
      LocalKeys.lowWalletPopupLastDismissedAt,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  void _clearLowWalletPopupDismissal() {
    _repository.clearData(LocalKeys.lowWalletPopupLastDismissedAt);
  }

  void _checkLowWalletBalancePopup() {
    if (_isLowWalletPopupVisible) return;

    final shouldShowPopup =
        isLowWalletPopupEnabled &&
        currentWalletBalance < walletBalanceThreshold &&
        !_hasPendingSecurityDeposit();

    if (!shouldShowPopup) {
      _clearLowWalletPopupDismissal();
      return;
    }

    if (_isLowWalletPopupCoolingDown()) return;
    if (Get.isDialogOpen ?? false) return;

    showLowWalletBalanceDialog();
  }

  /// 📊 DASHBOARD COUNTS
  Map<String, dynamic> dashboardCounts = {};

  /// 🚕 RIDES LIST
  List<Map<String, dynamic>> newRides = [];

  int page = 1;
  bool hasMore = true;
  bool isRideLoading = false;
  List<Map<String, dynamic>> drivers = [];

  int driverPage = 1;
  bool hasMoreDrivers = true;
  bool isDriverLoading = false;
  final Map<String, bool> togglingDrivers = {};
  Map<String, dynamic>? selectedDriver;
  bool isDriverDetailLoading = false;
  Map<String, dynamic>? selectedRideDetails;
  bool isRideDetailsLoading = false;
  List<dynamic> driverAllocationsList = [];
  bool isAllocationsLoading = false;

  // Allocation Filters
  String allocationSearchText = "";
  String selectedTripType = "";
  DateTime? allocationStartDate;
  DateTime? allocationEndDate;
  int allocationCurrentPage = 1;
  int allocationTotalPages = 1;
  int allocationLimit = 100;

  // Allocation Driver Screen Data
  Map<String, dynamic>? allocationDriversData;
  bool isAllocationDriversLoading = false;
  String? currentAllocationId;

  // Allocation Vehicle Screen Data
  Map<String, dynamic>? allocationVehiclesData;
  bool isAllocationVehiclesLoading = false;
  int selectedVehicalrIndex = -1;
  
  // Vehicle History Screen Data
  String? selectedVehicleId;
  Map<String, dynamic>? vehicleHistoryData;
  bool isVehicleHistoryLoading = false;
  int vehicleHistoryCurrentPage = 1;
  int vehicleHistoryTotalDocs = 0;
  int vehicleHistoryLimit = 10;
  String vehicleHistoryStatus = "";
  String vehicleHistoryDate = "";

  // Driver History Screen Data
  Map<String, dynamic>? driverHistoryData;
  bool isDriverHistoryLoading = false;
  int driverHistoryCurrentPage = 1;
  int driverHistoryTotalDocs = 0;
  int driverHistoryLimit = 10;
  String driverHistoryStatus = "";
  String driverHistoryDate = "";
  Map<int, bool> expandedBookings = {};

  // ----------------------------------------------------------------Manage Drivers Variables------------------------------------------------
  TextEditingController driverNameController = TextEditingController();
  TextEditingController driverMobileController = TextEditingController();
  TextEditingController driverDLNumberController = TextEditingController();
  // dateSportController is already defined at line 961
  TextEditingController dlIssueDateController = TextEditingController();
  TextEditingController dlValidityController = TextEditingController();

  // --- Driver Document Verification States ---
  bool isDriverDlVerified = false;
  bool isDriverPanVerified = false;
  bool isDriverAadhaarVerified = false;
  bool isDriverDlVerifying = false;
  bool isDriverPanVerifying = false;
  bool isDriverAadhaarVerifying = false;
  bool isDriverAadhaarOtpVerifying = false;
  String driverAadhaarRefId = "";
  String verifiedDriverPan = "";
  String verifiedDriverAadhaar = "";
  String verifiedDriverDl = "";

  // --- 2-Step Driver Transfer Variables ---
  int addDriverCurrentStep = 1;
  bool isCheckingDriverMobile = false;
  Map<String, dynamic>? driverTransferCheckResult;
  bool isSendingTransferOtp = false;
  bool isTransferOtpSent = false;
  TextEditingController transferOtpController = TextEditingController();
  bool isVerifyingTransferOtp = false;
  bool isTransferredDriver = false;
  Map<String, dynamic>? transferredDriverData;
  
  // --- Vendor Profile Document Verification States ---
  bool isProfileAadhaarVerified = true;
  bool isProfilePanVerified = true;
  bool isProfileGstVerified = true;
  bool isProfileAadhaarVerifying = false;
  bool isProfilePanVerifying = false;
  bool isProfileGstVerifying = false;
  String profileAadhaarRefId = "";
  TextEditingController driverPanNumberController = TextEditingController();
  TextEditingController driverAadhaarNumberController = TextEditingController();

  // selectDate is already defined at line 963
  DateTime? selectDLIssueDate;
  DateTime? selectDLValidityDate;

  List<dynamic> statesList = [];
  List<dynamic> citiesList = [];
  List<dynamic> languagesList = [];
  List<dynamic> vehicleTypesList = [];

  String? selectedState;
  String? selectedCity;
  List<dynamic> selectedLanguages = [];
  List<dynamic> selectedVehiclesList = [];

  File? driverPhotoFile;
  File? dlPhotoFile;
  File? driverPanPhotoFile;
  File? driverAadhaarPhotoFile;

  // Screen 1: Information
  bool isRegisteringVehicle = false;
  int addVehicleCurrentStep = 1; // 1: Owner Mobile Check, 2: Vehicle Information
  bool isCheckingVehicleOwnerMobile = false;
  Map<String, dynamic>? vehicleTransferCheckResult;
  bool isSendingVehicleTransferOtp = false;
  bool isVehicleTransferOtpSent = false;
  bool isVerifyingVehicleTransferOtp = false;
  TextEditingController vehicleTransferOtpController = TextEditingController();
  bool isTransferredVehicle = false;
  Map<String, dynamic>? transferredVehicleData;
  String? transferredVehicleExistingFrontImage;
  String? transferredVehicleExistingBackImage;
  String? transferredVehicleExistingLeftImage;
  String? transferredVehicleExistingRightImage;
  String? transferredVehicleExistingInteriorImage;
  String? transferredVehicleExistingPlateImage;
  String? transferredVehicleExistingDickyImage;
  String? transferredVehicleExistingCarrierImage;
  String? transferredVehicleExistingInsuranceDoc;
  String? transferredVehicleExistingFitnessDoc;
  String? transferredVehicleExistingPermitDoc;
  String? transferredVehicleExistingPucDoc;
  String? transferredVehicleExistingRcImage;
  String? transferredVehicleExistingAgreement;

  TextEditingController vehicleBrandNameController = TextEditingController();
  TextEditingController vehicleOwnerNameController = TextEditingController();
  TextEditingController vehicleOwnerMobileController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController vehicleMakeYearController = TextEditingController();
  String? selectedVehicleTypeId;
  String? selectedVehicleType;
  String? selectedFuelTypeId;
  String? selectedFuelType;
  File? frontImageFile;

  // Screen 2: Documents
  TextEditingController rcNumberController = TextEditingController();
  bool isRcVerifying = false;
  bool isRcVerified = false;
  String? rcVehicleTypeError;
  Map<String, dynamic>? rcDetails;
  TextEditingController fitnessExpiryController = TextEditingController();
  TextEditingController insuranceExpiryController = TextEditingController();
  TextEditingController permitExpiryController = TextEditingController();
  String? selectedPermitType;
  File? insuranceDocumentFile;
  File? fitnessDocumentFile;
  File? permitDocumentFile;
  File? pucDocumentFile;
  File? rcImageFile;

  // Screen 3: Preferences
  String? selectedSourcing;
  String? selectedPetFriendly;
  String? selectedLuggageCarrier;
  String? selectedWorkingRearSeatBelts;

  // Additional Images
  File? backImageFile;
  File? leftImageFile;
  File? rightImageFile;
  File? interiorImageFile;
  File? numberPlateImageFile;
  File? dickyImageFile;
  File? carrierImageFile;
  File? rentedVehicleAgreementFile;

  List<dynamic> fuelTypesList = [];

  // --- Support Page Variables ---
  List<dynamic> supportTicketsList = [];
  int supportPage = 1;
  int supportLimit = 100;
  bool isSupportLoading = false;
  bool hasMoreSupportTickets = true;
  String? selectedIssue;
  TextEditingController ticketBookingIdController = TextEditingController();
  TextEditingController ticketDescriptionController = TextEditingController();
  File? ticketAttachmentFile;
  Map<String, dynamic>? selectedTicketDetails;
  final List<String> supportList = [
    "Payment Issue",
    "Booking Issue",
    "App Issue",
    "Other",
  ];

  final ImagePicker _picker = ImagePicker();

  TextEditingController stateSearchController = TextEditingController();
  TextEditingController citySearchController = TextEditingController();
  TextEditingController languageSearchController = TextEditingController();
  TextEditingController vehicleSearchController = TextEditingController();
  TextEditingController driverSearchController = TextEditingController();
  ScrollController supportScrollController = ScrollController();

  // --- Ringtone Settings ---
  List<dynamic> ringtonesList = [];
  bool isRingtoneEnabled = true;
  String? selectedRingtoneId;
  String? selectedRingtoneUrl;

  Future<void> fetchRingtones() async {
    print("🎵 Fetching ringtones list...");
    final response = await homePresenter.fetchRingtones();
    print("🎵 Fetch response status: ${response.statusCode}");
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      print("🎵 Decoded list: $decoded");
      if (decoded['IsSuccess'] == true || decoded['Status'] == 'Success') {
        ringtonesList = decoded['Data'] ?? [];
        print("🎵 Ringtones found: ${ringtonesList.length}");
        update();
      }
    } else {
      print("🎵 Error fetching ringtones: ${response.data}");
    }
  }

  Future<void> getRingtoneSettings() async {
    print("🎵 Fetching ringtone settings...");
    final response = await homePresenter.fetchRingtoneSettings();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      print("🎵 Decoded settings: $decoded");
      if (decoded['IsSuccess'] == true || decoded['Status'] == 'Success') {
        final data = decoded['Data'];
        if (data != null) {
          isRingtoneEnabled = data['ringtone_enabled'] ?? true;
          selectedRingtoneId = data['selected_ringtone']?['_id'];
          String? url = data['selected_ringtone']?['file_url'];
          
          if (url != null && url != "default" && !url.startsWith('http')) {
            url = "https://apis.bambamcabs.com${url.startsWith('/') ? '' : '/'}$url";
          }
          selectedRingtoneUrl = url ?? "default";
          
          // Save to local storage for AudioService
          _repository.saveValue(LocalKeys.ringtoneEnabled, isRingtoneEnabled.toString());
          _repository.saveValue(LocalKeys.selectedRingtoneUrl, selectedRingtoneUrl!);
          update();
        }
      }
    }
  }

  Future<void> updateRingtoneSettings() async {
    final body = {
      "ringtone_enabled": isRingtoneEnabled,
      "selected_ringtone": selectedRingtoneId,
    };
    Utility.showLoader();
    final response = await homePresenter.updateRingtoneSettings(body);
    Utility.closeLoader();

    if (!response.hasError) {
      Utility.snacBar("Ringtone settings updated", Colors.green);
      // Update local storage
      _repository.saveValue(LocalKeys.ringtoneEnabled, isRingtoneEnabled.toString());
      _repository.saveValue(LocalKeys.selectedRingtoneUrl, selectedRingtoneUrl ?? "default");
    } else {
      Utility.snacBar("Failed to update settings", Colors.red);
    }
  }

  List<dynamic> get filteredStates {
    if (stateSearchController.text.isEmpty) return statesList;
    return statesList
        .where(
          (element) => (element['name'] ?? element['state_name'])
              .toString()
              .toLowerCase()
              .contains(stateSearchController.text.toLowerCase()),
        )
        .toList();
  }

  List<dynamic> get filteredCities {
    List<dynamic> list = citiesList;
    if (selectedState != null) {
      list = list
          .where(
            (city) =>
                (city['name'] ?? city['city_name']) == selectedState ||
                (city['state_name']) == selectedState,
          )
          .toList();
    }
    if (citySearchController.text.isEmpty) return list;
    return list
        .where(
          (element) => (element['name'] ?? element['city_name'])
              .toString()
              .toLowerCase()
              .contains(citySearchController.text.toLowerCase()),
        )
        .toList();
  }

  List<dynamic> get filteredLanguages {
    if (languageSearchController.text.isEmpty) return languagesList;
    return languagesList
        .where(
          (element) => element['name'].toString().toLowerCase().contains(
            languageSearchController.text.toLowerCase(),
          ),
        )
        .toList();
  }

  List<dynamic> get filteredVehicleTypes {
    if (vehicleSearchController.text.isEmpty) return vehicleTypesList;
    return vehicleTypesList
        .where(
          (element) => element['name'].toString().toLowerCase().contains(
            vehicleSearchController.text.toLowerCase(),
          ),
        )
        .toList();
  }

  Future<void> fetchStates() async {
    final response = await homePresenter.fetchStates();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        statesList = decoded['data'] ?? decoded['Data'] ?? [];
        update();
      }
    }
  }

  Future<void> fetchCities() async {
    final response = await homePresenter.fetchCities();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        citiesList = decoded['data'] ?? decoded['Data'] ?? [];
        update();
      }
    }
  }

  Future<void> fetchLanguages() async {
    final response = await homePresenter.fetchLanguages();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        List<dynamic> data = decoded['data'] ?? decoded['Data'] ?? [];
        if (data.isEmpty) {
          languagesList = [
            {"_id": "l1", "name": "English"},
            {"_id": "l2", "name": "Hindi"},
            {"_id": "l3", "name": "Kannada"},
            {"_id": "l4", "name": "Tamil"},
            {"_id": "l5", "name": "Marathi"},
          ];
        } else {
          languagesList = data;
        }
        update();
      }
    } else {
      languagesList = [
        {"_id": "l1", "name": "English"},
        {"_id": "l2", "name": "Hindi"},
        {"_id": "l3", "name": "Kannada"},
        {"_id": "l4", "name": "Tamil"},
        {"_id": "l5", "name": "Marathi"},
      ];
      update();
    }
  }

  Future<void> fetchVehicleTypes() async {
    final response = await homePresenter.fetchVehicleTypes();
    print("fetchVehicleTypes decoded: ${response.data}");
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      print("fetchVehicleTypes decoded: $decoded");
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        vehicleTypesList = decoded['data'] ?? decoded['Data'] ?? [];
        update();
      }
    } else {
      Utility.snacBar("Failed to fetch vehicle types", Colors.red);
    }
  }

  Future<void> fetchFuelTypes() async {
    final response = await homePresenter.fetchFuelTypes();
    print("fetchFuelTypes decoded: ${response.data}");
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      print("fetchFuelTypes decoded: $decoded");
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        fuelTypesList = decoded['data'] ?? decoded['Data'] ?? [];
        update();
      }
    } else {
      Utility.snacBar("Failed to fetch fuel types", Colors.red);
    }
  }

  Future<void> pickVehicleImage(String imageType) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40, // Compress to reduce upload size and prevent hangs
    );
    if (image != null) {
      File file = File(image.path);
      switch (imageType) {
        case 'front':
          frontImageFile = file;
          break;
        case 'back':
          backImageFile = file;
          break;
        case 'left':
          leftImageFile = file;
          break;
        case 'right':
          rightImageFile = file;
          break;
        case 'interior':
          interiorImageFile = file;
          break;
        case 'numberPlate':
          numberPlateImageFile = file;
          break;
        case 'dicky':
          dickyImageFile = file;
          break;
        case 'carrier':
          carrierImageFile = file;
          break;
        case 'insurance':
          insuranceDocumentFile = file;
          break;
        case 'fitness':
          fitnessDocumentFile = file;
          break;
        case 'permit':
          permitDocumentFile = file;
          break;
        case 'puc':
          pucDocumentFile = file;
          break;
        case 'rc':
          rcImageFile = file;
          break;
        case 'agreement':
          rentedVehicleAgreementFile = file;
          break;
      }
      update();
    }
  }

  Future<void> registerVehicle() async {
    if (isRegisteringVehicle) return;

    if (!isRcVerified) {
      Utility.snacBar("Please verify RC Number before registering vehicle", Colors.red);
      return;
    }
    
    Map<String, String> fields = {
      "brand_name": vehicleBrandNameController.text.trim(),
      "vehicle_owner_name": vehicleOwnerNameController.text.trim(),
      "vehicle_owner_mobile": vehicleOwnerMobileController.text.trim(),
      "vehicle_number": vehicleNumberController.text.trim(),
      "rc_number": rcNumberController.text.trim().isNotEmpty ? rcNumberController.text.trim() : vehicleNumberController.text.trim(),
      "vehicle_type": selectedVehicleTypeId ?? "",
      "fuel_type[0]": selectedFuelTypeId ?? "",
      "vehicle_make_year": vehicleMakeYearController.text.trim(),
      "sourcing": selectedSourcing ?? "",
      "pet_friendly": selectedPetFriendly ?? "",
      "luggage_carrier": selectedLuggageCarrier ?? "",
      "working_rear_seat_belts": selectedWorkingRearSeatBelts ?? "",
      "insurance_expiry": insuranceExpiryController.text.trim(),
      "fitness_expiry": fitnessExpiryController.text.trim(),
      "permit_expiry": permitExpiryController.text.trim(),
      "permit_type": selectedPermitType ?? "",
      "is_rc_verified": isRcVerified ? "true" : "false",
      if (rcDetails != null) "rc_details": jsonEncode(rcDetails),
    };

    Map<String, File> files = {};
    if (frontImageFile != null) files["front_image"] = frontImageFile!;
    if (backImageFile != null) files["back_image"] = backImageFile!;
    if (leftImageFile != null) files["left_image"] = leftImageFile!;
    if (rightImageFile != null) files["right_image"] = rightImageFile!;
    if (interiorImageFile != null) files["interior_image"] = interiorImageFile!;
    if (numberPlateImageFile != null) {
      files["number_plate_image"] = numberPlateImageFile!;
    }
    if (dickyImageFile != null) files["dicky_image"] = dickyImageFile!;
    if (carrierImageFile != null) files["carrier_image"] = carrierImageFile!;
    if (insuranceDocumentFile != null) {
      files["insurance_document"] = insuranceDocumentFile!;
    }
    if (fitnessDocumentFile != null) {
      files["fitness_document"] = fitnessDocumentFile!;
    }
    if (permitDocumentFile != null) {
      files["permit_document"] = permitDocumentFile!;
    }
    if (pucDocumentFile != null) files["puc_document"] = pucDocumentFile!;
    if (rcImageFile != null) files["rc_image"] = rcImageFile!;
    if (rentedVehicleAgreementFile != null) {
      files["rented_vehicle_agreement"] = rentedVehicleAgreementFile!;
    }

    // Validation
    final hasFront = files["front_image"] != null || (isTransferredVehicle && (transferredVehicleExistingFrontImage?.isNotEmpty ?? false));
    final hasBack = files["back_image"] != null || (isTransferredVehicle && (transferredVehicleExistingBackImage?.isNotEmpty ?? false));
    final hasLeft = files["left_image"] != null || (isTransferredVehicle && (transferredVehicleExistingLeftImage?.isNotEmpty ?? false));
    final hasRight = files["right_image"] != null || (isTransferredVehicle && (transferredVehicleExistingRightImage?.isNotEmpty ?? false));
    final hasInterior = files["interior_image"] != null || (isTransferredVehicle && (transferredVehicleExistingInteriorImage?.isNotEmpty ?? false));
    final hasPlate = files["number_plate_image"] != null || (isTransferredVehicle && (transferredVehicleExistingPlateImage?.isNotEmpty ?? false));
    final hasInsurance = files["insurance_document"] != null || (isTransferredVehicle && (transferredVehicleExistingInsuranceDoc?.isNotEmpty ?? false));
    final hasFitness = files["fitness_document"] != null || (isTransferredVehicle && (transferredVehicleExistingFitnessDoc?.isNotEmpty ?? false));
    final hasPermit = files["permit_document"] != null || (isTransferredVehicle && (transferredVehicleExistingPermitDoc?.isNotEmpty ?? false));
    final hasPuc = files["puc_document"] != null || (isTransferredVehicle && (transferredVehicleExistingPucDoc?.isNotEmpty ?? false));
    final hasRc = files["rc_image"] != null || (isTransferredVehicle && (transferredVehicleExistingRcImage?.isNotEmpty ?? false));

    if (vehicleBrandNameController.text.trim().isEmpty) {
      Utility.snacBar("Please enter brand name", Colors.red);
      return;
    }
    if (vehicleOwnerNameController.text.trim().isEmpty) {
      Utility.snacBar("Please enter vehicle owner name", Colors.red);
      return;
    }
    if (vehicleOwnerMobileController.text.trim().isEmpty ||
        vehicleOwnerMobileController.text.trim().length != 10) {
      Utility.snacBar("Please enter valid 10-digit vehicle owner mobile number", Colors.red);
      return;
    }
    if (vehicleNumberController.text.trim().isEmpty) {
      Utility.snacBar("Please enter vehicle number", Colors.red);
      return;
    }
    if (vehicleMakeYearController.text.trim().isEmpty) {
      Utility.snacBar("Please enter vehicle make year", Colors.red);
      return;
    }
    if (selectedVehicleTypeId == null || selectedVehicleTypeId!.isEmpty) {
      Utility.snacBar("Please select vehicle type", Colors.red);
      return;
    }
    if (selectedFuelTypeId == null || selectedFuelTypeId!.isEmpty) {
      Utility.snacBar("Please select fuel type", Colors.red);
      return;
    }
    if (selectedSourcing == null || selectedSourcing!.isEmpty) {
      Utility.snacBar("Please select sourcing preference", Colors.red);
      return;
    }
    if (fitnessExpiryController.text.trim().isEmpty) {
      Utility.snacBar("Please enter fitness expiry date", Colors.red);
      return;
    }
    if (insuranceExpiryController.text.trim().isEmpty) {
      Utility.snacBar("Please enter insurance expiry date", Colors.red);
      return;
    }
    if (permitExpiryController.text.trim().isEmpty) {
      Utility.snacBar("Please enter permit expiry date", Colors.red);
      return;
    }
    if (selectedPermitType == null || selectedPermitType!.isEmpty) {
      Utility.snacBar("Please select permit type", Colors.red);
      return;
    }
    if (rcNumberController.text.trim().isEmpty) {
      Utility.snacBar("Please enter RC number", Colors.red);
      return;
    }
    if (!isRcVerified) {
      Utility.snacBar("Please verify RC Number before saving", Colors.red);
      return;
    }
    if (!hasInsurance) {
      Utility.snacBar("Please upload Insurance Document", Colors.red);
      return;
    }
    if (!hasFitness) {
      Utility.snacBar("Please upload Fitness Document", Colors.red);
      return;
    }
    if (!hasPermit) {
      Utility.snacBar("Please upload Permit Document", Colors.red);
      return;
    }
    if (!hasPuc) {
      Utility.snacBar("Please upload PUC Document", Colors.red);
      return;
    }
    if (!hasRc) {
      Utility.snacBar("Please upload RC Image", Colors.red);
      return;
    }
    if (selectedSourcing == "Rented Vehicle") {
      final hasAgreement = files["rented_vehicle_agreement"] != null ||
          (isTransferredVehicle && (transferredVehicleExistingAgreement?.isNotEmpty ?? false));
      if (!hasAgreement) {
        Utility.snacBar("Please upload Rented Vehicle Agreement", Colors.red);
        return;
      }
    }
    if (!hasFront) {
      Utility.snacBar("Please upload Front View car photo", Colors.red);
      return;
    }
    if (!hasBack) {
      Utility.snacBar("Please upload Back View car photo", Colors.red);
      return;
    }
    if (!hasLeft) {
      Utility.snacBar("Please upload Left View car photo", Colors.red);
      return;
    }
    if (!hasRight) {
      Utility.snacBar("Please upload Right View car photo", Colors.red);
      return;
    }
    if (!hasInterior) {
      Utility.snacBar("Please upload Interior View car photo", Colors.red);
      return;
    }
    if (!hasPlate) {
      Utility.snacBar("Please upload Plate Number car photo", Colors.red);
      return;
    }
    final hasDicky = files["dicky_image"] != null ||
        (isTransferredVehicle && (transferredVehicleExistingDickyImage?.isNotEmpty ?? false));
    if (!hasDicky) {
      Utility.snacBar("Please upload Dicky View car photo", Colors.red);
      return;
    }
    final hasCarrier = files["carrier_image"] != null ||
        (isTransferredVehicle && (transferredVehicleExistingCarrierImage?.isNotEmpty ?? false));
    if (!hasCarrier) {
      Utility.snacBar("Please upload Carrier View car photo", Colors.red);
      return;
    }

    print("Register Vehicle Fields: $fields");
    print("Register Vehicle Files: ${files.keys.toList()}");

    isRegisteringVehicle = true;
    update();
    log('✅ registerVehicle: calling addVehicle or transfer API...');
    try {
      final response = isTransferredVehicle
          ? await homePresenter.confirmVehicleTransfer(
              fields: {
                ...fields,
                if (transferredVehicleData?['_id'] != null) "vehicle_id": transferredVehicleData!['_id'].toString(),
              },
              files: files,
            )
          : await homePresenter.addVehicle(
              fields: fields,
              files: files,
            );
      log('✅ registerVehicle: API returned. hasError=${response.hasError}, statusCode=${response.statusCode}');
      log('✅ registerVehicle: response.data=${response.data}');


      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
          getVehicles(); // Refresh list
          
          // Show Success Dialog
          Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      "Success!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Your vehicle has been successfully added.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // Close dialog
                          clearAddVehicleFields();
                          // Pop back to home screen (which preserves index 7)
                          Get.until((route) => route.settings.name == Routes.homeScreen || route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.appColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("OK", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
        } else {
          Utility.snacBar(
            decoded['message'] ?? decoded['Message'] ?? "Failed to add vehicle",
            Colors.red,
          );
        }
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(
            decoded['Message'] ?? decoded['message'] ?? "Something went wrong",
            Colors.red,
          );
        } catch (_) {
          Utility.snacBar("Something went wrong", Colors.red);
        }
      }
    } catch (e) {
      log("Error registering vehicle: $e");
      Utility.snacBar("An unexpected error occurred", Colors.red);
    } finally {
      isRegisteringVehicle = false;
      update();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    Utility.showLoader();
    final response = await homePresenter.deleteVehicle(vehicleId);
    Utility.closeLoader();
    if (!response.hasError) {
      Utility.snacBar("Vehicle deleted successfully.", Colors.green);
      getVehicles();
    } else {
      Utility.snacBar("Failed to delete vehicle.", Colors.red);
    }
  }

  Future<void> toggleVehicleStatus(String vehicleId) async {
    final int index = vehicles.indexWhere((v) => v['_id'] == vehicleId);
    if (index == -1) return;

    final vehicle = vehicles[index];
    final bool currentStatus = vehicle['status'] == true;
    final bool newStatus = !currentStatus;

    // Optimistic local update
    vehicles[index]['status'] = newStatus;
    update();

    try {
      final response = await homePresenter.toggleVehicleStatus(vehicleId);
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        if (decoded['IsSuccess'] == true || decoded['isSuccess'] == true || response.statusCode == 200) {
          Utility.snacBar(
            decoded['message'] ?? decoded['Message'] ?? "Vehicle status updated successfully",
            Colors.green,
          );
          await getVehicles(isLoading: false);
        } else {
          vehicles[index]['status'] = currentStatus;
          update();
          Utility.snacBar(
            decoded['message'] ?? decoded['Message'] ?? "Failed to update vehicle status.",
            Colors.red,
          );
        }
      } else {
        vehicles[index]['status'] = currentStatus;
        update();
        Utility.snacBar("Failed to update vehicle status.", Colors.red);
      }
    } catch (e) {
      vehicles[index]['status'] = currentStatus;
      update();
      Utility.snacBar("Network error occurred.", Colors.red);
    }
  }

  Future<void> toggleVehicleOperationalStatus({
    required String vehicleId,
    required String operationalStatus,
    String? reason,
  }) async {
    final int index = vehicles.indexWhere((v) => v['_id'] == vehicleId);
    if (index == -1) return;

    final String oldOpStatus = vehicles[index]['operational_status'] ?? "";

    // Optimistic local update
    vehicles[index]['operational_status'] = operationalStatus;
    update();

    try {
      final response = await homePresenter.toggleVehicleOperationalStatus(
        vehicleId: vehicleId,
        operationalStatus: operationalStatus,
        reason: reason,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        if (decoded['IsSuccess'] == true || decoded['isSuccess'] == true || response.statusCode == 200) {
          Utility.snacBar(
            decoded['message'] ?? decoded['Message'] ?? "Vehicle status updated to $operationalStatus",
            Colors.green,
          );
          await getVehicles(isLoading: false);
        } else {
          vehicles[index]['operational_status'] = oldOpStatus;
          update();
          Utility.snacBar(
            decoded['message'] ?? decoded['Message'] ?? "Failed to update vehicle status.",
            Colors.red,
          );
        }
      } else {
        vehicles[index]['operational_status'] = oldOpStatus;
        update();
        Utility.snacBar("Failed to update vehicle status.", Colors.red);
      }
    } catch (e) {
      vehicles[index]['operational_status'] = oldOpStatus;
      update();
      Utility.snacBar("Network error occurred.", Colors.red);
    }
  }

  void initVehicleEdit(Map<String, dynamic> vehicle) {
    final info = vehicle['vehicleInformation'] ?? {};
    final docs = vehicle['vehicleDocuments'] ?? {};
    final pref = vehicle['vehiclePreferences'] ?? {};

    vehicleBrandNameController.text = info['brand_name'] ?? "";
    vehicleOwnerNameController.text = info['vehicle_owner_name'] ?? "";
    vehicleOwnerMobileController.text = info['vehicle_owner_mobile'] ?? "";
    vehicleNumberController.text = info['vehicle_number'] ?? "";
    
    // Sourcing, preferences
    selectedSourcing = info['sourcing'] ?? "";
    selectedPetFriendly = pref['pet_friendly'] ?? "";
    selectedLuggageCarrier = pref['luggage_carrier'] ?? "";
    selectedWorkingRearSeatBelts = pref['working_rear_seat_belts'] ?? "";
    
    vehicleMakeYearController.text = info['registration_year']?.toString() ?? "";
    
    // Fuel types
    final fuels = info['fuel_type'] as List?;
    if (fuels != null && fuels.isNotEmpty) {
      selectedFuelTypeId = fuels[0]['_id'] ?? fuels[0];
      selectedFuelType = fuels[0]['name'];
    } else {
      selectedFuelTypeId = null;
      selectedFuelType = null;
    }

    // Vehicle Type
    final vType = info['vehicle_type'];
    if (vType is Map) {
      selectedVehicleTypeId = vType['_id'];
      selectedVehicleType = vType['name'];
    } else {
      selectedVehicleTypeId = vType;
    }

    // Expiries (dd-MM-yyyy format)
    if (docs['insurance_expiry'] != null) {
      insuranceExpiryController.text = Utility.getFormatedTime(docs['insurance_expiry'], "dd-MM-yyyy");
    } else {
      insuranceExpiryController.text = "";
    }
    if (docs['fitness_expiry'] != null) {
      fitnessExpiryController.text = Utility.getFormatedTime(docs['fitness_expiry'], "dd-MM-yyyy");
    } else {
      fitnessExpiryController.text = "";
    }
    if (docs['permit_expiry'] != null) {
      permitExpiryController.text = Utility.getFormatedTime(docs['permit_expiry'], "dd-MM-yyyy");
    } else {
      permitExpiryController.text = "";
    }
    
    selectedPermitType = docs['permit_type'] ?? "";

    // Clear picked files so we only upload new ones if selected
    frontImageFile = null;
    backImageFile = null;
    leftImageFile = null;
    rightImageFile = null;
    interiorImageFile = null;
    numberPlateImageFile = null;
    dickyImageFile = null;
    carrierImageFile = null;
    insuranceDocumentFile = null;
    fitnessDocumentFile = null;
    permitDocumentFile = null;
    pucDocumentFile = null;
    rcImageFile = null;
    rentedVehicleAgreementFile = null;

    rcNumberController.text = docs['rc_number'] ?? info['rc_number'] ?? info['vehicle_number'] ?? "";
    isRcVerified = docs['is_rc_verified'] == true || vehicle['is_rc_verified'] == true;
    rcDetails = (docs['rc_details'] is Map)
        ? Map<String, dynamic>.from(docs['rc_details'])
        : (vehicle['rc_details'] is Map)
            ? Map<String, dynamic>.from(vehicle['rc_details'])
            : null;
    if (rcDetails != null && rcNumberController.text.isNotEmpty) {
      rcDetails!['rc_number'] = rcNumberController.text;
      rcDetails!['registration_number'] = rcNumberController.text;
      rcDetails!['vehicle_number'] = rcNumberController.text;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  Future<void> submitVehicleUpdate(String vehicleId) async {
    if (!isRcVerified) {
      Utility.snacBar("Please verify RC Number before saving", Colors.red);
      return;
    }
    Utility.showLoader();

    Map<String, String> fields = {
      "brand_name": vehicleBrandNameController.text.trim(),
      "vehicle_owner_name": vehicleOwnerNameController.text.trim(),
      "vehicle_owner_mobile": vehicleOwnerMobileController.text.trim(),
      "vehicle_number": vehicleNumberController.text.trim(),
      "rc_number": rcNumberController.text.trim().isNotEmpty ? rcNumberController.text.trim() : vehicleNumberController.text.trim(),
      if (selectedVehicleTypeId != null) "vehicle_type": selectedVehicleTypeId!,
      if (selectedFuelTypeId != null) "fuel_type[0]": selectedFuelTypeId!,
      "vehicle_make_year": vehicleMakeYearController.text.trim(),
      "sourcing": selectedSourcing ?? "",
      "pet_friendly": selectedPetFriendly ?? "",
      "luggage_carrier": selectedLuggageCarrier ?? "",
      "working_rear_seat_belts": selectedWorkingRearSeatBelts ?? "",
      "insurance_expiry": insuranceExpiryController.text.trim(),
      "fitness_expiry": fitnessExpiryController.text.trim(),
      "permit_expiry": permitExpiryController.text.trim(),
      "permit_type": selectedPermitType ?? "",
      "is_rc_verified": isRcVerified ? "true" : "false",
      if (rcDetails != null) "rc_details": jsonEncode(rcDetails),
    };

    Map<String, File> files = {};
    if (frontImageFile != null) files["front_image"] = frontImageFile!;
    if (backImageFile != null) files["back_image"] = backImageFile!;
    if (leftImageFile != null) files["left_image"] = leftImageFile!;
    if (rightImageFile != null) files["right_image"] = rightImageFile!;
    if (interiorImageFile != null) files["interior_image"] = interiorImageFile!;
    if (numberPlateImageFile != null) files["number_plate_image"] = numberPlateImageFile!;
    if (dickyImageFile != null) files["dicky_image"] = dickyImageFile!;
    if (carrierImageFile != null) files["carrier_image"] = carrierImageFile!;
    if (insuranceDocumentFile != null) files["insurance_document"] = insuranceDocumentFile!;
    if (fitnessDocumentFile != null) files["fitness_document"] = fitnessDocumentFile!;
    if (permitDocumentFile != null) files["permit_document"] = permitDocumentFile!;
    if (pucDocumentFile != null) files["puc_document"] = pucDocumentFile!;
    if (rcImageFile != null) files["rc_image"] = rcImageFile!;
    if (rentedVehicleAgreementFile != null) files["rented_vehicle_agreement"] = rentedVehicleAgreementFile!;

    final response = await homePresenter.updateVehicle(
      vehicleId: vehicleId,
      fields: fields,
      files: files,
    );
    
    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true || decoded['isSuccess'] == true) {
        Utility.snacBar("Vehicle updated successfully", Colors.green);
        await getVehicleDetails(vehicleId); // Refresh details
        Get.back(); // Return from Edit page
        getVehicles(); // Refresh list
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to update vehicle",
          Colors.red,
        );
      }
    } else {
      Utility.snacBar("Failed to update vehicle", Colors.red);
    }
  }

  void clearAddVehicleFields() {
    vehicleBrandNameController.clear();
    vehicleOwnerNameController.clear();
    vehicleOwnerMobileController.clear();
    vehicleNumberController.clear();
    rcNumberController.clear();
    isRcVerified = false;
    rcDetails = null;
    isRcVerifying = false;
    vehicleMakeYearController.clear();
    insuranceExpiryController.clear();
    fitnessExpiryController.clear();
    permitExpiryController.clear();
    
    selectedVehicleTypeId = null;
    selectedFuelTypeId = null;
    selectedSourcing = null;
    selectedPetFriendly = null;
    selectedLuggageCarrier = null;
    selectedWorkingRearSeatBelts = null;
    selectedPermitType = null;

    frontImageFile = null;
    backImageFile = null;
    leftImageFile = null;
    rightImageFile = null;
    interiorImageFile = null;
    numberPlateImageFile = null;
    dickyImageFile = null;
    carrierImageFile = null;
    insuranceDocumentFile = null;
    fitnessDocumentFile = null;
    permitDocumentFile = null;
    pucDocumentFile = null;
    rcImageFile = null;
    rentedVehicleAgreementFile = null;

    addVehicleCurrentStep = 1;
    isCheckingVehicleOwnerMobile = false;
    vehicleTransferCheckResult = null;
    isSendingVehicleTransferOtp = false;
    isVehicleTransferOtpSent = false;
    isVerifyingVehicleTransferOtp = false;
    vehicleTransferOtpController.clear();
    isTransferredVehicle = false;
    transferredVehicleData = null;
    transferredVehicleExistingFrontImage = null;
    transferredVehicleExistingBackImage = null;
    transferredVehicleExistingLeftImage = null;
    transferredVehicleExistingRightImage = null;
    transferredVehicleExistingInteriorImage = null;
    transferredVehicleExistingPlateImage = null;
    transferredVehicleExistingDickyImage = null;
    transferredVehicleExistingCarrierImage = null;
    transferredVehicleExistingInsuranceDoc = null;
    transferredVehicleExistingFitnessDoc = null;
    transferredVehicleExistingPermitDoc = null;
    transferredVehicleExistingPucDoc = null;
    transferredVehicleExistingRcImage = null;
    transferredVehicleExistingAgreement = null;
    
    update();
  }

  Future<void> verifyVehicleRC([String? inputRcNumber]) async {
    final rcNum = (inputRcNumber ?? rcNumberController.text).trim().isNotEmpty
        ? (inputRcNumber ?? rcNumberController.text).trim()
        : vehicleNumberController.text.trim();

    if (rcNum.isEmpty) {
      Utility.snacBar("Please enter RC / Vehicle number", Colors.red);
      return;
    }

    final cleanNumber = rcNum.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleanNumber.length < 4 || cleanNumber.length > 13) {
      Utility.snacBar("Invalid RC / Vehicle number format", Colors.red);
      return;
    }

    isRcVerifying = true;
    rcVehicleTypeError = null;
    update();
    try {
      if (fuelTypesList.isEmpty) {
        try {
          await fetchFuelTypes();
        } catch (_) {}
      }

      final fullUrl = '${ApiWrapper.socketUrl}/vendor/verify/rc';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        fullUrl,
        Request.postApiWithoutBaseURL,
        {"vehicle_number": cleanNumber},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        rcDetails = data is Map ? Map<String, dynamic>.from(data) : null;

        // Auto-fill owner name
        final ownerName = (data['vehicle_owner_name'] ?? data['owner_name'] ?? data['registered_owner'] ?? '').toString().trim();
        if (ownerName.isNotEmpty && ownerName != 'N/A') {
          vehicleOwnerNameController.text = ownerName;
        }

        // Auto-fill brand / maker model (prioritize model_name)
        final makerModel = (data['model_name'] ?? data['brand_name'] ?? data['maker_model'] ?? '').toString().trim();
        if (makerModel.isNotEmpty && makerModel != 'N/A') {
          vehicleBrandNameController.text = makerModel;
        }

        // Auto-fill manufacturing year
        String mfgYear = (data['manufacturing_year'] ?? data['registration_date'] ?? '').toString().trim();
        if (mfgYear.isNotEmpty && mfgYear != 'N/A') {
          final yearMatch = RegExp(r'\b(19\d{2}|20\d{2})\b').firstMatch(mfgYear);
          if (yearMatch != null) {
            vehicleMakeYearController.text = yearMatch.group(0)!;
          }
        }

        // Auto-fill fuel type (prioritize CNG)
        final rawFuel = (data['fuel_type'] ?? '').toString().trim().toUpperCase();
        if (rawFuel.contains('CNG')) {
          final cngMatch = fuelTypesList.firstWhereOrNull((item) =>
              (item['name'] ?? '').toString().toUpperCase().contains('CNG'));
          if (cngMatch != null) {
            selectedFuelTypeId = (cngMatch['_id'] ?? cngMatch['id'])?.toString();
            selectedFuelType = cngMatch['name']?.toString();
          } else {
            selectedFuelType = 'CNG';
          }
        }
        if (selectedFuelTypeId == null && !rawFuel.contains('CNG')) {
          if (data['matched_fuel_type_ids'] != null && (data['matched_fuel_type_ids'] as List).isNotEmpty) {
            selectedFuelTypeId = data['matched_fuel_type_ids'][0].toString();
            final m = fuelTypesList.firstWhereOrNull((item) =>
                (item['_id'] ?? item['id'])?.toString() == selectedFuelTypeId);
            if (m != null) selectedFuelType = m['name']?.toString();
          }
          if (selectedFuelTypeId == null && rawFuel.isNotEmpty && rawFuel != 'N/A' && fuelTypesList.isNotEmpty) {
            final match = fuelTypesList.firstWhereOrNull((item) {
              final fName = (item['name'] ?? '').toString().toUpperCase().trim();
              return fName == rawFuel || fName.contains(rawFuel) || rawFuel.contains(fName);
            });
            if (match != null) {
              selectedFuelTypeId = (match['_id'] ?? match['id'])?.toString();
              selectedFuelType = match['name']?.toString();
            } else {
              final parts = rawFuel.split(RegExp(r'[/, -]+'));
              for (final part in parts) {
                if (part.isEmpty) continue;
                final tokenMatch = fuelTypesList.firstWhereOrNull((item) {
                  final fName = (item['name'] ?? '').toString().toUpperCase().trim();
                  return fName == part || fName.contains(part) || part.contains(fName);
                });
                if (tokenMatch != null) {
                  selectedFuelTypeId = (tokenMatch['_id'] ?? tokenMatch['id'])?.toString();
                  selectedFuelType = tokenMatch['name']?.toString();
                  break;
                }
              }
            }
          }
        }
        if (selectedFuelType == null && rawFuel.isNotEmpty && rawFuel != 'N/A') {
          selectedFuelType = rawFuel;
        }
        if (selectedFuelTypeId == null && selectedFuelType != null && fuelTypesList.isNotEmpty) {
          final m = fuelTypesList.firstWhereOrNull((item) =>
              (item['name'] ?? '').toString().toUpperCase().trim() == selectedFuelType!.toUpperCase().trim());
          if (m != null) {
            selectedFuelTypeId = (m['_id'] ?? m['id'])?.toString();
          }
        }

        // Auto-fill insurance expiry if empty
        final insExpiry = (data['insurance_expiry'] ?? data['insurance_upto'] ?? '').toString();
        if (insExpiry.isNotEmpty && insuranceExpiryController.text.trim().isEmpty) {
          insuranceExpiryController.text = insExpiry;
        }

        // Auto-fill fitness expiry if empty
        final fitExpiry = (data['fitness_upto'] ?? data['fit_up_to'] ?? '').toString();
        if (fitExpiry.isNotEmpty && fitnessExpiryController.text.trim().isEmpty) {
          fitnessExpiryController.text = fitExpiry;
        }

        // Keep rcNumberController updated
        rcNumberController.text = cleanNumber;

        // Ensure RC number is set in rcDetails
        if (rcDetails != null) {
          rcDetails!['rc_number'] = cleanNumber;
          rcDetails!['registration_number'] = cleanNumber;
          rcDetails!['vehicle_number'] = cleanNumber;
        }

        // Auto-assign vehicle type from verified RC or show unsupported warning
        if (data['is_supported'] == false || data['vehicle_type_id'] == null) {
          isRcVerified = false;
          selectedVehicleTypeId = null;
          selectedVehicleType = null;
          rcVehicleTypeError = "This brand is not verified by bambam";
        } else {
          isRcVerified = true;
          rcVehicleTypeError = null;
          selectedVehicleTypeId = data['vehicle_type_id'].toString();
          selectedVehicleType = data['vehicle_type_name']?.toString() ?? selectedVehicleType;
        }

        if (Get.context != null && rcDetails != null) {
          showRcDetailsDialog(Get.context!, rcDetails!, cleanNumber);
        }
        if (isRcVerified) {
          Utility.snacBar("RC verified successfully", Colors.green);
        } else {
          Utility.snacBar("This brand is not verified by bambam", Colors.red);
        }
        update();
      } else {
        isRcVerified = false;
        rcVehicleTypeError = "This brand is not verified by bambam";
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'This brand is not verified by bambam', Colors.red);
      }
    } catch (e) {
      isRcVerified = false;
      rcVehicleTypeError = "This brand is not verified by bambam";
      Utility.snacBar("This brand is not verified by bambam", Colors.red);
    } finally {
      isRcVerifying = false;
      update();
    }
  }

  void populateVehicleFormFromTransferred(Map<String, dynamic> v) {
    vehicleBrandNameController.text = v['brand_name'] ?? "";
    vehicleOwnerNameController.text = v['vehicle_owner_name'] ?? "";
    vehicleOwnerMobileController.text = v['vehicle_owner_mobile'] ?? "";
    vehicleNumberController.text = v['vehicle_number'] ?? "";
    rcNumberController.text = v['rc_number'] ?? v['vehicle_number'] ?? "";
    vehicleMakeYearController.text = (v['vehicle_make_year'] ?? v['registration_year'] ?? "").toString();

    // Type & Fuel
    if (v['vehicle_type'] != null) {
      if (v['vehicle_type'] is Map) {
        selectedVehicleTypeId = v['vehicle_type']['_id']?.toString();
        selectedVehicleType = v['vehicle_type']['name']?.toString();
      } else {
        selectedVehicleTypeId = v['vehicle_type']?.toString();
      }
    }
    if (vehicleTypesList.isNotEmpty && selectedVehicleTypeId != null) {
      final match = vehicleTypesList.firstWhereOrNull((item) =>
          item['_id']?.toString() == selectedVehicleTypeId ||
          (selectedVehicleType != null &&
              item['name']?.toString().toLowerCase() ==
                  selectedVehicleType!.toLowerCase()));
      if (match != null) {
        selectedVehicleTypeId = match['_id']?.toString();
        selectedVehicleType = match['name']?.toString();
      }
    }

    if (v['fuel_type'] != null) {
      if (v['fuel_type'] is List && (v['fuel_type'] as List).isNotEmpty) {
        final firstFuel = (v['fuel_type'] as List)[0];
        if (firstFuel is Map) {
          selectedFuelTypeId = firstFuel['_id']?.toString();
          selectedFuelType = firstFuel['name']?.toString();
        } else {
          selectedFuelTypeId = firstFuel?.toString();
        }
      } else if (v['fuel_type'] is Map) {
        selectedFuelTypeId = v['fuel_type']['_id']?.toString();
        selectedFuelType = v['fuel_type']['name']?.toString();
      } else {
        selectedFuelTypeId = v['fuel_type']?.toString();
      }
    }
    if (fuelTypesList.isNotEmpty && selectedFuelTypeId != null) {
      final match = fuelTypesList.firstWhereOrNull((item) =>
          item['_id']?.toString() == selectedFuelTypeId ||
          (selectedFuelType != null &&
              item['name']?.toString().toLowerCase() ==
                  selectedFuelType!.toLowerCase()));
      if (match != null) {
        selectedFuelTypeId = match['_id']?.toString();
        selectedFuelType = match['name']?.toString();
      }
    }

    // Preferences
    selectedSourcing = v['sourcing'] ?? "Owner Vehicle";
    selectedPetFriendly = v['pet_friendly'] ?? "No";
    selectedLuggageCarrier = v['luggage_carrier'] ?? "No";
    selectedWorkingRearSeatBelts = v['working_rear_seat_belts'] ?? "No";
    selectedPermitType = v['permit_type'] ?? "State Permit";

    // Expiries
    fitnessExpiryController.text = v['fitness_expiry'] ?? "";
    insuranceExpiryController.text = v['insurance_expiry'] ?? "";
    permitExpiryController.text = v['permit_expiry'] ?? "";

    // Existing Image URLs/filenames for previews and backend reuse
    transferredVehicleExistingFrontImage = v['front_image'];
    transferredVehicleExistingBackImage = v['back_image'];
    transferredVehicleExistingLeftImage = v['left_image'];
    transferredVehicleExistingRightImage = v['right_image'];
    transferredVehicleExistingInteriorImage = v['interior_image'];
    transferredVehicleExistingPlateImage = v['number_plate_image'];
    transferredVehicleExistingDickyImage = v['dicky_image'];
    transferredVehicleExistingCarrierImage = v['carrier_image'];
    transferredVehicleExistingInsuranceDoc = v['insurance_document'];
    transferredVehicleExistingFitnessDoc = v['fitness_document'];
    transferredVehicleExistingPermitDoc = v['permit_document'];
    transferredVehicleExistingPucDoc = v['puc_document'];
    transferredVehicleExistingRcImage = v['rc_image'];
    transferredVehicleExistingAgreement = v['rented_vehicle_agreement'];

    // RC Verification
    isRcVerified = true;
    if (v['rc_details'] != null && v['rc_details'] is Map) {
      rcDetails = Map<String, dynamic>.from(v['rc_details']);
    } else {
      rcDetails = {
        "rc_number": rcNumberController.text,
        "owner_name": vehicleOwnerNameController.text,
      };
    }

    update();
  }

  Future<void> checkVehicleOwnerMobileForTransfer() async {
    final phone = vehicleOwnerMobileController.text.trim();
    if (phone.length != 10) {
      Utility.snacBar("Owner mobile number must be exactly 10 digits", Colors.red);
      return;
    }
    isCheckingVehicleOwnerMobile = true;
    vehicleTransferCheckResult = null;
    isVehicleTransferOtpSent = false;
    vehicleTransferOtpController.clear();
    update();

    try {
      final fullUrl = '${ApiWrapper.socketUrl}/vendor/vehicle/vendor-check-mobile';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        fullUrl,
        Request.postApiWithoutBaseURL,
        {"mobile": phone},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        if (data['isOwnVehicle'] == true) {
          vehicleTransferCheckResult = Map<String, dynamic>.from(data);
          Utility.snacBar(data['message'] ?? "This vehicle is already in your vehicle list.", Colors.blue);
        } else if (data['belongsToOtherVendor'] == true) {
          vehicleTransferCheckResult = Map<String, dynamic>.from(data);
          Utility.snacBar(data['message'] ?? "Vehicle registered with another vendor. OTP required.", Colors.orange);
        } else {
          // New vehicle owner: auto advance to Step 2
          isTransferredVehicle = false;
          transferredVehicleData = null;
          addVehicleCurrentStep = 2;
          vehicleOwnerMobileController.text = phone;
          Utility.snacBar("New vehicle owner. Please fill vehicle details.", Colors.green);
        }
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Error checking mobile", Colors.red);
        } catch (_) {
          Utility.snacBar("Error checking mobile number", Colors.red);
        }
      }
    } catch (e) {
      Utility.snacBar("Error checking mobile: $e", Colors.red);
    } finally {
      isCheckingVehicleOwnerMobile = false;
      update();
    }
  }

  Future<void> sendVehicleTransferOtp() async {
    final phone = vehicleOwnerMobileController.text.trim();
    isSendingVehicleTransferOtp = true;
    update();
    try {
      final fullUrl = '${ApiWrapper.socketUrl}/vendor/vehicle/transfer/send-otp';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        fullUrl,
        Request.postApiWithoutBaseURL,
        {"vehicle_owner_mobile": phone},
        false,
      );
      if (!response.hasError) {
        isVehicleTransferOtpSent = true;
        Utility.snacBar("OTP sent to vehicle owner's mobile number!", Colors.green);
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Failed to send OTP", Colors.red);
        } catch (_) {
          Utility.snacBar("Failed to send OTP", Colors.red);
        }
      }
    } catch (e) {
      Utility.snacBar("Failed to send OTP: $e", Colors.red);
    } finally {
      isSendingVehicleTransferOtp = false;
      update();
    }
  }

  Future<void> verifyVehicleTransferOtp() async {
    final otp = vehicleTransferOtpController.text.trim();
    final phone = vehicleOwnerMobileController.text.trim();
    if (otp.length < 5) {
      Utility.snacBar("Please enter valid OTP", Colors.red);
      return;
    }
    isVerifyingVehicleTransferOtp = true;
    update();
    try {
      final fullUrl = '${ApiWrapper.socketUrl}/vendor/vehicle/transfer/verify-otp';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        fullUrl,
        Request.postApiWithoutBaseURL,
        {"vehicle_owner_mobile": phone, "otp": otp},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        final vehicle = Map<String, dynamic>.from(data['vehicle'] ?? {});

        isTransferredVehicle = true;
        transferredVehicleData = vehicle;
        populateVehicleFormFromTransferred(vehicle);
        addVehicleCurrentStep = 2;
        Utility.snacBar("Vehicle verified! All details and documents loaded. ✅", Colors.green);
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Invalid OTP", Colors.red);
        } catch (_) {
          Utility.snacBar("Invalid OTP", Colors.red);
        }
      }
    } catch (e) {
      Utility.snacBar("Error verifying OTP: $e", Colors.red);
    } finally {
      isVerifyingVehicleTransferOtp = false;
      update();
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

  void toggleVehicleType(dynamic vehicleType) {
    if (selectedVehiclesList.any(
      (element) => element['_id'] == vehicleType['_id'],
    )) {
      selectedVehiclesList.removeWhere(
        (element) => element['_id'] == vehicleType['_id'],
      );
    } else {
      selectedVehiclesList.add(vehicleType);
    }
    update();
  }

  Future<void> pickDriverPhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      driverPhotoFile = File(image.path);
      update();
    }
  }

  Future<void> pickDLPhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      dlPhotoFile = File(image.path);
      update();
    }
  }

  Future<void> pickDriverPanPhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      driverPanPhotoFile = File(image.path);
      update();
    }
  }

  Future<void> pickDriverAadhaarPhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      driverAadhaarPhotoFile = File(image.path);
      update();
    }
  }

  void clearDriverForm() {
    driverNameController.clear();
    driverMobileController.clear();
    driverDLNumberController.clear();
    dateSportController.clear();
    dlIssueDateController.clear();
    dlValidityController.clear();
    selectDate = null;
    selectDLIssueDate = null;
    selectDLValidityDate = null;
    selectedVehicles = null;
    selectedDriver = null;
    selectedState = null;
    selectedCity = null;
    driverPhotoFile = null;
    dlPhotoFile = null;
    driverPanPhotoFile = null;
    driverAadhaarPhotoFile = null;
    stateSearchController.clear();
    citySearchController.clear();
    languageSearchController.clear();
    vehicleSearchController.clear();
    selectedLanguages.clear();
    selectedVehiclesList.clear();

    isDriverDlVerified = false;
    isDriverPanVerified = false;
    isDriverAadhaarVerified = false;
    driverAadhaarRefId = '';
    verifiedDriverDl = '';
    verifiedDriverPan = '';
    verifiedDriverAadhaar = '';
    driverPanNumberController.clear();
    driverAadhaarNumberController.clear();

    addDriverCurrentStep = 1;
    isCheckingDriverMobile = false;
    driverTransferCheckResult = null;
    isSendingTransferOtp = false;
    isTransferOtpSent = false;
    transferOtpController.clear();
    isVerifyingTransferOtp = false;
    isTransferredDriver = false;
    transferredDriverData = null;
    update();
  }

  void populateDriverForm(Map<String, dynamic> driver) {
    selectedDriver = driver;
    driverNameController.text = driver['driver_name'] ?? "";
    driverMobileController.text = driver['driver_mobile'] ?? "";
    driverDLNumberController.text = driver['DL_number'] ?? "";

    if (driver['dob'] != null) {
      try {
        selectDate = DateTime.parse(driver['dob']);
        dateSportController.text = DateFormat("dd/MM/yyyy").format(selectDate!);
      } catch (e) {
        log("Error parsing DOB: $e");
      }
    }

    selectedState = driver['state'];
    selectedCity = driver['city'];
    selectedLanguages = List<dynamic>.from(driver['language_known'] ?? []);
    selectedVehiclesList = List<dynamic>.from(driver['vehicales_drive'] ?? []);

    // Pre-mark as verified when editing existing driver
    isDriverDlVerified = (driver['DL_number'] ?? '').isNotEmpty;
    isDriverPanVerified = (driver['pan_number'] ?? '').isNotEmpty;
    isDriverAadhaarVerified = (driver['aadhar_number'] ?? '').isNotEmpty;
    verifiedDriverDl = driver['DL_number'] ?? '';
    verifiedDriverPan = driver['pan_number'] ?? '';
    verifiedDriverAadhaar = driver['aadhar_number'] ?? '';
    driverPanNumberController.text = driver['pan_number'] ?? '';
    driverAadhaarNumberController.text = driver['aadhar_number'] ?? '';

    // DL Issue Date
    if (driver['DL_issue_date'] != null) {
      try {
        selectDLIssueDate = DateTime.parse(driver['DL_issue_date']);
        dlIssueDateController.text = DateFormat(
          "dd/MM/yyyy",
        ).format(selectDLIssueDate!);
      } catch (e) {
        log("Error parsing DL Issue Date: $e");
      }
    }

    // DL Expiry Date
    if (driver['DL_expiry_date'] != null) {
      try {
        selectDLValidityDate = DateTime.parse(driver['DL_expiry_date']);
        dlValidityController.text = DateFormat(
          "dd/MM/yyyy",
        ).format(selectDLValidityDate!);
      } catch (e) {
        log("Error parsing DL Expiry Date: $e");
      }
    }

    update();
  }

  Future<void> updateDriver() async {
    if (selectedDriver == null) return;

    // Document verification checks
    if (!isDriverDlVerified) {
      Utility.snacBar("Please verify DL number before saving", Colors.red);
      return;
    }
    if (!isDriverPanVerified) {
      Utility.snacBar("Please verify PAN number before saving", Colors.red);
      return;
    }
    if (!isDriverAadhaarVerified) {
      Utility.snacBar("Please verify Aadhaar number before saving", Colors.red);
      return;
    }
    if (driverMobileController.text.trim().length != 10) {
      Utility.snacBar("Mobile number must be exactly 10 digits", Colors.red);
      return;
    }

    Utility.showLoader();

    Map<String, String> fields = {
      "driverId": selectedDriver!['_id'].toString(),
      "driver_name": driverNameController.text,
      "driver_mobile": driverMobileController.text,
      "DL_number": driverDLNumberController.text,
      "dob": selectDate?.toIso8601String() ?? "",
      "DL_issue_date": selectDLIssueDate?.toIso8601String() ?? "",
      "DL_expiry_date": selectDLValidityDate?.toIso8601String() ?? "",
      "state": selectedState ?? "",
      "city": selectedCity ?? "",
      "pan_number": driverPanNumberController.text.trim(),
      "aadhar_number": driverAadhaarNumberController.text.trim(),
      "language_known": jsonEncode(
        selectedLanguages.map((e) => e['_id']).toList(),
      ),
      "vehicales_drive": jsonEncode(
        selectedVehiclesList.map((e) => e['_id']).toList(),
      ),
    };

    final Map<String, File> files = {};
    if (driverPhotoFile != null) files['driver_photo'] = driverPhotoFile!;
    if (dlPhotoFile != null) files['DL_photo'] = dlPhotoFile!;
    if (driverPanPhotoFile != null) files['pan_photo'] = driverPanPhotoFile!;
    if (driverAadhaarPhotoFile != null) files['aadhar_photo'] = driverAadhaarPhotoFile!;

    final response = await homePresenter.updateDriver(
      fields: fields,
      files: files,
    );
    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        Get.back(); // Close screen
        getDrivers(); // Refresh list
        Utility.snacBar("Driver updated successfully", Colors.green);
      } else {
        Utility.snacBar(decoded['Message'] ?? "Update failed", Colors.red);
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  // -----------------------------------------------------------------------
  // 🔍 DRIVER DOCUMENT VERIFICATION
  // -----------------------------------------------------------------------

  Future<void> verifyDriverDL() async {
    final dlNumber = driverDLNumberController.text.trim();
    if (dlNumber.isEmpty) {
      Utility.snacBar("Please enter DL number", Colors.red);
      return;
    }
    isDriverDlVerifying = true;
    update();
    try {
      final fullUrl = '${ApiWrapper.socketUrl}/driver/verify/dl';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        fullUrl,
        Request.postApiWithoutBaseURL,
        {"dl_number": dlNumber},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        isDriverDlVerified = true;
        verifiedDriverDl = dlNumber;
        // Auto-fill driver name if available
        final holderName = data['holder_name'] ?? data['name'] ?? data['dob_name'] ?? '';
        if (holderName.isNotEmpty && driverNameController.text.isEmpty) {
          driverNameController.text = holderName;
        }
        // Auto-fill issue date
        final issueDate = data['issue_date'] ?? data['dl_issue_date'] ?? '';
        if (issueDate.isNotEmpty) {
          dlIssueDateController.text = issueDate;
        }
        // Auto-fill expiry date
        final expiryDate = data['expiry_date'] ?? data['dl_expiry_date'] ?? data['validity_date'] ?? '';
        if (expiryDate.isNotEmpty) {
          dlValidityController.text = expiryDate;
        }
        if (Get.context != null) {
          showDlDetailsDialog(Get.context!, data);
        }
        Utility.snacBar("DL verified successfully", Colors.green);
        update();
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'DL verification failed', Colors.red);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", Colors.red);
    } finally {
      isDriverDlVerifying = false;
      update();
    }
  }

  Future<void> verifyDriverPAN() async {
    final panNumber = driverPanNumberController.text.trim();
    if (panNumber.isEmpty) {
      Utility.snacBar("Please enter PAN number", Colors.red);
      return;
    }
    final dobStr = dateSportController.text.trim();
    if (dobStr.isEmpty) {
      Utility.snacBar("Please select Date of Birth first", Colors.red);
      return;
    }
    isDriverPanVerifying = true;
    update();
    try {
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        "verify/pan",
        Request.post,
        {
          "pan_number": panNumber.toUpperCase(),
          "name": driverNameController.text.trim(),
          "dob": _normalizeDob(dobStr),
        },
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        isDriverPanVerified = true;
        verifiedDriverPan = panNumber;
        if (Get.context != null) {
          showPanDetailsDialog(Get.context!, data);
        }
        Utility.snacBar("PAN verified successfully", Colors.green);
        update();
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'PAN verification failed', Colors.red);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", Colors.red);
    } finally {
      isDriverPanVerifying = false;
      update();
    }
  }

  Future<void> requestDriverAadhaarOtp() async {
    final aadhaarNumber = driverAadhaarNumberController.text.trim();
    if (aadhaarNumber.length != 12) {
      Utility.snacBar("Please enter valid 12-digit Aadhaar number", Colors.red);
      return;
    }
    isDriverAadhaarVerifying = true;
    update();
    try {
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        "verify/aadhaar-otp",
        Request.post,
        {"aadhaar_number": aadhaarNumber},
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
          driverAadhaarRefId = refId;
          _showDriverAadhaarOtpDialog(aadhaarNumber);
        } else {
          Utility.snacBar("Failed to get Aadhaar reference ID", Colors.red);
        }
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'Failed to send Aadhaar OTP', Colors.red);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", Colors.red);
    } finally {
      isDriverAadhaarVerifying = false;
      update();
    }
  }

  Future<void> verifyDriverAadhaarOtp(String otp) async {
    if (otp.length != 6) {
      Utility.snacBar("Please enter valid 6-digit OTP", Colors.red);
      return;
    }
    isDriverAadhaarOtpVerifying = true;
    update();
    try {
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        "verify/aadhaar-verify",
        Request.post,
        {"otp": otp, "ref_id": driverAadhaarRefId},
        false,
      );
      if (!response.hasError) {
        isDriverAadhaarVerified = true;
        verifiedDriverAadhaar = driverAadhaarNumberController.text.trim();
        Get.back(); // close dialog
        Utility.snacBar("Aadhaar verified successfully", Colors.green);
        update();
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'Aadhaar OTP verification failed', Colors.red);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", Colors.red);
    } finally {
      isDriverAadhaarOtpVerifying = false;
      update();
    }
  }

  void _showDriverAadhaarOtpDialog(String aadhaarNumber) {
    final TextEditingController otpController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFFFF6B00), size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Enter Aadhaar OTP',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'OTP sent to mobile linked to Aadhaar: ${aadhaarNumber.replaceRange(0, 8, 'XXXXXXXX')}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDriverAadhaarOtpVerifying ? null : () async {
                        setState(() {
                          isDriverAadhaarOtpVerifying = true;
                        });
                        await verifyDriverAadhaarOtp(otpController.text.trim());
                        setState(() {
                          isDriverAadhaarOtpVerifying = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isDriverAadhaarOtpVerifying
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Verify OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isDriverAadhaarVerifying ? null : () async {
                      Get.back();
                      await requestDriverAadhaarOtp();
                    },
                    child: const Text('Resend OTP', style: TextStyle(color: Color(0xFFFF6B00))),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> checkDriverMobileForTransfer() async {
    final phone = driverMobileController.text.trim();
    if (phone.length != 10) {
      Utility.snacBar("Mobile number must be exactly 10 digits", Colors.red);
      return;
    }
    isCheckingDriverMobile = true;
    driverTransferCheckResult = null;
    isTransferOtpSent = false;
    transferOtpController.clear();
    update();

    try {
      final fullUrl = '${ApiWrapper.socketUrl}/driver/vendor-check-mobile';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        fullUrl,
        Request.postApiWithoutBaseURL,
        {"mobile": phone},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        if (data['isOwnDriver'] == true) {
          driverTransferCheckResult = Map<String, dynamic>.from(data);
          Utility.snacBar(data['message'] ?? "Driver is already registered in your driver list.", Colors.blue);
        } else if (data['belongsToOtherVendor'] == true) {
          driverTransferCheckResult = Map<String, dynamic>.from(data);
          Utility.snacBar(data['message'] ?? "Driver belongs to another vendor. OTP required.", Colors.orange);
        } else {
          // New driver
          isTransferredDriver = false;
          transferredDriverData = null;
          addDriverCurrentStep = 2;
          Utility.snacBar("New driver. Continue to enter details.", Colors.green);
        }
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Error checking mobile", Colors.red);
        } catch (_) {
          Utility.snacBar("Error checking mobile number", Colors.red);
        }
      }
    } catch (e) {
      Utility.snacBar("Error checking mobile: $e", Colors.red);
    } finally {
      isCheckingDriverMobile = false;
      update();
    }
  }

  Future<void> sendTransferOtp() async {
    final phone = driverMobileController.text.trim();
    isSendingTransferOtp = true;
    update();
    try {
      final fullUrl = '${ApiWrapper.socketUrl}/driver/transfer/send-otp';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        fullUrl,
        Request.postApiWithoutBaseURL,
        {"driver_mobile": phone},
        false,
      );
      if (!response.hasError) {
        isTransferOtpSent = true;
        Utility.snacBar("OTP sent to driver's mobile number!", Colors.green);
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Failed to send OTP", Colors.red);
        } catch (_) {
          Utility.snacBar("Failed to send OTP", Colors.red);
        }
      }
    } catch (e) {
      Utility.snacBar("Failed to send OTP: $e", Colors.red);
    } finally {
      isSendingTransferOtp = false;
      update();
    }
  }

  Future<void> verifyTransferOtp() async {
    final otp = transferOtpController.text.trim();
    final phone = driverMobileController.text.trim();
    if (otp.length < 5) {
      Utility.snacBar("Please enter valid OTP", Colors.red);
      return;
    }
    isVerifyingTransferOtp = true;
    update();
    try {
      final fullUrl = '${ApiWrapper.socketUrl}/driver/transfer/verify-otp';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        fullUrl,
        Request.postApiWithoutBaseURL,
        {"driver_mobile": phone, "otp": otp},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        final driver = Map<String, dynamic>.from(data['driver'] ?? {});

        isTransferredDriver = true;
        transferredDriverData = driver;
        populateDriverForm(driver);
        addDriverCurrentStep = 2;
        Utility.snacBar("Driver verified! All details loaded. ✅", Colors.green);
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(decoded['message'] ?? decoded['Message'] ?? "Invalid OTP", Colors.red);
        } catch (_) {
          Utility.snacBar("Invalid OTP", Colors.red);
        }
      }
    } catch (e) {
      Utility.snacBar("Error verifying OTP: $e", Colors.red);
    } finally {
      isVerifyingTransferOtp = false;
      update();
    }
  }

  Future<void> registerDriver() async {
    // Basic validation
    if (driverNameController.text.isEmpty ||
        driverMobileController.text.isEmpty ||
        selectedState == null ||
        selectedCity == null) {
      Utility.snacBar("Please fill all required fields", Colors.red);
      return;
    }
    if (driverMobileController.text.trim().length != 10) {
      Utility.snacBar("Mobile number must be exactly 10 digits", Colors.red);
      return;
    }

    // Photo validation (only required if not transferred driver)
    if (!isTransferredDriver) {
      if (driverPhotoFile == null || dlPhotoFile == null || driverPanPhotoFile == null || driverAadhaarPhotoFile == null) {
        Utility.snacBar("Please select all 4 required driver and document photos", Colors.red);
        return;
      }

      // Document verification checks
      if (!isDriverDlVerified) {
        Utility.snacBar("Please verify DL number before saving", Colors.red);
        return;
      }
      if (!isDriverPanVerified) {
        Utility.snacBar("Please verify PAN number before saving", Colors.red);
        return;
      }
      if (!isDriverAadhaarVerified) {
        Utility.snacBar("Please verify Aadhaar number before saving", Colors.red);
        return;
      }
    }

    final fields = {
      "driver_name": driverNameController.text,
      "driver_mobile": driverMobileController.text,
      "dob": selectDate?.toIso8601String() ?? "",
      "DL_number": driverDLNumberController.text,
      "DL_issue_date": selectDLIssueDate?.toIso8601String() ?? "",
      "DL_expiry_date": selectDLValidityDate?.toIso8601String() ?? "",
      "state": selectedState!,
      "city": selectedCity!,
      "pan_number": driverPanNumberController.text.trim(),
      "aadhar_number": driverAadhaarNumberController.text.trim(),
      "language_known": jsonEncode(
        selectedLanguages.map((e) => e['_id']).toList(),
      ),
      "vehicales_drive": jsonEncode(
        selectedVehiclesList.map((e) => e['_id']).toList(),
      ),
    };

    if (isTransferredDriver && transferredDriverData != null) {
      fields['is_transfer'] = 'true';
      fields['transfer_driver_id'] = (transferredDriverData!['_id'] ?? '').toString();
    }

    final files = <String, File>{};
    if (driverPhotoFile != null) files['driver_photo'] = driverPhotoFile!;
    if (dlPhotoFile != null) files['DL_photo'] = dlPhotoFile!;
    if (driverPanPhotoFile != null) files['pan_photo'] = driverPanPhotoFile!;
    if (driverAadhaarPhotoFile != null) files['aadhar_photo'] = driverAadhaarPhotoFile!;

    // Note: addDriver API uses isLoading: true by default in apiWrapper
    final response = await homePresenter.addDriver(
      fields: fields,
      files: files,
    );

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true || decoded['isSuccess'] == true) {
        Get.back(); // Close AddNewdriversScreen
        // Refresh list WITHOUT a blocking dialog
        getDrivers(isLoading: false);
        Utility.snacBar(isTransferredDriver ? "Driver transferred successfully" : "Driver added successfully", Colors.green);
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to add driver",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  Future<void> fetchDepositAmount({
    bool showLoader = false,
    bool silent = true,
  }) async {
    if (showLoader) Utility.showLoader();

    final response = await homePresenter.fetchDepositAmount(
      isLoading: showLoader,
    );
    log("Deposit API response: ${response.data}");

    if (showLoader) Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true || decoded['isSuccess'] == true) {
        depositData = decoded['Data'];

        // Comprehensive status check
        final String status = (depositData?['status'] ?? '')
            .toString()
            .toLowerCase();
        final String detailsStatus =
            (depositData?['deposit_details']?['status'] ?? '')
                .toString()
                .toLowerCase();

        isDepositSubmitted =
            status == 'paid' || status == 'true' || detailsStatus == 'true';
      } else if (!silent) {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to fetch deposit status",
          Colors.red,
        );
      }
    } else if (!silent) {
      Utility.snacBar("Deposit status API failed", Colors.red);
    }

    update();
  }

  void _startDepositPolling() {
    _depositTimer?.cancel();
    _depositTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      await fetchDepositAmount(silent: true);
      final double depositAmount = _getDepositAmount();

      // 🔹 TRIGGERS PERIODIC POPUP: only if deposit is not paid
      if (depositAmount >= 0 && !isDepositSubmitted) {
        // Check if a dialog is already open to avoid stacking
        if (!(Get.isDialogOpen ?? false)) {
          showDepositDialog();
        }
      }

      _checkLowWalletBalancePopup();
    });
  }

  @override
  void onInit() {
    super.onInit();
    final repo = Get.find<Repository>();
    print('Before delete: ${repo.getStringValue(LocalKeys.authToken)}');
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getVendorProfile();
      getDashboardCounts();
      getRides();
      getDriverAllocations();
      getTripLogs();
      fetchStates();
      fetchCities();
      fetchLanguages();
      fetchVehicleTypes();
      fetchFuelTypes();
      getVehicles();
      getSupportTickets();
      fetchDepositAmount(silent: true);
      _startDepositPolling();
      // ✅ Load ringtone settings on startup so AudioService can use them when socket fires
      getRingtoneSettings();
      // ✅ Fetch drivers on startup so home screen counts match Manage Drivers page
      getDrivers(isLoading: false);
    });

    driverScrollController.addListener(() {
      if (driverScrollController.position.pixels ==
          driverScrollController.position.maxScrollExtent) {
        getDrivers(loadMore: true);
      }
    });

    vehicleScrollController.addListener(() {
      if (vehicleScrollController.position.pixels ==
          vehicleScrollController.position.maxScrollExtent) {
        getVehicles(loadMore: true);
      }
    });

    rideScrollController.addListener(() {
      if (rideScrollController.position.pixels ==
          rideScrollController.position.maxScrollExtent) {
        getRides(loadMore: true);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    _depositTimer?.cancel();
    _razorpay.clear();
    driverScrollController.dispose();
    vehicleScrollController.dispose();
    rideScrollController.dispose();
  }

  late Razorpay _razorpay;

  Future<void> getRideDetails(String vendorRequestId, {String? bookingId}) async {
    isRideDetailsLoading = true;
    AudioService.stopRingtone();
    update();

    final response = await homePresenter.fetchVendorRideDetails(
      vendorRequestId,
      bookingId: bookingId,
    );

    log("Ride Details API Response: ${response.data}");

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      if (decoded['IsSuccess'] == true) {
        selectedRideDetails = Map<String, dynamic>.from(decoded['Data']);
      }
    } else {
      final decoded = jsonDecode(response.data);
      Utility.snacBar(
        decoded['Message'] ?? "Failed to load ride details",
        ColorsValue.redColor,
      );
    }

    isRideDetailsLoading = false;
    update();
  }

  Future<void> getDriverDetails(String driverId) async {
    isDriverDetailLoading = true;
    selectedDriver = null; // Clear old driver details to prevent stale layout
    update();

    try {
      final response = await homePresenter.fetchDriverDetails(driverId);
      log("Driver Details API Response: ${response.data}");

      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        if (decoded['IsSuccess'] == true) {
          selectedDriver = Map<String, dynamic>.from(decoded['Data']);
          driverHistoryStatus = "";
          driverHistoryDate = "";
          driverHistoryCurrentPage = 1;
          await fetchDriverHistory(page: 1, clear: true);
        } else {
          Utility.snacBar(
            decoded['Message'] ?? "Failed to load driver details",
            ColorsValue.redColor,
          );
        }
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(
            decoded['Message'] ?? "Failed to load driver details",
            ColorsValue.redColor,
          );
        } catch (_) {
          Utility.snacBar("Failed to load driver details", ColorsValue.redColor);
        }
        if (Get.currentRoute == Routes.driverHistorysScreen) {
          Get.back();
        }
      }
    } catch (e) {
      log("Error fetching driver details: $e");
      Utility.snacBar("An unexpected error occurred", ColorsValue.redColor);
      if (Get.currentRoute == Routes.driverHistorysScreen) {
        Get.back();
      }
    } finally {
      isDriverDetailLoading = false;
      update();
    }
  }

  Future<void> getDrivers({
    bool loadMore = false,
    bool isLoading = true,
  }) async {
    if (isDriverLoading) return;
    if (!hasMoreDrivers && loadMore) return;

    // When refreshing (not loading more) reset pagination + list
    if (!loadMore) {
      driverPage = 1;
      hasMoreDrivers = true;
      drivers.clear();
    }

    isDriverLoading = true;
    update();

    if (loadMore) driverPage++;

    final response = await homePresenter.fetchDriversWithPagination(
      page: driverPage,
      limit: 100,
      search: driverSearchController.text,
      isLoading: isLoading,
    );

    log("Drivers API Response: ${response.data}${response.statusCode}");

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      if (decoded['IsSuccess'] == true) {
        final List list = decoded['Data']?['drivers'] ?? [];

        if (list.isEmpty || list.length < 100) {
          hasMoreDrivers = false;
        }

        // De-duplicate by _id to avoid multiple data after reload / pagination
        final Map<String, Map<String, dynamic>> byId = {
          for (final d in drivers)
            (d['_id']?.toString() ?? ''): Map<String, dynamic>.from(d)
        };

        for (final e in list) {
          final m = Map<String, dynamic>.from(e);
          final id = m['_id']?.toString() ?? '';
          if (id.isEmpty) continue;
          byId[id] = m;
        }

        drivers = byId.values.toList();

        // 🔍 DEBUG: Print ALL keys + values of the first driver to identify real backend field names
        if (drivers.isNotEmpty) {
          log('🔍 [DRIVER STATUS DEBUG] ========= FIRST DRIVER OBJECT =========');
          log('🔍 [DRIVER STATUS DEBUG] Keys: ${drivers.first.keys.toList()}');
          drivers.first.forEach((key, value) {
            log('🔍 [DRIVER STATUS DEBUG]   $key = $value (${value.runtimeType})');
          });
          log('🔍 [DRIVER STATUS DEBUG] ==========================================');
        }
      }
    } else {
      final decoded = jsonDecode(response.data);
      Utility.snacBar(
        decoded['Message'] ?? "Failed to load drivers",
        ColorsValue.redColor,
      );
    }

    isDriverLoading = false;
    update();
  }

  Future<void> exportDriversData() async {
    try {
      if (drivers.isEmpty) {
        Utility.snacBar("No drivers available to export.", ColorsValue.redColor);
        return;
      }

      Utility.showLoader();
      
      List<List<dynamic>> rows = [];
      // Header
      rows.add([
        "Driver Name",
        "Phone Number",
        "Date of Birth",
        "DL Number",
        "Address",
        "Status"
      ]);

      for (var driver in drivers) {
        rows.add([
          driver['driver_name'] ?? "-",
          driver['driver_mobile'] ?? "-",
          driver['dob'] ?? "-",
          driver['DL_number'] ?? "-",
          driver['address'] ?? "-",
          getDriverStatus(driver),
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      
      final Directory tempDir = await getTemporaryDirectory();
      final String path = '${tempDir.path}/drivers_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final File file = File(path);
      await file.writeAsString(csv);
      
      Utility.closeLoader();
      
      await Share.shareXFiles([XFile(path)], text: 'Exported Drivers Data');
    } catch (e) {
      Utility.closeLoader();
      log("Error exporting drivers data: $e");
      Utility.snacBar("Failed to export drivers data.", ColorsValue.redColor);
    }
  }

  Future<void> toggleDriverStatusController(String driverId) async {
    // 1. Disable multiple rapid clicks by checking if already in progress
    if (togglingDrivers[driverId] == true) {
      log("Status toggle already in progress for driver $driverId. Ignoring request.");
      return;
    }

    final int index = drivers.indexWhere((d) => d['_id'] == driverId);
    if (index == -1) return;

    final driver = drivers[index];
    final bool currentStatus = _isTruthyVal(driver['status']);
    final bool newStatus = !currentStatus;

    // 2. Set loading state for this driver
    togglingDrivers[driverId] = true;
    
    // 3. Optimistic local update to ensure instant response
    drivers[index]['status'] = newStatus;
    update();

    // 4. Console logging: Request payload, URL, headers
    final String url = "https://apis.bambamcabs.com/vendor/driver/toggle-status";
    final Map<String, dynamic> requestPayload = {"driver_id": driverId};
    final Map<String, String> requestHeaders = Utility.commonHeader();
    
    log("==================================================");
    log("▶️ [API REQUEST] Toggling Driver Status");
    log("URL: $url");
    log("Method: POST");
    log("Headers: ${jsonEncode(requestHeaders)}");
    log("Payload: ${jsonEncode(requestPayload)}");
    log("==================================================");

    try {
      final response = await homePresenter.toggleDriverStatus(driverId);
      
      log("==================================================");
      log("◀️ [API RESPONSE] Toggling Driver Status");
      log("Status Code: ${response.statusCode}");
      log("Has Error: ${response.hasError}");
      log("Raw Data: ${response.data}");
      log("==================================================");

      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        
        // 5. Robust response parsing supporting diverse cases
        final bool isSuccess = decoded['IsSuccess'] == true ||
                               decoded['isSuccess'] == true ||
                               decoded['success'] == true ||
                               decoded['Status']?.toString().toLowerCase() == 'success';
                               
        final String statusMsg = decoded['Message'] ??
                                 decoded['message'] ??
                                 decoded['Message '] ??
                                 "Driver status updated successfully";

        if (isSuccess) {
          // 6. Show success toast and fetch fresh driver listing in the background
          Utility.showMessage(statusMsg, MessageType.success, null, "");
          
          // Re-fetch listing silently to sync everything with the backend state
          await getDrivers(isLoading: false);
        } else {
          // 7. Backend reported failure: revert optimistic update & show backend error message
          drivers[index]['status'] = currentStatus;
          Utility.showMessage(statusMsg, MessageType.error, null, "");
        }
      } else {
        // 8. API call returned error state (e.g. 401 Unauthorized, 500, etc.)
        drivers[index]['status'] = currentStatus;
        
        String errMsg = "Failed to sync status with server";
        try {
          final decoded = jsonDecode(response.data);
          errMsg = decoded['Message'] ?? decoded['message'] ?? errMsg;
        } catch (_) {}
        
        if (response.statusCode == 401) {
          errMsg = "Session expired. Please log in again.";
        }
        
        Utility.showMessage(errMsg, MessageType.error, null, "");
      }
    } catch (e, stack) {
      // 9. Local exception occurred during request
      log("❌ [EXCEPTION] in toggleDriverStatusController: $e", error: e, stackTrace: stack);
      drivers[index]['status'] = currentStatus;
      Utility.showMessage("Network error occurred. Please try again.", MessageType.error, null, "");
    } finally {
      // 10. Clean up toggling loading state and update UI
      togglingDrivers.remove(driverId);
      update();
    }
  }

  Future<void> deleteDriverController(String driverId) async {
    final int index = drivers.indexWhere((d) => d['_id'] == driverId);
    if (index == -1) return;

    drivers.removeAt(index);
    update();

    final response = await homePresenter.deleteDriver(driverId);
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        Utility.snacBar("Driver deleted successfully", Colors.green);
        await getDrivers(isLoading: false);
      } else {
        Utility.snacBar("Driver deleted successfully", Colors.green);
      }
    } else {
      Utility.snacBar("Driver deleted successfully", Colors.green);
    }
  }

  bool isDriverOnline(Map<String, dynamic> driver) {
    return _isTruthyVal(driver['status']);
  }

  bool _isTruthyVal(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final s = value.toString().trim().toLowerCase();
    return s == 'true' ||
        s == '1' ||
        s == 'yes' ||
        s == 'on' ||
        s == 'active' ||
        s == 'approved' ||
        s == 'available' ||
        s == 'online';
  }

  bool _isFalsyVal(dynamic value) {
    if (value == null) return false;
    if (value is bool) return !value;
    if (value is int) return value == 0;
    final s = value.toString().trim().toLowerCase();
    return s == 'false' ||
        s == '0' ||
        s == 'no' ||
        s == 'off' ||
        s == 'inactive' ||
        s == 'blocked' ||
        s == 'rejected' ||
        s == 'offline';
  }

  String _strVal(dynamic value) =>
      value?.toString().trim().toLowerCase() ?? '';

  String getDriverStatus(Map<String, dynamic> driver) {
    final String driverName = driver['driver_name'] ?? 'Unknown';
    final bool status = _isTruthyVal(driver['status']);
    final String driverStatusRaw = driver['driver_status']?.toString() ?? '';

    String finalStatus = 'Unavailable';
    if (!status) {
      finalStatus = 'Unavailable';
    } else {
      if (driverStatusRaw.toLowerCase() == 'busy') {
        finalStatus = 'Busy';
      } else if (driverStatusRaw.toLowerCase() == 'available' || driverStatusRaw.isEmpty) {
        finalStatus = 'Available';
      } else {
        // If there's any other status (e.g. assigned, on_ride) and toggle is true:
        if (driverStatusRaw.toLowerCase() == 'assigned' || driverStatusRaw.toLowerCase() == 'on_ride' || driverStatusRaw.toLowerCase() == 'onride') {
          finalStatus = 'Busy';
        } else {
          finalStatus = driverStatusRaw.substring(0, 1).toUpperCase() + driverStatusRaw.substring(1).toLowerCase();
        }
      }
    }

    log("🔍 [DRIVER STATUS MATCH] Driver: $driverName | API status: $status | driver_status: '$driverStatusRaw' | Decided: $finalStatus");
    return finalStatus;
  }



  Future<void> getVendorProfile({bool showPageLoader = true}) async {
    isProfileLoading = true;
    update();

    final response = await homePresenter.fetchVendorProfile(
      isLoading: false, // don't use global overlay loader
    );

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      if (decoded['IsSuccess'] == true) {
        profile = Map<String, dynamic>.from(decoded['Data'] ?? {});
        _syncDepositFromProfile(profile);
        _checkLowWalletBalancePopup();
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? 'Failed to load profile',
          ColorsValue.redColor,
        );
      } catch (_) {
        Utility.snacBar('Failed to load profile', ColorsValue.redColor);
      }
    }

    isProfileLoading = false;
    update();
  }

  Future<bool> updateVendorProfile({
    required String ownerName,
    required String email,
    required String address,
    required String aadharNumber,
    required String panNumber,
    String? gstNumber,
    String? bankName,
    String? bankHolderName,
    String? bankAccountNumber,
    String? bankIfsc,
    String? businessProofType,
    String? businessProofNumber,
    String? addressProofType,
    String? addressProofNumber,
    File? ownerPhotoFile,
    File? aadharCardFile,
    File? panCardFile,
    File? addressProofFile,
    File? licenseFile,
    File? gstCertificateFile,
    File? visitingCardFile,
    File? cancelChequeFile,
    File? officePhotoFile,
  }) async {
    if (profile == null) return false;
    final vendorId = profile!['_id'].toString();
    final registerType = profile!['register_type']?.toString().toLowerCase() ?? 'company';
    final isCompany = registerType == 'company';

    // Validate fields
    if (ownerName.trim().length < 3) {
      Utility.snacBar("Owner name must be at least 3 characters", ColorsValue.redColor);
      return false;
    }
    if (aadharNumber.isNotEmpty) {
      final cleanAadhar = aadharNumber.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanAadhar.length != 12) {
        Utility.snacBar("Aadhaar number must be exactly 12 digits", ColorsValue.redColor);
        return false;
      }
    }
    if (panNumber.isNotEmpty) {
      final cleanPan = panNumber.trim().toUpperCase();
      if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(cleanPan)) {
        Utility.snacBar("Invalid PAN number format", ColorsValue.redColor);
        return false;
      }
    }
    if (isCompany && gstNumber != null && gstNumber.isNotEmpty) {
      final cleanGst = gstNumber.trim().toUpperCase();
      if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(cleanGst)) {
        Utility.snacBar("Invalid GSTIN format", ColorsValue.redColor);
        return false;
      }
    }
    if (bankIfsc != null && bankIfsc.trim().isNotEmpty) {
      final cleanIfsc = bankIfsc.trim().toUpperCase();
      if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(cleanIfsc)) {
        Utility.snacBar("Invalid IFSC code format", ColorsValue.redColor);
        return false;
      }
    }

    final fields = <String, String>{
      "vendor_id": vendorId,
      "owner_name": ownerName.trim(),
      "address": address.trim(),
      "pan_number": panNumber.trim().toUpperCase(),
      "aadhar_number": aadharNumber.trim(),
    };

    if (bankName != null && bankName.trim().isNotEmpty) {
      fields["bank_name"] = bankName.trim();
    }
    if (bankHolderName != null && bankHolderName.trim().isNotEmpty) {
      fields["account_holder_name"] = bankHolderName.trim();
    }
    if (bankAccountNumber != null && bankAccountNumber.trim().isNotEmpty) {
      fields["account_number"] = bankAccountNumber.trim();
    }
    if (bankIfsc != null && bankIfsc.trim().isNotEmpty) {
      fields["ifsc_code"] = bankIfsc.trim().toUpperCase();
    }

    if (businessProofType != null && businessProofType.isNotEmpty) {
      fields["business_proof_type"] = businessProofType;
    }
    if (businessProofNumber != null && businessProofNumber.isNotEmpty) {
      fields["business_proof_number"] = businessProofNumber;
    }
    if (addressProofType != null && addressProofType.isNotEmpty) {
      fields["address_proof_type"] = addressProofType;
    }
    if (addressProofNumber != null && addressProofNumber.isNotEmpty) {
      fields["address_proof_number"] = addressProofNumber;
    }

    if (isCompany) {
      if (gstNumber != null) fields["gst_number"] = gstNumber.trim().toUpperCase();
      fields["company_email"] = email.trim();
    } else {
      fields["owner_email"] = email.trim();
    }

    final files = <String, File>{
      if (ownerPhotoFile != null) "owner_photo": ownerPhotoFile,
      if (aadharCardFile != null) "aadhar_card": aadharCardFile,
      if (panCardFile != null) "pan_card": panCardFile,
      if (addressProofFile != null) "address_proof": addressProofFile,
      if (gstCertificateFile != null) "gst_certificate": gstCertificateFile,
      if (visitingCardFile != null) "visiting_card": visitingCardFile,
      if (cancelChequeFile != null) "cancel_cheque": cancelChequeFile,
    };

    if (licenseFile != null) {
      if (isCompany) {
        files["business_license"] = licenseFile;
      } else {
        files["DL_photo"] = licenseFile;
      }
    }

    if (isCompany && officePhotoFile != null) {
      files["office_photo"] = officePhotoFile;
    }

    final requestData = {
      "fields": fields,
      "files": files,
    };

    Utility.showLoader();
    try {
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        isCompany ? "update-company-vendor" : "indivisual/update",
        isCompany ? Request.multipartPut : Request.multipartPost,
        requestData,
        false,
      );

      Utility.closeLoader();

      if (!response.hasError) {
        Utility.snacBar("Profile updated successfully", ColorsValue.greenColor);
        return true;
      } else {
        final decoded = jsonDecode(response.data);
        final msg = decoded['Message'] ?? decoded['message'] ?? 'Failed to update profile';
        Utility.snacBar(msg.toString(), ColorsValue.redColor);
        return false;
      }
    } catch (e) {
      Utility.closeLoader();
      Utility.snacBar("Error updating profile: $e", ColorsValue.redColor);
      return false;
    }
  }

  // --- Vendor Profile Document Verification Methods ---
  Future<void> verifyProfilePAN(String panNumber, String ownerName) async {
    if (panNumber.trim().isEmpty) {
      Utility.snacBar("Please enter PAN number", Colors.red);
      return;
    }
    isProfilePanVerifying = true;
    update();
    try {
      final dobStr = profile?['dob']?.toString() ?? '';
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        "verify/pan",
        Request.post,
        {
          "pan_number": panNumber.toUpperCase(),
          "name": ownerName.trim(),
          "dob": _normalizeDob(dobStr),
        },
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data'] ?? decoded['data'] ?? {};
        isProfilePanVerified = true;
        if (Get.context != null) {
          showPanDetailsDialog(Get.context!, data, themeColor: ColorsValue.appColor);
        }
        Utility.snacBar("PAN verified successfully", Colors.green);
        update();
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'PAN verification failed', Colors.red);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", Colors.red);
    } finally {
      isProfilePanVerifying = false;
      update();
    }
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

  Future<void> verifyProfileGST(String gstNumber) async {
    if (gstNumber.trim().isEmpty) {
      Utility.snacBar("Please enter GST number", Colors.red);
      return;
    }
    isProfileGstVerifying = true;
    update();
    try {
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        "verify/gst",
        Request.post,
        {"gst_number": gstNumber.trim().toUpperCase()},
        false,
      );
      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        final data = decoded['Data']?['data'] ?? decoded['Data'] ?? {};
        isProfileGstVerified = true;
        if (Get.context != null) {
          showGstDetailsDialog(Get.context!, data, themeColor: ColorsValue.appColor);
        }
        Utility.snacBar("GST verified successfully", Colors.green);
        update();
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'GST verification failed', Colors.red);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", Colors.red);
    } finally {
      isProfileGstVerifying = false;
      update();
    }
  }

  Future<void> requestProfileAadhaarOtp(String aadhaarNumber) async {
    if (aadhaarNumber.trim().length != 12) {
      Utility.snacBar("Please enter valid 12-digit Aadhaar number", Colors.red);
      return;
    }
    isProfileAadhaarVerifying = true;
    update();
    try {
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        "verify/aadhaar-otp",
        Request.post,
        {"aadhaar_number": aadhaarNumber},
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
          profileAadhaarRefId = refId;
          if (Get.context != null) {
            showAadhaarOtpDialog(
              aadhaarNumber: aadhaarNumber,
              onVerify: (otp) async {
                await verifyProfileAadhaarOtp(otp);
              },
              onResend: () async {
                Get.back();
                await requestProfileAadhaarOtp(aadhaarNumber);
              },
              isVerifying: false,
              isResending: false,
            );
          }
        } else {
          Utility.snacBar("Failed to get Aadhaar reference ID", Colors.red);
        }
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'Failed to send Aadhaar OTP', Colors.red);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", Colors.red);
    } finally {
      isProfileAadhaarVerifying = false;
      update();
    }
  }

  Future<void> verifyProfileAadhaarOtp(String otp) async {
    if (otp.length != 6) {
      Utility.snacBar("Please enter valid 6-digit OTP", Colors.red);
      return;
    }
    isProfileAadhaarVerifying = true;
    update();
    try {
      final response = await homePresenter.homeUsecases.apiWrapper.makeRequest(
        "verify/aadhaar-verify",
        Request.post,
        {"otp": otp, "ref_id": profileAadhaarRefId},
        false,
      );
      if (!response.hasError) {
        isProfileAadhaarVerified = true;
        Get.back(); // close dialog
        Utility.snacBar("Aadhaar verified successfully", Colors.green);
        update();
      } else {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(decoded['Message'] ?? decoded['message'] ?? 'Aadhaar OTP verification failed', Colors.red);
      }
    } catch (e) {
      Utility.snacBar("Error: $e", Colors.red);
    } finally {
      isProfileAadhaarVerifying = false;
      update();
    }
  }

  Future<void> getVehicles({
    bool loadMore = false,
    bool isLoading = false,
  }) async {
    if (isVehicleLoading) return;
    if (loadMore && !hasMoreVehicles) return;

    // When refreshing (not loading more) reset pagination + list
    if (!loadMore) {
      vehiclePage = 1;
      vehicles.clear();
      hasMoreVehicles = true;
    } else {
      vehiclePage++;
    }

    isVehicleLoading = true;
    update();

    try {
      final response = await homePresenter.fetchVehiclesWithPagination(
        page: vehiclePage,
        limit: 100,
        search: "",
        isLoading: isLoading,
      );

      if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        final List list = decoded['Data']?['vehicles'] ?? [];
        final totalPagesValue = decoded['Data']?['totalPages'] ?? 1;

        if (list.isEmpty || vehiclePage >= totalPagesValue) {
          hasMoreVehicles = false;
        }

        // De-duplicate by _id to avoid multiple data after reload / pagination
        final Map<String, Map<String, dynamic>> byId = {
          for (final v in vehicles)
            (v['_id']?.toString() ?? ''): Map<String, dynamic>.from(v)
        };

        for (final e in list) {
          final m = Map<String, dynamic>.from(e);
          final id = m['_id']?.toString() ?? '';
          if (id.isEmpty) continue;
          byId[id] = m;
        }

        vehicles = byId.values.toList();
      }
    } else {
        Utility.snacBar("Failed to fetch vehicles", Colors.red);
      }
    } catch (e) {
      log("Error fetching vehicles: $e");
    } finally {
      isVehicleLoading = false;
      update();
    }
  }


  Future<void> getVehicleDetails(String vehicleId) async {
    selectedVehicleId = vehicleId;
    vehicleHistoryData = null; 
    final response = await homePresenter.fetchVehicleDetails(vehicleId);

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        final data = decoded['Data'];
        if (data != null && data is Map) {
          if (data.containsKey('vehicleInformation') || data.containsKey('vehicleDocuments')) {
            selectedVehicleDetails = Map<String, dynamic>.from(data);
          } else {
            // It's flat! Map to nested keys expected by ManagevehicleDetilesscreen UI
            selectedVehicleDetails = {
              '_id': data['_id'],
              'createdAt': data['createdAt'],
              'vehicleInformation': {
                'front_image': data['front_image'],
                'brand_name': data['brand_name'],
                'model_name': data['model_name'],
                'vehicle_number': data['vehicle_number'],
                'fuel_type': data['fuel_type'],
                'registration_year': data['registration_year'] ?? data['vehicle_make_year'],
                'sourcing': data['sourcing'],
                'rented_vehicle_agreement': data['rented_vehicle_agreement'],
                'back_image': data['back_image'],
                'interior_image': data['interior_image'],
                'left_image': data['left_image'],
                'right_image': data['right_image'],
                'number_plate_image': data['number_plate_image'],
                'dicky_image': data['dicky_image'],
              },
              'vehicleDocuments': {
                'insurance_expiry': data['insurance_expiry'],
                'insurance_document': data['insurance_document'],
                'fitness_expiry': data['fitness_expiry'],
                'fitness_document': data['fitness_document'],
                'permit_expiry': data['permit_expiry'],
                'permit_document': data['permit_document'],
                'permit_type': data['permit_type'],
                'puc_document': data['puc_document'],
                'rc_image': data['rc_image'],
              },
              'vehiclePreferences': {
                'working_rear_seat_belts': data['working_rear_seat_belts'],
                'pet_friendly': data['pet_friendly'],
                'luggage_carrier': data['luggage_carrier'],
              }
            };
          }
        } else {
          selectedVehicleDetails = null;
        }
        update();
        RouteManagement.gotoManagevehicleDetilesscreen();
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to fetch vehicle details",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  /// 📊 DASHBOARD COUNTS
  Future<void> getDashboardCounts({bool isLoading = true}) async {
    final response = await homePresenter.fetchDashboardCounts(isLoading: isLoading);
    log(" Dashboard Response: ${response.data}");
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        dashboardCounts = decoded['Data'] ?? {};
      }
    } else {
      final decoded = jsonDecode(response.data);
      Utility.snacBar(
        decoded['Message'] ?? 'Failed to load dashboard',
        ColorsValue.redColor,
      );
    }

    if (drivers.isEmpty) {
      getDrivers(isLoading: false);
    }

    update();
  }

  /// 🚕 FETCH RIDES
  Future<void> getRides({bool loadMore = false, bool isLoading = true}) async {
    if (isRideLoading) return;
    if (!hasMore && loadMore) return;

    if (!loadMore) {
      page = 1;
      hasMore = true;
    }

    if (isLoading) {
      isRideLoading = true;
      update();
    }

    if (loadMore) page++;

    final response = await homePresenter.fetchRidesWithPagination(
      page: page,
      limit: 30,
      search: "",
      tripType: "",
      dateFrom: "",
      dateTo: "",
      isLoading: isLoading,
    );
    log("Rides Response: ${response.data}");
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      final List list = decoded['Data']?['data'] ?? [];

      if (!loadMore) {
        newRides.clear();
      }

      if (list.isEmpty) {
        hasMore = false;
      } else {
        // 🔹 FILTER RIDES:
        // 1. Always show rides already Confirmed/Accepted by THIS vendor
        // 2. Show Pending rides if NOT taken by others AND NOT cancelled/expired
        final String? currentVendorId = profile?['_id']?.toString();

        final filteredList = list.where((e) {
          final ride = Map<String, dynamic>.from(e);
          final booking = ride['booking_id'] ?? {};
          final bookingStatus = (booking['booking_status'] ?? '')
              .toString()
              .toLowerCase();
          final vendorStatus = (ride['ride_status'] ?? '')
              .toString()
              .toLowerCase();
          final bookingVendorId = (booking['vendor_id'] ?? '').toString();

          // Rule 1: Always show rides already Confirmed/Accepted by THIS vendor
          if (vendorStatus == 'confirmed' || vendorStatus == 'accepted') {
            return true;
          }

          // Rule 2: Hide if it's overall cancelled (but show if overall expired, matching web)
          if (bookingStatus == 'cancelled') {
            return false;
          }

          // Rule 3: If it's still pending for this vendor, only show if NOT taken by others
          // If bookingVendorId is present and belongs to someone else, hide it.
          if (bookingVendorId.isNotEmpty &&
              bookingVendorId != 'null' &&
              currentVendorId != null &&
              bookingVendorId != currentVendorId) {
            return false;
          }

          return true;
        }).toList();

        newRides.addAll(
          filteredList.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      }
    } else {
      final decoded = jsonDecode(response.data);
      if (isLoading) {
        Utility.snacBar(
          decoded['Message'] ?? 'Failed to load rides',
          ColorsValue.redColor,
        );
      }
    }

    isRideLoading = false;
    update();
  }

  List allScrrenList = [
    BambamHubScreen(),
    DriverAllocatehomeScreen(),
    TriplogoHomepage(),
    RidereviewsHomescreen(),
    FineboardHomeScreen(),
    EarningsVaultscreen(),
    ManagedriversHomescreen(),
    ManagevehicleHomescreen(),
    SupportHomescreen(),
  ];

  List appBarTextList = [
    "Bambam Hub",
    "Driver & Vehicle Allocate",
    "Trip Logs",
    "Ride Reviews",
    "Fine Board",
    "Earnings Vault",
    "Manage Drivers",
    "Manage Vehicles",
    "Support",
  ];

  // --------------------------------------------------------------------Booking Responce Details--------------------------------------------------

  bool isInterested = false;
  bool isSpecial = false;
  bool isAdvance = false;
  bool isAcknowledge = false;

  // -------------------------------------------------------------------Driver Allocation---------------------------------------------------------------

  bool autoAssign = false;

  int selectedDriverIndex = -1;

  bool isConfirmingRide = false;

  Future<void> handleConfirmTap(
    BuildContext context, {
    Map<String, dynamic>? ride,
  }) async {
    if (isConfirmingRide) return;

    final targetRide = ride ?? selectedRideDetails?['vendorRequest'];
    if (targetRide == null) return;

    isConfirmingRide = true;
    try {

    // 🔹 PRIORITY 1: Check Security Deposit status immediately (Robust Fallback logic)
    final bool isActuallyPending = _hasPendingSecurityDeposit();

    if (isActuallyPending) {
      _pendingRideForConfirmation = targetRide;
      showDepositDialog();
      return;
    }

    Utility.showLoader();

    // 1. Refresh rides to check availability
    await getRides(isLoading: false);

    // 2. Check if the ride still exists and is not already accepted/confirmed
    final String rideId = targetRide['_id'] ?? '';
    final refreshedRide = newRides.firstWhereOrNull(
      (element) => element['_id'] == rideId,
    );

    final status =
        refreshedRide?['ride_status']?.toString().toLowerCase() ?? '';
    final isAvailable =
        refreshedRide != null && (status.isEmpty || status == 'pending');

    if (!isAvailable) {
      Utility.closeLoader();
      Utility.snacBar(
        "This ride is no longer available or has already been accepted.",
        ColorsValue.redColor,
      );
      return;
    }

    _pendingRideForConfirmation = targetRide;

    // Refresh deposit amount once more behind the scenes
    await fetchDepositAmount(showLoader: false, silent: true);

    Utility.closeLoader();

    // Re-check deposit status just in case it was paid in another tab/window recently
    if (_hasPendingSecurityDeposit()) {
      showDepositDialog();
    } else {
      paymentType = 'RIDE_CONFIRM';
      _pendingRideForConfirmation = null;
      showRideConfirmationDialog(ride: ride);
    }
    } finally {
      isConfirmingRide = false;
    }
  }

  void showDepositDialog() {
    final double depositAmount = _getDepositAmount();
    final int amountInPaise = (depositAmount * 100).toInt();

    if (amountInPaise <= 0) {
      _checkLowWalletBalancePopup();
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: Dimens.edgeInsets20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 CLOSE BUTTON (X)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ),
              ),
              Dimens.boxHeight10,

              // 🔹 TITLE: IMPORTANT NOTICE
              Text(
                "Important Notice",
                style: Styles.g1txtColor60018.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Dimens.boxHeight16,

              // 🔹 DESCRIPTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "To continue using Bambam services, please clear your pending deposit amount. This helps us ensure secure and smooth operations for all vendors.",
                  textAlign: TextAlign.center,
                  style: Styles.g5txtColor40012.copyWith(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              Dimens.boxHeight24,

              // 🔹 AMOUNT: ₹5000 (Green)
              Text(
                "₹${depositAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Dimens.boxHeight30,

              // 🔹 BUTTON: PROCEED TO PAYMENT (Orange)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (amountInPaise <= 0) {
                      Utility.snacBar("Invalid deposit amount", Colors.red);
                      return;
                    }
                    Get.back();
                    _openDepositCheckout(amountInPaise, depositAmount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Proceed to Payment",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showLowWalletBalanceDialog() {
    final double balance = currentWalletBalance;
    final int suggestedTopUp = ((walletBalanceThreshold - balance) > 0
        ? (walletBalanceThreshold - balance).ceil()
        : walletBalanceThreshold.toInt());

    _isLowWalletPopupVisible = true;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: Dimens.edgeInsets20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              Dimens.boxHeight16,
              Text(
                "Low Wallet Balance",
                style: Styles.g1txtColor60018.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Dimens.boxHeight12,
              Text(
                "Your wallet balance is low. Please add money to continue using Bambam services smoothly.",
                textAlign: TextAlign.center,
                style: Styles.g5txtColor40012.copyWith(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              Dimens.boxHeight20,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text("Current Balance", style: Styles.g7txtColor40014),
                    Dimens.boxHeight8,
                    Text(
                      "₹${balance.toStringAsFixed(0)}",
                      style: Styles.g1txtColor60020.copyWith(
                        color: Colors.green,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Dimens.boxHeight8,
                    Text(
                      "Recommended minimum: ₹${walletBalanceThreshold.toStringAsFixed(0)}",
                      textAlign: TextAlign.center,
                      style: Styles.g5txtColor40012.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Dimens.boxHeight24,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _markLowWalletPopupDismissed();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorsValue.l2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Remind Later",
                        style: Styles.g7txtColor70014,
                      ),
                    ),
                  ),
                  Dimens.boxWidth12,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        topUpAmountController.text = suggestedTopUp.toString();
                        Get.back();
                        RouteManagement.gotoTopUpwalletscreen();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsValue.appColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Top Up Now", style: Styles.whiteColorW60016),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    ).whenComplete(() {
      _isLowWalletPopupVisible = false;
    });
  }

  void showRideConfirmationDialog({Map<String, dynamic>? ride}) {
    Map<String, dynamic>? data;

    if (ride != null && ride['booking_id'] is Map) {
      data = {
        'vendorRequest': ride,
        'bookingDetails': ride['booking_id'] ?? {},
      };
    } else {
      data = selectedRideDetails;
    }

    if (data == null) return;

    final booking = data['bookingDetails'] ?? {};
    final vendorRequest = data['vendorRequest'] ?? {};
    final paymentSummary = booking['payment_summary'] ?? {};
    final paymentMode = booking['payment_mode']?.toString().toLowerCase() ?? '';
    final paymentId = booking['payment_id']?.toString() ?? '';

    // If the payment mode is online, skip the fee dialog entirely and just confirm directly.
    if (paymentMode == 'online') {
      _confirmWithoutPayment(vendorRequest['_id'] ?? '', paymentId: paymentId);
      return;
    }

    double commissionAmount =
        double.tryParse(paymentSummary['commission_amount'].toString()) ?? 0.0;

    if (commissionAmount == 0) {
      commissionAmount =
          double.tryParse(
            vendorRequest['commission_amount']?.toString() ?? '0',
          ) ??
          0.0;
    }

    // Razorpay amount is in paise
    final amountInPaise = (commissionAmount * 100).toInt();

    paymentType = 'RIDE_CONFIRM';

    // ✅ Fetch fresh profile so wallet balance shown in dialog is always real-time
    // (Same as web: dispatch(getProfile()) on component mount)
    getVendorProfile(showPageLoader: false);

    String selectedMethod = 'wallet';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: StatefulBuilder(
          builder: (context, setState) {
            bool isProcessingPayment = false;
            return Padding(
              padding: Dimens.edgeInsets20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close Button
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset(AssetConstants.ic_cancle),
                    ),
                  ),
                  Dimens.boxHeight10,

                  // Image
                  SvgPicture.asset(AssetConstants.ic_sucessImage),
                  Dimens.boxHeight20,

                  // Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "BamBam Ride Confirmation Fee ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: "₹${commissionAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  const Text(
                    "To confirm this ride, please pay the BamBam fee. "
                    "Once the payment is complete, you can proceed to manage and fulfill this booking.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  Dimens.boxHeight24,

                  // Payment Method Selection
                  const Text(
                    "Select Payment Method",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Dimens.boxHeight16,
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedMethod = 'wallet'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedMethod == 'wallet' ? Colors.orange : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: selectedMethod == 'wallet' ? Colors.orange.withValues(alpha: 0.05) : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Wallet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text("Bal: ₹${currentWalletBalance.toStringAsFixed(0)}", style: const TextStyle(color: Colors.green, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                if (selectedMethod == 'wallet')
                                  const Icon(Icons.check_circle, color: Colors.orange, size: 18)
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedMethod = 'online'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedMethod == 'online' ? Colors.orange : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: selectedMethod == 'online' ? Colors.orange.withValues(alpha: 0.05) : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.credit_card, color: Colors.black87, size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Online Pay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text("Card, UPI,\nNetbanking", style: TextStyle(color: Colors.grey, fontSize: 9)),
                                    ],
                                  ),
                                ),
                                if (selectedMethod == 'online')
                                  const Icon(Icons.check_circle, color: Colors.orange, size: 18)
                                else
                                  Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 18)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Dimens.boxHeight24,

                  // Pay Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isProcessingPayment) return;
                        setState(() => isProcessingPayment = true);
                        
                        if (selectedMethod == 'wallet') {
                          if (currentWalletBalance >= commissionAmount) {
                            Get.back(); // close dialog
                            _confirmWithoutPayment(
                              data!['vendorRequest']['_id'],
                              paymentId: "wallet",
                            );
                          } else {
                            setState(() => isProcessingPayment = false);
                            Utility.snacBar(
                              "Insufficient wallet balance. Please add funds or use Online Pay.",
                              Colors.red,
                            );
                          }
                        } else {
                          Get.back(); // close dialog
                          _openCheckout(
                            amountInPaise,
                            commissionAmount,
                            data!['vendorRequest']['_id'],
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Pay Now & Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showRideRejectDialog(String vendorRequestId) {
    rideRejectReasonController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: Dimens.edgeInsets20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Reject Ride Request",
                      style: Styles.g1txtColor60018,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      rideRejectReasonController.clear();
                      Get.back();
                    },
                    child: SvgPicture.asset(AssetConstants.ic_cancle),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              Text(
                "Please enter a reason for rejecting this request.",
                style: Styles.g7txtColor40014,
              ),
              Dimens.boxHeight12,
              TextField(
                controller: rideRejectReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter rejection reason",
                  filled: true,
                  fillColor: ColorsValue.whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimens.twelve),
                    borderSide: BorderSide(color: ColorsValue.l2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimens.twelve),
                    borderSide: BorderSide(color: ColorsValue.l2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimens.twelve),
                    borderSide: BorderSide(color: ColorsValue.appColor),
                  ),
                ),
              ),
              Dimens.boxHeight20,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        rideRejectReasonController.clear();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorsValue.redColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Cancel", style: Styles.redColor50014),
                    ),
                  ),
                  Dimens.boxWidth12,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => rejectRideRequest(vendorRequestId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsValue.redColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Reject", style: Styles.whiteColorW60016),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDepositCheckout(int amountInPaise, double displayAmount) {
    paymentType = 'DEPOSIT';

    var options = {
      'key': StringConstants.razorPayKey,
      'amount': amountInPaise,
      'name': 'Bam Bam Cabs',
      'description': 'Vendor Security Deposit',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': profile?['owner_mobile'] ?? "",
        'email': profile?['owner_email'] ?? "",
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      Utility.snacBar("Error opening payment: $e", Colors.red);
    }
  }

  void _openCheckout(int amount, double displayAmount, String vendorRequestId) {
    // Save vendorRequestId for success callback
    currentPaymentVendorRequestId = vendorRequestId;

    if (profile == null) {
      Utility.snacBar(
        "Profile not loaded. Cannot process payment.",
        Colors.red,
      );
      return;
    }

    var options = {
      'key': StringConstants.razorPayKey, // REPLACE WITH YOUR KEY
      'amount': amount,
      'name': 'Bam Bam Cabs',
      'description': 'Ride Confirmation Fee',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': profile!['owner_mobile'],
        'email': profile!['owner_email'],
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  String paymentType =
      'RIDE_CONFIRM'; // 'RIDE_CONFIRM' | 'WALLET_TOPUP' | 'DEPOSIT'
  String? currentPaymentVendorRequestId;
  String? currentRazorpayOrderId; // For Top-up

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (paymentType == 'WALLET_TOPUP') {
      _verifyTopUp(response);
    } else if (paymentType == 'DEPOSIT') {
      _completeDepositPayment(response);
    } else {
      _confirmRideRequest(response);
    }
  }

  Future<void> _completeDepositPayment(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId;
    if (paymentId == null || paymentId.isEmpty) {
      Utility.snacBar("Payment ID missing from Razorpay response", Colors.red);
      return;
    }

    log("Calling payDeposit with paymentId: $paymentId");
    Utility.showLoader();

    final apiResponse = await homePresenter.payDeposit(
      razorpayPaymentId: paymentId,
    );
    log("Deposit pay API response: ${apiResponse.data}");

    Utility.closeLoader();

    if (!apiResponse.hasError) {
      final decoded = jsonDecode(apiResponse.data);
      if (decoded['IsSuccess'] == true) {
        isDepositSubmitted = true;
        fetchDepositAmount(silent: true);
        Utility.snacBar(
          decoded['Message'] ?? "Deposit payment successful",
          Colors.green,
        );

        // Proceed with ride confirmation flow if user initiated it
        final ctx = Get.context;
        if (ctx != null) {
          paymentType = 'RIDE_CONFIRM';
          showRideConfirmationDialog(ride: _pendingRideForConfirmation);
        }
        _pendingRideForConfirmation = null;
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Deposit payment failed",
          Colors.red,
        );
      }
    } else {
      Utility.snacBar("Deposit payment API failed", Colors.red);
    }
  }

  // Original confirmation logic moved here
  void _confirmRideRequest(PaymentSuccessResponse response) async {
    if (currentPaymentVendorRequestId == null) {
      Utility.snacBar("Error: Vendor Request ID missing", Colors.red);
      return;
    }

    Utility.showLoader();
    final vendorRequestId = currentPaymentVendorRequestId;

    final body = {
      "vendorRequestId": vendorRequestId,
      "payment_id": response.paymentId,
    };

    final apiResponse = await homePresenter.confirmRequest(body);
    Utility.closeLoader();

    if (!apiResponse.hasError) {
      final decoded = jsonDecode(apiResponse.data);
      if (decoded['IsSuccess'] == true) {
        // ✅ Real-time refresh after online payment success
        getVendorProfile(showPageLoader: false);
        fetchEarningsVaultData();
        getRides(isLoading: false);

        if (Get.context != null) {
          showConfromBooking(Get.context!);
        }
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Confirmation Failed",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(apiResponse.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  void _confirmWithoutPayment(
    String vendorRequestId, {
    String? paymentId,
  }) async {
    if (vendorRequestId.isEmpty) {
      Utility.snacBar("Error: Vendor Request ID missing", Colors.red);
      return;
    }

    Utility.showLoader();
    AudioService.stopRingtone();

    final body = {
      "vendorRequestId": vendorRequestId,
      if (paymentId != null && paymentId.isNotEmpty) "payment_id": paymentId,
    };

    final apiResponse = await homePresenter.confirmRequest(body);
    Utility.closeLoader();

    if (!apiResponse.hasError) {
      final decoded = jsonDecode(apiResponse.data);
      if (decoded['IsSuccess'] == true) {
        // ✅ Real-time wallet balance update: refresh profile + earnings silently
        // This ensures the wallet balance shown in UI deducts immediately after payment
        getVendorProfile(showPageLoader: false);
        fetchEarningsVaultData();
        getRides(isLoading: false);

        if (Get.context != null) {
          showConfromBooking(Get.context!);
        }
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Confirmation Failed",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(apiResponse.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  Future<void> rejectRideRequest(String vendorRequestId) async {
    final reason = rideRejectReasonController.text.trim();

    if (reason.isEmpty) {
      Utility.snacBar("Please enter rejection reason.", Colors.red);
      return;
    }

    Utility.showLoader();
    AudioService.stopRingtone();

    final apiResponse = await homePresenter.rejectRequest({
      "vendorRequestId": vendorRequestId,
      "reason": reason,
    });

    Utility.closeLoader();

    if (!apiResponse.hasError) {
      final decoded = jsonDecode(apiResponse.data);

      if (decoded['IsSuccess'] == true) {
        final rejectedData = decoded['Data'] ?? {};
        final rideIndex = newRides.indexWhere(
          (ride) => ride['_id'] == vendorRequestId,
        );

        if (rideIndex != -1) {
          final updatedRide = Map<String, dynamic>.from(newRides[rideIndex]);
          final updatedBooking = updatedRide['booking_id'] is Map
              ? Map<String, dynamic>.from(updatedRide['booking_id'])
              : <String, dynamic>{};

          updatedBooking['vendor_status'] = rejectedData['status'] ?? 'Rejected';
          updatedRide['ride_status'] = rejectedData['ride_status'] ?? updatedRide['ride_status'];
          updatedRide['cancellation_reason'] = rejectedData['cancellation_reason'] ?? reason;
          updatedRide['booking_id'] = updatedBooking;
          newRides[rideIndex] = updatedRide;
          update();
        }

        if (selectedRideDetails?['vendorRequest']?['_id'] == vendorRequestId) {
          final updatedSelectedRide = Map<String, dynamic>.from(
            selectedRideDetails ?? {},
          );
          final updatedVendorRequest =
              updatedSelectedRide['vendorRequest'] is Map
              ? Map<String, dynamic>.from(updatedSelectedRide['vendorRequest'])
              : <String, dynamic>{};
          final updatedBookingDetails =
              updatedSelectedRide['bookingDetails'] is Map
              ? Map<String, dynamic>.from(updatedSelectedRide['bookingDetails'])
              : <String, dynamic>{};

          updatedVendorRequest['ride_status'] =
              rejectedData['ride_status'] ??
              updatedVendorRequest['ride_status'];
          updatedVendorRequest['status'] =
              rejectedData['status'] ?? updatedVendorRequest['status'];
          updatedVendorRequest['cancellation_reason'] =
              rejectedData['cancellation_reason'] ?? reason;
          updatedBookingDetails['vendor_status'] =
              rejectedData['status'] ??
              updatedBookingDetails['vendor_status'] ??
              'Rejected';

          updatedSelectedRide['vendorRequest'] = updatedVendorRequest;
          updatedSelectedRide['bookingDetails'] = updatedBookingDetails;
          selectedRideDetails = updatedSelectedRide;
        }

        rideRejectReasonController.clear();
        update();

        // Close the reject dialog
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Utility.snacBar(
          decoded['Message'] ?? "Vendor request rejected successfully",
          Colors.green,
        );
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to reject request",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(apiResponse.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  /// 🚕 Public method to accept ride from Popup
  void acceptRideFromPopup(String vendorRequestId) async {
    if (vendorRequestId.isEmpty) return;
    _confirmWithoutPayment(vendorRequestId);
  }

  /// 🚕 Public method to reject ride from Popup
  void rejectRideFromPopup(String vendorRequestId) async {
    if (vendorRequestId.isEmpty) return;
    
    // For popup rejection, we use a default reason to make it quick
    Utility.showLoader();
    AudioService.stopRingtone();

    final apiResponse = await homePresenter.rejectRequest({
      "vendorRequestId": vendorRequestId,
      "reason": "Rejected from Mobile Popup",
    });

    Utility.closeLoader();

    if (!apiResponse.hasError) {
      final decoded = jsonDecode(apiResponse.data);
      if (decoded['IsSuccess'] == true) {
        Utility.snacBar("Ride Rejected", Colors.orange);
        getRides(isLoading: false);
      }
    }
  }

  // ----------------------------------------------------------------Earnings Vault------------------------------------------------
  TextEditingController topUpAmountController = TextEditingController();
  TextEditingController withdrawAmountController = TextEditingController();
  Map<String, dynamic>? earningsData;
  bool isEarningsLoading = false;
  bool isWithdrawLoading = false;

  /// 💰 Fetch Earnings Vault Data
  Future<void> fetchEarningsVaultData() async {
    isEarningsLoading = true;
    update();

    final response = await homePresenter.getEarningsVaultData();
    log("Earnings Vault Response: ${response.data}");

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        earningsData = decoded['Data'];
        _checkLowWalletBalancePopup();
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to fetch earnings",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
    isEarningsLoading = false;
    update();
  }

  /// 💰 Partner Earnings Withdrawal
  Future<void> withdrawEarningsController(int amount) async {
    if (amount <= 0) {
      Utility.snacBar("Please enter a valid amount", Colors.red);
      return;
    }

    final num rawBalance = earningsData?['wallet_balance'] ?? 0;
    final double walletBalance = rawBalance.toDouble();
    if (amount > walletBalance) {
      Utility.snacBar("Amount cannot exceed your wallet balance (₹${walletBalance.toStringAsFixed(0)})", Colors.red);
      return;
    }
    
    isWithdrawLoading = true;
    update();

    try {
      final response = await homePresenter.withdrawEarnings(amount: amount);
      log("Withdraw Earnings Response: ${response.data}");

      isWithdrawLoading = false;
      update();

      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        if (decoded['IsSuccess'] == true || decoded['isSuccess'] == true) {
          withdrawAmountController.clear();
          Get.back(); // close the withdraw screen
          fetchEarningsVaultData(); // refresh the balance
          Utility.snacBar(
            decoded['Message'] ?? "Withdrawal request submitted successfully",
            Colors.green,
          );
        } else {
          Utility.snacBar(
            decoded['Message'] ?? "Failed to process withdrawal",
            Colors.red,
          );
        }
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(
            decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
            Colors.red,
          );
        } catch (_) {
          Utility.snacBar("API Call Failed", Colors.red);
        }
      }
    } catch (e) {
      isWithdrawLoading = false;
      update();
      Utility.snacBar(
        "Something went wrong. Please check your network and try again.",
        Colors.red,
      );
    }
  }


  /// 💳 Initiate Wallet Top-Up
  Future<void> initiateWalletTopUp(int amount) async {
    if (profile == null || profile!['_id'] == null) {
      Utility.snacBar("Profile not loaded. Please try again.", Colors.red);
      return;
    }

    // Use razorpay_user_id if available in profile, otherwise use _id or email as fallback?
    // The request example used "rzp_user_..." so it might be a specific field.
    // Assuming backend handles mapping or we send user ID.
    // Request: {amount: 500, razorpay_user_id: "rzp_user_..."}
    // If we don't have rzp_user_id in profile, let's try sending the mongo ID or check profile response.
    // For now I'll send the profile ID or a placeholder if missing, but likely it's in profile.

    final String rzpUserId =
        profile?['razorpay_user_id']?.toString() ??
        profile?['rzp_user_id']?.toString() ??
        profile?['razorpayUserId']?.toString() ??
        profile?['_id']?.toString() ??
        "";

    if (rzpUserId.isEmpty) {
      Utility.snacBar(
        "Razorpay user ID is missing. Please try again later.",
        Colors.red,
      );
      return;
    }

    final response = await homePresenter.createTopUpOrder(
      amount: amount,
      razorpayUserId: rzpUserId,
    );
    log("TopUp Order Response: ${response.data}");

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        final orderData = decoded['Data']['order'];
        final String orderId = orderData['id'];
        final int orderAmount = orderData['amount']; // In paise

        _openTopUpCheckout(orderId, orderAmount);
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to create order",
          Colors.red,
        );
      }
    } else {
      Utility.snacBar("Failed to initiate top-up", Colors.red);
    }
  }

  void _openTopUpCheckout(String orderId, int amountInPaise) {
    paymentType = 'WALLET_TOPUP';
    currentRazorpayOrderId = orderId;

    var options = {
      'key': StringConstants.razorPayKey,
      'amount': amountInPaise,
      'name': 'Bam Bam Cabs',
      'description': 'Wallet Top-Up',
      'order_id': orderId, // Crucial for verification
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': profile?['owner_mobile'] ?? "",
        'email': profile?['owner_email'] ?? "",
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      Utility.snacBar("Error opening payment: $e", Colors.red);
    }
  }

  void _verifyTopUp(PaymentSuccessResponse response) async {
    final apiResponse = await homePresenter.verifyTopUpPayment(
      razorpayOrderId: response.orderId ?? currentRazorpayOrderId ?? "",
      razorpayPaymentId: response.paymentId ?? "",
      razorpaySignature: response.signature ?? "",
    );
    log("TopUp Verify Response: ${apiResponse.data}");

    if (!apiResponse.hasError) {
      final decoded = jsonDecode(apiResponse.data);
      if (decoded['IsSuccess'] == true) {
        await getVendorProfile(showPageLoader: false);
        await fetchEarningsVaultData();
        topUpAmountController.clear();
        Get.back(); // Redirect back to EarningsVaultscreen
        Utility.snacBar("Wallet Top-up Successful!", Colors.green);
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Payment Verification Failed",
          Colors.red,
        );
      }
    } else {
      Utility.snacBar("Verification API Failed", Colors.red);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Utility.snacBar("Payment Failed: ${response.message}", Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Utility.snacBar(
      "External Wallet Selected: ${response.walletName}",
      Colors.blue,
    );
  }

  void showConfromBooking(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: Dimens.edgeInsets20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: SvgPicture.asset(AssetConstants.ic_cancle),
                ),
              ),
              Dimens.boxHeight10,

              // Image
              SvgPicture.asset(AssetConstants.ic_confrom),
              Dimens.boxHeight20,

              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Your New Ride Request is Confirmed!",
                      style: Styles.g1txtColor60016,
                    ),
                  ],
                ),
              ),

              Dimens.boxHeight12,

              // Description
              Text(
                "Your ride request has been successfully completed. Assign Driver & Vehicle.",
                textAlign: TextAlign.center,
                style: Styles.g5txtColor40012,
              ),

              Dimens.boxHeight24,

              // Pay Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    selectedIndex = 1;
                    update();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Assign Driver & Vehicle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- Trip Logo -----------------------------------------------

  int selectedIndexTripLogs = 0;

  final List<String> tabs = ['Upcoming', 'Ongoing', 'Completed', 'Cancelled'];

  // Trip Log Data
  List<dynamic> tripLogList = [];
  int tripLogCurrentPage = 1;
  int tripLogTotalPages = 1;
  int tripLogTotal = 0;
  int tripLogLimit = 100;
  String tripLogSearch = "";
  String tripLogTripType = "";
  String? tripLogStartDate;
  String? tripLogEndDate;
  Map<String, dynamic>? selectedTripDetails;

  TextEditingController descriptionPolicyContrioller = TextEditingController();

  // Trip Cancellation Data
  List<dynamic> cancellationReasonsList = [];
  String selectedCancellationReasonId = "";
  int selectedReason = -1; // Index for UI radio selection

  // Fetch Cancellation Reasons
  Future<void> fetchCancellationReasons() async {
    final response = await homePresenter.getCancellationReasons();
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        cancellationReasonsList = decoded['Data'] ?? [];
        update();
      }
    }
  }

  // Cancel Trip
  Future<void> submitTripCancellation(String vendorRequestId) async {
    if (selectedCancellationReasonId.isEmpty) {
      Utility.snacBar("Please select a cancellation reason.", Colors.red);
      return;
    }
    if (descriptionPolicyContrioller.text.trim().isEmpty) {
      Utility.snacBar("Please enter a description.", Colors.red);
      return;
    }

    Utility.showLoader();
    final response = await homePresenter.cancelTrip(
      vendorRequestId: vendorRequestId,
      cancellationReasonId: selectedCancellationReasonId,
      cancellationDescription: descriptionPolicyContrioller.text.trim(),
    );
    Utility.closeLoader();
    print("Cancel Trip Response: ${response.data}");

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        Utility.snacBar("Trip Cancelled Successfully!!", Colors.green);
        Get.back(); // Go back to details or list
        getTripLogs(); // Refresh logs
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to cancel trip.",
          Colors.red,
        );
      }
    } else {
      Utility.snacBar("Something went wrong. Please try again.", Colors.red);
    }
  }

  /// 🎫 Get Support Tickets
  Future<void> getSupportTickets({bool loadMore = false}) async {
    if (loadMore) {
      if (isSupportLoading || !hasMoreSupportTickets) return;
      supportPage++;
    } else {
      supportPage = 1;
      hasMoreSupportTickets = true;
      isSupportLoading = true;
      supportTicketsList.clear();
      update();
    }

    final response = await homePresenter.fetchSupportTickets(
      page: supportPage,
      limit: supportLimit,
    );

    isSupportLoading = false;

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        final data = decoded['data'] ?? decoded['Data'];
        final List<dynamic> newTickets = data['tickets'] ?? [];

        if (newTickets.isEmpty) {
          hasMoreSupportTickets = false;
        } else {
          supportTicketsList.addAll(newTickets);
          if (newTickets.length < supportLimit) {
            hasMoreSupportTickets = false;
          }
        }
      }
    } else {
      Utility.snacBar("Failed to fetch support tickets", Colors.red);
    }
    update();
  }

  /// 🎫 Submit Support Ticket
  Future<void> submitSupportTicket() async {
    if (selectedIssue == null ||
        ticketBookingIdController.text.trim().isEmpty ||
        ticketDescriptionController.text.trim().isEmpty) {
      Utility.snacBar(
        "Please fill all mandatory fields",
        Colors.red,
      );
      return;
    }

    Map<String, String> fields = {
      "issue_type": selectedIssue!,
      "booking_id": ticketBookingIdController.text.trim(),
      "description": ticketDescriptionController.text.trim(),
    };

    Map<String, File> files = {};
    if (ticketAttachmentFile != null) {
      files["attachment"] = ticketAttachmentFile!;
    }

    try {
      final response = await homePresenter.createSupportTicket(
        fields: fields,
        files: files,
      );

      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
          clearSupportForm();
          getSupportTickets(); // Refresh list
          Get.back(); // Go back to list
          Utility.snacBar("Ticket submitted successfully", Colors.green);
        } else {
          Utility.snacBar(
            decoded['message'] ?? decoded['Message'] ?? "Failed to submit ticket",
            Colors.red,
          );
        }
      } else {
        try {
          final decoded = jsonDecode(response.data);
          Utility.snacBar(
            decoded['message'] ?? decoded['Message'] ?? "Something went wrong",
            Colors.red,
          );
        } catch (_) {
          Utility.snacBar("Something went wrong", Colors.red);
        }
      }
    } catch (e) {
      Utility.snacBar("An unexpected error occurred", Colors.red);
    }
  }

  /// 📎 Pick Ticket Attachment
  Future<void> pickTicketAttachment() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ticketAttachmentFile = File(image.path);
      update();
    }
  }

  void clearSupportForm() {
    selectedIssue = null;
    ticketBookingIdController.clear();
    ticketDescriptionController.clear();
    ticketAttachmentFile = null;
    update();
  }

  /// 🎫 Get Support Ticket Details
  Future<void> getSupportTicketDetails(String ticketId) async {
    selectedTicketDetails = null;
    Utility.showLoader();

    final response = await homePresenter.fetchSupportTicketDetails(ticketId);

    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        selectedTicketDetails = decoded['data'] ?? decoded['Data'];
        RouteManagement.gotoTicketDetilesscreen();
      } else {
        Utility.snacBar("Failed to load ticket details", Colors.red);
      }
    } else {
      Utility.snacBar("Something went wrong", Colors.red);
    }
    update();
  }

  // Legacy hardcoded reasons - kept if needed elsewhere, otherwise superseded by API list
  final List<String> reasons = ['Driver is not available'];

  // ----------------------------------------------------------------Earnigs Vault ------------------------------------------------

  int selectedIndexEarn = 0;

  // ---------------------------------------------------------------- Support ------------------------------------------------
  // Variables defined at top of file
  // ---------------------------------------------------------------- Support ------------------------------------------------

  List<String> vehiclesList = ["Booking Issue", "Payment Issue", "Ride Issue"];
  String? selectedVehicles;

  TextEditingController dateSportController = TextEditingController();

  DateTime? selectDate = DateTime.now();

  // ---------------------------------------------------------------- vehical Manage ------------------------------------------------

  // ---------------------------------------------------------------- vehical Manage ------------------------------------------------

  // City Preference Variables
  Map<String, dynamic>? cityPreferenceData;
  List<dynamic> selectedCities = [];
  List<dynamic> suggestedCities = [];
  List<dynamic> searchResultsCities = [];
  TextEditingController citySearchControllerPref = TextEditingController();
  Timer? _searchTimer;

  void onCitySearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      getCityPreferences(search: value);
    });
  }

  int selectedIndexVehicalH = 0;

  final List<String> tabsVehicalH = [
    'Information',
    'Documents',
    'Preferences',
    'Trip History',
  ];

  // ---------------------------------------------------------------- profile Detiles ------------------------------------------------

  Future<void> _clearSessionAndGoToLogin() async {
    final repo = Get.find<Repository>();
    
    // Disconnect the socket connection
    SocketConnection.socketDisconnect();

    // Call backend logout to clear FCM token
    try {
      await homePresenter.logout();
    } catch (e) {
      print("Logout API error: $e");
    }

    await repo.deleteAllSecuredValues();
    repo.clearData(LocalKeys.authToken);
    repo.clearData(LocalKeys.vendorId);
    repo.clearData(LocalKeys.chanelId);
    repo.clearData(LocalKeys.lowWalletPopupLastDismissedAt);
    
    RouteManagement.gotoLogainScreen();
  }

  Future<void> deleteAccount() async {
    final response = await homePresenter.deleteAccount();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      final isSuccess =
          decoded['IsSuccess'] == true || decoded['isSuccess'] == true;

      if (isSuccess) {
        await _clearSessionAndGoToLogin();
        Utility.showMessage(
          decoded['Message']?.toString() ?? "Account deleted successfully.",
          MessageType.success,
          null,
          "OK",
        );
        return;
      }

      Utility.showMessage(
        decoded['Message']?.toString() ?? "Unable to delete account.",
        MessageType.error,
        null,
        "OK",
      );
      return;
    }

    String message = "Delete account request failed.";
    try {
      final decoded = jsonDecode(response.data);
      message = decoded['Message']?.toString() ?? message;
    } catch (_) {}

    Utility.showMessage(message, MessageType.error, null, "OK");
  }

  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: Dimens.edgeInsets20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset(AssetConstants.ic_cancle),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  AssetConstants.ic_logout,
                  height: Dimens.hundredTwenty,
                ),
                Dimens.boxHeight20,
                const Text(
                  "Are you sure you want to delete your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Dimens.boxHeight20,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    Get.back();
                    await deleteAccount();
                  },
                  child: const Text(
                    "Yes, Delete Account",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: Dimens.edgeInsets20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset(AssetConstants.ic_cancle),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  AssetConstants.ic_logout,
                  height: Dimens.hundredTwenty,
                ),
                Dimens.boxHeight20,
                const Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Dimens.boxHeight20,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsValue.appColor,
                    shape: StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    Get.back();
                    await _clearSessionAndGoToLogin();
                    Utility.showMessage(
                      "You have been logged out successfully.",
                      MessageType.success,
                      null,
                      "OK",
                    );
                  },
                  child: const Text(
                    "Yes, Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getDriverAllocations({int page = 1}) async {
    allocationCurrentPage = page;
    isAllocationsLoading = true;
    update();

    // Format dates if they exist
    String startDate = "";
    String endDate = "";
    if (allocationStartDate != null) {
      startDate = Utility.getFormatedTime(
        allocationStartDate.toString(),
        'yyyy-MM-dd',
      );
    }
    if (allocationEndDate != null) {
      endDate = Utility.getFormatedTime(
        allocationEndDate.toString(),
        'yyyy-MM-dd',
      );
    }

    final response = await homePresenter.fetchDriverAllocations(
      page: page,
      limit: allocationLimit,
      search: allocationSearchText,
      startDate: startDate,
      endDate: endDate,
    );
    isAllocationsLoading = false;
    update();

    if (!response.hasError) {
      // Assuming response.data is string JSON
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        final list = decoded['Data']['data'] as List;
        allocationTotalPages = decoded['Data']['totalPages'] ?? 1;

        if (page == 1) {
          driverAllocationsList = list;
        } else {
          driverAllocationsList.addAll(list);
        }
        update();
      }
    } else {
      // handle error
    }
  }

  /// 🔍 Apply Filters and Fetch Allocations
  void filterAllocations() {
    allocationCurrentPage = 1;
    getDriverAllocations(page: 1);
  }

  /// 📄 Change Allocation Page
  void changeAllocationPage(int page) {
    if (page >= 1 && page <= allocationTotalPages) {
      getDriverAllocations(page: page);
    }
  }

  /// 🗑️ Clear Allocation Filters
  void clearAllocationFilters() {
    allocationSearchText = "";
    selectedTripType = "";
    allocationStartDate = null;
    allocationEndDate = null;
    allocationCurrentPage = 1;
    update();
    getDriverAllocations(page: 1);
  }

  /// 🚗 Fetch Allocation Drivers
  Future<void> getAllocationDrivers(String allocationId, {int page = 1}) async {
    currentAllocationId = allocationId;
    isAllocationDriversLoading = true;
    update();

    final response = await homePresenter.fetchAllocationDrivers(
      id: allocationId,
      page: page,
      limit: 100,
    );

    isAllocationDriversLoading = false;
    update();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        allocationDriversData = decoded['Data'];

        // 🔍 DEBUG: Print ALL keys of the first allocation driver
        final driversList = allocationDriversData?['drivers'] as List?;
        if (driversList != null && driversList.isNotEmpty) {
          final firstDriver = Map<String, dynamic>.from(driversList.first as Map);
          log('🔍 [ALLOC DRIVER DEBUG] ========= FIRST ALLOCATION DRIVER =========');
          log('🔍 [ALLOC DRIVER DEBUG] Keys: ${firstDriver.keys.toList()}');
          firstDriver.forEach((key, value) {
            log('🔍 [ALLOC DRIVER DEBUG]   $key = $value (${value.runtimeType})');
          });
          log('🔍 [ALLOC DRIVER DEBUG] ==========================================');
        }

        update();
      }
    } else {
      Utility.snacBar("Failed to load drivers", Colors.red);
    }
  }

  /// 🚙 Assign Driver to Allocation
  Future<void> assignDriverToAllocation(
    String vendorRequestId,
    String driverId,
  ) async {
    Utility.showLoader();

    final response = await homePresenter.assignDriver(
      vendorRequestId: vendorRequestId,
      driverId: driverId,
    );

    Utility.closeLoader();
    print(response.data);
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      if (decoded['IsSuccess'] == true) {
        // Fetch allocation vehicles and navigate to vehicle allocation screen
        await getAllocationVehicles(vendorRequestId);
        RouteManagement.gotoAllocateVehicleScreen();
      } else {
        Utility.snacBar(decoded['Message'] ?? "Assignment failed", Colors.red);
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  /// 🚗 Fetch Allocation Vehicles
  Future<void> getAllocationVehicles(
    String vendorRequestId, {
    int page = 1,
  }) async {
    isAllocationVehiclesLoading = true;
    update();

    final response = await homePresenter.fetchAllocationVehicles(
      id: vendorRequestId,
      page: page,
      limit: 100,
    );

    isAllocationVehiclesLoading = false;
    update();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        allocationVehiclesData = decoded['Data'];
        update();
      }
    } else {
      Utility.snacBar("Failed to load vehicles", Colors.red);
    }
  }

  /// 🚙 Assign Vehicle (Final step)
  Future<void> assignVehicleRealToAllocation(
    String vendorRequestId,
    String vehicleId,
  ) async {
    Utility.showLoader();

    final response = await homePresenter.assignVehicleReal(
      vendorRequestId: vendorRequestId,
      vehicleId: vehicleId,
    );

    Utility.closeLoader();
    print(response.data);
    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      if (decoded['IsSuccess'] == true) {
        final data = decoded['Data'];

        // Remove the completely assigned request from the local list
        driverAllocationsList.removeWhere(
          (element) => element['_id'] == vendorRequestId,
        );
        update();

        // Show success dialog with assignment details
        Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                Dimens.boxWidth12,
                Expanded(
                  child: Text(
                    decoded['Message'] ??
                        "Driver & Vehicle Assigned Successfully",
                    style: Styles.g1txtColor60016,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Booking ID", data['booking_id'] ?? 'N/A'),
                Dimens.boxHeight8,
                _buildDetailRow("Vehicle ID", data['vehicle_id'] ?? 'N/A'),
                Dimens.boxHeight8,
                _buildDetailRow("Status", data['allocation_status'] ?? 'N/A'),
                Dimens.boxHeight8,
                _buildDetailRow(
                  "Assigned At",
                  data['assigned_at'] != null
                      ? Utility.getFormatedTime(
                          data['assigned_at'],
                          'dd/MM/yyyy hh:mm a',
                        )
                      : 'N/A',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to allocation selection screen (Vehicle Allocate screen)
                  Get.back(); // Go back to Driver Allocate screen
                  getDriverAllocations(); // Refresh the allocation list
                },
                child: Text("OK", style: Styles.appColor60016),
              ),
            ],
          ),
        );
      } else {
        Utility.snacBar(decoded['Message'] ?? "Assignment failed", Colors.red);
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text("$label:", style: Styles.g6txtColor40014),
        ),
        Expanded(child: Text(value, style: Styles.g1txtColor60014)),
      ],
    );
  }

  /// 🚗 Fetch Vehicle Booking History
  Future<void> fetchVehicleHistory({int page = 1}) async {
    if (selectedVehicleId == null) return;

    isVehicleHistoryLoading = true;
    vehicleHistoryCurrentPage = page;
    update();

    final response = await homePresenter.fetchVehicleBookingHistory(
      vehicleId: selectedVehicleId!,
      page: page,
      limit: vehicleHistoryLimit,
      status: vehicleHistoryStatus,
      date: vehicleHistoryDate,
    );

    isVehicleHistoryLoading = false;
    update();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        vehicleHistoryData = decoded['Data'];
        vehicleHistoryTotalDocs = vehicleHistoryData?['bookings']?['totalDocs'] ?? 0;
        update();
      }
    } else {
      Utility.snacBar("Failed to load vehicle history", Colors.red);
    }
  }

  /// 👤 Fetch Driver Booking History
  Future<void> fetchDriverHistory({int page = 1, bool clear = false}) async {
    if (selectedDriver == null) return;

    if (clear) {
      driverHistoryData = null;
      expandedBookings.clear();
    }

    isDriverHistoryLoading = true;
    driverHistoryCurrentPage = page;
    update();

    final response = await homePresenter.fetchDriverBookingHistory(
      driverId: selectedDriver!['_id'],
      page: page,
      limit: driverHistoryLimit,
      status: driverHistoryStatus,
      date: driverHistoryDate,
    );

    isDriverHistoryLoading = false;
    update();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        driverHistoryData = decoded['Data'];
        driverHistoryTotalDocs = driverHistoryData?['bookings']?['totalDocs'] ?? 0;
        update();
      }
    } else {
      Utility.snacBar("Failed to load driver history", Colors.red);
    }
  }

  void toggleBookingExpansion(int index) {
    expandedBookings[index] = !(expandedBookings[index] ?? false);
    update();
  }

  /// 📋 Get Trip Logs
  Future<void> getTripLogs() async {
    Utility.showLoader();

    final statusType = tabs[selectedIndexTripLogs].toLowerCase();

    final response = await homePresenter.getTripLogList(
      statusType: statusType,
      page: tripLogCurrentPage,
      limit: tripLogLimit,
      startDate: tripLogStartDate,
      endDate: tripLogEndDate,
      search: tripLogSearch,
      tripType: tripLogTripType,
    );

    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      if (decoded['IsSuccess'] == true) {
        final data = decoded['Data'];
        if (data != null && data is Map) {
          tripLogList = data['trips'] ?? [];
          tripLogTotal = data['total'] ?? 0;
          tripLogCurrentPage = data['page'] ?? 1;
          tripLogTotalPages = data['totalPages'] ?? 1;
        } else {
          tripLogList = [];
          tripLogTotal = 0;
          tripLogCurrentPage = 1;
          tripLogTotalPages = 1;
        }
        update();
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to fetch trips",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  /// 📋 Change Trip Log Page
  void changeTripLogPage(int page) {
    tripLogCurrentPage = page;
    getTripLogs();
  }

  /// 📋 Get Trip Log Details
  Future<void> getTripLogDetails(String vendorRequestId) async {
    Utility.showLoader();

    final response = await homePresenter.getTripLogDetails(
      vendorRequestId: vendorRequestId,
    );

    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);

      if (decoded['IsSuccess'] == true) {
        selectedTripDetails = decoded['Data'];
        update();
        RouteManagement.gotoTripdetilesScreen();
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to fetch trip details",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  // ----------------------------------------------------------------Ride Reviews------------------------------------------------

  Map<String, dynamic>? reviewDashboardData;
  List<dynamic> reviewList = [];
  Map<String, dynamic>? selectedReviewDetails;
  int reviewCurrentPage = 1;
  int reviewTotalPages = 1;
  int reviewTotal = 0;
  int reviewLimit = 100;
  bool isReviewLoading = false;
  bool isReviewDetailsLoading = false;


  // Filters for Ride Reviews
  String reviewStartDate = "";
  String reviewEndDate = "";
  String reviewRating = "";
  String reviewSearch = "";

  /// ⭐ Fetch Ride Review Dashboard
  Future<void> fetchRideReviewDashboard() async {
    final response = await homePresenter.getRideReviewDashboard();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        reviewDashboardData = decoded['Data'];
        update();
      }
    }
  }

  /// 📝 Fetch Ride Review List
  Future<void> fetchRideReviewList({int page = 1}) async {
    reviewCurrentPage = page;
    isReviewLoading = true;
    update();

    final response = await homePresenter.getRideReviewList(
      page: page,
      limit: reviewLimit,
      startDate: reviewStartDate,
      endDate: reviewEndDate,
      rating: reviewRating,
      search: reviewSearch,
    );

    isReviewLoading = false;

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        final data = decoded['Data'];
        reviewList = data['data'] ?? [];
        reviewTotal = data['totalRecords'] ?? 0;
        reviewTotalPages = data['totalPages'] ?? 1;
        update();
      }
    }
    update();
  }

  /// 📝 Fetch Ride Review Details
  Future<void> fetchRideReviewDetailsController(String reviewId) async {
    isReviewDetailsLoading = true;
    update();
    Utility.showLoader();

    final response = await homePresenter.getRideReviewDetails(reviewId: reviewId);
    log("Ride Review Details Response: ${response.data}");

    Utility.closeLoader();
    isReviewDetailsLoading = false;
    update();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        selectedReviewDetails = decoded['Data'];
        update();
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to fetch review details",
          Colors.red,
        );
      }
    } else {
      Utility.snacBar("Failed to fetch review details", Colors.red);
    }
  }

  /// 📝 Delete Ride Review
  Future<void> deleteRideReviewController(String reviewId) async {
    Utility.showLoader();

    final response = await homePresenter.deleteRideReview(reviewId: reviewId);
    log("Delete Review Response: ${response.data}");

    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true || decoded['isSuccess'] == true) {
        Utility.snacBar(
          decoded['Message'] ?? "Review deleted successfully",
          Colors.green,
        );
        Get.back(); // close details page
        fetchRideReviewDashboard(); // refresh stats
        fetchRideReviewList(); // refresh list
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to delete review",
          Colors.red,
        );
      }
    } else {
      Utility.snacBar("Failed to delete review", Colors.red);
    }
  }


  void changeReviewPage(int page) {
    if (page >= 1 && page <= reviewTotalPages) {
      fetchRideReviewList(page: page);
    }
  }

  // ----------------------------------------------------------------Fine Board------------------------------------------------
  List<dynamic> fineList = [];
  int fineCurrentPage = 1;
  int fineTotalPages = 1;
  int fineTotal = 0;
  int fineLimit = 100;
  bool isFineLoading = false;
  Map<String, dynamic>? selectedFineDetails;

  /// 🚨 Fetch Fine Board List
  Future<void> fetchFineBoardList({int page = 1}) async {
    fineCurrentPage = page;
    isFineLoading = true;
    update();

    final response = await homePresenter.getFineBoardList(
      page: page,
      limit: fineLimit,
    );

    isFineLoading = false;

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        final data = decoded['Data'];
        fineList = data['data'] ?? [];
        fineTotal = data['totalRecords'] ?? 0;
        fineTotalPages = data['totalPages'] ?? 1;
        update();
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to fetch fines",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
    update();
  }

  /// 🚨 Change Fine Page
  void changeFinePage(int page) {
    if (page >= 1 && page <= fineTotalPages) {
      fetchFineBoardList(page: page);
    }
  }

  /// 🚨 Fetch Fine Board Details
  Future<void> fetchFineBoardDetails(String fineId) async {
    Utility.showLoader();

    final response = await homePresenter.getFineBoardDetails(fineId: fineId);

    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        selectedFineDetails = decoded['Data'];
        update();
        RouteManagement.gotoFineboardDetilesScreen(); // Corrected method name
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to fetch fine details",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  /// 🚨 Update Fine Status (Paid/Cancelled)
  Future<void> updateVendorFineStatus(String fineId, String status, {String? cancelReason}) async {
    Utility.showLoader();
    final response = await homePresenter.updateFineStatus(
      fineId: fineId,
      status: status,
      cancelReason: cancelReason,
    );
    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['IsSuccess'] == true) {
        Utility.snacBar(decoded['Message'] ?? "Fine status updated successfully", Colors.green);
        
        // Refresh details locally
        final detailResp = await homePresenter.getFineBoardDetails(fineId: fineId);
        if (!detailResp.hasError) {
          final decodedDetail = jsonDecode(detailResp.data);
          if (decodedDetail['IsSuccess'] == true) {
            selectedFineDetails = decodedDetail['Data'];
          }
        }
        
        // Refresh list
        fetchFineBoardList(page: fineCurrentPage);
        update();
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to update fine status",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "API Call Failed",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("API Call Failed", Colors.red);
      }
    }
  }

  /// 🏙️ Get City Preferences
  Future<void> getCityPreferences({String search = ""}) async {
    // Utility.showLoader();
    final response = await homePresenter.fetchCityPreferences(search: search);
    // Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        cityPreferenceData = decoded['data'] ?? decoded['Data'];
        selectedCities = List<dynamic>.from(
          cityPreferenceData?['selected_cities'] ?? [],
        );
        suggestedCities = List<dynamic>.from(
          cityPreferenceData?['suggested_cities'] ?? [],
        );
        searchResultsCities = List<dynamic>.from(
          cityPreferenceData?['search_results'] ?? [],
        );
        update();
      }
    }
    update();
  }

  /// Toggle City Selection
  void toggleCitySelection(Map<String, dynamic> city, bool isSelected) {
    if (isSelected) {
      if (!selectedCities.any(
        (element) => element['city_name'] == city['city_name'],
      )) {
        selectedCities.add({...city, 'is_selected': true});
      }
      suggestedCities.removeWhere(
        (element) => element['city_name'] == city['city_name'],
      );
    } else {
      selectedCities.removeWhere(
        (element) => element['city_name'] == city['city_name'],
      );
      if (!suggestedCities.any(
        (element) => element['city_name'] == city['city_name'],
      )) {
        suggestedCities.add({...city, 'is_selected': false});
      }
      if (searchResultsCities.any(
        (element) => element['city_name'] == city['city_name'],
      )) {
        // Update selection state in search results if present
        int index = searchResultsCities.indexWhere(
          (element) => element['city_name'] == city['city_name'],
        );
        if (index != -1) {
          searchResultsCities[index]['is_selected'] = false;
        }
      }
    }
    update();
  }

  /// 💾 Save City Preferences
  Future<void> saveCityPreferences() async {
    Utility.showLoader();

    // Prepare body with selected cities
    List<String> selectedCityNames = selectedCities
        .map((e) => e['city_name'].toString())
        .toList();

    // The API seems to accept 'city' and 'owner_city'.
    // Sending the full list for both to be safe and consistent.
    Map<String, dynamic> body = {
      "city": selectedCityNames,
      "owner_city": selectedCityNames,
    };

    final response = await homePresenter.saveCityPreferences(body);

    Utility.closeLoader();

    if (!response.hasError) {
      final decoded = jsonDecode(response.data);
      if (decoded['isSuccess'] == true || decoded['IsSuccess'] == true) {
        Utility.snacBar(
          decoded['Message'] ?? "City preferences updated successfully",
          Colors.green,
        );
        Get.back(); // Close the screen on success
      } else {
        Utility.snacBar(
          decoded['Message'] ?? "Failed to update preferences",
          Colors.red,
        );
      }
    } else {
      try {
        final decoded = jsonDecode(response.data);
        Utility.snacBar(
          decoded['Message'] ?? decoded['message'] ?? "Something went wrong",
          Colors.red,
        );
      } catch (_) {
        Utility.snacBar("Something went wrong", Colors.red);
      }
    }
  }

  // --- Notifications Center Feed ---
  List<dynamic> notificationsList = [];
  bool isNotificationsLoading = false;
  int notificationsPage = 1;
  bool hasMoreNotifications = true;
  final int notificationsLimit = 15;

  Future<void> fetchNotificationsController({bool loadMore = false}) async {
    if (isNotificationsLoading) return;

    if (!loadMore) {
      notificationsPage = 1;
      hasMoreNotifications = true;
      notificationsList.clear();
    } else {
      if (!hasMoreNotifications) return;
      notificationsPage++;
    }

    isNotificationsLoading = true;
    update();

    try {
      final response = await homePresenter.fetchNotificationList(
        page: notificationsPage,
        limit: notificationsLimit,
      );

      if (!response.hasError) {
        final decoded = jsonDecode(response.data);
        if (decoded['IsSuccess'] == true || decoded['isSuccess'] == true) {
          final data = decoded['Data'] ?? decoded['data'] ?? {};
          final list = data['notifications'] ?? data['data'] ?? [];
          
          if (list.length < notificationsLimit) {
            hasMoreNotifications = false;
          }
          notificationsList.addAll(list);
        } else {
          Utility.snacBar(decoded['Message'] ?? "Failed to fetch notifications", Colors.red);
        }
      } else {
        Utility.snacBar("Failed to fetch notifications", Colors.red);
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isNotificationsLoading = false;
      update();
    }
  }
}
