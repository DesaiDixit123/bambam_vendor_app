import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Addvehicale3Screen extends StatelessWidget {
  const Addvehicale3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Add New Vehicle",
          ),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () => RouteManagement.gotoAddvehicale4Screen(),
              text: "Save & Continue",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              //
              StepHeaderWidget(
                title: "Vehicle Preferences",
                nextTitle: "Next : Include Facilities",
                currentStep: 3,
                totalSteps: 7,
                activeColor: ColorsValue.appColor,
                inactiveColor: ColorsValue.yelloCB,
              ),
              Dimens.boxHeight16,
              Text("Sourcing *", style: Styles.g1txtColor60014),
              Dimens.boxHeight4,
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: ColorsValue.fildColos,
                ),
                hint: const Text("Select"),
                initialValue: controller.selectedSourcing,
                items: ["Rented Vehicle", "Owner Vehicle"]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedSourcing = value;
                  controller.update();
                },
              ),
              Dimens.boxHeight16,
              Text("Pet Friendly *", style: Styles.g1txtColor60014),
              Dimens.boxHeight4,
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: ColorsValue.fildColos,
                ),
                hint: const Text("Select"),
                initialValue: controller.selectedPetFriendly,
                items: ["Yes", "No"]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedPetFriendly = value;
                  controller.update();
                },
              ),
              Dimens.boxHeight16,
              Text("Luggage Carrier *", style: Styles.g1txtColor60014),
              Dimens.boxHeight4,
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: ColorsValue.fildColos,
                ),
                hint: const Text("Select"),
                initialValue: controller.selectedLuggageCarrier,
                items: ["Yes", "No"]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedLuggageCarrier = value;
                  controller.update();
                },
              ),
              Dimens.boxHeight16,
              Text("Working Rear Seat Belts *", style: Styles.g1txtColor60014),
              Dimens.boxHeight4,
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: ColorsValue.fildColos,
                ),
                hint: const Text("Select"),
                initialValue: controller.selectedWorkingRearSeatBelts,
                items: ["Yes", "No"]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedWorkingRearSeatBelts = value;
                  controller.update();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
