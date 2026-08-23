import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  AppBarWidget({
    super.key,
    required this.onTapBack,
    required this.title,
    this.isVisible = true,
    this.isCenter = false,
    this.actions,
  });

  void Function()? onTapBack;
  String title;
  bool isVisible;
  bool isCenter;
  List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorsValue.l3,
      centerTitle: isCenter ? true : false,
      automaticallyImplyLeading: false,
      leadingWidth: isVisible ? Dimens.eighty * .95 : Dimens.twenty,
      leading: isVisible
          ? IconButton(
              onPressed: onTapBack,
              icon: Icon(Icons.arrow_back_ios_new_rounded),
            )
          : null,
      titleSpacing: Dimens.zero,
      title: Text(title, style: Styles.g1txtColor60018.copyWith()),
      actions: actions,
    );
  }

  static final _appBar = AppBar();

  @override
  Size get preferredSize => AppBarWidget._appBar.preferredSize;
}
