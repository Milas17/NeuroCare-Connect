import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/clinic_list_model.dart';
import 'package:kivicare_flutter/network/clinic_repository.dart';
import 'package:kivicare_flutter/screens/patient/components/clinic_component.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/switch_clinic_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class PatientClinicSelectionScreen extends StatefulWidget {
  final VoidCallback? callback;
  final bool? isForRegistration;
  final int? clinicId;
  bool? isDoctor;
  final List<Clinic>? preselectedClinics;

  PatientClinicSelectionScreen({this.callback, this.isForRegistration, this.clinicId, this.isDoctor, this.preselectedClinics});

  @override
  _PatientClinicSelectionScreenState createState() => _PatientClinicSelectionScreenState();
}

class _PatientClinicSelectionScreenState extends State<PatientClinicSelectionScreen> {
  Future<List<Clinic>>? future;

  final List<Clinic> loadedClinics = []; // only for pagination/API
  List<Clinic> selectedClinics = []; // only for user selection
  Clinic? selectedClinic; // for single-select flow
  int? preselectedClinicId;
  int page = 1;
  int selectedIndex = -1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    if ((widget.isDoctor ?? false) && widget.preselectedClinics != null) {
      selectedClinics = List.from(widget.preselectedClinics!);
    } else if (!(widget.isDoctor ?? false) && widget.clinicId != null) {
      preselectedClinicId = widget.clinicId;
    }

    init();
  }

  Future<void> init() async {
    final isReg = widget.isForRegistration.validate();
    final isDoc = widget.isDoctor ?? false;

    future = getClinicListAPI(
      page: page,
      clinicList: loadedClinics,
      isAuthRequired: !isReg,
      lastPageCallback: (p0) => isLastPage = p0,
    ).then((value) {
      if (isDoc) {
        // doctor → keep preselected list
        if (widget.preselectedClinics != null && widget.preselectedClinics!.isNotEmpty) {
          selectedClinics = List.from(widget.preselectedClinics!);
        }
      } else {
        // patient flow → single select
        if (preselectedClinicId != null) {
          try {
            selectedClinic = value.firstWhere((e) => e.id.validate().toInt() == preselectedClinicId);
            selectedIndex = value.indexWhere((e) => e.id.validate().toInt() == preselectedClinicId);
          } catch (e) {
            selectedClinic = null;
            selectedIndex = -1;
          }
        } else if (userStore.userClinicId.validate().isNotEmpty) {
          try {
            selectedClinic = value.firstWhere((e) => e.id.validate() == userStore.userClinicId);
            selectedIndex = value.indexWhere((e) => e.id.validate() == userStore.userClinicId);
          } catch (e) {
            selectedClinic = null;
            selectedIndex = -1;
          }
        }
      }

      setState(() {}); // refresh UI
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  Future<void> switchFavouriteClinic(Clinic newClinic, int newIndex) async {
    int originalIndex = selectedIndex;
    selectedIndex = newIndex;
    if (mounted) setState(() {});

    showConfirmDialogCustom(
      context,
      dialogType: DialogType.CONFIRMATION,
      title: locale.lblDoYouWantToSwitchYourClinicTo,
      onCancel: (p0) {
        selectedIndex = originalIndex;
        if (mounted) setState(() {});
      },
      onAccept: (_) async {
        appStore.setLoading(true);
        Map<String, dynamic> req = {'clinic_id': newClinic.id};

        try {
          var value = await switchClinicApi(
            req: req,
          );

          if (!mounted) return; // ✅ prevent crash

          toast(value['message']);
          appStore.setLoading(false);

          if (value['status'] == true) {
            widget.callback?.call();
            userStore.setClinicId(newClinic.id.toString());
            userStore.setUserClinicImage(newClinic.profileImage.validate(), initialize: true);
            userStore.setUserClinicName(newClinic.name.validate(), initialize: true);
            userStore.setUserClinicStatus(newClinic.status.validate(), initialize: true);

            String clinicAddress = '';
            if (newClinic.city.validate().isNotEmpty) clinicAddress = newClinic.city.validate();
            if (newClinic.country.validate().isNotEmpty) clinicAddress += ' ,${newClinic.country.validate()}';
            userStore.setUserClinicAddress(clinicAddress, initialize: true);
          } else {
            selectedIndex = originalIndex;
          }

          if (mounted) setState(() {});
        } catch (e) {
          selectedIndex = originalIndex;
          if (mounted) setState(() {});
          toast(e.toString());
        } finally {
          appStore.setLoading(false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.isForRegistration ?? false ? locale.lblSelectOneClinic.capitalizeEachWord() : locale.lblMyClinic,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        elevation: 0,
        color: appPrimaryColor,
      ),
      body: InternetConnectivityWidget(
        retryCallback: () => setState(() {}),
        child: Stack(
          children: [
            SnapHelperWidget<List<Clinic>>(
              future: future,
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                  title: error.toString(),
                );
              },
              errorWidget: ErrorStateWidget(),
              loadingWidget: SwitchClinicShimmerScreen(),
              onSuccess: (snap) {
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  itemCount: snap.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final item = snap[index];
                    final isDoc = widget.isDoctor ?? false;

                    final alreadySelected = selectedClinics.any((c) => c.id == item.id);

                    return ClinicComponent(
                      // helps Flutter keep state right
                      clinicData: item,
                      isCheck: isDoc ? alreadySelected : selectedIndex == index,
                      onTap: (_) async {
                        if (isDoc) {
                          setState(() {
                            if (alreadySelected) {
                              selectedClinics.removeWhere((c) => c.id == item.id);
                            } else {
                              selectedClinics.add(item);
                            }
                          });
                        } else {
                          // single-select flow
                          setState(() {
                            selectedIndex = index;
                            selectedClinic = item;
                          });
                          await switchFavouriteClinic(item, index);
                        }
                      },
                    );
                  },
                );
              },
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)).center()
          ],
        ),
      ),
      floatingActionButton: widget.isForRegistration.validate()
          ? FloatingActionButton(
              child: const Icon(Icons.done),
              onPressed: () {
                final isDoc = widget.isDoctor ?? false;
                finish(context, isDoc ? selectedClinics : selectedClinic);
              },
            )
          : const Offstage(),
    );
  }
}
