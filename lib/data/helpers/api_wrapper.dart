// coverage:ignore-file
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart' as media_type;

import 'package:bam_bam_vendor/app/app.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
// ignore: depend_on_referenced_packages
import 'package:mime/mime.dart';

import 'package:bam_bam_vendor/domain/domain.dart';

class ApiWrapper {
  static const bool isLocalDev = true; // Toggle this for local testing

  final String _baseUrl = isLocalDev 
      ? 'https://apis.bambamcabs.com/vendor/' 
      : 'https://apis.bambamcabs.com/vendor/';

  static String socketUrl = isLocalDev 
      ? 'https://apis.bambamcabs.com' 
      : 'https://apis.bambamcabs.com';

  static String imageUrl = isLocalDev 
      ? 'https://apis.bambamcabs.com/uploads/' 
      : 'https://apis.bambamcabs.com/uploads/';

  static http.Client client = http.Client();

  Future<ResponseModel> makeRequest(
    String url,
    Request request,
    dynamic data,
    bool isLoading, {
    media_type.MediaType? mediaType,
  }) async {
    if (!await Utility.isNetworkAvailable()) {
      return ResponseModel(
        data: '{"message":"No internet connection"}',
        hasError: true,
        statusCode: 1000,
      );
    }

    try {
      if (isLoading) Utility.showLoader();

      ResponseModel response;
      switch (request) {
        case Request.postApiWithoutBaseURL:
          response = await _handlePostWithoutBase(
            url,
            data,
            Utility.commonHeader(),
            false,
          );
          break;

        // ========================== GET ==========================
        case Request.get:
          response = await _handleGet(url, Utility.commonHeader(), false);
          break;

        // ========================== POST JSON ==========================
        case Request.post:
          response = await _handlePost(url, data, Utility.commonHeader(), false);
          break;

        // ========================== MULTIPART POST ==========================
        case Request.multipartPost:
          response = await _handleMultipartPost(
            url,
            data,
            Utility.commonHeader(forMultipart: true),
            false,
          );
          break;

        // ========================== PUT ==========================
        case Request.put:
          response = await _handlePut(url, data, Utility.commonHeader(), false);
          break;

        // ========================== PATCH ==========================
        case Request.patch:
          response = await _handlePatch(url, data, Utility.commonHeader(), false);
          break;

        // ========================== DELETE ==========================
        case Request.delete:
          response = await _handleDelete(url, data, Utility.commonHeader(), false);
          break;

        // ========================== AWS UPLOAD ==========================
        case Request.awsUpload:
          response = await _handleAwsUpload(
            url,
            data,
            Utility.commonHeader(),
            false,
            mediaType,
          );
          break;

        case Request.awsFileUpload:
          response = await _handleAwsFileUpload(
            url,
            data,
            Utility.commonHeader(),
            false,
            mediaType,
          );
          break;

        case Request.getApiWithoutBaseURL:
          response = await _handleGetWithoutBase(url, Utility.commonHeader(), false);
          break;

        case Request.putApiWithoutBaseURL:
          response = await _handlePutWithoutBase(
            url,
            data,
            Utility.commonHeader(),
            false,
          );
          break;

        case Request.multipartPostWithoutBaseURL:
          response = await _handleMultipartPostWithoutBase(
            url,
            data,
            Utility.commonHeader(forMultipart: true),
            false,
          );
          break;

        case Request.multipartPut:
          response = await _handleMultipartPut(
            url,
            data,
            Utility.commonHeader(forMultipart: true),
            false,
          );
          break;

        case Request.multipartPutWithoutBaseURL:
          response = await _handleMultipartPutWithoutBase(
            url,
            data,
            Utility.commonHeader(forMultipart: true),
            false,
          );
          break;

        case Request.exportFile:
          response = await _handleExportFile(
            url,
            data,
            Utility.commonHeader(),
            false,
          );
          break;
      }
      _logOtpApiDetails(
        url: url,
        requestType: request,
        requestData: data,
        headers: Utility.commonHeader(forMultipart: request.toString().contains('multipart')),
        response: response,
      );
      return response;
    } catch (e, stackTrace) {
      log("API request exception: $e");
      final errorResponse = ResponseModel(
        data: '{"message":"${e.toString()}"}',
        hasError: true,
        statusCode: 500,
      );
      _logOtpApiDetails(
        url: url,
        requestType: request,
        requestData: data,
        headers: Utility.commonHeader(forMultipart: request.toString().contains('multipart')),
        response: errorResponse,
        exception: e,
        stackTrace: stackTrace,
      );
      return errorResponse;
    } finally {
      if (isLoading) Utility.closeLoader();
    }
  }

