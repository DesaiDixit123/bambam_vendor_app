import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final driver = controller.selectedDriver ?? {};
        final driverName = driver['driver_name'] ?? driver['name'] ?? 'N/A';
        final driverMobile = driver['driver_mobile'] ?? driver['mobile'] ?? 'N/A';
        final dob = driver['dob'] ?? driver['DOB'] ?? 'N/A';
        final languages = driver['languages'] ?? driver['languages_known'] ?? 'English, Hindi';
        final address = driver['address'] ?? driver['city'] ?? 'N/A';
        final vehicleTypes = driver['vehicle_types'] ?? 'N/A';
        
        final dlNumber = driver['DL_number'] ?? 'N/A';
        final dlValidity = driver['DL_validity'] ?? driver['DL_expiry'] ?? 'N/A';
        final dlIssueDate = driver['DL_issue_date'] ?? 'N/A';

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Driver History",
          ),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  onPressed: () {
                    Get.back();
                  },
                  text: "Select",
                  backgroundColor: ColorsValue.appColor,
                  widthBtn: Dimens.twoHundred * .8,
                ),
              ],
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,
                  child: Column(
                    children: [
                      Center(
                        child: ClipOval(
                          child: () {
                            final photoPath = driver['driver_photo'];
                            if (photoPath != null && photoPath.toString().trim().isNotEmpty) {
                              final String trimmed = photoPath.toString().trim();
                              String resolvedUrl = trimmed;
                              if (!resolvedUrl.startsWith("http://") && !resolvedUrl.startsWith("https://")) {
                                String cleanPath = resolvedUrl;
                                if (cleanPath.startsWith("uploads/")) {
                                  cleanPath = cleanPath.substring("uploads/".length);
                                } else if (cleanPath.startsWith("/uploads/")) {
                                  cleanPath = cleanPath.substring("/uploads/".length);
                                }
                                resolvedUrl = "${ApiWrapper.imageUrl}$cleanPath";
                              }
                              
                              return Image.network(
                                resolvedUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) {
                                  final fallbackUrl = trimmed;
                                  final s3Url = fallbackUrl.startsWith("http")
                                      ? fallbackUrl
                                      : "https://bambams3.s3.ap-south-1.amazonaws.com/${fallbackUrl.replaceFirst("uploads/", "")}";
                                  return Image.network(
                                    s3Url,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      AssetConstants.person,
                                      height: 100,
                                      width: 100,
                                    ),
                                  );
                                },
                              );
                            }
                            return Image.asset(
                              AssetConstants.person,
                              height: 100,
                              width: 100,
                            );
                          }(),
                        ),
                      ),
                      Dimens.boxHeight10,
                      Divider(color: ColorsValue.l3),
                      Dimens.boxHeight8,
                      profileshowrow(
                        icons: AssetConstants.persons,
                        name: driverName,
                      ),
                      profileshowrow(
                        icons: AssetConstants.mobile,
                        name: driverMobile,
                      ),
                      profileshowrow(
                        icons: AssetConstants.bod,
                        name: dob != 'N/A'
                            ? Utility.getFormatedTime(dob.toString(), 'dd/MM/yyyy')
                            : 'N/A',
                      ),
                      profileshowrow(
                        icons: AssetConstants.luguse,
                        name: languages,
                      ),
                      profileshowrow(
                        icons: AssetConstants.location,
                        name: address,
                      ),
                      profileshowrow(
                        icons: AssetConstants.settinging,
                        name: vehicleTypes,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Driving License Details",
                        style: Styles.appColor60020,
                      ),
                      Dimens.boxHeight16,
                      Text("Driving License", style: Styles.g1txtColor60012),
                      Dimens.boxHeight4,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: () {
                          final dlPhotoPath = driver['DL_photo'] ?? driver['dl_photo'];
                          if (dlPhotoPath != null && dlPhotoPath.toString().trim().isNotEmpty) {
                            final String trimmed = dlPhotoPath.toString().trim();
                            String resolvedUrl = trimmed;
                            if (!resolvedUrl.startsWith("http://") && !resolvedUrl.startsWith("https://")) {
                              String cleanPath = resolvedUrl;
                              if (cleanPath.startsWith("uploads/")) {
                                cleanPath = cleanPath.substring("uploads/".length);
                              } else if (cleanPath.startsWith("/uploads/")) {
                                cleanPath = cleanPath.substring("/uploads/".length);
                              }
                              resolvedUrl = "${ApiWrapper.imageUrl}$cleanPath";
                            }
                            
                            return Image.network(
                              resolvedUrl,
                              height: Dimens.hundredFifty,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) {
                                final fallbackUrl = trimmed;
                                final s3Url = fallbackUrl.startsWith("http")
                                    ? fallbackUrl
                                    : "https://bambams3.s3.ap-south-1.amazonaws.com/${fallbackUrl.replaceFirst("uploads/", "")}";
                                return Image.network(
                                  s3Url,
                                  height: Dimens.hundredFifty,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    AssetConstants.driving_licence_Imge,
                                    height: Dimens.hundredFifty,
                                  ),
                                );
                              },
                            );
                          }
                          return Image.asset(
                            AssetConstants.driving_licence_Imge,
                            height: Dimens.hundredFifty,
                          );
                        }(),
                      ),
                      Dimens.boxHeight12,
                      Text("DL Number  ", style: Styles.g7txtColor40014),
                      Dimens.boxHeight2,
                      Text(dlNumber, style: Styles.g1txtColor60016),
                      Divider(color: ColorsValue.l3),
                      Text("DL Validity", style: Styles.g7txtColor40014),
                      Dimens.boxHeight2,
                      Text(
                        dlValidity != 'N/A'
                            ? Utility.getFormatedTime(dlValidity.toString(), 'dd/MM/yyyy')
                            : 'N/A',
                        style: Styles.g1txtColor60016,
                      ),
                      Divider(color: ColorsValue.l3),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "DL Issue Date",
                                  style: Styles.g7txtColor40014,
                                ),
                                Dimens.boxHeight2,
                                Text(
                                  dlIssueDate != 'N/A'
                                      ? Utility.getFormatedTime(dlIssueDate.toString(), 'dd/MM/yyyy')
                                      : 'N/A',
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget profileshowrow({
    String? icons,
    String? name,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icons != null) SvgPicture.asset(icons),
            SizedBox(width: Dimens.eight),
            Expanded(
              child: Text(
                name ?? "",
                style: Styles.g7txtColor40016.copyWith(
                  color: ColorsValue.g6txtColor,
                ),
              ),
            ),
          ],
        ),
        Dimens.boxHeight8,
        if (showDivider) ...[Divider(color: ColorsValue.l2), Dimens.boxHeight8],
      ],
    );
  }
}
