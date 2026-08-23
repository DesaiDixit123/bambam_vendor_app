import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CityPreferenceScreen extends StatelessWidget {
  const CityPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.find<HomeController>().getCityPreferences(search: "");
        });
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            title: "City Preference",
            onTapBack: () => Get.back(),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.getCityPreferences(search: "");
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "city *",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: controller.citySearchControllerPref,
                      decoration: InputDecoration(
                        hintText: "Search City",
                        suffixIcon: controller
                                .citySearchControllerPref.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  controller.citySearchControllerPref.clear();
                                  controller.getCityPreferences(search: "");
                                },
                              )
                            : Icon(Icons.search),
                        fillColor: Colors.blue.shade50.withOpacity(0.3),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.cyan.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.cyan.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.cyan, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        controller.onCitySearchChanged(value);
                      },
                    ),
                    SizedBox(height: 16),
                    if (controller.selectedCities.isNotEmpty) ...[
                      Text(
                        "Selected City",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: controller.selectedCities.map((city) {
                          return _buildCheckbox(
                            label: city['city_name'],
                            value: true,
                            onChanged: (val) {
                              controller.toggleCitySelection(city, false);
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                    ],

                    // Use search results if searching, otherwise suggested
                    if (controller.citySearchControllerPref.text.isNotEmpty &&
                        controller.searchResultsCities.isNotEmpty) ...[
                      Text(
                        "Search Results",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        constraints: BoxConstraints(maxHeight: 400),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children:
                                controller.searchResultsCities.map((city) {
                              bool isSelected = controller.selectedCities.any(
                                (element) =>
                                    element['city_name'] == city['city_name'],
                              );
                              return _buildCheckbox(
                                label: city['city_name'],
                                value:
                                    isSelected, // Should be false if in search results usually, unless we want to show selected ones too
                                onChanged: (val) {
                                  // If it's already selected, we are deselecting?
                                  // Actually, toggle logic handles add/remove.
                                  // If it is in search results, it might already be selected.
                                  controller.toggleCitySelection(
                                    city,
                                    !isSelected,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ] else if (controller.suggestedCities.isNotEmpty) ...[
                      Text(
                        "Suggested Cities",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        constraints: BoxConstraints(maxHeight: 400),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: controller.suggestedCities.map((city) {
                              return _buildCheckbox(
                                label: city['city_name'],
                                value: false,
                                onChanged: (val) {
                                  controller.toggleCitySelection(city, true);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 24),
                    Center(
                      child: CustomButton(
                        onPressed: () {
                          controller.saveCityPreferences();
                        },
                        text: "Save",
                        backgroundColor: ColorsValue.orangeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: ColorsValue.orangeColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
