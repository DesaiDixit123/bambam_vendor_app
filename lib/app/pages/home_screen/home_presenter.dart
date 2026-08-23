import 'dart:developer';
import 'dart:io';
import 'package:bam_bam_vendor/domain/domain.dart';

class HomePresenter {
  HomePresenter(this.homeUsecases);

  final HomeUsecases homeUsecases;

  /// Vendor Profile API
  Future<ResponseModel> fetchVendorProfile({bool isLoading = true}) {
    return homeUsecases.fetchVendorProfile(isLoading: isLoading);
  }

  Future<ResponseModel> deleteAccount() {
    return homeUsecases.deleteAccount();
  }

  Future<ResponseModel> logout() {
    return homeUsecases.logout();
  }

  Future<ResponseModel> fetchDashboardCounts({bool isLoading = true}) {
    return homeUsecases.fetchDashboardCounts(isLoading: isLoading);
  }

  Future<ResponseModel> fetchRidesWithPagination({
    required int page,
    required int limit,
    String search = "",
    String tripType = "",
    String dateFrom = "",
    String dateTo = "",
    bool isLoading = true,
  }) {
    return homeUsecases.fetchRidesWithPagination(
      page: page,
      limit: limit,
      search: search,
      tripType: tripType,
      dateFrom: dateFrom,
      dateTo: dateTo,
      isLoading: isLoading,
    );
  }

  /// 👤 Drivers With Pagination
  Future<ResponseModel> fetchDriversWithPagination({
    required int page,
    required int limit,
    String search = "",
    bool isLoading = true,
  }) {
    return homeUsecases.fetchDriversWithPagination(
      page: page,
      limit: limit,
      search: search,
      isLoading: isLoading,
    );
  }

  /// 👤 Driver Details
  Future<ResponseModel> fetchDriverDetails(String driverId) {
    return homeUsecases.fetchDriverDetails(driverId);
  }

