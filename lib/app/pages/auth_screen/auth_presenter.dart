import 'dart:io';

import 'package:bam_bam_vendor/domain/models/response_model.dart';
import 'package:bam_bam_vendor/domain/usecases/auth_usecases.dart';

class AuthPresenter {
  AuthPresenter(this.authUsecases);

  final AuthUsecases authUsecases;

  Future<ResponseModel> registerIndividual({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return authUsecases.registerIndividual(
      fields: fields,
      files: files,
    );
  }

  Future<ResponseModel> registerCompany({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return authUsecases.registerCompany(
      fields: fields,
      files: files,
    );
  }

  Future<ResponseModel> fetchStates() {
    return authUsecases.fetchStates();
  }

  Future<ResponseModel> fetchCities() {
    return authUsecases.fetchCities();
  }

  Future<ResponseModel> fetchLanguages() {
    return authUsecases.fetchLanguages();
  }

  Future<ResponseModel> fetchVehicleTypes() {
    return authUsecases.fetchVehicleTypes();
  }

  Future<ResponseModel> fetchFuelTypes() {
    return authUsecases.fetchFuelTypes();
  }

  Future<ResponseModel> verifyPAN({required String panNumber}) {
    return authUsecases.verifyPAN(panNumber: panNumber);
  }

  Future<ResponseModel> verifyGST({required String gstNumber}) {
    return authUsecases.verifyGST(gstNumber: gstNumber);
  }

  Future<ResponseModel> verifyBank({
    required String accountNumber,
    required String ifscCode,
  }) {
    return authUsecases.verifyBank(
      accountNumber: accountNumber,
      ifscCode: ifscCode,
    );
  }

  Future<ResponseModel> requestAadhaarOtp({required String aadhaarNumber}) {
    return authUsecases.requestAadhaarOtp(aadhaarNumber: aadhaarNumber);
  }

  Future<ResponseModel> verifyAadhaarOtp({
    required String otp,
    required String refId,
  }) {
    return authUsecases.verifyAadhaarOtp(otp: otp, refId: refId);
  }
}

