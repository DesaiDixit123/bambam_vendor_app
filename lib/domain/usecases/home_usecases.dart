import 'dart:io';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:bam_bam_vendor/domain/models/response_model.dart';

import '../entities/enums.dart';

class HomeUsecases {
  HomeUsecases(this.apiWrapper);

  final ApiWrapper apiWrapper;

  Future<ResponseModel> fetchVendorProfile({bool isLoading = true}) {
    return apiWrapper.makeRequest("profile", Request.get, null, isLoading);
  }

  Future<ResponseModel> deleteAccount() {
    return apiWrapper.makeRequest("delete-account", Request.post, {}, true);
  }

  Future<ResponseModel> logout() {
    return apiWrapper.makeRequest("logout", Request.post, {}, true);
  }

  /// 📊 Dashboard Counts
  Future<ResponseModel> fetchDashboardCounts({bool isLoading = true}) {
    return apiWrapper.makeRequest(
      "request/dashboard/counts",
      Request.get,
      null,
      isLoading,
    );
  }

  /// 🚕 Fetch Rides With Pagination
  /// 🚕 FETCH RIDES WITH PAGINATION (PAYLOAD)
  Future<ResponseModel> fetchRidesWithPagination({
    required int page,
    required int limit,
    String search = "",
    String tripType = "",
    String dateFrom = "",
    String dateTo = "",
    bool isLoading = true,
  }) {
    return apiWrapper.makeRequest(
      "request/fetch/withpagination",
      Request.post, // ✅ IMPORTANT
      {
        "page": page,
        "limit": limit,
        "search": search,
        "trip_type": tripType,
        "date_from": dateFrom,
        "date_to": dateTo,
      },
      isLoading,
    );
  }

