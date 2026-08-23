import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FacilityCardWidget extends StatefulWidget {
  final VoidCallback? onRemove;

  const FacilityCardWidget({super.key, this.onRemove});

  @override
  State<FacilityCardWidget> createState() => _FacilityCardWidgetState();
}

class _FacilityCardWidgetState extends State<FacilityCardWidget> {
  File? logoFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        logoFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---- Remove Button Row ----
          if (widget.onRemove != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),

          /// ---- Logo ----
          Text("Logo *", style: Styles.g1txtColor60014),
          Dimens.boxHeight10,
          GestureDetector(
            onTap: _pickImage,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              dashPattern: const [6, 4],
              strokeWidth: 1.5,
              color: ColorsValue.l2,
              child: Container(
                padding: Dimens.edgeInsets14,
                width: double.infinity,
                alignment: Alignment.center,
                child: logoFile != null
                    ? Image.file(logoFile!, height: Dimens.sixty, fit: BoxFit.cover)
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            spacing: Dimens.four,
                            children: [
                              Icon(Icons.add, color: ColorsValue.g7txtColor),
                              Text("Upload", style: Styles.g7txtColor40014),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Dimens.boxHeight16,

          /// ---- Description ----
          CustomTextFormField(
            filled: true,
            fillColor: ColorsValue.fildColos,
            style: Styles.g7txtColor70014,
            hintText: "Enter Facility Description",

            isBorder: true,
            isCompulsory: true,
            isTitle: true,
            keyboardType: TextInputType.text,
            onChanged: (vaule) {},
            title: "Facility Description",
            hintStyle: Styles.g7txtColor40012,
            titleStyle: Styles.blackColor60014,
          ),
        ],
      ),
    );
  }
}

class FacilityListWidget extends StatefulWidget {
  const FacilityListWidget({super.key});

  @override
  State<FacilityListWidget> createState() => _FacilityListWidgetState();
}

class _FacilityListWidgetState extends State<FacilityListWidget> {
  List<int> items = [1]; // start with one card

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Add new card button
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              setState(() {
                items.add(items.length + 1);
              });
            },
            child: Container(
              width: Dimens.fourtyFive,
              height: Dimens.fourtyFive,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsValue.appColor,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
        Dimens.boxHeight10,

        /// List of cards
        ...items.map((index) {
          return FacilityCardWidget(
            onRemove: items.length == 1
                ? null // don't show delete when only one left
                : () {
                    setState(() {
                      items.remove(index);
                    });
                  },
          );
        }),
      ],
    );
  }
}
