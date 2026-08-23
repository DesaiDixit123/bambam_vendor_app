import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/theme/colors_value.dart';
import 'package:bam_bam_vendor/app/theme/dimens.dart';
import 'package:bam_bam_vendor/app/theme/styles.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/home_controller.dart';
import 'package:bam_bam_vendor/domain/services/audio_service.dart';

class RingtoneSettingsScreen extends StatelessWidget {
  const RingtoneSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: Get.find<HomeController>(),
      initState: (state) {
        Get.find<HomeController>().fetchRingtones();
        Get.find<HomeController>().getRingtoneSettings();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          appBar: AppBar(
            backgroundColor: ColorsValue.whiteColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                AudioService.stopRingtone();
                Get.back();
              },
            ),
            title: Text("Ringtone Settings", style: Styles.blackColor60018),
          ),
          body: Padding(
            padding: Dimens.edgeInsets20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle Switch
                Container(
                  padding: Dimens.edgeInsets16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sound Alerts", style: Styles.blackColor60016),
                          Text(
                            "Enable/Disable ride request sounds",
                            style: Styles.blackColor40012.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      Switch(
                        value: controller.isRingtoneEnabled,
                        activeThumbColor: ColorsValue.orangeColor,
                        onChanged: (val) {
                          controller.isRingtoneEnabled = val;
                          controller.update();
                        },
                      ),
                    ],
                  ),
                ),
                Dimens.boxHeight24,
                Text("Select Ringtone", style: Styles.blackColor60016),
                Dimens.boxHeight12,
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.ringtonesList.length + 1, // +1 for Default option
                    separatorBuilder: (_, __) => Dimens.boxHeight12,
                    itemBuilder: (context, index) {
                      final bool isDefaultOption = index == 0;
                      final ringtone = isDefaultOption ? null : controller.ringtonesList[index - 1];
                      
                      final String? rId = isDefaultOption ? null : ringtone!['_id'];
                      final String rName = isDefaultOption ? "Default Ringtone (Alarm Clock)" : (ringtone!['name'] ?? ringtone['title'] ?? "Untitled");
                      String? rUrl = isDefaultOption ? "default" : ringtone!['file_url'];
                      
                      if (rUrl != null && rUrl != "default" && !rUrl.startsWith('http')) {
                        rUrl = "https://apis.bambamcabs.com${rUrl.startsWith('/') ? '' : '/'}$rUrl";
                      }

                      final isSelected = controller.selectedRingtoneId == rId;
                      
                      return InkWell(
                        onTap: () {
                          controller.selectedRingtoneId = rId;
                          controller.selectedRingtoneUrl = rUrl;
                          controller.update();
                        },
                        child: Container(
                          padding: Dimens.edgeInsets12,
                          decoration: BoxDecoration(
                            color: isSelected ? ColorsValue.orangeColor.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? ColorsValue.orangeColor : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? ColorsValue.orangeColor : Colors.grey,
                              ),
                              Dimens.boxWidth12,
                              Expanded(
                                child: Text(
                                  isDefaultOption ? "🎵 $rName" : rName,
                                  style: isSelected ? Styles.blackColor60014 : Styles.blackColor40014,
                                ),
                              ),
                              // Preview Button
                              Obx(() {
                                final bool isThisPlaying = AudioService.isPlaying.value && AudioService.playingUrl.value == (rUrl ?? "default");
                                
                                return IconButton(
                                  icon: Icon(
                                    isThisPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                                    color: ColorsValue.orangeColor,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    if (isThisPlaying) {
                                      AudioService.stopRingtone();
                                    } else {
                                      AudioService.playRingtone(url: rUrl);
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Dimens.boxHeight20,
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.updateRingtoneSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsValue.orangeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Save Changes", style: Styles.whiteColor60016),
                  ),
                ),
                Dimens.boxHeight10,
              ],
            ),
          ),
        );
      },
    );
  }
}
