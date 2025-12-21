import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/components/price_widget.dart';
import 'package:kivicare_flutter/components/voice_search_suffix.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/model/tax_model.dart';
import 'package:kivicare_flutter/network/bill_repository.dart';
import 'package:kivicare_flutter/network/service_repository.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/select_service_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class MultiSelectServiceComponent extends StatefulWidget {
  final int? clinicId;
  final int? doctorId;
  List<String>? selectedServicesId;
  List<ServiceRequestModel>? requestList = [];
  bool isForBill;

  MultiSelectServiceComponent({
    this.clinicId,
    this.selectedServicesId,
    this.requestList,
    this.doctorId,
    this.isForBill = false,
  });

  @override
  _MultiSelectServiceComponentState createState() => _MultiSelectServiceComponentState();
}

class _MultiSelectServiceComponentState extends State<MultiSelectServiceComponent> {
  TextEditingController searchCont = TextEditingController();
  Future<ServiceListModel>? future;
  List<ServiceData> servicesList = [];
  bool showClear = false;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) appStore.setLoading(true);
    getData();
  }

  Future<void> _onClearSearch() async {
    searchCont.clear();
    hideKeyboard(context);
    init(showLoader: true);
  }

  Future<void> getData() async {
    future = getServiceResponseAPI(
      searchString: searchCont.text,
      clinicId: isProEnabled() ? widget.clinicId.toString() : userStore.userClinicId,
      doctorId: widget.doctorId ?? (appointmentAppStore.mDoctorSelected?.iD ?? userStore.userId.validate()),
    ).then((value) {
      if (searchCont.text.isNotEmpty) {
        showClear = true;
      } else {
        showClear = false;
      }
      servicesList = value.serviceData.validate();
      if (widget.selectedServicesId != null) {
        multiSelectStore.clearList();
        if (value.serviceData != null && value.serviceData.validate().isNotEmpty) {
          value.serviceData.validate().forEach((element) {
            if (widget.selectedServicesId.validate().contains(element.serviceId)) {
              element.isCheck = true;
              multiSelectStore.addSingleItem(element, isClear: false);
            }
          });
          value.serviceData.validate().retainWhere((element) => element.status == ACTIVE_SERVICE_STATUS);
        }
        setState(() {});
        appStore.setLoading(false);
      }
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      setState(() {});
      throw e;
    });
  }

  void _clearSearch() async {
    hideKeyboard(context);
    searchCont.clear();
    init(showLoader: true);
  }

  void _toggleSelection(ServiceData serviceData) {
    if (serviceData.multiple.validate()) {
      // Multiple → allow more than one
      serviceData.isCheck = !serviceData.isCheck;

      if (serviceData.isCheck) {
        // Do not clear old ones
        multiSelectStore.addSingleItem(serviceData, isClear: false);
      } else {
        multiSelectStore.removeItem(serviceData);
      }
    } else {
      // Single service → clear all, keep only this
      servicesList.forEach((e) => e.isCheck = false);

      serviceData.isCheck = true;
      multiSelectStore.addSingleItem(serviceData, isClear: true);
    }

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblSelectServices,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Observer(builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: searchCont,
              textFieldType: TextFieldType.NAME,
              decoration: inputDecoration(
                context: context,
                hintText: locale.lblSearchServices,
                prefixIcon: ic_search.iconImage().paddingAll(16),
                suffixIcon: VoiceSearchSuffix(
                  controller: searchCont,
                  lottieAnimationPath: lt_voice,
                  onClear: _onClearSearch,
                  onSearchChanged: (value) {
                    if (value.isEmpty) {
                      _onClearSearch();
                    } else {
                      Timer(pageAnimationDuration, () {
                        init(showLoader: true);
                      });
                    }
                  },
                  onSearchSubmitted: (value) {
                    hideKeyboard(context);
                    init(showLoader: true);
                  },
                ),
              ),
              onChanged: (newValue) {
                if (newValue.isEmpty) {
                  showClear = false;
                  _clearSearch();
                } else {
                  Timer(pageAnimationDuration, () {
                    init(showLoader: true);
                  });
                  showClear = true;
                }
                setState(() {});
              },
              onFieldSubmitted: (searchString) {
                hideKeyboard(context);
                init(showLoader: true);
              },
            ).paddingAll(16),
            Row(
              children: [
                ic_multi_select.iconImage(size: 16),
                8.width,
                Text(locale.lblMultipleSelectionIsAvailableForThisService, style: secondaryTextStyle()).expand(),
              ],
            ).paddingSymmetric(horizontal: 16, vertical: 8),
            Expanded(
              child: SnapHelperWidget<ServiceListModel>(
                future: future,
                loadingWidget: SelectServiceShimmerScreen(),
                errorBuilder: (error) {
                  return NoDataWidget(
                    imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                    title: error.toString(),
                  );
                },
                errorWidget: ErrorStateWidget(),
                onSuccess: (snap) {
                  if (snap.serviceData.validate().isEmpty && !appStore.isLoading) {
                    return SingleChildScrollView(
                      child: NoDataFoundWidget(
                        text: searchCont.text.isEmpty ? locale.lblNoActiveServicesAvailable : locale.lblCantFindServiceYouSearchedFor,
                      ),
                    ).center();
                  }
                  snap.serviceData.validate().retainWhere((element) => element.status == ACTIVE_SERVICE_STATUS);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: snap.serviceData.validate().length,
                    padding: EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      ServiceData serviceData = snap.serviceData.validate()[index];
                      if (serviceData.name.isEmptyOrNull) return Offstage();
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _toggleSelection(serviceData),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGE SECTION
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: serviceData.image.validate().isNotEmpty
                                        ? Image.network(
                                            serviceData.image.validate(),
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 120,
                                            alignment: Alignment.center,
                                            color: context.scaffoldBackgroundColor,
                                            child: Text(
                                              serviceData.name.validate(value: 'S')[0],
                                              style: boldTextStyle(size: 26),
                                            ),
                                          ),
                                  ),
                                  if (serviceData.multiple.validate())
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                                        ),
                                        child: ic_multi_select.iconImage(size: 16),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Marquee(
                                      direction: Axis.horizontal,
                                      child: Text(
                                        serviceData.name.capitalizeFirstLetter().validate(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: boldTextStyle(size: 14),
                                      ),
                                    ),
                                    // 6.height,
                                    Row(
                                      children: [
                                        PriceWidget(
                                          price: serviceData.charges.validate(),
                                          textStyle: primaryTextStyle(size: 13),
                                        ),
                                        Spacer(),
                                        Checkbox(
                                          value: serviceData.isCheck,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (v) => _toggleSelection(serviceData),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            LoaderWidget().visible(appStore.isLoading).center(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () async {
          if (isProEnabled() && !widget.isForBill && multiSelectStore.selectedService.validate().isNotEmpty) {
            Map<String, dynamic> request = {
              ConstantKeys.doctorIdKey: appointmentAppStore.mDoctorSelected?.iD ?? userStore.userId.validate(),
              ConstantKeys.clinicIdKey: widget.clinicId,
            };
            List<ServiceRequestModel> selectedServiceRequest = [];
            multiSelectStore.selectedService.validate().forEachIndexed((element, index) {
              if (widget.requestList.validate().isNotEmpty) {
                int i = widget.requestList.validate().indexWhere((e) => e.serviceId == element.id);
                if (i < 0)
                  selectedServiceRequest.add(ServiceRequestModel(serviceId: element.mappingTableId.toInt(), quantity: 1));
                else {
                  selectedServiceRequest.add(ServiceRequestModel(
                    serviceId: widget.requestList.validate()[i].serviceId,
                    quantity: widget.requestList.validate()[i].quantity,
                  ));
                }
              } else {
                selectedServiceRequest.add(ServiceRequestModel(serviceId: element.mappingTableId.toInt(), quantity: 1));
              }
            });
            log("Final Request: ${jsonEncode(request)}");
            request.putIfAbsent(
              ConstantKeys.visitTypeKey,
              () => selectedServiceRequest.map((e) => e.toJson()).toList(),
            );

            appStore.setLoading(true);
            await getTaxData(request).then((taxData) {
              multiSelectStore.setTaxData(taxData);
              appStore.setLoading(false);
              finish(context);
            }).catchError((e) {
              appStore.setLoading(false);
              toast(e.toString());
              throw e;
            });
          } else {
            finish(context);
          }
        },
      ),
    );
  }
}
