import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  int _step = 1; // 1: Request OTP, 2: Verify & Reset

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsValue.whiteColor,
      appBar: AppBarWidget(
        onTapBack: () => Get.back(),
        title: "Forgot Password",
      ),
      body: SingleChildScrollView(
        padding: Dimens.edgeInsets20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimens.boxHeight20,
            Text(
              _step == 1 ? "Reset Your Password" : "Enter Verification Code & New Password",
              style: Styles.g1txtColor60018,
            ),
            Dimens.boxHeight8,
            Text(
              _step == 1
                  ? "Enter your registered email address to receive an OTP code."
                  : "An OTP has been sent to ${_emailController.text}. Enter the code and your new password below.",
              style: Styles.g7txtColor40014,
            ),
            Dimens.boxHeight24,
            if (_step == 1) ...[
              CustomTextFormField(
                isTitle: true,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                textEditingController: _emailController,
                title: "Registered Email",
                hintText: "Enter email address",
                keyboardType: TextInputType.emailAddress,
                titleStyle: Styles.blackColor60014,
                hintStyle: Styles.g7txtColor40012,
              ),
              Dimens.boxHeight24,
              CustomButton(
                onPressed: () {
                  if (_emailController.text.trim().isEmpty) {
                    Utility.snacBar("Please enter your registered email.", Colors.red);
                    return;
                  }
                  Utility.snacBar("OTP sent to your email.", ColorsValue.appColor);
                  setState(() {
                    _step = 2;
                  });
                },
                text: "Send Verification Code",
                textStyle: Styles.whiteColorW60016,
                backgroundColor: ColorsValue.appColor,
                radius: Dimens.twelve,
              ),
            ] else ...[
              CustomTextFormField(
                isTitle: true,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                textEditingController: _otpController,
                title: "OTP Code",
                hintText: "Enter 6-digit OTP",
                keyboardType: TextInputType.number,
                maxLength: 6,
                titleStyle: Styles.blackColor60014,
                hintStyle: Styles.g7txtColor40012,
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                isTitle: true,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                obscureText: true,
                textEditingController: _newPasswordController,
                title: "New Password",
                hintText: "Enter new password",
                titleStyle: Styles.blackColor60014,
                hintStyle: Styles.g7txtColor40012,
              ),
              Dimens.boxHeight24,
              CustomButton(
                onPressed: () {
                  if (_otpController.text.trim().length < 4) {
                    Utility.snacBar("Please enter a valid OTP code.", Colors.red);
                    return;
                  }
                  if (_newPasswordController.text.trim().isEmpty) {
                    Utility.snacBar("Please enter a new password.", Colors.red);
                    return;
                  }
                  Utility.snacBar("Password reset successfully. Please login.", Colors.green);
                  Get.back();
                },
                text: "Reset Password",
                textStyle: Styles.whiteColorW60016,
                backgroundColor: ColorsValue.appColor,
                radius: Dimens.twelve,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
