import 'package:yourappname/model/appointmentmodel.dart';
import 'package:yourappname/model/appointmentmodel.dart' as search;
import 'package:yourappname/model/appointmentmodel.dart' as appointment;
import 'package:yourappname/model/appointmentstatusmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class AppointmentProvider extends ChangeNotifier {
  AppointmentModel allAppointmentModel = AppointmentModel();
  AppointmentModel appointmentByTypeModel = AppointmentModel();
  AppointmentModel searchappointmentModel = AppointmentModel();
  AppointmentStatusModel appointmnetStatusModel = AppointmentStatusModel();

  SuccessModel successModel = SuccessModel();
  SuccessModel appointmentCallingModel = SuccessModel();
  List<appointment.Result>? appointmentList = [];
  bool statusLoading = false;
  List<search.Result>? searchAppointmentList = [];
  bool loading = false, searchloading = false, isShow = false;
  bool loadingUpdate = false, isDateSelected = false, isCalling = false;
  SharedPre sharePref = SharedPre();
  int selectedIndex = 0;
  String? lastTabValue;
  int? lastTabPosition, lastTabIndex;

  setSelectedTab(index) {
    selectedIndex = index;
    notifyListeners();
  }

  setTabPosition(position) {
    lastTabPosition = position;
    notifyListeners();
  }

  setTabIndex(position) {
    lastTabIndex = position;
    notifyListeners();
  }

  setTabValue(position) {
    lastTabValue = position;
    notifyListeners();
  }

  setLoading(isLoading) {
    statusLoading = isLoading;
    loading = isLoading;
  }

  Future<void> getAppointmentList() async {
    loading = true;
    printLog("getAppointmentList userId :==> ${Constant.userID}");
    allAppointmentModel = await ApiService().appoinmentList(Constant.userID);
    loading = false;
    notifyListeners();
  }

  Future<void> updateAppoinmentStatus(appointmentID, status) async {
    printLog("updateAppoinmentStatus appointmentID :==> $appointmentID");
    printLog("updateAppoinmentStatus status :=========> $status");
    loadingUpdate = true;
    successModel =
        await ApiService().appoinmentStatusUpdate(appointmentID, status);
    printLog("updateAppoinmentStatus status :===> ${successModel.status}");
    printLog("updateAppoinmentStatus message :==> ${successModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }

    Future<void> appoinmentCalling(appointmentID) async {
    printLog("appointmentCalling appointmentID :==> $appointmentID");
    isCalling = true;
    appointmentCallingModel =
        await ApiService().appoinmentCalling(appointmentID);
    printLog("appointmentCalling message :==> ${appointmentCallingModel.message}");
    isCalling = false;
    notifyListeners();
  }

  Future<void> getAppointment(type, pageNo) async {
    printLog("getAllAppointment patientID :==> ${Constant.userID}");
    loading = true;
    appointmentByTypeModel =
        await ApiService().appintmentByType(Constant.userID, type, pageNo);
    if (appointmentByTypeModel.status == 200) {
      setPodcastPaginationData(
          appointmentByTypeModel.totalRows,
          appointmentByTypeModel.totalPage,
          appointmentByTypeModel.currentPage,
          appointmentByTypeModel.morePage);
      if (appointmentByTypeModel.result != null &&
          (appointmentByTypeModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (appointmentByTypeModel.result?.length ?? 0); i++) {
          appointmentList
              ?.add(appointmentByTypeModel.result?[i] ?? appointment.Result());
        }
        final Map<int, appointment.Result> postMap = {};
        appointmentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        appointmentList = postMap.values.toList();
        printLog("contentList length :==> ${(appointmentList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getAppointmentStatus() async {
    printLog("get_appointment_status patientID :==> ${Constant.userID}");
    statusLoading = true;
    appointmnetStatusModel = await ApiService().appointmnetStatus();
    statusLoading = false;
    notifyListeners();
  }

  // AppointMent pagination
  bool loadmore = false;
  int? totalRows, totalPage, currentPage;
  bool isMorePage = false;
  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPodcastPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage!;

    notifyListeners();
  }

  Future<void> getSearchAppointment(name, pageNo) async {
    printLog("searchappointmentModel patientID :==> ${Constant.userID}");
    searchloading = true;
    searchappointmentModel = await ApiService().searchAppointment(name, pageNo);
    if (searchappointmentModel.status == 200) {
      setsearchPaginationData(
          searchappointmentModel.totalRows,
          searchappointmentModel.totalPage,
          searchappointmentModel.currentPage,
          searchappointmentModel.morePage);
      if (searchappointmentModel.result != null &&
          (searchappointmentModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (searchappointmentModel.result?.length ?? 0); i++) {
          searchAppointmentList
              ?.add(searchappointmentModel.result?[i] ?? search.Result());
        }
        final Map<int, search.Result> postMap = {};
        searchAppointmentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        searchAppointmentList = postMap.values.toList();
        setLoadMore(false);
      }
    }
    searchloading = false;
    notifyListeners();
  }

  //Search AppointMent pagination
  int? searchtotalRows, searchtotalPage, searchcurrentPage;
  bool issearchMorePage = false;

  setsearchPaginationData(int? searchtotalRows, int? searchtotalPage,
      int? searchcurrentPage, bool? issearchMorePage) {
    this.searchcurrentPage = searchcurrentPage;
    this.searchtotalRows = searchtotalRows;
    this.searchtotalPage = searchtotalPage;
    this.issearchMorePage = issearchMorePage!;

    notifyListeners();
  }

  searchsetLoading(isLoading) {
    searchloading = isLoading;
  }

  showsreachScreen(bool show) {
    printLog("searchprovider.isShow = $show");
    isShow = show;
    notifyListeners();
  }

  clearProvider() {
    loading = false;
    loadingUpdate = false;
    isCalling = false;
    isShow = false;
    appointmentList = [];
    searchAppointmentList = [];
    allAppointmentModel = AppointmentModel();
  }
}
