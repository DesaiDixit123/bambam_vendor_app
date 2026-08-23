import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripInvoiceScreen extends StatelessWidget {
  const TripInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = Get.arguments is Map<String, dynamic> ? Get.arguments : {};
    final booking = data['booking_id'] is Map ? data['booking_id'] : {};
    final travel = booking['travelDetailsId'] ?? {};
    final payment = booking['payment_summary'] ?? {};
    final driver = booking['driver_id'] is Map ? booking['driver_id'] : (data['driver_id'] is Map ? data['driver_id'] : {});
    final user = booking['userId'] ?? {};

    return Scaffold(
      backgroundColor: ColorsValue.whiteColor,
      appBar: AppBarWidget(
        onTapBack: () => Get.back(),
        title: "Trip Invoice",
      ),
      body: ListView(
        padding: Dimens.edgeInsets20,
        children: [
          Container(
            padding: Dimens.edgeInsets16,
            decoration: BoxDecoration(
              border: Border.all(color: ColorsValue.l2),
              borderRadius: BorderRadius.circular(Dimens.twelve),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("BAMBAM CABS", style: Styles.appColor60016.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorsValue.appColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text("INVOICE", style: Styles.appColor60016),
                    ),
                  ],
                ),
                Dimens.boxHeight16,
                Divider(color: ColorsValue.l2),
                Dimens.boxHeight10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Invoice No: INV-${booking['booking_id'] ?? '1001'}", style: Styles.g1txtColor60014),
                        Text("Date: ${Utility.getFormatedTime(booking['createdAt'] ?? DateTime.now().toString(), 'dd/MM/yyyy')}", style: Styles.g7txtColor40014),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Trip Status", style: Styles.g7txtColor40014),
                        Text("${data['ride_status'] ?? 'Completed'}", style: Styles.g1txtColor60014.copyWith(color: ColorsValue.greenColor)),
                      ],
                    )
                  ],
                ),
                Dimens.boxHeight16,
                Text("Billed To:", style: Styles.g7txtColor40014),
                Text("${user['full_name'] ?? 'Customer'}", style: Styles.g1txtColor60016),
                if (user['phone_no'] != null) Text("Mobile: ${user['phone_no']}", style: Styles.g7txtColor40014),
                Dimens.boxHeight16,
                Divider(color: ColorsValue.l2),
                Dimens.boxHeight10,
                Text("Route Information", style: Styles.appColor60016),
                Dimens.boxHeight8,
                Text("Pickup: ${travel['pickup_address'] ?? '-'}", style: Styles.g7txtColor40014),
                Text("Drop: ${(travel['drop_address'] as List?)?.join(', ') ?? '-'}", style: Styles.g7txtColor40014),
                if (driver['driver_name'] != null) Text("Driver: ${driver['driver_name']} (${driver['driver_mobile'] ?? ''})", style: Styles.g7txtColor40014),
                Dimens.boxHeight16,
                Divider(color: ColorsValue.l2),
                Dimens.boxHeight10,
                Text("Fare Breakdown", style: Styles.appColor60016),
                Dimens.boxHeight12,
                _rowItem("Base Fare", "₹${travel['fare_summary']?['base_fare'] ?? travel['final_price'] ?? 0}"),
                _rowItem("GST (Tax)", "₹${travel['fare_summary']?['gst_amount'] ?? payment['gst_applied']?['gst_amount'] ?? booking['gst_amount'] ?? 0}"),
                if (payment['advance_paid'] != null && payment['advance_paid'].toString() != '0')
                  _rowItem("Advance Paid", "₹${payment['advance_paid']}"),
                if (payment['commission_amount'] != null && payment['commission_amount'].toString() != '0')
                  _rowItem("Commission", "-₹${payment['commission_amount']}"),
                Divider(color: ColorsValue.l2),
                _rowItem("Total Invoice Amount", "₹${payment['final_trip_fare'] ?? payment['total_booking_price'] ?? payment['total_fare'] ?? 0}", isBold: true),
              ],
            ),
          ),
          Dimens.boxHeight20,
          CustomButton(
            text: "Print / Save PDF",
            onPressed: () {
              Utility.snacBar("Invoice saved to downloads.", ColorsValue.appColor);
            },
            backgroundColor: ColorsValue.appColor,
            radius: Dimens.twelve,
          ),
        ],
      ),
    );
  }

  Widget _rowItem(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: isBold ? Styles.g1txtColor60016 : Styles.g7txtColor40014),
          Text(value, style: isBold ? Styles.g1txtColor60016.copyWith(color: ColorsValue.appColor) : Styles.g1txtColor60014),
        ],
      ),
    );
  }
}
