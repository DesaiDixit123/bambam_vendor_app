import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionHistoryscreen extends StatelessWidget {
  const TransactionHistoryscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.find<HomeController>().fetchEarningsVaultData();
        });
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.appBg,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Transaction History",
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchEarningsVaultData();
            },
            child: ListView(
              padding: Dimens.edgeInsets20,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                if (controller.isEarningsLoading)
                  const Center(child: CircularProgressIndicator())
                else if (controller.earningsData == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        "No transaction history found",
                        style: Styles.g7txtColor40014,
                      ),
                    ),
                  )
                else
                  ...(() {
                    final rawList = controller.earningsData!['wallet_history'] as List? ?? [];
                    final filteredList = rawList.where((item) {
                      if (item == null || item is! Map) return false;
                      final type = (item['type'] ?? '').toString().toLowerCase();
                      final status = (item['status'] ?? '').toString().toLowerCase();
                      if (type == 'credit') {
                        return status == 'paid';
                      } else if (type == 'debit') {
                        return status == 'success';
                      }
                      return false;
                    }).toList();

                    if (filteredList.isEmpty) {
                      return [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Text(
                              "No transaction history found",
                              style: Styles.g7txtColor40014,
                            ),
                          ),
                        )
                      ];
                    }

                    return filteredList.map((item) {
                      final bool isCredit =
                          (item['type'] ?? '').toString().toLowerCase() ==
                          'credit';
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: Dimens.edgeInsets0,
                            leading: CircleAvatar(
                              backgroundColor: (isCredit ? ColorsValue.greenColor : ColorsValue.redColor).withOpacity(0.1),
                              child: Icon(
                                isCredit ? Icons.add : Icons.remove,
                                color: isCredit ? ColorsValue.greenColor : ColorsValue.redColor,
                              ),
                            ),
                            title: Text(
                              "${item['description'] ?? 'Transaction'}",
                              style: Styles.g1txtColor60014,
                              maxLines: 2,
                            ),
                            subtitle: Text(
                              Utility.getFormatedTime(
                                item['createdAt'] ?? DateTime.now().toString(),
                                "dd-MM-yyyy HH:mm",
                              ),
                              style: Styles.g7txtColor40012,
                            ),
                            trailing: Text(
                              "${isCredit ? '+' : '-'} ₹${item['amount'] ?? 0}",
                              style: Styles.g1txtColor60016.copyWith(
                                color: isCredit ? ColorsValue.greenColor : ColorsValue.redColor,
                              ),
                            ),
                          ),
                          Dimens.boxHeight10,
                        ],
                      );
                    }).toList();
                  }()),
              ],
            ),
          ),
        );
      },
    );
  }
}
