import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:bam_bam_vendor/domain/services/socket_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/app.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return PopScope(
          canPop: controller.selectedIndex == 0 &&
              !(controller.scaffoldKey.currentState?.isDrawerOpen ?? false),
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (controller.scaffoldKey.currentState?.isDrawerOpen ?? false) {
              controller.scaffoldKey.currentState?.closeDrawer();
              return;
            }
            if (controller.selectedIndex != 0) {
              controller.changeDrawerIndex(0);
            }
          },
          child: Scaffold(
            key: controller.scaffoldKey,
            backgroundColor: ColorsValue.l3,
            appBar: AppBar(
              backgroundColor: ColorsValue.l3,
              elevation: 0,
              leading: Padding(
                padding: Dimens.edgeInsets10,
                child: InkWell(
                  onTap: () {
                    if (controller.selectedIndex != 0) {
                      controller.changeDrawerIndex(0);
                    } else {
                      controller.scaffoldKey.currentState?.openDrawer();
                    }
                  },
                  child: controller.selectedIndex != 0
                      ? const Icon(Icons.arrow_back, color: Colors.black)
                      : SvgPicture.asset(AssetConstants.menu),
                ),
              ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    controller.appBarTextList[controller.selectedIndex],
                    style: Styles.g1txtColor60020,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 2)),
                  builder: (context, snapshot) {
                    bool isConnected =
                        SocketConnection.socket?.connected ?? false;
                    return Icon(
                      Icons.circle,
                      size: 12,
                      color: isConnected ? Colors.green : Colors.red,
                    );
                  },
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_active_outlined,
                        color: ColorsValue.orangeColor,
                        size: 26,
                      ),
                      onPressed: () {
                        RouteManagement.gotoNotificationsScreen();
                      },
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<int>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    offset: const Offset(0, 50),
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == 1) {
                        RouteManagement.gotoProfileHomescreen();
                      } else if (value == 2) {
                        controller.showLogoutDialog(context);
                      } else if (value == 3) {
                        controller.showDeleteAccountDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 20),
                            SizedBox(width: 10),
                            Text("Personal Information"),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Logout", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 3,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Delete Account",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 👇 THIS IS IMPORTANT
                    child: Container(
                      width: 42,
                      height: 42,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorsValue.orangeColor.withOpacity(0.1),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child:
                              controller.profile?['owner_photo'] != null &&
                                  controller.profile!['owner_photo']
                                      .toString()
                                      .isNotEmpty
                              ? Image.network(
                                  "${ApiWrapper.imageUrl}${controller.profile!['owner_photo']}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    size: 28,
                                    color: ColorsValue.orangeColor,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 28,
                                  color: ColorsValue.orangeColor,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ),
              // Row(
              //   children: [
              //     IconButton(
              //       icon: Image.asset(
              //         AssetConstants.person,
              //         height: Dimens.twentyFour,
              //       ),
              //       onPressed: () {
              //         // RouteManagement.gotoNotificationScreen();
              //       },
              //     ),
              //     Dimens.boxWidth8,
              //     IconButton(
              //       icon: Image.asset(
              //         AssetConstants.person,
              //         height: Dimens.twentyFour,
              //       ),
              //       onPressed: () {
              //         //   RouteManagement.gotoNotificationScreen();
              //       },
              //     ),
              //     Dimens.boxWidth8,
              //     IconButton(
              //       icon: Image.asset(
              //         AssetConstants.person,
              //         height: Dimens.twentyFour,
              //       ),
              //       onPressed: () {
              //         // RouteManagement.gotoNotificationScreen();
              //       },
              //     ),
              //     Dimens.boxWidth8,
              //   ],
              // ),
            ],
          ),
          drawer: Container(
            width: Get.width * 0.7, // control drawer width
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Image.asset(
                        'assets/image/vendor_logo_new.png',
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  Divider(color: Color(0xffD8E2EF)),

                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerItem(
                          index: 0,
                          icon: AssetConstants.drower1,
                          title: "Bambam Hub",
                          isActive: controller.selectedIndex == 0,
                          onTap: () {
                            controller.changeDrawerIndex(0);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 1,
                          icon: AssetConstants.drower2,
                          title: "Driver & Vehicle Allocate",
                          isActive: controller.selectedIndex == 1,
                          onTap: () {
                            controller.changeDrawerIndex(1);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 2,
                          icon: AssetConstants.drower4,
                          title: "Trip Logs",
                          isActive: controller.selectedIndex == 2,
                          onTap: () {
                            controller.changeDrawerIndex(2);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 3,
                          icon: AssetConstants.drower6,
                          title: "Ride Reviews",
                          isActive: controller.selectedIndex == 3,
                          onTap: () {
                            controller.changeDrawerIndex(3);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 4,
                          icon: AssetConstants.drower9,
                          title: "Fine Board",
                          isActive: controller.selectedIndex == 4,
                          onTap: () {
                            controller.changeDrawerIndex(4);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 5,
                          icon: AssetConstants.drower11,
                          title: "Earnings Vault",
                          isActive: controller.selectedIndex == 5,
                          onTap: () {
                            controller.changeDrawerIndex(5);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 6,
                          icon: AssetConstants.drower13,
                          title: "Manage Drivers",
                          isActive: controller.selectedIndex == 6,
                          onTap: () {
                            controller.changeDrawerIndex(6);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 7,
                          icon: AssetConstants.drower14,
                          title: "Manage Vehicles",
                          isActive: controller.selectedIndex == 7,
                          onTap: () {
                            controller.changeDrawerIndex(7);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 8,
                          icon: AssetConstants.ic_supoort,
                          title: "Support",
                          isActive: controller.selectedIndex == 8,
                          onTap: () {
                            controller.changeDrawerIndex(8);
                            controller.scaffoldKey.currentState?.closeDrawer();
                          },
                        ),
                        _buildDrawerItem(
                          index: 9,
                          icon: AssetConstants.drower5,
                          title: "City Preference",
                          isActive: false,
                          onTap: () {
                            controller.scaffoldKey.currentState?.closeDrawer();
                            RouteManagement.gotoCityPreferenceScreen();
                          },
                        ),
                        _buildDrawerItem(
                          index: 10,
                          icon: AssetConstants.ic_notification,
                          title: "Ringtone Settings",
                          isActive: false,
                          onTap: () {
                            controller.scaffoldKey.currentState?.closeDrawer();
                            RouteManagement.gotoRingtoneSettingsScreen();
                          },
                        ),
                        _buildDrawerItem(
                          index: 11,
                          icon: AssetConstants.ic_supoort,
                          title: "FAQ",
                          isActive: false,
                          onTap: () {
                            controller.scaffoldKey.currentState?.closeDrawer();
                            RouteManagement.gotoFaqScreen();
                          },
                        ),
                        _buildDrawerItem(
                          index: 12,
                          icon: AssetConstants.ic_logout,
                          title: "Logout",
                          isActive: false,
                          onTap: () {
                            controller.scaffoldKey.currentState?.closeDrawer();
                            controller.showLogoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: controller.allScrrenList[controller.selectedIndex],
        ),
      );
    },
  );
}

  Widget _buildDrawerItem({
    required int index,
    required String icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? ColorsValue.appColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          icon,
          colorFilter: ColorFilter.mode(
            isActive ? ColorsValue.appColor : Colors.grey,
            BlendMode.srcIn,
          ),
          height: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isActive ? ColorsValue.appColor : Colors.grey.shade700,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  asdsdd() {
    return Container(
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      child: Padding(
        padding: Dimens.edgeInsets16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
        ),
      ),
    );
  }
}
