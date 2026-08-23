import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketDetilesscreen extends StatelessWidget {
  const TicketDetilesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final ticket = controller.selectedTicketDetails ?? {};
        return Scaffold(
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Ticket Details",
          ),
          backgroundColor: ColorsValue.l3,
          body: ListView(
            padding: Dimens.edgeInsets16,
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                width: Get.width,
                padding: Dimens.edgeInsets16,
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.sixteen),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ticket ID:", style: Styles.g6txtColor40012),
                            Dimens.boxHeight4,
                            Text(
                              "#${ticket['ticket_no'] ?? ''}",
                              style: Styles.g1txtColor60018.copyWith(
                                color: ColorsValue.appColor,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              "Ticket Status",
                              style: Styles.g6txtColor40012,
                            ),
                            Dimens.boxHeight4,
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
                      ],
                    ),
                    Dimens.boxHeight12,
                    Text("Ticket Category", style: Styles.g6txtColor40014),
                    Dimens.boxHeight2,
                    Text(
                      "${ticket['issue_type'] ?? ''}",
                      style: Styles.g1txtColor60016,
                    ),
                    if (ticket['booking_id'] != null &&
                        ticket['booking_id'].toString().trim().isNotEmpty) ...[
                      Dimens.boxHeight16,
                      Text("Booking ID", style: Styles.g6txtColor40014),
                      Dimens.boxHeight2,
                      Text(
                        "#${ticket['booking_id']}",
                        style: Styles.g1txtColor60014,
                      ),
                    ],
                    Dimens.boxHeight16,
                    Text("Created On", style: Styles.g6txtColor40014),
                    Dimens.boxHeight2,
                    Text(
                      ticket['createAtTimestamp'] != null
                          ? Utility.parseTimeStampToTime(
                              ticket['createAtTimestamp'] as int,
                              'dd/MM/yyyy hh:mm a',
                            )
                          : ticket['createdAt'] != null
                          ? Utility.getFormatedTime(
                              ticket['createdAt'].toString(),
                              'dd/MM/yyyy hh:mm a',
                            )
                          : "N/A",
                      style: Styles.g1txtColor60014,
                    ),
                    Dimens.boxHeight16,
                    Text("Description", style: Styles.g6txtColor40014),
                    Dimens.boxHeight4,
                    Text(
                      ticket['description'] ?? "",
                      style: Styles.g1txtColor60014,
                    ),
                    if (ticket['attachment'] != null &&
                        ticket['attachment'].toString().trim().isNotEmpty &&
                        ticket['attachment'].toString().trim().toLowerCase() !=
                            "null" &&
                        ticket['attachment'].toString().trim().toLowerCase() !=
                            "undefined" &&
                        ticket['attachment'].toString().trim().toLowerCase() !=
                            "none") ...[
                      Dimens.boxHeight16,
                      Text("Attachment", style: Styles.g6txtColor40014),
                      Dimens.boxHeight8,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ticket['attachment'].toString().startsWith('http')
                              ? ticket['attachment'].toString()
                              : "${ApiWrapper.imageUrl}${ticket['attachment'].toString().trim().replaceFirst('uploads/', '')}",
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ColorsValue.l3,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_hasSupportResponse(ticket['support_response'])) ...[
                Dimens.boxHeight16,
                Text("🎧 Support Response", style: Styles.appColor60016),
                Dimens.boxHeight8,
                if (ticket['support_response'] is List &&
                    (ticket['support_response'] as List).isNotEmpty)
                  ...((ticket['support_response'] as List).map((response) {
                    String text = "";
                    if (response is Map) {
                      text =
                          response['message'] ??
                          response['response'] ??
                          response.toString();
                    } else {
                      text = response.toString();
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: Dimens.edgeInsets16,
                      decoration: BoxDecoration(
                        color: ColorsValue.whiteColor,
                        borderRadius: BorderRadius.circular(Dimens.twelve),
                        border: Border.all(color: ColorsValue.l3),
                      ),
                      child: Text(
                        text,
                        style: Styles.g6txtColor40014.copyWith(
                          color: ColorsValue.g1txtColor,
                        ),
                      ),
                    );
                  }))
                else if (ticket['support_response'] is String &&
                    ticket['support_response'].toString().trim().isNotEmpty)
                  Container(
                    width: Get.width,
                    padding: Dimens.edgeInsets16,
                    decoration: BoxDecoration(
                      color: ColorsValue.whiteColor,
                      borderRadius: BorderRadius.circular(Dimens.twelve),
                      border: Border.all(color: ColorsValue.l3),
                    ),
                    child: Text(
                      ticket['support_response'].toString(),
                      style: Styles.g6txtColor40014.copyWith(
                        color: ColorsValue.g1txtColor,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  bool _hasSupportResponse(dynamic response) {
    if (response == null) return false;
    if (response is List) return response.isNotEmpty;
    if (response is String) return response.trim().isNotEmpty;
    return true;
  }
}
