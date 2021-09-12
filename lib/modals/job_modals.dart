import 'dart:convert';

List<JobModals> jobModalsFromJson(String str) =>
    List<JobModals>.from(json.decode(str).map((x) => JobModals.fromJson(x)));

String jobModalsToJson(List<JobModals> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class JobModals {
  int id;
  String jobname;
  String tasktype;
  String activity;
  String apiaryIds;
  String role;
  JobModals({
    required this.id,
    required this.activity,
    required this.jobname,
    required this.role,
    required this.tasktype,
    required this.apiaryIds,
  });

  factory JobModals.fromJson(Map<String, dynamic> json) => JobModals(
      id: json["id"],
      activity: json["activity"],
      jobname: json["jobname"],
      tasktype: json["tasktype"],
      role: json["role"],
      apiaryIds: json["apiary"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "activity": activity,
        "jobname": jobname,
        "tasktype": tasktype,
        "role": role,
        "apiary_id": apiaryIds
      };
}
