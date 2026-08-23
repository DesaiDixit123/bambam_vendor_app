import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ReviewingScreen extends StatelessWidget {
  const ReviewingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          appBar: AppBarWidget(
            onTapBack: () {
              RouteManagement.gotoLogainScreen();
            },
            title: "Back",
          ),
          body: Padding(
            padding: Dimens.edgeInsets20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: SvgPicture.asset(AssetConstants.review_bg)),
                Dimens.boxHeight56,
                Text(
                  "review_text1".tr,
                  style: Styles.g1txtColor60016,
                  textAlign: TextAlign.center,
                ),
                Dimens.boxHeight8,
                Text(
                  "review_text2".tr,
                  style: Styles.g7txtColor70014.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
