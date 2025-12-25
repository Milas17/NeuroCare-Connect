// To parse this JSON data, do
// final workingTimeSlotModel = workingTimeSlotModelFromJson(jsonString);

import 'dart:convert';

WorkingTimeSlotModel workingTimeSlotModelFromJson(String str) =>
    WorkingTimeSlotModel.fromJson(json.decode(str));

String workingTimeSlotModelToJson(WorkingTimeSlotModel data) =>
    json.encode(data.toJson());

class WorkingTimeSlotModel {
  int? status;
  String? message;
  List<Result>? result;

  WorkingTimeSlotModel({
    this.status,
    this.message,
    this.result,
  });

  factory WorkingTimeSlotModel.fromJson(Map<String, dynamic> json) =>
      WorkingTimeSlotModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  String? weekDay;
  List<TimeSlote>? timeSlotes;

  Result({
    this.weekDay,
    this.timeSlotes,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        weekDay: json["week_day"],
        timeSlotes: json["time_slotes"] == null
            ? []
            : List<TimeSlote>.from(
                json["time_slotes"]?.map((x) => TimeSlote.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "week_day": weekDay,
        "time_slotes": timeSlotes == null
            ? []
            : List<dynamic>.from(timeSlotes?.map((x) => x.toJson()) ?? []),
      };
}

class TimeSlote {
  int? id;
  int? doctorId;
  String? weekDay;
  String? startTime;
  String? endTime;
  String? timeDuration;
  int? isBook;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<TimeSchedul>? timeSchedul;
  String? appointmentSlotsId;
  int? tslPosition;
  String? date;

  TimeSlote({
    this.id,
    this.doctorId,
    this.weekDay,
    this.isBook,
    this.startTime,
    this.endTime,
    this.timeDuration,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.timeSchedul,
    this.appointmentSlotsId,
    this.tslPosition,
    this.date,
  });

  factory TimeSlote.fromJson(Map<String, dynamic> json) => TimeSlote(
        id: json["id"],
        doctorId: json["doctor_id"],
        weekDay: json["week_day"],
        startTime: json["start_time"],
        isBook: json["is_book"],
        endTime: json["end_time"],
        timeDuration: json["time_duration"],
        status: json["status"],
        date: json["date"],
        createdAt: json["created_at"],
        appointmentSlotsId: json["appointment_slots_id"],
        updatedAt: json["updated_at"],
        timeSchedul: json["time_schedul"] == null
            ? []
            : List<TimeSchedul>.from(
                json["time_schedul"]?.map((x) => TimeSchedul.fromJson(x)) ??
                    []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "doctor_id": doctorId,
        "week_day": weekDay,
        "is_book": isBook,
        "start_time": startTime,
        "end_time": endTime,
        "time_duration": timeDuration,
        "status": status,
        "date": date,
        "created_at": createdAt,
        "appointment_slots_id": appointmentSlotsId,
        "updated_at": updatedAt,
        "time_schedul": timeSchedul == null
            ? []
            : List<dynamic>.from(timeSchedul?.map((x) => x.toJson()) ?? []),
      };
}

class TimeSchedul {
  int? id;
  int? doctorId;
  String? appointmentSlotsId;
  String? weekDay;
  String? startTime;
  String? endTime;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? tsPosition;

  TimeSchedul({
    this.id,
    this.doctorId,
    this.weekDay,
    this.startTime,
    this.endTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.appointmentSlotsId,
    this.tsPosition,
  });

  factory TimeSchedul.fromJson(Map<String, dynamic> json) => TimeSchedul(
        id: json["id"],
        doctorId: json["doctor_id"],
        weekDay: json["week_day"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        appointmentSlotsId: json["appointment_slots_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "doctor_id": doctorId,
        "week_day": weekDay,
        "start_time": startTime,
        "end_time": endTime,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "appointment_slots_id": appointmentSlotsId,
      };
}

String scheduleToJson(FinalSchedule finalSchedule) =>
    json.encode(finalSchedule.toJson());

class FinalSchedule {
  FinalSchedule({
    this.doctorId,
    this.weekDay,
    this.startTime,
    this.endTime,
    this.timeDuration,
  });

  String? doctorId;
  String? weekDay;
  String? startTime;
  String? endTime;
  String? timeDuration;

  factory FinalSchedule.fromJson(Map<String, dynamic> json) => FinalSchedule(
        doctorId: json["doctor_id"],
        weekDay: json["week_day"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        timeDuration: json["time_duration"],
      );

  Map<String, dynamic> toJson() => {
        "doctor_id": doctorId,
        "week_day": weekDay,
        "start_time": startTime,
        "end_time": endTime,
        "time_duration": timeDuration,
      };
}
