import 'package:bam_bam_vendor/app/theme/theme.dart';
import 'package:flutter/material.dart';

class StepHeaderWidget extends StatelessWidget {
  final String title;
  final String nextTitle;
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  const StepHeaderWidget({
    super.key,
    required this.title,
    required this.nextTitle,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: activeColor.withOpacity(.10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---- Title Row ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Styles.g1txtColor60016),
                Text(
                  "Step $currentStep Of $totalSteps",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: activeColor,
                  ),
                ),
              ],
            ),

            Dimens.boxHeight2,

            /// ---- Next ----
            Text(nextTitle, style: Styles.g7txtColor40012),

            Dimens.boxHeight16,

            /// ---- Step Progress Row ----
            Row(
              children: [
                for (int i = 1; i <= totalSteps; i++) ...[
                  /// Dot
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (i <= currentStep) ? activeColor : null,
                      border: (i <= currentStep)
                          ? null
                          : Border.all(color: inactiveColor),
                    ),
                  ),

                  /// Line (active until currentStep - 1)
                  if (i != totalSteps)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: (i < currentStep)
                              ? activeColor
                              : inactiveColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
