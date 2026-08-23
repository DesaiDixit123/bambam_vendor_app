import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RidereviewsHomescreen extends StatelessWidget {
  const RidereviewsHomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctrl = Get.find<HomeController>();
          ctrl.fetchRideReviewDashboard();
          ctrl.fetchRideReviewList();
        });
      },
      builder: (controller) {
        final dashboard = controller.reviewDashboardData ?? {};
        final distribution = (dashboard['rating_distribution'] as List?) ?? [];
        final totalReviews = dashboard['total_reviews'] ?? 0;
        final avgRating =
            double.tryParse(dashboard['average_rating'].toString()) ?? 0.0;

        return Scaffold(
          backgroundColor: Color(0xFFF4F7FC),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchRideReviewDashboard();
              await controller.fetchRideReviewList();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: Dimens.edgeInsets20,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 300,
                      child: Text(
                        "Customer Feedback",
                        style: Styles.g1txtColor60016,
                      ),
                    ),
                  ],
                ),
                Dimens.boxHeight16,
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildReviewStat(
                            "Total Reviews",
                            NumberFormat.compact().format(totalReviews),
                          ),
                          _buildRatingStat("Average Rating", avgRating),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (distribution.isEmpty)
                        Text("No rating distribution data available")
                      else
                        ...distribution.map((item) {
                          final ratingVal =
                              double.tryParse(item['rating'].toString()) ?? 0.0;
                          return _ProgressItem(
                            title: item['name'] ?? "",
                            rating: ratingVal,
                            color: _getColorForRating(ratingVal),
                          );
                        }),
                    ],
                  ),
                ),
                Dimens.boxHeight20,

                // ---------- Review Cards ----------
                if (controller.isReviewLoading)
                  Center(child: CircularProgressIndicator())
                else if (controller.reviewList.isEmpty)
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: Get.height * 0.2),
                      Center(child: Text("No reviews found")),
                    ],
                  )
                else
                  ...controller.reviewList.map((review) {
                    final user = review['userId'] ?? {};
                    final catItem = review['reviewer_category_item'] ?? {};
                    final overallRating =
                        double.tryParse(review['overall_rating'].toString()) ??
                        0.0;

                    return _ReviewCard(
                      reviewId: review['_id'] ?? "",
                      name:
                          review['reviewer_name'] ??
                          user['full_name'] ??
                          "Unknown",
                      bookingId: review['booking_id'] ?? "",
                      reviewText: review['comments'] ?? "",
                      rating: overallRating,
                      ratingLabel: catItem['name'] ?? "",
                      detailRating:
                          double.tryParse(review['overall_rating'].toString()) ??
                          0.0,
                      reviewCategory: review['review_category'] ?? {},
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorForRating(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.blue;
    if (rating >= 2.0) return Colors.amber;
    return Colors.red;
  }

  Widget _buildReviewStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.g1txtColor40012),
        Dimens.boxHeight4,
        Text(
          value,
          style: TextStyle(
            fontSize: Dimens.twentyEight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStat(String title, double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.g1txtColor40012),
        Dimens.boxHeight4,
        Row(
          children: [
            Text(
              rating.toString(),
              style: TextStyle(
                fontSize: Dimens.twentyEight,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.star, color: Colors.amber, size: 22),
            Icon(Icons.star, color: Colors.amber, size: 22),
            Icon(Icons.star, color: Colors.amber, size: 22),
            Icon(Icons.star, color: Colors.amber, size: 22),
            Icon(Icons.star_border, color: Colors.amber, size: 22),
          ],
        ),
      ],
    );
  }
}

// ---------- Progress Item ----------
class _ProgressItem extends StatelessWidget {
  final String title;
  final double rating;
  final Color color;

  const _ProgressItem({
    required this.title,
    required this.rating,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (rating / 5).clamp(0.0, 1.0);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(rating.toString(), style: Styles.g1txtColor60012),
            ],
          ),
          Dimens.boxHeight4,
          LinearProgressIndicator(
            value: progress,
            color: color,
            backgroundColor: Colors.grey.shade200,
            minHeight: 5,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// ---------- Review Card ----------
class _ReviewCard extends StatelessWidget {
  final String reviewId;
  final String name;
  final String bookingId;
  final String reviewText;
  final double rating;
  final String ratingLabel;
  final double detailRating;
  final Map<String, dynamic> reviewCategory;

  const _ReviewCard({
    required this.reviewId,
    required this.name,
    required this.bookingId,
    required this.reviewText,
    required this.rating,
    required this.ratingLabel,
    this.detailRating = 0.0,
    this.reviewCategory = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final homeController = Get.find<HomeController>();
            await homeController.fetchRideReviewDetailsController(reviewId);
            RouteManagement.gotoRidereviewsDetilesscreen();
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(AssetConstants.usera),

                      radius: Dimens.twentyFour,
                    ),
                    Dimens.boxWidth12,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookingId, style: Styles.g1txtColor60016),
                        Text(
                          name,
                          style: Styles.g5txtColor40012.copyWith(
                            fontSize: Dimens.fourteen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Dimens.boxHeight12,
                Text(reviewText, style: Styles.g7txtColor40012),
                Dimens.boxHeight8,
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    Dimens.boxWidth8,
                    Text(
                      ratingLabel,
                      style: Styles.g7txtColor40016.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: Dimens.eighteen,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => _RatingDetailsDialog(
                            overallRating: detailRating,
                            ratingLabel: ratingLabel,
                            reviewCategory: reviewCategory,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: ColorsValue.l1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Dimens.boxHeight16,
      ],
    );
  }
}

class _RatingDetailsDialog extends StatelessWidget {
  final double overallRating;
  final String ratingLabel;
  final Map<String, dynamic> reviewCategory;

  const _RatingDetailsDialog({
    required this.overallRating,
    required this.ratingLabel,
    this.reviewCategory = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Reviews And Rating", style: Styles.g1txtColor60016),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(overallRating.toString(), style: Styles.g1txtColor60020),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.amber, size: 22),
              ],
            ),
            Text(
              ratingLabel,
              style: Styles.g7txtColor40016.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // --- Dynamic Category Items ---
            if (reviewCategory.isEmpty)
              Text("No detailed ratings")
            else
              ...reviewCategory.entries.map((entry) {
                final val = double.tryParse(entry.value.toString()) ?? 0.0;
                return _ProgressItem(
                  title: _formatKey(entry.key),
                  rating: val,
                  color: _getColorForRating(val),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  Color _getColorForRating(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.blue;
    if (rating >= 2.0) return Colors.amber;
    return Colors.red;
  }
}