  // ------------------------------------------------------------
  // MULTIPART FORM DATA HANDLER (MAIN PART)
  // ------------------------------------------------------------
  Future<ResponseModel> _handlePostWithoutBase(
    String url,
    dynamic data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    log("API REQUEST URL (Direct): $url");
    if (isLoading) Utility.showLoader();

    final response = await client.post(
      Uri.parse(url), // 👈 FULL URL
      body: jsonEncode(data),
      headers: headers,
    ).timeout(const Duration(seconds: 30));

    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handleMultipartPost(
    String url,
    Map<String, dynamic> data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    final uri = Uri.parse(_baseUrl + url);

    try {
      if (isLoading) Utility.showLoader();

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // TEXT FIELDS
      if (data['fields'] != null) {
        request.fields.addAll(Map<String, String>.from(data['fields']));
      }

      // FILES
      if (data['files'] != null) {
        Map<String, File> files = Map<String, File>.from(data['files']);

        for (final entry in files.entries) {
          final file = entry.value;
          final mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';
          final split = mimeType.split('/');

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              contentType: MediaType(split[0], split[1]),
            ),
          );
        }
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 120),
      );

      final responseBody = await streamed.stream.bytesToString().timeout(
        const Duration(seconds: 30),
      );

      if (isLoading) Utility.closeLoader();

      log("MULTIPART URL: $url");
      log("STATUS: ${streamed.statusCode}");
      log("RESPONSE: $responseBody");

