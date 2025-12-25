// // To parse this JSON data, do
// //
// //     final downloadPrescriptionModel = downloadPrescriptionModelFromJson(jsonString);

// import 'dart:convert';

// DownloadPrescriptionModel downloadPrescriptionModelFromJson(String str) =>
//     DownloadPrescriptionModel.fromJson(json.decode(str));

// String downloadPrescriptionModelToJson(DownloadPrescriptionModel data) =>
//     json.encode(data.toJson());

// class DownloadPrescriptionModel {
//   int? status;
//   String? message;
//   Result? result;

//   DownloadPrescriptionModel({
//     this.status,
//     this.message,
//     this.result,
//   });

//   factory DownloadPrescriptionModel.fromJson(Map<String, dynamic> json) =>
//       DownloadPrescriptionModel(
//         status: json["status"],
//         message: json["message"],
//         result: json["result"] == null ? null : Result.fromJson(json["result"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "result": result?.toJson(),
//       };
// }

// class Result {
//   String? pdfUrl;

//   Result({
//     this.pdfUrl,
//   });

//   factory Result.fromJson(Map<String, dynamic> json) => Result(
//         pdfUrl: json["pdf_url"],
//       );

//   Map<String, dynamic> toJson() => {
//         "pdf_url": pdfUrl,
//       };
// }

class DownloadPrescriptionModel {
  int? status;
  String? message;
  List<Result>? result;

  DownloadPrescriptionModel({this.status, this.message, this.result});

  DownloadPrescriptionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add( Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? pdfUrl;

  Result({this.pdfUrl});

  Result.fromJson(Map<String, dynamic> json) {
    pdfUrl = json['pdf_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pdf_url'] = pdfUrl;
    return data;
  }
}
