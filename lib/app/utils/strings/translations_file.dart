// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/app.dart';

class TranslationsFile extends Translations {
  /// List of locales used in the application
  static const listOfLocales = <Locale>[Locale('en')];

  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'appName': StringConstants.appName,
      'hi': 'Hi, ',
      'vendor_logain': "Vendor Login",
      'login_usename': "Login Via Username",
      'logain_otp': "Login Via OTP",
      'username': "Username",
      'enter_usename': "Enter User Name",
      'password': "Password",
      'enter_password': "Enter Password",
      'remember_me': "Remember Me",
      'logain': "Login",
      'don_account': "Don't have an account?",
      'register': "Register",
      'mobile_de': "We will send you a One Time Password on this mobile number",
      'mobile_number': "Mobile Number",
      'enter_mobile_number': "Enter Mobile Number",
      'get_otp': "Get OTP",
      'otp_verify': "OTP Verification",
      'enter_otp_dep': "Enter the OTP sent to +00-1234-567-8912",
      'verify_otp': "Verify OTP",
      'vendor_registration': "Vendor Registration",
      'compny_info': "Company Information",
      'next_contact': "Next : Contact Details",
      'setp1to4': "Step 1 Of 4",
      'Copnay_name': "Company Name",
      'Enter_name': "Enter Name",
      'contact_name': "Contact Person Name",
      'uplod_person_image': "Upload Contact Person Photo",
      'choose_file': "Choose File",
      'step2to4': "Step 2 Of 4",
      'contact_details': "Contact Details",
      'next_fleet': "Next : Fleet & Office Details",
      'company_email': "Company Email",
      'enter_email': "Enter Email",
      'phone_number': "Phone Number",
      'enter_phonenumber': "Enter Phone Number",
      'address': "Address",
      'enter_address': "Enter Address",
      'fleet_office': "Fleet & Office Details",
      'step3to4': "Step 3 Of 4",
      'fleet_size': "Fleet Size",
      'document_uplodes': "Next : Document Uploads",
      'office_photo': "Office Photo Upload",
      'visiting_card': "Visiting Card",
      'document_uplods': "Document Uploads",
      'setp4': "Step 4 Of 4",
      'business_license': "Business License",
      'aadhaar_pan': "Aadhaar / PAN Card",
      'gst_cer': "GST Certificate",
      'electricity_bill': "Electricity Bill",
      'review_text1': "We’re Currently Reviewing Your Account.",
      'review_text2':
          "Your account is in under review when it it verified we will notify you.",
      'bam': "Bambam Hub",
      'special_seriveDp':
          "I have understood the requirement and i will assign the driver and vehicle accordingly. In case I fail to deliver this, I agree to pay a penalty of double the special request fee.",
      'is_intersetedDp':
          "I am interested in this trip and will comply with all the terms and conditions of bambam.",
      'is_Advance':
          "I will make the payment as soon as the booking is assigned to me. If I don't pay on time, I understand that I may be penalized up to ₹500.",
      'is_acknowlege':
          "I acknowledge and agree to the above penalties in case of any non-compliance or delays from my side.",
      'driver_allocation_detiles': "Driver Allocation Details",
      'reg1': "BamBam Vendor application form",
      'reg2':
          "Are you a driver with your own car Join BamBam and start earning!",
      'reg3':
          "Have a fleet of cars and drivers? Partner with BamBam to onboard them all!",
      'partner_regisration': "Vendor Registration",
      'company_partner_registration': "Company Vendor Registration",
      'full_name': "Full Name",
      'email': "Email",
      'become_partner': "Become a BamBam Vendor",
      'name_as_per_pan': "Name as per PAN Card",
      'dob_as_per_pan': "Date of Birth according to PAN Card",
    },
  };
}
