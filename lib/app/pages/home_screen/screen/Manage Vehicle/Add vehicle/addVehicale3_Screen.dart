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
              onPressed: () {
                if (controller.selectedSourcing == null || controller.selectedSourcing!.isEmpty) {
                  Utility.snacBar("Please select sourcing preference", Colors.red);
                  return;
                }
                if (controller.selectedPetFriendly == null || controller.selectedPetFriendly!.isEmpty) {
                  Utility.snacBar("Please select pet friendly preference", Colors.red);
                  return;
                }
                if (controller.selectedLuggageCarrier == null || controller.selectedLuggageCarrier!.isEmpty) {
                  Utility.snacBar("Please select luggage carrier preference", Colors.red);
                  return;
                }
                if (controller.selectedWorkingRearSeatBelts == null || controller.selectedWorkingRearSeatBelts!.isEmpty) {
                  Utility.snacBar("Please select working rear seat belts preference", Colors.red);
                  return;
                }
                RouteManagement.gotoAddvehicale4Screen();
              },
              text: "Save & Continue",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const BouncingScrollPhysics(),
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
              Row(
                children: [
                  Text("Sourcing", style: Styles.g1txtColor60014),
                  Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
                ],
              ),
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
              Row(
                children: [
                  Text("Pet Friendly", style: Styles.g1txtColor60014),
                  Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
                ],
              ),
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
              Row(
                children: [
                  Text("Luggage Carrier", style: Styles.g1txtColor60014),
                  Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
                ],
              ),
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
              Row(
                children: [
                  Text("Working Rear Seat Belts", style: Styles.g1txtColor60014),
                  Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
                ],
              ),
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