      return ResponseModel(
        data: responseBody,
        hasError: streamed.statusCode >= 400,
        statusCode: streamed.statusCode,
      );
    } on TimeoutException {
      if (isLoading) Utility.closeLoader();
      return ResponseModel(
        data: '{"message":"Request timeout"}',
        hasError: true,
      );
    } catch (e) {
      if (isLoading) Utility.closeLoader();
      log("MULTIPART ERROR: $e");
      return ResponseModel(
        data: '{"message":"Something went wrong"}',
        hasError: true,
      );
    }
  }

  // ------------------------------------------------------------
  // OTHER HANDLERS (UNCHANGED)
  // ------------------------------------------------------------
  Future<ResponseModel> _handleGet(
    String url,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    if (isLoading) Utility.showLoader();
    log("API REQUEST URL: $_baseUrl$url");
    final response = await client.get(
      Uri.parse(_baseUrl + url),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handlePost(
    String url,
    dynamic data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    if (isLoading) Utility.showLoader();
    log("API REQUEST URL: $_baseUrl$url");
    final response = await client.post(
      Uri.parse(_baseUrl + url),
      body: jsonEncode(data),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handleExportFile(
    String url,
    dynamic data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    if (isLoading) Utility.showLoader();
    final targetUrl = url.startsWith('http') ? url : (_baseUrl + url);
    log("EXPORT FILE REQUEST URL: $targetUrl");
    final response = await client.post(
      Uri.parse(targetUrl),
      body: jsonEncode(data ?? {}),
      headers: headers,
    ).timeout(const Duration(seconds: 45));
    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handlePut(
    String url,
    dynamic data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    if (isLoading) Utility.showLoader();
    final response = await client.put(
      Uri.parse(_baseUrl + url),
      body: data,
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handlePatch(
    String url,
    dynamic data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    if (isLoading) Utility.showLoader();
    final response = await client.patch(
      Uri.parse(_baseUrl + url),
      body: jsonEncode(data),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handleDelete(
    String url,
    dynamic data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    if (isLoading) Utility.showLoader();
    final response = await client.delete(
      Uri.parse(_baseUrl + url),
      body: jsonEncode(data),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handleGetWithoutBase(
    String url,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    if (isLoading) Utility.showLoader();
    log("API REQUEST URL (Direct): $url");
    final response = await client.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 30));
    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handlePutWithoutBase(
    String url,
    dynamic data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    if (isLoading) Utility.showLoader();
    final response = await client.put(
      Uri.parse(url),
      body: data,
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    if (isLoading) Utility.closeLoader();
    return returnResponse(response);
  }

  Future<ResponseModel> _handleMultipartPostWithoutBase(
    String url,
    Map<String, dynamic> data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    final uri = Uri.parse(url);

    try {
      if (isLoading) Utility.showLoader();

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // TEXT FIELDS
      if (data['fields'] != null) {
        request.fields.addAll(Map<String, String>.from(data['fields']));
      }

      // FILES
      if (data['files'] != null) {
        Map<String, File> files = Map<String, File>.from(data['files']);

        for (final entry in files.entries) {
          final file = entry.value;
          final mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';
          final split = mimeType.split('/');

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              contentType: MediaType(split[0], split[1]),
            ),
          );
        }
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 120),
      );

      final responseBody = await streamed.stream.bytesToString().timeout(
        const Duration(seconds: 30),
      );

      if (isLoading) Utility.closeLoader();

      log("MULTIPART URL: $url");
      log("STATUS: ${streamed.statusCode}");
      log("RESPONSE: $responseBody");

      return ResponseModel(
        data: responseBody,
        hasError: streamed.statusCode >= 400,
        statusCode: streamed.statusCode,
      );
    } on TimeoutException {
      if (isLoading) Utility.closeLoader();
      return ResponseModel(
        data: '{"message":"Request timeout"}',
        hasError: true,
      );
    } catch (e) {
      if (isLoading) Utility.closeLoader();
      log("MULTIPART ERROR: $e");
      return ResponseModel(
        data: '{"message":"Something went wrong"}',
        hasError: true,
      );
    }
  }

  Future<ResponseModel> _handleMultipartPut(
    String url,
    Map<String, dynamic> data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    final uri = Uri.parse(_baseUrl + url);

    try {
      if (isLoading) Utility.showLoader();

      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll(headers);

      // TEXT FIELDS
      if (data['fields'] != null) {
        request.fields.addAll(Map<String, String>.from(data['fields']));
      }

      // FILES
      if (data['files'] != null) {
        Map<String, File> files = Map<String, File>.from(data['files']);

        for (final entry in files.entries) {
          final file = entry.value;
          final mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';
          final split = mimeType.split('/');

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              contentType: MediaType(split[0], split[1]),
            ),
          );
        }
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 120),
      );

      final responseBody = await streamed.stream.bytesToString().timeout(
        const Duration(seconds: 30),
      );

      if (isLoading) Utility.closeLoader();

      log("MULTIPART PUT URL: $url");
      log("STATUS: ${streamed.statusCode}");
      log("RESPONSE: $responseBody");

      return ResponseModel(
        data: responseBody,
        hasError: streamed.statusCode >= 400,
        statusCode: streamed.statusCode,
      );
    } on TimeoutException {
      if (isLoading) Utility.closeLoader();
      return ResponseModel(
        data: '{"message":"Request timeout"}',
        hasError: true,
      );
    } catch (e) {
      if (isLoading) Utility.closeLoader();
      log("MULTIPART PUT ERROR: $e");
      return ResponseModel(
        data: '{"message":"Something went wrong"}',
        hasError: true,
      );
    }
  }

  Future<ResponseModel> _handleMultipartPutWithoutBase(
    String url,
    Map<String, dynamic> data,
    Map<String, String> headers,
    bool isLoading,
  ) async {
    final uri = Uri.parse(url);

    try {
      if (isLoading) Utility.showLoader();

      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll(headers);

      // TEXT FIELDS
      if (data['fields'] != null) {
        request.fields.addAll(Map<String, String>.from(data['fields']));
      }

      // FILES
      if (data['files'] != null) {
        Map<String, File> files = Map<String, File>.from(data['files']);

        for (final entry in files.entries) {
          final file = entry.value;
          final mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';
          final split = mimeType.split('/');

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              contentType: MediaType(split[0], split[1]),
            ),
          );
        }
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 120),
      );

      final responseBody = await streamed.stream.bytesToString().timeout(
        const Duration(seconds: 30),
      );

      if (isLoading) Utility.closeLoader();

      log("MULTIPART PUT URL: $url");
      log("STATUS: ${streamed.statusCode}");
      log("RESPONSE: $responseBody");

      return ResponseModel(
        data: responseBody,
        hasError: streamed.statusCode >= 400,
        statusCode: streamed.statusCode,
      );
    } on TimeoutException {
      if (isLoading) Utility.closeLoader();
      return ResponseModel(
        data: '{"message":"Request timeout"}',
        hasError: true,
      );
    } catch (e) {
      if (isLoading) Utility.closeLoader();
      log("MULTIPART PUT ERROR: $e");
      return ResponseModel(
        data: '{"message":"Something went wrong"}',
        hasError: true,
      );
    }
  }

  Future<ResponseModel> _handleAwsUpload(
    String url,
    String filePath,
    Map<String, String> headers,
    bool isLoading,
    media_type.MediaType? mediaType,
  ) async {
    if (isLoading) Utility.showLoader();
    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl + url));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: mediaType ?? media_type.MediaType('image', 'jpeg'),
      ),
    );
    request.headers.addAll(headers);
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (isLoading) Utility.closeLoader();
    return ResponseModel(data: body, hasError: false, statusCode: 200);
  }

  Future<ResponseModel> _handleAwsFileUpload(
    String url,
    String filePath,
    Map<String, String> headers,
    bool isLoading,
    media_type.MediaType? mediaType,
  ) async {
    return _handleAwsUpload(url, filePath, headers, isLoading, mediaType);
  }

  // ------------------------------------------------------------
  // RESPONSE PARSER
  // ------------------------------------------------------------
  ResponseModel returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return ResponseModel(
          data: response.body,
          hasError: false,
          statusCode: response.statusCode,
        );
      default:
        return ResponseModel(
          data: response.body,
          hasError: true,
          statusCode: response.statusCode,
        );
    }
  }

  void _logOtpApiDetails({
    required String url,
    required Request requestType,
    required dynamic requestData,
    required Map<String, String> headers,
    ResponseModel? response,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    final lowerUrl = url.toLowerCase();
    final isOtpApi = lowerUrl.contains('send-otp') || lowerUrl.contains('send/otp') || lowerUrl.contains('otp');
    if (!isOtpApi) return;

    final buffer = StringBuffer();
    buffer.writeln('\n\x1B[1;33m${'=' * 80}\x1B[0m');
    buffer.writeln('\x1B[1;37;41m   [!!! OTP API CALL DETECTED !!!]   \x1B[0m');
    buffer.writeln('\x1B[1;36mURL:\x1B[0m $_baseUrl$url');
    buffer.writeln('\x1B[1;36mMethod:\x1B[0m ${requestType.toString().split('.').last}');
    
    // Clean headers for logging
    final cleanHeaders = Map<String, String>.from(headers);
    buffer.writeln('\x1B[1;36mHeaders:\x1B[0m ${jsonEncode(cleanHeaders)}');
    
    // Clean request data
    try {
      buffer.writeln('\x1B[1;36mRequest Body:\x1B[0m ${jsonEncode(requestData)}');
    } catch (_) {
      buffer.writeln('\x1B[1;36mRequest Body (Raw):\x1B[0m $requestData');
    }

    if (response != null) {
      buffer.writeln('\x1B[1;36mResponse Status Code:\x1B[0m ${response.statusCode}');
      buffer.writeln('\x1B[1;36mHas Error:\x1B[0m ${response.hasError}');
      if (response.hasError) {
        buffer.writeln('\x1B[1;37;41mResponse Body (ERROR):\x1B[0m ${response.data}');
      } else {
        buffer.writeln('\x1B[1;32mResponse Body (SUCCESS):\x1B[0m ${response.data}');
      }
    }

    if (exception != null) {
      buffer.writeln('\x1B[1;37;41mException Occurred:\x1B[0m $exception');
      if (stackTrace != null) {
        buffer.writeln('\x1B[1;31mStack Trace:\x1B[0m $stackTrace');
      }
    }
    buffer.writeln('\x1B[1;33m${'=' * 80}\x1B[0m\n');
    
    // ignore: avoid_print
    print(buffer.toString());
    log(buffer.toString());
  }
}
