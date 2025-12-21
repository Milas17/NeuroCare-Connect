import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

enum FilterCategory { service, doctor, clinic }

class ServiceFilterScreen extends StatefulWidget {
  final List<ServiceData> serviceData;
  final String? currentType;
  final String? currentDoctor;
  final String? currentClinic;

  const ServiceFilterScreen({
    super.key,
    required this.serviceData,
    this.currentType,
    this.currentDoctor,
    this.currentClinic,
  });

  @override
  State<ServiceFilterScreen> createState() => _ServiceFilterScreenState();
}

class _ServiceFilterScreenState extends State<ServiceFilterScreen> {
  FilterCategory? selectedCategory;
  String? selectedType;
  String? selectedDoctorName;
  String? selectedClinicName;

  late List<FilterCategory> filterCategories;

  @override
  void initState() {
    super.initState();

    selectedType = widget.currentType;
    selectedDoctorName = widget.currentDoctor;
    selectedClinicName = widget.currentClinic;

    // Determine available categories based on role
    if (isDoctor()) {
      filterCategories = [FilterCategory.service, FilterCategory.clinic];
    } else if (isReceptionist()) {
      filterCategories = [FilterCategory.service, FilterCategory.doctor];
    } else {
      filterCategories = [FilterCategory.service, FilterCategory.doctor, FilterCategory.clinic];
    }

    selectedCategory = filterCategories.first;
  }

  String getLocalizedCategory(FilterCategory category) {
    switch (category) {
      case FilterCategory.service:
        return locale.lblCategory;
      case FilterCategory.doctor:
        return locale.lblDoctor;
      case FilterCategory.clinic:
        return locale.lblClinic;
    }
  }

  @override
  Widget build(BuildContext context) {
    //List<String> serviceTypes = widget.serviceData.map((e) => e.type?.trim().replaceAll('_', ' ').replaceAll(';', ' ').capitalizeEachWord() ?? '').where((type) => type.isNotEmpty).toSet().toList();
// ServiceFilterScreen ma
    List<String> serviceTypes = widget.serviceData.map((e) => e.type?.trim() ?? '').where((type) => type.isNotEmpty).toSet().toList();

    List<String> doctorNames = widget.serviceData.where((e) => e.doctorList != null).expand((e) => e.doctorList!).map((doc) => doc.displayName?.trim() ?? '').where((name) => name.isNotEmpty).toSet().toList();

    List<String> clinicNames = widget.serviceData
        .expand((e) {
          if (e.clinicList != null && e.clinicList!.isNotEmpty) {
            return e.clinicList!.map((clinic) => clinic.name?.trim() ?? '');
          } else {
            return [e.clinicName?.trim() ?? ''];
          }
        })
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    return Scaffold(
      appBar: appBarWidget(
        locale.lblFilterBy,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Row(
        children: [
          // LEFT CATEGORY LIST
          Container(
            width: 120,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView.builder(
              itemCount: filterCategories.length,
              itemBuilder: (context, index) {
                final category = filterCategories[index];
                final isSelected = selectedCategory == category;
                return AnimatedContainer(
                  duration: 200.milliseconds,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? context.primaryColor.withAlpha(25) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      getLocalizedCategory(category),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                        color: isSelected
                            ? context.primaryColor
                            : appStore.isDarkModeOn
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                    onTap: () => setState(() => selectedCategory = category),
                  ),
                );
              },
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: Theme.of(context).dividerColor).paddingSymmetric(vertical: 16),
          // RIGHT FILTER LIST
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text(
                  '${locale.lblSelect} ${getLocalizedCategory(selectedCategory!)}',
                  style: boldTextStyle(size: 18),
                ).paddingSymmetric(horizontal: 16),
                16.height,
                Expanded(
                  child: Builder(
                    builder: (context) {
                      switch (selectedCategory) {
                        case FilterCategory.service:
                          return _buildFilterList(serviceTypes, selectedType, (val) {
                            setState(() {
                              selectedType = val;
                              selectedDoctorName = null;
                              selectedClinicName = null;
                            });
                          });
                        case FilterCategory.doctor:
                          return _buildFilterList(doctorNames, selectedDoctorName, (val) {
                            setState(() {
                              selectedDoctorName = val;
                              selectedType = null;
                              selectedClinicName = null;
                            });
                          });
                        case FilterCategory.clinic:
                          return _buildFilterList(clinicNames, selectedClinicName, (val) {
                            setState(() {
                              selectedClinicName = val;
                              selectedType = null;
                              selectedDoctorName = null;
                            });
                          });
                        default:
                          return Offstage();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AppButton(
                    text: locale.lblApplyFilter,
                    color: appBarBackgroundColorGlobal,
                    textStyle: boldTextStyle(color: Colors.white),
                    width: context.width(),
                    onTap: () {
                      Navigator.pop(context, {
                        'type': selectedType,
                        'doctor': selectedDoctorName,
                        'clinic': selectedClinicName,
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterList(List<String> items, String? selectedItem, Function(String) onSelect) {
    if (items.isEmpty) {
      return Center(child: Text('No items found', style: secondaryTextStyle()));
    }
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem == item;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? context.primaryColor.withAlpha(13) : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? context.primaryColor : Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Marquee(
                    direction: Axis.horizontal,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? context.primaryColor : Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: context.primaryColor, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
