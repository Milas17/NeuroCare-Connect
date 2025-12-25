// To parse this JSON data, do
//
//     final timeSlotModel = timeSlotModelFromJson(jsonString);

import 'dart:convert';

TimeSlotModel timeSlotModelFromJson(String str) =>
    TimeSlotModel.fromJson(json.decode(str));

String timeSlotModelToJson(TimeSlotModel data) => json.encode(data.toJson());

class TimeSlotModel {
  int? status;
  String? message;
  List<Result>? result;

  TimeSlotModel({
    this.status,
    this.message,
    this.result,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) => TimeSlotModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  String? weekDay;
  List<TimeS>? timeSlotes;

  Result({
    this.weekDay,
    this.timeSlotes,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        weekDay: json["week_day"],
        timeSlotes: json["time_slotes"] == null
            ? []
            : List<TimeS>.from(
                json["time_slotes"].map((x) => TimeS.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "week_day": weekDay,
        "time_slotes":
            List<dynamic>.from(timeSlotes?.map((x) => x.toJson()) ?? []),
      };
}

class TimeS {
  int? id;
  int? doctorId;
  String? weekDay;
  String? startTime;
  String? endTime;
  String? timeDuration;
  int? status;
  String? createdAt;
  int? isBook;
  String? updatedAt;
  List<TimeS>? timeSchedul;
  String? appointmentSlotsId;

  TimeS({
    this.id,
    this.doctorId,
    this.weekDay,
    this.startTime,
    this.endTime,
    this.timeDuration,
    this.status,
    this.isBook,
    this.createdAt,
    this.updatedAt,
    this.timeSchedul,
    this.appointmentSlotsId,
  });

  factory TimeS.fromJson(Map<String, dynamic> json) => TimeS(
        id: json["id"],
        doctorId: json["doctor_id"],
        weekDay: json["week_day"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        timeDuration: json["time_duration"],
        status: json["status"],
        createdAt: json["created_at"],
        isBook: json["is_book"],
        updatedAt: json["updated_at"],
        timeSchedul: json["time_schedul"] == null
            ? []
            : List<TimeS>.from(
                json["time_schedul"].map((x) => TimeS.fromJson(x))),
        appointmentSlotsId: json["appointment_slots_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "doctor_id": doctorId,
        "week_day": weekDay,
        "start_time": startTime,
        "end_time": endTime,
        "time_duration": timeDuration,
        "status": status,
        "is_book": isBook,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "time_schedul":
            List<dynamic>.from(timeSchedul?.map((x) => x.toJson()) ?? []),
        "appointment_slots_id": appointmentSlotsId,
      };
}
