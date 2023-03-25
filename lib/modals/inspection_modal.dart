import 'dart:convert';
import 'dart:io' as Io;

List<InspectionModal> inspectionModalFromJson(String str) =>
    List<InspectionModal>.from(
        json.decode(str).map((x) => InspectionModal.fromJson(x)));

String inspectionModalToJson(List<InspectionModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InspectionModal {
  // int id;
  String inspectionSeason;
  String generalCondition;
  String taskActivityId;
  String apiaryId;
  String insetingWay;
  String hiveCode;
  String colonizationDate;
  String expectedObservation;
  String actionsTaken;
  String specifyExpectedObservation = " ";
  String specifyActionTaken = " ";
  String bloomingspecies;
  String img1;
  String img2;
  String jobId;
  String userId;
  String apiaryName;
  String expectedForHarvest;
  String isComplete;
  String expectedHarvest = "";
  String uploadStatus = "";
  InspectionModal(
      {required this.actionsTaken,
      required this.bloomingspecies,
      required this.insetingWay,
      required this.inspectionSeason,
      required this.specifyExpectedObservation,
      required this.apiaryId,
      required this.hiveCode,
      required this.isComplete,
      required this.expectedHarvest,
      required this.colonizationDate,
      required this.expectedObservation,
      required this.generalCondition,
      required this.expectedForHarvest,
      required this.specifyActionTaken,
      required this.img1,
      required this.img2,
      required this.taskActivityId,
      required this.uploadStatus,
      required this.jobId,
      required this.apiaryName,
      required this.userId});

  factory InspectionModal.fromJson(Map<String, dynamic> json) =>
      InspectionModal(
          jobId: json["job_id"] == null ? '' : json["job_id"],
          actionsTaken: json["action_taken"],
          userId: json["person_id"] == null ? '' : json["person_id"],
          bloomingspecies: json["blooming_species"],
          inspectionSeason: json["inspection_seasons"] == null
              ? ''
              : json["inspection_seasons"],
          colonizationDate: json["colonization_date"],
          expectedForHarvest:
              json["harvest_expected"] == null ? '' : json["harvest_expected"],
          apiaryId: json["apiary_id"],
          expectedHarvest: json["expected_harvest_kg"],
          expectedObservation: json["observations"],
          generalCondition: json["general_condition"],
          hiveCode: json["hive_code"],
          specifyActionTaken: json["action_taken"],
          specifyExpectedObservation: json["other_observations"],
          img1: json["img1"],
          img2: json["img2"],
          uploadStatus: json["upload_status"],
          insetingWay: json["inserting_way"],
          apiaryName: json["apiary_name"],
          isComplete: json["is_complete"],
          taskActivityId: json["task_activity_id"]);

  Map<String, dynamic> toJson() => {
        // "id": id,
        "inspection_season": inspectionSeason,
        "general_condition": generalCondition,
        "hive_code": hiveCode,
        "colonization_date": colonizationDate,
        "observations": expectedObservation,
        "other_observations": specifyExpectedObservation,
        "action_taken": actionsTaken,
        "other_action_taken": specifyActionTaken,
        "blooming_species": bloomingspecies,
        "harvest_expected": expectedForHarvest,
        "expected_harvest_kg": expectedHarvest,
        "img1": img1,
        "img2": img2,
        "upload_status": uploadStatus,
        "job_id": jobId,
        "person_id": userId,
        "apiary_id": apiaryId,
        "apiary_name": apiaryName,
        "inserting_way": insetingWay,
        "is_complete": isComplete,
        "task_activity_id": taskActivityId,
        "file1": base64.encode(
          Io.File(img1).readAsBytesSync(),
        ),
        "file2": base64.encode(
          Io.File(img2).readAsBytesSync(),
        ),
      };

  Map<String, dynamic> toJsonSync() => {
        // "id": id,
        "inspection_season": inspectionSeason,
        "general_condition": generalCondition,
        "hive_code": hiveCode,
        "colonization_date": colonizationDate,
        "observations": expectedObservation,
        "other_observations": specifyExpectedObservation,
        "action_taken": actionsTaken,
        "other_action_taken": specifyActionTaken,
        "blooming_species": bloomingspecies,
        "harvest_expected": expectedForHarvest,
        "expected_harvest_kg": expectedHarvest,
        "img1": img1,
        "img2": img2,
        "upload_status": uploadStatus,
        "job_id": jobId,
        "person_id": userId,
        "apiary_id": apiaryId,
        "apiary_name": apiaryName,
        "inserting_way": insetingWay,
        "is_complete": isComplete,
        "task_activity_id": taskActivityId,
      };
}
