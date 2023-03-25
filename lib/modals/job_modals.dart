import 'dart:convert';

List<JobModals> jobModalsFromJson(String str) =>
    List<JobModals>.from(json.decode(str).map((x) => JobModals.fromJson(x)));

String jobModalsToJson(List<JobModals> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class JobModals {
  int id;
  String jobname;
  String tasktype;
  String userId;
  String activity;
  String apiaryIds;
  String role;
  String jobId;
  String startdate;
  String endDate;
  JobModals(
      {required this.id,
      required this.activity,
      required this.jobname,
      required this.role,
      required this.startdate,
      required this.endDate,
      required this.jobId,
      required this.tasktype,
      required this.apiaryIds,
      required this.userId});

// 'id INTEGER PRIMARY KEY,'
//           'person_id TEXT,'
//           'job_id TEXT,'
//           'jobname TEXT,'
//           'activity TEXT,'
//           'hiveNo TEXT,'
//           'tasktype TEXT,'
//           'apiary_id TEXT,'
//           'hive_attended TEXT,'
//           'task_activity_id TEXT,'
//           'role TEXT'
  factory JobModals.fromJson(Map<String, dynamic> json, {String? userId}) =>
      JobModals(
          id: json["id"],
          userId: userId!,
          jobId: json["id"],
          activity: json["activity"].toString(),
          jobname: json["name"],
          tasktype: json["tasktype"]["name"],
          role: " ",
          apiaryIds: json["apiary"],
          startdate: json["start_date"],
          endDate: json["end_date"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "person_id": userId,
        "activity": activity,
        "jobname": jobname,
        "tasktype": tasktype,
        "role": role,
        "apiary_id": apiaryIds
      };
}
