import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kivicare_flutter/components/disabled_rating_bar_widget.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/model/rating_model.dart';
import 'package:kivicare_flutter/screens/patient/screens/review/add_review_dialog.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class ReviewWidget extends StatelessWidget {
  final RatingData data;
  final bool isDoctor;
  final VoidCallback? callDelete;
  final Function(RatingData)? callUpdate;

  ReviewWidget({
    required this.data,
    required this.isDoctor,
    this.callDelete,
    this.callUpdate,
    required bool addMargin,
    required EdgeInsets padding,
    required Decoration decoration,
  });

  bool get showDelete {
    return isPatient() && isVisible(SharedPreferenceKey.kiviCarePatientReviewDeleteKey);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(data.id),
      enabled: showDelete,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (c) async {
              RatingData? updatedData = await showInDialog<RatingData>(
                context,
                backgroundColor: context.cardColor,
                contentPadding: EdgeInsets.zero,
                builder: (p0) {
                  return AddReviewDialog(
                    customerReview: data,
                    doctorId: isDoctor ? data.doctorId.validate().toInt() : data.patientId.validate().toInt(),
                  );
                },
              );
              if (updatedData != null) callUpdate?.call(updatedData);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (c) => callDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageBorder(
                  src: data.patientProfileImage.validate(),
                  height: 40,
                  nameInitial: isDoctor ? data.patientName.validate(value: 'P')[0] : data.doctorName.validate(value: 'D')[0],
                ),
                16.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDoctor ? data.patientName.validate() : data.doctorName.validate(),
                      style: boldTextStyle(size: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    DisabledRatingBarWidget(
                      rating: data.rating.validate().toDouble(),
                      size: 14,
                      showRatingText: true,
                    ),
                    if (data.createdAt.validate().isNotEmpty) Text(data.createdAt.validate(), style: secondaryTextStyle(size: 12)),
                    if (data.reviewDescription.validate().isNotEmpty)
                      ReadMoreText(
                        data.reviewDescription.validate(),
                        style: secondaryTextStyle(),
                        trimLength: 120,
                        colorClickableText: appSecondaryColor,
                      ).paddingTop(4),
                  ],
                ).flexible(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
