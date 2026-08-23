import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportHomescreen extends StatelessWidget {
  const SupportHomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          //   appBar: AppBarWidget(onTapBack: () => Get.back(), title: ""),
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                RouteManagement.gotoAddTicketscreen();
              },
              text: " Add Ticket",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.getSupportTickets();
            },
            child: controller.isSupportLoading &&
                    controller.supportTicketsList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : controller.supportTicketsList.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(height: Get.height * 0.4),
                          Center(child: Text("No tickets found")),
                        ],
                      )
                    : ListView.builder(
                        controller: controller.supportScrollController,
                        padding: Dimens.edgeInsets20,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: controller.supportTicketsList.length +
                            (controller.isSupportLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.supportTicketsList.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final ticket = controller.supportTicketsList[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  controller.getSupportTicketDetails(ticket['_id']);
                                },
                                child: Container(
                                  width: Get.width,
                                  padding: Dimens.edgeInsets16,
                                  decoration: BoxDecoration(
                                    color: ColorsValue.whiteColor,
                                    borderRadius: BorderRadius.circular(
                                      Dimens.sixteen,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Ticket ID:",
                                            style: Styles.g6txtColor40012,
                                          ),
                                          Dimens.boxWidth4,
                                          Text(
                                            "#${ticket['ticket_no'] ?? ''}",
                                            style: Styles.g1txtColor60018,
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: Dimens.edgeInsets16_8_16_8,
                                            decoration: BoxDecoration(
                                              color: Color(0xffFFE4E3),
                                              borderRadius: BorderRadius.circular(
                                                Dimens.twelve,
                                              ),
                                            ),
                                            child: Text(
                                              ticket['status'] ?? "Pending",
                                              style: Styles.redColor50014,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Dimens.boxHeight12,
                                      Text(
                                        "${ticket['issue_type'] ?? ''}:",
                                        style: Styles.g1txtColor60016,
                                      ),
                                      Dimens.boxHeight4,
                                      Text(
                                        ticket['description'] ?? "",
                                        style: Styles.g7txtColor40014,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Dimens.boxHeight16,
                            ],
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}
