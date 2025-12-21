import 'dart:io';

import 'package:http/http.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/doctor_list_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

Future<UserModel> getSelectedDoctorAPI({int? clinicId, required int doctorId}) async {
  return await getDoctorListAPI(clinicId: clinicId, page: null).then((value) {
    UserModel data = value.doctorList.validate().firstWhere((element) => element.iD.validate() == doctorId);

    appointmentAppStore.setSelectedDoctor(data);
    return data;
  });
}

Future<void> deleteDoctorAPI(Map request) async {
  return await handleResponse(await buildHttpResponse(
    '${ApiEndPoints.doctorEndPoint}/${EndPointKeys.deleteDoctorEndPointKey}',
    request: request,
    method: HttpMethod.POST,
  ));
}

Future<List<UserModel>> getDoctorListWithPagination({
  int? clinicId,
  String? searchString,
  required List<UserModel> doctorList,
  required int page,
  Function(bool)? lastPageCallback,
}) async {
  List<String> param = [];

  if (isReceptionist()) {
    param.add('?clinic_id=${userStore.userClinicId}');
  } else if (isDoctor() || isPatient()) {
    if (clinicId != null)
      param.add('?clinic_id=${clinicId.validate()}');
    else if (isProEnabled()) param.add('?clinic_id=${userStore.userClinicId}');
  }
  param.add('limit=$PER_PAGE');
  param.add('page=$page');

  if (searchString.validate().isNotEmpty) param.add('s=$searchString');

  DoctorListModel res = DoctorListModel.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/get-list${param.validate().join('&')}')));

  if (page == 1) doctorList.clear();

  lastPageCallback?.call(res.doctorList.validate().length != PER_PAGE);

  doctorList.addAll(res.doctorList.validate());

  appStore.setLoading(false);

  cachedDoctorList = doctorList;
  return doctorList;
}

Future<DoctorListModel> getDoctorListAPI({int? page, int? clinicId}) async {
  int? id;
  if (isReceptionist()) {
    id = userStore.userClinicId.toInt();
  } else if (isDoctor() || isPatient()) {
    id = clinicId;
  }

  if (page == null) {
    DoctorListModel res = DoctorListModel.fromJson(await (handleResponse(await buildHttpResponse('${ApiEndPoints.doctorEndPoint}/${EndPointKeys.getListEndPointKey}?clinic_id=${id != null ? id : ''}'))));

    return res;
  } else {
    return DoctorListModel.fromJson(await (handleResponse(await buildHttpResponse('${ApiEndPoints.doctorEndPoint}/${EndPointKeys.getListEndPointKey}?clinic_id=${id != null ? id : ''}&limit=$PER_PAGE&page=$page'))));
  }
}

Future<String> addUpdateDoctorDetailsAPI({required Map<String, dynamic> data, File? profileImage}) async {
  var multiPartRequest = await getMultiPartRequest('${ApiEndPoints.doctorEndPoint}/${EndPointKeys.addDoctorEndPointKey}');

  multiPartRequest.fields.addAll(await getMultipartFields(val: data));
  if (profileImage != null) {
    multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', profileImage.path));
  }

  multiPartRequest.headers.addAll(buildHeaderTokens());

  appStore.setLoading(true);
  String msg = '';

  await sendMultiPartRequest(
    multiPartRequest,
    onSuccess: (temp) async {
      appStore.setLoading(false);
      UserModel data = UserModel.fromJson(temp['data']);
      cachedUserData = data;

      msg = temp['message'];
    },
    onError: (error) {
      msg = error;
      return error;
    },
  );
  return msg;
}
