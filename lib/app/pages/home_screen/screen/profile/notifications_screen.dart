import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Get.find<HomeController>();
      ctrl.fetchNotificationsController(loadMore: false);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        Get.find<HomeController>().fetchNotificationsController(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final notifications = controller.notificationsList;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FC),
          appBar: AppBarWidget(
            onTapBack: Get.back,
            title: "Notifications Feed",
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchNotificationsController(loadMore: false);
            },
            child: notifications.isEmpty && controller.isNotificationsLoading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(controller, notifications),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(height: Get.height * 0.25),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                "No notifications yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "We will notify you here when there are new rides, earnings withdrawals, or updates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(HomeController controller, List<dynamic> list) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length + (controller.hasMoreNotifications ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }

        final item = list[index];
        final title = item['title']?.toString() ?? "Alert";
        final message = item['message']?.toString() ?? "";
        final createdAt = item['createdAt']?.toString() ?? "";
        
        final formattedDate = createdAt.isNotEmpty
            ? Utility.getFormatedTime(createdAt, "dd MMM yyyy - hh:mm a")
            : "Recent";

        return _buildNotificationCard(title, message, formattedDate);
      },
    );
  }

  Widget _buildNotificationCard(String title, String message, String timeStr) {
    final categoryIcon = _getCategoryIcon(title, message);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: categoryIcon.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              categoryIcon.icon,
              color: categoryIcon.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Styles.g1txtColor60016.copyWith(
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: Styles.g7txtColor40012.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: Styles.g7txtColor40012.copyWith(
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _CategoryIcon _getCategoryIcon(String title, String message) {
    final t = title.toLowerCase();
    final m = message.toLowerCase();

    if (t.contains("wallet") || t.contains("withdraw") || t.contains("earning") || m.contains("wallet") || m.contains("payout")) {
      return _CategoryIcon(Icons.account_balance_wallet_rounded, Colors.green);
    } else if (t.contains("driver") || m.contains("driver")) {
      return _CategoryIcon(Icons.person_rounded, Colors.blue);
    } else if (t.contains("vehicle") || t.contains("car") || m.contains("vehicle")) {
      return _CategoryIcon(Icons.local_taxi_rounded, Colors.orange);
    } else if (t.contains("ride") || t.contains("booking") || m.contains("booking") || m.contains("ride")) {
      return _CategoryIcon(Icons.navigation_rounded, Colors.teal);
    } else if (t.contains("fine") || t.contains("penalty") || m.contains("fine")) {
      return _CategoryIcon(Icons.error_outline_rounded, Colors.red);
    } else {
      return _CategoryIcon(Icons.notifications_active_rounded, ColorsValue.appColor);
    }
  }
}

class _CategoryIcon {
  final IconData icon;
  final Color color;
  _CategoryIcon(this.icon, this.color);
}
