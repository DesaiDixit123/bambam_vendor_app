import 'dart:io';

import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:bam_bam_vendor/domain/entities/enums.dart';
import 'package:bam_bam_vendor/domain/models/response_model.dart';


class AuthUsecases {
  final ApiWrapper apiWrapper;

  AuthUsecases(this.apiWrapper);

  Future<ResponseModel> registerIndividual({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return apiWrapper.makeRequest(
      'indivisual/register',
      Request.multipartPost,
      {
        'fields': fields,
        'files': files,
      },
      true,
     
    );
  }

  Future<ResponseModel> registerCompany({
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    return apiWrapper.makeRequest(
      'company/register',
      Request.multipartPost,
      {
        'fields': fields,
        'files': files,
      },
      true,
     
    );
  }

  Future<ResponseModel> fetchStates() {
    return apiWrapper.makeRequest("common/states/IN", Request.get, null, false);
  }

  Future<ResponseModel> fetchCities() {
    return apiWrapper.makeRequest("common/cities/india", Request.get, null, false);
  }

  Future<ResponseModel> fetchLanguages() {
    return apiWrapper.makeRequest(
      "admin/language/withoutpagination",
      Request.post,
      {},
      false,
    );
  }

  Future<ResponseModel> fetchVehicleTypes() {
    return apiWrapper.makeRequest(
      "admin/vehicle_type/withoutpagination",
      Request.post,
      {},
      false,
    );
  }

  Future<ResponseModel> fetchFuelTypes() {
    return apiWrapper.makeRequest(
      "admin/fuel_type/withoutpagination",
      Request.post,
      {},
      false,
    );
  }

  Future<ResponseModel> verifyPAN({required String panNumber}) {
    return apiWrapper.makeRequest(
      'verify/pan',
      Request.post,
      {'pan_number': panNumber},
      true,
    );
  }

  Future<ResponseModel> verifyGST({required String gstNumber}) {
    return apiWrapper.makeRequest(
      'verify/gst',
      Request.post,
      {'gst_number': gstNumber},
      true,
    );
  }

  Future<ResponseModel> verifyBank({
    required String accountNumber,
    required String ifscCode,
  }) {
    return apiWrapper.makeRequest(
      'verify/bank',
      Request.post,
      {
        'account_number': accountNumber,
        'ifsc_code': ifscCode,
      },
      true,
    );
  }

  Future<ResponseModel> requestAadhaarOtp({required String aadhaarNumber}) {
    return apiWrapper.makeRequest(
      'verify/aadhaar-otp',
      Request.post,
      {'aadhaar_number': aadhaarNumber},
      true,
    );
  }

  Future<ResponseModel> verifyAadhaarOtp({
    required String otp,
    required String refId,
  }) {
    return apiWrapper.makeRequest(
      'verify/aadhaar-verify',
      Request.post,
      {
        'otp': otp,
        'ref_id': refId,
      },
      true,
    );
  }
}

