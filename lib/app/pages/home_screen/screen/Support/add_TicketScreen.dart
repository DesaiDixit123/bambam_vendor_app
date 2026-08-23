import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTicketscreen extends StatelessWidget {
  const AddTicketscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Add new tiket",
          ),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                controller.submitSupportTicket();
              },
              text: "Submit Ticket",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets16,
            physics: BouncingScrollPhysics(),
            children: [
              Text(
                "What is your issue about? *",
                style: Styles.g1txtColor60014,
              ),
              Dimens.boxHeight4,
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: ColorsValue.fildColos,
                ),
                hint: const Text("Select Issue"),
                initialValue: controller.selectedIssue,
                items: controller.supportList
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedIssue = value;
                  controller.update(); // refresh UI
                },
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                textEditingController: controller.ticketBookingIdController,
                title: "Booking ID".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              Text(
                "Attach Screenshot or Photo (Optional)",
                style: Styles.g1txtColor60014,
              ),
              Dimens.boxHeight4,
              InkWell(
                onTap: () {
                  controller.pickTicketAttachment();
                },
                child: Container(
                  height: Dimens.hundredFifty,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsValue.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorsValue.l2),
                  ),
                  child: controller.ticketAttachmentFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            controller.ticketAttachmentFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: ColorsValue.appColor,
                            ),
                            Dimens.boxHeight8,
                            Text(
                              "Tap to upload screenshot",
                              style: Styles.g7txtColor40014,
                            ),
                          ],
                        ),
                ),
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.whiteColor,
                isTitle: true,
                title: "Share Your Thoughts Below!",
                isCompulsory: true,
                maxLines: 6,
                hintText: "Enter Description",
                textEditingController: controller.ticketDescriptionController,
              ),
            ],
          ),
        );
      },
    );
  }
}