  Future<ResponseModel> updateDriver({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return homeUsecases.updateDriver(fields: fields, files: files);
  }

  Future<ResponseModel> fetchVendorRideDetails(String vendorRequestId, {String? bookingId}) {
    return homeUsecases.fetchVendorRideDetails(vendorRequestId, bookingId: bookingId);
  }

  Future<ResponseModel> confirmRequest(Map<String, dynamic> body) {
    return homeUsecases.confirmRequest(body);
  }

  Future<ResponseModel> fetchDepositAmount({bool isLoading = false}) {
    return homeUsecases.fetchDepositAmount(isLoading: isLoading);
  }

  Future<ResponseModel> payDeposit({required String razorpayPaymentId}) {
    return homeUsecases.payDeposit(razorpayPaymentId: razorpayPaymentId);
  }

  Future<ResponseModel> rejectRequest(Map<String, dynamic> body) {
    return homeUsecases.rejectRequest(body);
  }

  Future<ResponseModel> fetchVehicleBookingHistory({
    required String vehicleId,
    required int page,
    required int limit,
    String search = "",
    String status = "",
    String date = "",
  }) {
    return homeUsecases.fetchVehicleBookingHistory(
      vehicleId: vehicleId,
      page: page,
      limit: limit,
      search: search,
      status: status,
      date: date,
    );
  }

  Future<ResponseModel> fetchDriverBookingHistory({
    required String driverId,
    required int page,
    required int limit,
    String search = "",
    String status = "",
    String date = "",
  }) {
    return homeUsecases.fetchDriverBookingHistory(
      driverId: driverId,
      page: page,
      limit: limit,
      search: search,
      status: status,
      date: date,
    );
  }

  Future<ResponseModel> fetchDriverAllocations({
    required int page,
    required int limit,
    String search = "",
    String startDate = "",
    String endDate = "",
  }) {
    return homeUsecases.fetchDriverAllocations(
      page: page,
      limit: limit,
      search: search,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<ResponseModel> fetchAllocationDrivers({
    required String id,
    required int page,
    required int limit,
    String search = "",
  }) {
    return homeUsecases.fetchAllocationDrivers(
      id: id,
      page: page,
      limit: limit,
      search: search,
    );
  }

  Future<ResponseModel> assignDriver({
    required String vendorRequestId,
    required String driverId,
  }) {
    return homeUsecases.assignDriver(
      vendorRequestId: vendorRequestId,
      driverId: driverId,
    );
  }

  Future<ResponseModel> fetchAllocationVehicles({
    required String id,
    required int page,
    required int limit,
    String search = "",
  }) {
    return homeUsecases.fetchAllocationVehicles(
      id: id,
      page: page,
      limit: limit,
      search: search,
    );
  }

  Future<ResponseModel> assignVehicleReal({
    required String vendorRequestId,
    required String vehicleId,
  }) {
    return homeUsecases.assignVehicleReal(
      vendorRequestId: vendorRequestId,
      vehicleId: vehicleId,
    );
  }

  Future<ResponseModel> getTripLogList({
    required String statusType,
    required int page,
    required int limit,
    String? startDate,
    String? endDate,
    String? search,
    String? tripType,
  }) {
    return homeUsecases.getTripLogList(
      statusType: statusType,
      page: page,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
      search: search,
      tripType: tripType,
    );
  }

  Future<ResponseModel> getTripLogDetails({required String vendorRequestId}) {
    return homeUsecases.getTripLogDetails(vendorRequestId: vendorRequestId);
  }

  Future<ResponseModel> getCancellationReasons() {
    return homeUsecases.getCancellationReasons();
  }

  Future<ResponseModel> cancelTrip({
    required String vendorRequestId,
    required String cancellationReasonId,
    required String cancellationDescription,
  }) {
    return homeUsecases.cancelTrip(
      vendorRequestId: vendorRequestId,
      cancellationReasonId: cancellationReasonId,
      cancellationDescription: cancellationDescription,
    );
  }

  Future<ResponseModel> getRideReviewDashboard() {
    return homeUsecases.getRideReviewDashboard();
  }

  Future<ResponseModel> getRideReviewList({
    required int page,
    required int limit,
    String? startDate,
    String? endDate,
    String? rating,
    String? search,
  }) {
    return homeUsecases.getRideReviewList(
      page: page,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
      rating: rating,
      search: search,
    );
  }

  Future<ResponseModel> getFineBoardList({
    required int page,
    required int limit,
  }) {
    return homeUsecases.getFineBoardList(page: page, limit: limit);
  }

  Future<ResponseModel> getFineBoardDetails({required String fineId}) async {
    print("[getFineBoardDetails] Calling request/fine-board/view");
    print("[getFineBoardDetails] Request fine_id: $fineId");

    final response = await homeUsecases.getFineBoardDetails(fineId: fineId);

    print("[getFineBoardDetails] Status code: ${response.statusCode}");
    print("[getFineBoardDetails] Has error: ${response.hasError}");
    log("[getFineBoardDetails] Response body: ${response.data}");

    return response;
  }

  Future<ResponseModel> updateFineStatus({
    required String fineId,
    required String status,
    String? cancelReason,
  }) async {
    print("[updateFineStatus] Calling request/fine-board/update-status");
    final response = await homeUsecases.updateFineStatus(
      fineId: fineId,
      status: status,
      cancelReason: cancelReason,
    );
    print("[updateFineStatus] Status code: ${response.statusCode}");
    return response;
  }

  Future<ResponseModel> getEarningsVaultData() {
    return homeUsecases.getEarningsVaultData();
  }

  Future<ResponseModel> createTopUpOrder({
    required int amount,
    required String razorpayUserId,
  }) {
    return homeUsecases.createTopUpOrder(
      amount: amount,
      razorpayUserId: razorpayUserId,
    );
  }

  Future<ResponseModel> verifyTopUpPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) {
    return homeUsecases.verifyTopUpPayment(
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }

  /// 🌍 Fetch States (India)
  Future<ResponseModel> fetchStates() {
    return homeUsecases.fetchStates();
  }

  /// 🌍 Fetch Cities (India)
  Future<ResponseModel> fetchCities() {
    return homeUsecases.fetchCities();
  }

  /// 🌍 Fetch Languages
  Future<ResponseModel> fetchLanguages() {
    return homeUsecases.fetchLanguages();
  }

  /// 🌍 Fetch Vehicle Types
  Future<ResponseModel> fetchVehicleTypes() {
    return homeUsecases.fetchVehicleTypes();
  }

  /// 👤 Add New Driver (Multipart)
  Future<ResponseModel> addDriver({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return homeUsecases.addDriver(fields: fields, files: files);
  }

  /// 🚗 Vehicles With Pagination
  Future<ResponseModel> fetchVehiclesWithPagination({
    required int page,
    required int limit,
    String search = "",
    bool isLoading = true,
  }) {
    return homeUsecases.fetchVehiclesWithPagination(
      page: page,
      limit: limit,
      search: search,
      isLoading: isLoading,
    );
  }

  /// 🚗 Vehicle Details
  Future<ResponseModel> fetchVehicleDetails(String vehicleId) {
    return homeUsecases.fetchVehicleDetails(vehicleId);
  }

  /// 🚗 Add New Vehicle (Multipart)
  Future<ResponseModel> addVehicle({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return homeUsecases.addVehicle(fields: fields, files: files);
  }

  /// 🚗 Fetch Fuel Types
  Future<ResponseModel> fetchFuelTypes() {
    return homeUsecases.fetchFuelTypes();
  }

  /// 🎫 Fetch Support Tickets
  Future<ResponseModel> fetchSupportTickets({
    required int page,
    required int limit,
    String search = "",
    String status = "",
  }) {
    return homeUsecases.fetchSupportTickets(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }

  /// 🎫 Create Support Ticket
  Future<ResponseModel> createSupportTicket({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return homeUsecases.createSupportTicket(fields: fields, files: files);
  }

  /// 🎫 Fetch Support Ticket Details
  Future<ResponseModel> fetchSupportTicketDetails(String ticketId) {
    return homeUsecases.fetchSupportTicketDetails(ticketId);
  }

  /// 🏙️ Fetch City Preferences
  Future<ResponseModel> fetchCityPreferences({String search = ""}) {
    return homeUsecases.fetchCityPreferences(search: search);
  }

  Future<ResponseModel> saveCityPreferences(Map<String, dynamic> body) {
    return homeUsecases.saveCityPreferences(body);
  }

  /// 🎵 Fetch Available Ringtones
  Future<ResponseModel> fetchRingtones() {
    return homeUsecases.fetchRingtones();
  }

  /// 🎵 Fetch Ringtone Settings
  Future<ResponseModel> fetchRingtoneSettings() {
    return homeUsecases.fetchRingtoneSettings();
  }

  /// 🎵 Update Ringtone Settings
  Future<ResponseModel> updateRingtoneSettings(Map<String, dynamic> body) {
    return homeUsecases.updateRingtoneSettings(body);
  }

  /// 👤 Toggle Driver Status
  Future<ResponseModel> toggleDriverStatus(String driverId) {
    return homeUsecases.toggleDriverStatus(driverId);
  }

  /// 🚗 Toggle Vehicle Status
  Future<ResponseModel> toggleVehicleStatus(String vehicleId) {
    return homeUsecases.toggleVehicleStatus(vehicleId);
  }

  /// 🚗 Toggle Vehicle Operational Status
  Future<ResponseModel> toggleVehicleOperationalStatus({
    required String vehicleId,
    required String operationalStatus,
    String? reason,
  }) {
    return homeUsecases.toggleVehicleOperationalStatus(
      vehicleId: vehicleId,
      operationalStatus: operationalStatus,
      reason: reason,
    );
  }

  /// 👤 Delete Driver
  Future<ResponseModel> deleteDriver(String driverId) {
    return homeUsecases.deleteDriver(driverId);
  }

  /// 💰 Partner Earnings Withdrawal
  Future<ResponseModel> withdrawEarnings({required int amount}) {
    return homeUsecases.withdrawEarnings(amount: amount);
  }

  /// 💰 Get Withdrawal History
  Future<ResponseModel> getWithdrawalHistory({required int page, required int limit}) {
    return homeUsecases.getWithdrawalHistory(page: page, limit: limit);
  }

  /// 🚗 Update Existing Vehicle (Multipart PUT)
  Future<ResponseModel> updateVehicle({
    required String vehicleId,
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return homeUsecases.updateVehicle(
      vehicleId: vehicleId,
      fields: fields,
      files: files,
    );
  }

  /// 📝 Get Ride Review Details
  Future<ResponseModel> getRideReviewDetails({required String reviewId}) {
    return homeUsecases.getRideReviewDetails(reviewId: reviewId);
  }

  /// 📝 Delete Ride Review
  Future<ResponseModel> deleteRideReview({required String reviewId}) {
    return homeUsecases.deleteRideReview(reviewId: reviewId);
  }

  Future<ResponseModel> deleteVehicle(String vehicleId) {
    return homeUsecases.deleteVehicle(vehicleId);
  }

  /// 🔔 Fetch Notification List With Pagination
  Future<ResponseModel> fetchNotificationList({required int page, required int limit}) {
    return homeUsecases.fetchNotificationList(page: page, limit: limit);
  }

  /// 📤 Export APIs
  Future<ResponseModel> exportDriversList({String search = ""}) {
    return homeUsecases.exportDriversList(search: search);
  }

  Future<ResponseModel> exportDriverBookingHistory({required String driverId, String search = "", String status = "", String date = ""}) {
    return homeUsecases.exportDriverBookingHistory(driverId: driverId, search: search, status: status, date: date);
  }

  Future<ResponseModel> exportVehiclesList({String search = ""}) {
    return homeUsecases.exportVehiclesList(search: search);
  }

  Future<ResponseModel> exportVehicleBookingHistory({required String vehicleId, String search = "", String status = "", String date = ""}) {
    return homeUsecases.exportVehicleBookingHistory(vehicleId: vehicleId, search: search, status: status, date: date);
  }

  Future<ResponseModel> exportTripLogs({String statusType = "upcoming", String? startDate, String? endDate, String? search, String? tripType}) {
    return homeUsecases.exportTripLogs(statusType: statusType, startDate: startDate, endDate: endDate, search: search, tripType: tripType);
  }

  Future<ResponseModel> exportSupportTickets({String search = "", String status = ""}) {
    return homeUsecases.exportSupportTickets(search: search, status: status);
  }

  Future<ResponseModel> exportFineBoard() {
    return homeUsecases.exportFineBoard();
  }

  Future<ResponseModel> exportRideReviews({String? startDate, String? endDate, String? rating, String? search}) {
    return homeUsecases.exportRideReviews(startDate: startDate, endDate: endDate, rating: rating, search: search);
  }

  Future<ResponseModel> exportEarningsVault() {
    return homeUsecases.exportEarningsVault();
  }
}



