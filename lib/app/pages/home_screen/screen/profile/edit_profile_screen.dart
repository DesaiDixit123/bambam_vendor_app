import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<HomeController>();
    final profile = controller.vendorProfile;
    _nameController.text = profile['owner_name'] ?? '';
    _companyController.text = profile['company_name'] ?? '';
    _emailController.text = profile['company_email'] ?? profile['owner_email'] ?? '';
    _phoneController.text = profile['owner_mobile'] ?? '';
    _addressController.text = profile['address'] ?? '';

    final bank = profile['bank_details'] ?? {};
    _bankNameController.text = bank['bank_name'] ?? '';
    _accountHolderController.text = bank['account_holder_name'] ?? '';
    _accountNumberController.text = bank['account_number'] ?? '';
    _ifscController.text = bank['ifsc_code'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsValue.l3,
      appBar: AppBarWidget(
        onTapBack: () => Get.back(),
        title: "Edit Profile",
      ),
      body: ListView(
        padding: Dimens.edgeInsets20,
        children: [
          _sectionTitle("Basic Information"),
          Dimens.boxHeight10,
          _buildTextField("Owner Name", _nameController),
          Dimens.boxHeight10,
          _buildTextField("Company Name", _companyController),
          Dimens.boxHeight10,
          _buildTextField("Email Address", _emailController),
          Dimens.boxHeight10,
          _buildTextField("Mobile Number", _phoneController, keyboardType: TextInputType.phone),
          Dimens.boxHeight10,
          _buildTextField("Address", _addressController, maxLines: 2),
          Dimens.boxHeight20,
          _sectionTitle("Bank Details"),
          Dimens.boxHeight10,
          _buildTextField("Bank Name", _bankNameController),
          Dimens.boxHeight10,
          _buildTextField("Account Holder Name", _accountHolderController),
          Dimens.boxHeight10,
          _buildTextField("Account Number", _accountNumberController, keyboardType: TextInputType.number),
          Dimens.boxHeight10,
          _buildTextField("IFSC Code", _ifscController),
          Dimens.boxHeight20,
          CustomButtonWidget(
            buttonTitle: "Save Changes",
            onTap: () async {
              Utility.showLoader();
              await Future.delayed(const Duration(seconds: 1));
              Utility.closeLoader();
              Utility.showToast("Profile updated successfully!");
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Styles.appColor60016.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: Styles.g1txtColor60016,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Styles.g7txtColor40014,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
