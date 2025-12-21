import 'package:flutter/material.dart';
import 'package:kivicare_flutter/model/woo_commerce/common_models.dart';
import 'package:kivicare_flutter/utils/app_widgets.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class SortFilterBottomSheet extends StatefulWidget {
  final Function(FilterModel? filter, RangeValues? priceRange)? onTapCall;

  SortFilterBottomSheet({this.onTapCall});

  @override
  _SortFilterBottomSheetState createState() => _SortFilterBottomSheetState();
}

class _SortFilterBottomSheetState extends State<SortFilterBottomSheet> {
  List<FilterModel> allFilters = getProductFilters();
  FilterModel? selectedFilter;

  // 👇 Price Range
  RangeValues _selectedRange = RangeValues(0, 500); // default
  final double _minPrice = 0;
  final double _maxPrice = 500;
  bool _isPriceRangeChanged = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---- Price Range ----
            Text("Price Range", style: boldTextStyle(size: 18)),
            8.height,
            Text(
              "\$${_selectedRange.start.toInt()} - \$${_selectedRange.end.toInt()}",
              style: secondaryTextStyle(),
            ),
            RangeSlider(
              min: _minPrice,
              max: _maxPrice,
              divisions: 10,
              values: _selectedRange,
              activeColor: appSecondaryColor,
              labels: RangeLabels(
                "\$${_selectedRange.start.toInt()}",
                "\$${_selectedRange.end.toInt()}",
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _selectedRange = values;
                  _isPriceRangeChanged = true;
                });
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                text: "Apply",
                color: appSecondaryColor,
                textColor: Colors.white,
                onTap: () {
                  widget.onTapCall?.call(selectedFilter, _selectedRange);
                  finish(context);
                },
              ),
            ),

            24.height,

            /// ---- Sort Filters ----
            Text("Filter By", style: boldTextStyle(size: 18)),
            16.height,
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: allFilters.map((filter) {
                bool isSelected = selectedFilter == filter;
                return ChoiceChip(
                  label: Text(
                    filter.title.validate(),
                    style: primaryTextStyle(
                      color: isSelected ? Colors.white : context.primaryColor,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: appSecondaryColor,
                  backgroundColor: context.cardColor,
                  shape: StadiumBorder(side: BorderSide(color: appSecondaryColor)),
                  onSelected: (val) {
                    setState(() {
                      selectedFilter = filter;
                    });

                    widget.onTapCall?.call(
                      selectedFilter,
                      _isPriceRangeChanged ? _selectedRange : null,
                    );

                    finish(context);
                  },
                );
              }).toList(),
            ),
            24.height,

            /// ---- Buttons ----
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  text: "Clear",
                  color: Colors.blueGrey,
                  textColor: Colors.white,
                  onTap: () {
                    setState(() {
                      selectedFilter = null;
                      _selectedRange = RangeValues(_minPrice, _maxPrice);
                    });
                    widget.onTapCall?.call(null, null);
                    finish(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
