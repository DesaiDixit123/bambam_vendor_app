import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FineboardHomeScreen extends StatelessWidget {
  const FineboardHomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.find<HomeController>().fetchFineBoardList();
        });
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          body: controller.isFineLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchFineBoardList();
                  },
                  child: ListView(
                    padding: Dimens.edgeInsets20,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Text(
                              "Fine Board Issued",
                              style: Styles.g1txtColor60016,
                            ),
                          ),
                        ],
                      ),
                      Dimens.boxHeight16,
                      if (controller.fineList.isEmpty)
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: Get.height * 0.2),
                            Center(child: Text("No fines found")),
                          ],
                        )
                      else
                        ...controller.fineList.map((fine) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  controller.fetchFineBoardDetails(
                                    fine['_id'] ?? '',
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimens.sixteen,
                                    ),
                                    color: ColorsValue.whiteColor,
                                  ),
                                  child: Padding(
                                    padding: Dimens.edgeInsets16,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          contentPadding: Dimens.edgeInsets0,
                                          leading: CircleAvatar(
                                            // Placeholder or dynamic image if available
                                            backgroundImage: AssetImage(
                                              AssetConstants.usera,
                                            ),
                                            radius: 24,
                                          ),
                                          title: Text(
                                            fine['booking_id'] ?? "",
                                            style: Styles.g1txtColor60016,
                                          ),
                                          subtitle: Text(
                                            fine['driver_name'] ?? "",
                                            style: Styles.g7txtColor40014,
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            child: Text(
                                              fine['penalty_status'] ??
                                                  'Pending',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Dimens.boxHeight16,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Vehicle No",
                                                style: Styles.g6txtColor40012,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                fine['vehicle_number'] ?? "",
                                                style: Styles.g1txtColor60018,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Dimens.boxHeight4,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Penalty Amount",
                                                style: Styles.g6txtColor40012,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "₹${fine['penalty_amount'] ?? '0'}",
                                                style: Styles.g1txtColor60018
                                                    .copyWith(
                                                  color: ColorsValue.redColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Dimens.boxHeight16,
                            ],
                          );
                        }),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
