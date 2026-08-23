import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripcancellationPolicyScreen extends StatelessWidget {
  const TripcancellationPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.appBg,
          appBar: AppBarWidget(
            onTapBack: Get.back,
            title: "Cancellation & Penalty Policy",
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with close button

                    // 1. General Guidelines
                    _sectionTitle("1. General Guidelines"),
                    Dimens.boxHeight8,
                    _bulletPoint(
                      "Vendors are expected to honor all confirmed bookings once accepted.",
                    ),
                    _bulletPoint(
                      "Cancellations disrupt customer trust and will attract penalties as per the rules below.",
                    ),
                    _bulletPoint(
                      "Penalty charges are automatically deducted from the vendor's upcoming payouts.",
                    ),

                    Dimens.boxHeight20,

                    // 2. Cancellation Penalties
                    _sectionTitle("2. Cancellation Penalties"),
                    Dimens.boxHeight8,
                    _penaltyTable(),

                    Dimens.boxHeight20,

                    // 3. Special Cases (No Penalty)
                    _sectionTitle("3. Special Cases (No Penalty)"),
                    Dimens.boxHeight8,
                    _bulletPoint(
                      "Customer Requested Cancellation – If cancellation is initiated by the customer.",
                    ),
                    _bulletPoint(
                      "Force Majeure Events – Natural calamities, strikes, or unavoidable emergencies (must be reported with valid proof).",
                    ),
                    _bulletPoint(
                      "System/Technical Errors – If cancellation occurs due to BamBam platform issues.",
                    ),

                    Dimens.boxHeight20,

                    // 4. Repeated Cancellations
                    _sectionTitle("4. Repeated Cancellations"),
                    Dimens.boxHeight8,
                    _bulletPoint(
                      "More than 3 late cancellations in a month may result in:",
                    ),
                    _subBullet("Temporary account suspension (up to 7 days)."),
                    _subBullet("Reduced booking priority."),
                    _subBullet("Permanent suspension for repeated violations."),

                    Dimens.boxHeight20,

                    // 5. Communication Requirement
                    _sectionTitle("5. Communication Requirement"),
                    Dimens.boxHeight8,
                    _bulletPoint(
                      "Vendors must provide a valid cancellation reason each time.",
                    ),
                    _bulletPoint(
                      "Misuse of “Other Reason” may be flagged for review by BamBam Admin.",
                    ),

                    Dimens.boxHeight20,

                    // 6. Refund & Payout Adjustment
                    _sectionTitle("6. Refund & Payout Adjustment"),
                    Dimens.boxHeight8,
                    _bulletPoint(
                      "Customer refunds (if applicable) will be handled directly by BamBam.",
                    ),
                    _bulletPoint(
                      "Vendor payout will be adjusted after deducting penalties.",
                    ),
                    _bulletPoint(
                      "Deductions will reflect in the Earnings Vault > Penalty Deductions section.",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Section title widget
  Widget _sectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );

  // Bullet point
  Widget _bulletPoint(String text) => Padding(
    padding: EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 14)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  // Sub bullet point (for indented lists)
  Widget _subBullet(String text) => Padding(
    padding: EdgeInsets.only(left: 20, bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 13)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  // Penalty table
  Widget _penaltyTable() {
    final tableData = [
      ["More than 24 hours", "₹0", "Free cancellation"],
      ["6 – 24 hours", "₹100", "Deducted from vendor earnings"],
      ["Less than 6 hours", "₹200", "Higher penalty due to late cancellation"],
      ["After trip start time", "₹250", "Considered a critical violation"],
    ];

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: {
        0: FlexColumnWidth(1.3),
        1: FlexColumnWidth(0.6),
        2: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            _tableCell("Category", isHeader: true),
            _tableCell("Penalty", isHeader: true),
            _tableCell("Description", isHeader: true),
          ],
        ),
        ...tableData.map(
          (row) =>
              TableRow(children: row.map((cell) => _tableCell(cell)).toList()),
        ),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) => Padding(
    padding: EdgeInsets.all(8.0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
        color: isHeader ? Colors.black : Colors.grey.shade700,
      ),
    ),
  );
}
