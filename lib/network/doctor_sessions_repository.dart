import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/model/doctor_session_model.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

//region Doctor Sessions

Future<List<SessionData>> getDoctorSessionDataAPI({String clinicId = '', int page=1, int perPages=PER_PAGE, Function(bool)? lastPageCallback, required List<SessionData> sessionList}) async {

  List<String> params = [];

  if (clinicId.isNotEmpty) params.add('${ConstantKeys.clinicIdKey}=$clinicId');
  params.add('page=$page');
  params.add('per_page=$perPages');
  DoctorSessionModel doctorSessionData= DoctorSessionModel.fromJson(await (handleResponse(
      await buildHttpResponse(getEndPoint(endPoint: '${ApiEndPoints.settingEndPoint}/${EndPointKeys.getDoctorClinicSessionEndPointKey}',params: params)))));
  if (page == 1) sessionList.clear();

  lastPageCallback?.call(doctorSessionData.sessionData.validate().length != PER_PAGE);

  sessionList.addAll(doctorSessionData.sessionData.validate());
  return sessionList;
}


Future addDoctorSessionDataAPI(Map request) async {
  return await handleResponse(await buildHttpResponse('${ApiEndPoints.settingEndPoint}/save-doctor-clinic-session', request: request, method: HttpMethod.POST));
}

Future deleteDoctorSessionDataAPI(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/setting/delete-doctor-clinic-session', request: request, method: HttpMethod.POST));
}

//endregion