  /// 👤 Fetch Drivers With Pagination
  Future<ResponseModel> fetchDriversWithPagination({
    required int page,
    required int limit,
    String search = "",
    bool isLoading = true,
  }) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/driver/with-pagination?t=${DateTime.now().millisecondsSinceEpoch}", // FULL URL
      Request.postApiWithoutBaseURL, // 👈 POST request
      {"page": page, "limit": limit, "search": search},
      isLoading,
    );
  }

  /// 👤 Fetch Single Driver Details
  Future<ResponseModel> fetchDriverDetails(String driverId) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/driver/get-one?t=${DateTime.now().millisecondsSinceEpoch}",
      Request.postApiWithoutBaseURL, // 👈 custom base
      {"driver_id": driverId},
      true,
    );
  }

  Future<ResponseModel> updateDriver({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/driver/update",
      Request.multipartPutWithoutBaseURL,
      {"fields": fields, "files": files},
      true,
    );
  }

  /// 🚕 View Vendor Ride Details
  Future<ResponseModel> fetchVendorRideDetails(String vendorRequestId, {String? bookingId}) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/request/view",
      Request.postApiWithoutBaseURL,
      {
        "vendorRequestId": vendorRequestId,
        if (bookingId != null && bookingId.isNotEmpty) "bookingId": bookingId,
        if (bookingId != null && bookingId.isNotEmpty) "booking_id": bookingId,
      },
      true,
    );
  }

  /// 🚕 Confirm Request (Payment + API)
  Future<ResponseModel> confirmRequest(Map<String, dynamic> body) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/request/confirm-request",
      Request.postApiWithoutBaseURL,
      body,
      true,
    );
  }

  /// 🚕 Reject Vendor Request
  Future<ResponseModel> rejectRequest(Map<String, dynamic> body) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/request/reject-request",
      Request.postApiWithoutBaseURL,
      body,
      true,
    );
  }

  /// 🚗 Fetch Vehicle Booking History
  Future<ResponseModel> fetchVehicleBookingHistory({
    required String vehicleId,
    required int page,
    required int limit,
    String search = "",
    String status = "",
    String date = "",
  }) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/vehicle/booking-history",
      Request.postApiWithoutBaseURL,
      {
        "vehicleId": vehicleId,
        "page": page,
        "limit": limit,
        "search": search,
        "status": status,
        "date": date,
      },
      true,
    );
  }

  /// 👤 Fetch Driver Booking History
  Future<ResponseModel> fetchDriverBookingHistory({
    required String driverId,
    required int page,
    required int limit,
    String search = "",
    String status = "",
    String date = "",
  }) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/driver/booking-history",
      Request.postApiWithoutBaseURL,
      {
        "driverId": driverId,
        "page": page,
        "limit": limit,
        "search": search,
        "status": status,
        "date": date,
      },
      true,
    );
  }

  /// 💰 Fetch Vendor Deposit Requirement
  Future<ResponseModel> fetchDepositAmount({bool isLoading = false}) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/request/deposite/amount",
      Request.getApiWithoutBaseURL,
      null,
      isLoading,
    );
  }

  /// 💳 Submit Deposit Payment
  Future<ResponseModel> payDeposit({
    required String razorpayPaymentId,
    bool isLoading = true,
  }) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/request/pay/deposite",
      Request.postApiWithoutBaseURL,
      {"razorpay_payment_id": razorpayPaymentId},
      isLoading,
    );
  }

  /// 🚕 Fetch Driver Allocations
  Future<ResponseModel> fetchDriverAllocations({
    required int page,
    required int limit,
    String search = "",
    String startDate = "",
    String endDate = "",
  }) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/request/allocations/list",
      Request.postApiWithoutBaseURL,
      {
        "page": page,
        "limit": limit,
        "search": search,
        "startDate": startDate,
        "endDate": endDate,
      },
      true,
    );
  }

  /// 🚗 Fetch Allocation Drivers List
  Future<ResponseModel> fetchAllocationDrivers({
    required String id,
    required int page,
    required int limit,
    String search = "",
  }) {
    return apiWrapper.makeRequest(
      "request/allocation/drivers/list",
      Request.post,
      {"id": id, "page": page, "limit": limit, "search": search},
      true,
    );
  }

  /// 🚙 Assign Driver to Allocation
  Future<ResponseModel> assignDriver({
    required String vendorRequestId,
    required String driverId,
  }) {
    return apiWrapper.makeRequest("request/assign/driver", Request.post, {
      "driver_id": driverId,
      "vendor_request_id": vendorRequestId,
    }, true);
  }

  /// 🚗 Fetch Allocation Vehicles List
  Future<ResponseModel> fetchAllocationVehicles({
    required String id,
    required int page,
    required int limit,
    String search = "",
  }) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/request/allocation/vehicles/list",
      Request.postApiWithoutBaseURL,
      {"vendorAllocationId": id, "page": page, "limit": limit, "search": search},
      true,
    );
  }

  /// 🚙 Assign Vehicle to Allocation
  Future<ResponseModel> assignVehicleReal({
    required String vendorRequestId,
    required String vehicleId,
  }) {
    return apiWrapper.makeRequest("request/assign/vehicle", Request.post, {
      "vehicle_id": vehicleId,
      "vendor_request_id": vendorRequestId,
    }, true);
  }

  /// 📋 Get Trip Log List
  Future<ResponseModel> getTripLogList({
    required String statusType,
    required int page,
    required int limit,
    String? startDate,
    String? endDate,
    String? search,
    String? tripType,
  }) {
    return apiWrapper.makeRequest("request/trip/log/list", Request.post, {
      "statusType": statusType,
      "page": page,
      "limit": limit,
      "startDate": startDate ?? "",
      "endDate": endDate ?? "",
      "search": search ?? "",
      "tripType": tripType ?? "",
    }, true);
  }

  /// 📋 Get Trip Log Details
  Future<ResponseModel> getTripLogDetails({required String vendorRequestId}) {
    return apiWrapper.makeRequest("request/trip/log/view", Request.post, {
      "vendor_request_id": vendorRequestId,
    }, true);
  }

  /// ❌ Get Cancellation Reasons
  Future<ResponseModel> getCancellationReasons() {
    return apiWrapper.makeRequest(
      "request/trip/cancel/reasons",
      Request.get,
      null,
      true,
    );
  }

  /// ❌ Cancel Trip
  Future<ResponseModel> cancelTrip({
    required String vendorRequestId,
    required String cancellationReasonId,
    required String cancellationDescription,
  }) {
    return apiWrapper.makeRequest("request/trip/cancel", Request.post, {
      "vendorRequestId": vendorRequestId,
      "cancellation_reason_id": cancellationReasonId,
      "cancellation_description": cancellationDescription,
    }, true);
  }

  /// ⭐ Get Ride Review Dashboard
  Future<ResponseModel> getRideReviewDashboard() {
    return apiWrapper.makeRequest(
      "request/ride-reviews/dashboard",
      Request.get,
      null,
      true,
    );
  }

  /// 📝 Get Ride Review List
  Future<ResponseModel> getRideReviewList({
    required int page,
    required int limit,
    String? startDate,
    String? endDate,
    String? rating,
    String? search,
  }) {
    return apiWrapper.makeRequest("request/ride-reviews/list", Request.post, {
      "page": page,
      "limit": limit,
      "startDate": startDate ?? "",
      "endDate": endDate ?? "",
      "rating": rating ?? "",
      "search": search ?? "",
    }, true);
  }

  /// 🚨 Get Fine Board List
  Future<ResponseModel> getFineBoardList({
    required int page,
    required int limit,
  }) {
    return apiWrapper.makeRequest("request/fine-board/list", Request.post, {
      "page": page,
      "limit": limit,
    }, true);
  }

  /// 🚨 Get Fine Board Details
  Future<ResponseModel> getFineBoardDetails({required String fineId}) {
    return apiWrapper.makeRequest("request/fine-board/view", Request.post, {
      "fine_id": fineId,
    }, true);
  }

  /// 🚨 Update Fine Board Status (Paid/Cancelled)
  Future<ResponseModel> updateFineStatus({
    required String fineId,
    required String status,
    String? cancelReason,
  }) {
    final body = <String, dynamic>{
      "fine_id": fineId,
      "status": status,
    };
    if (status == 'Cancelled' && cancelReason != null && cancelReason.trim().isNotEmpty) {
      body["cancel_reason"] = cancelReason.trim();
    }
    return apiWrapper.makeRequest("request/fine-board/update-status", Request.post, body, true);
  }

  /// 💰 Get Earnings Vault Data
  Future<ResponseModel> getEarningsVaultData() {
    return apiWrapper.makeRequest(
      "request/earnings-vault",
      Request.post,
      {},
      false,
    );
  }

  /// 💳 Create Top-Up Order
  Future<ResponseModel> createTopUpOrder({
    required int amount,
    required String razorpayUserId,
  }) {
    return apiWrapper.makeRequest("wallet/topup/create-order", Request.post, {
      "amount": amount,
      "razorpay_user_id": razorpayUserId,
    }, true);
  }

  /// ✅ Verify Top-Up Payment
  Future<ResponseModel> verifyTopUpPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) {
    return apiWrapper.makeRequest("wallet/topup/verify-payment", Request.post, {
      "razorpay_order_id": razorpayOrderId,
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature,
    }, true);
  }

  /// 🌍 Fetch States (India)
  Future<ResponseModel> fetchStates() {
    return apiWrapper.makeRequest("common/states/IN", Request.get, null, true);
  }

  /// 🌍 Fetch Cities (India)
  Future<ResponseModel> fetchCities() {
    return apiWrapper.makeRequest(
      "common/cities/india",
      Request.get,
      null,
      true,
    );
  }

  /// 🌍 Fetch Languages
  Future<ResponseModel> fetchLanguages() {
    return apiWrapper.makeRequest(
      "common/languages/IN",
      Request.get,
      null,
      true,
    );
  }

  /// 🌍 Fetch Vehicle Types
  Future<ResponseModel> fetchVehicleTypes() {
    return apiWrapper.makeRequest(
      "admin/vehicle_type/withoutpagination",
      Request.post,
      {},
      true,
    );
  }

  /// 👤 Add New Driver (Multipart)
  Future<ResponseModel> addDriver({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/driver/save",
      Request.multipartPostWithoutBaseURL,
      {"fields": fields, "files": files},
      true,
    );
  }

  /// 🚗 Vehicles With Pagination
  Future<ResponseModel> fetchVehiclesWithPagination({
    required int page,
    required int limit,
    String search = "",
    bool isLoading = true,
  }) {
    return apiWrapper.makeRequest("vehicles/withpagination", Request.post, {
      "page": page,
      "limit": limit,
      "search": search,
    }, isLoading);
  }

  /// 🚗 Vehicle Details
  Future<ResponseModel> fetchVehicleDetails(String vehicleId) {
    return apiWrapper.makeRequest(
      "vehicles/details/$vehicleId",
      Request.get,
      null,
      true,
    );
  }

  /// 🚗 Add New Vehicle (Multipart)
  Future<ResponseModel> addVehicle({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return apiWrapper.makeRequest("vehicles/save", Request.multipartPost, {
      "fields": fields,
      "files": files,
    }, true);
  }

  /// 🚗 Fetch Fuel Types
  Future<ResponseModel> fetchFuelTypes() {
    return apiWrapper.makeRequest(
      "admin/fuel_type/withoutpagination",
      Request.post,
      {},
      true,
    );
  }

  /// 🎫 Fetch Support Tickets
  Future<ResponseModel> fetchSupportTickets({
    required int page,
    required int limit,
    String search = "",
    String status = "",
  }) {
    return apiWrapper.makeRequest(
      "support-ticket/list/with/pagination",
      Request.post,
      {"page": page, "limit": limit, "search": search, "status": status},
      true,
    );
  }

  /// 🎫 Create Support Ticket
  Future<ResponseModel> createSupportTicket({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return apiWrapper.makeRequest(
      "support-ticket/save",
      Request.multipartPost,
      {"fields": fields, "files": files},
      true,
    );
  }

  /// 🎫 Fetch Support Ticket Details
  Future<ResponseModel> fetchSupportTicketDetails(String ticketId) {
    return apiWrapper.makeRequest("support-ticket/view", Request.post, {
      "ticket_id": ticketId,
    }, true);
  }

  /// 🏙️ Fetch City Preferences
  Future<ResponseModel> fetchCityPreferences({String search = ""}) {
    return apiWrapper.makeRequest(
      "request/city-preference?search=$search",
      Request.get,
      null,
      true,
    );
  }

  /// 🏙️ Save City Preferences
  Future<ResponseModel> saveCityPreferences(Map<String, dynamic> body) {
    return apiWrapper.makeRequest(
      "request/city-preference/add",
      Request.post,
      body,
      true,
    );
  }

  /// 🎵 Fetch Available Ringtones (Master List)
  Future<ResponseModel> fetchRingtones() {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/master/ringtone/active",
      Request.getApiWithoutBaseURL,
      null,
      true,
    );
  }

  /// 🎵 Fetch Vendor Ringtone Settings
  Future<ResponseModel> fetchRingtoneSettings() {
    return apiWrapper.makeRequest("ringtone/settings", Request.get, null, true);
  }

  /// 🎵 Update Vendor Ringtone Settings
  Future<ResponseModel> updateRingtoneSettings(Map<String, dynamic> body) {
    return apiWrapper.makeRequest("ringtone/settings", Request.post, body, true);
  }

  /// 👤 Toggle Driver Status
  Future<ResponseModel> toggleDriverStatus(String driverId) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/driver/toggle-status",
      Request.postApiWithoutBaseURL,
      {"driver_id": driverId},
      true,
    );
  }

  /// 🚗 Toggle Vehicle Status (On/Off)
  Future<ResponseModel> toggleVehicleStatus(String vehicleId) {
    return apiWrapper.makeRequest(
      "vehicle/toggle-status",
      Request.post,
      {"vehicle_id": vehicleId},
      false,
    );
  }

  /// 🚗 Toggle Vehicle Operational Status (Available, Inactive, Under Maintenance with Reason)
  Future<ResponseModel> toggleVehicleOperationalStatus({
    required String vehicleId,
    required String operationalStatus,
    String? reason,
  }) {
    final Map<String, dynamic> body = {
      "vehicleId": vehicleId,
      "operational_status": operationalStatus,
    };
    if (reason != null && reason.trim().isNotEmpty) {
      body["reason"] = reason.trim();
    }
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/admin/admin-vehicle/operational-status/toggle",
      Request.postApiWithoutBaseURL,
      body,
      false,
    );
  }

  /// 👤 Delete Driver
  Future<ResponseModel> deleteDriver(String driverId) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/driver/delete",
      Request.postApiWithoutBaseURL,
      {"driver_id": driverId},
      true,
    );
  }

  /// 💰 Partner Earnings Withdrawal
  Future<ResponseModel> withdrawEarnings({required int amount}) {
    return apiWrapper.makeRequest(
      "wallet/withdraw",
      Request.post,
      {"amount": amount},
      true,
    );
  }

  /// 💰 Get Withdrawal History
  Future<ResponseModel> getWithdrawalHistory({required int page, required int limit}) {
    return apiWrapper.makeRequest(
      "wallet/withdraw/list",
      Request.post,
      {
        "page": page,
        "limit": limit,
      },
      false,
    );
  }

  /// 🚗 Update Existing Vehicle (Multipart PUT)
  Future<ResponseModel> updateVehicle({
    required String vehicleId,
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return apiWrapper.makeRequest(
      "vehicles/update/$vehicleId",
      Request.multipartPut,
      {"fields": fields, "files": files},
      true,
    );
  }

  /// 📝 Get Ride Review Details
  Future<ResponseModel> getRideReviewDetails({required String reviewId}) {
    return apiWrapper.makeRequest(
      "request/ride-reviews/view",
      Request.post,
      {"reviewId": reviewId},
      true,
    );
  }

  /// 📝 Delete Ride Review
  Future<ResponseModel> deleteRideReview({required String reviewId}) {
    return apiWrapper.makeRequest(
      "request/ride-reviews/delete?reviewId=$reviewId",
      Request.post,
      {},
      true,
    );
  }

  Future<ResponseModel> deleteVehicle(String vehicleId) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/vehicles/delete",
      Request.postApiWithoutBaseURL,
      {"vehicle_id": vehicleId},
      true,
    );
  }

  /// 🔔 Fetch Notification List With Pagination
  Future<ResponseModel> fetchNotificationList({required int page, required int limit}) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/notifications/list/with/pagination",
      Request.postApiWithoutBaseURL,
      {"page": page, "limit": limit},
      false,
    );
  }

  /// 📤 Export APIs
  Future<ResponseModel> exportDriversList({String search = ""}) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/driver/export",
      Request.exportFile,
      {"search": search},
      true,
    );
  }

  Future<ResponseModel> exportDriverBookingHistory({required String driverId, String search = "", String status = "", String date = ""}) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/driver/booking-history/export",
      Request.exportFile,
      {"driverId": driverId, "search": search, "status": status, "date": date},
      true,
    );
  }

  Future<ResponseModel> exportVehiclesList({String search = ""}) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/vehicles/export",
      Request.exportFile,
      {"search": search},
      true,
    );
  }

  Future<ResponseModel> exportVehicleBookingHistory({required String vehicleId, String search = "", String status = "", String date = ""}) {
    return apiWrapper.makeRequest(
      "${ApiWrapper.socketUrl}/vendor/vehicle/booking-history/export",
      Request.exportFile,
      {"vehicleId": vehicleId, "search": search, "status": status, "date": date},
      true,
    );
  }

  Future<ResponseModel> exportTripLogs({String statusType = "upcoming", String? startDate, String? endDate, String? search, String? tripType}) {
    return apiWrapper.makeRequest("request/trip/log/export", Request.exportFile, {
      "statusType": statusType,
      "startDate": startDate ?? "",
      "endDate": endDate ?? "",
      "search": search ?? "",
      "tripType": tripType ?? "",
    }, true);
  }

  Future<ResponseModel> exportSupportTickets({String search = "", String status = ""}) {
    return apiWrapper.makeRequest("support-ticket/export", Request.exportFile, {
      "search": search,
      "status": status,
    }, true);
  }

  Future<ResponseModel> exportFineBoard() {
    return apiWrapper.makeRequest("request/fine-board/export", Request.exportFile, {}, true);
  }

  Future<ResponseModel> exportRideReviews({String? startDate, String? endDate, String? rating, String? search}) {
    return apiWrapper.makeRequest("request/ride-reviews/export", Request.exportFile, {
      "startDate": startDate ?? "",
      "endDate": endDate ?? "",
      "rating": rating ?? "",
      "search": search ?? "",
    }, true);
  }

  Future<ResponseModel> exportEarningsVault() {
    return apiWrapper.makeRequest("request/earnings-vault/export", Request.exportFile, {}, true);
  }
}



