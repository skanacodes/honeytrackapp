import 'dart:convert';

List<InspectionModal> inspectionModalFromJson(String str) =>
    List<InspectionModal>.from(
        json.decode(str).map((x) => InspectionModal.fromJson(x)));

String inspectionModalToJson(List<InspectionModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InspectionModal {
  // int id;
  String inspectionSeason;
  String generalCondition;
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
  String expectedHarvest = "";
  String uploadStatus = "";
  InspectionModal(
      {required this.actionsTaken,
      required this.bloomingspecies,
      required this.inspectionSeason,
      required this.specifyExpectedObservation,
      required this.hiveCode,
      required this.expectedHarvest,
      required this.colonizationDate,
      required this.expectedObservation,
      required this.generalCondition,
      required this.expectedForHarvest,
      required this.specifyActionTaken,
      required this.img1,
      required this.img2,
      required this.uploadStatus,
      required this.jobId,
      required this.apiaryName,
      required this.userId});

  factory InspectionModal.fromJson(Map<String, dynamic> json) =>
      InspectionModal(
          jobId: json["job_id"],
          actionsTaken: json["action_taken"],
          userId: json["user_id"],
          bloomingspecies: json["blooming_species"],
          inspectionSeason: json["inspection_seasons"],
          colonizationDate: json["colonization_date"],
          expectedForHarvest: json["expectedForHarvest"],
          expectedHarvest: json["expectedHarvest"],
          expectedObservation: json["expeced_obseravtion"],
          generalCondition: json["general_condition"],
          hiveCode: json["hive_code"],
          specifyActionTaken: json["specifaction"],
          specifyExpectedObservation: json["specifyObservation"],
          img1: json["img1"],
          img2: json["img2"],
          uploadStatus: json["upload_status"],
          apiaryName: json["apiary"]);

  Map<String, dynamic> toJson() => {
        // "id": id,
        "inspection_season": inspectionSeason,
        "general_condition": generalCondition,
        "hivecode": hiveCode,
        "colonization_date": colonizationDate,
        "expected_observation": expectedObservation,
        "specify_observation": specifyExpectedObservation,
        "action_taken": actionsTaken,
        "specify_action": specifyActionTaken,
        "blooming_species": bloomingspecies,
        "expectedForHarvest": expectedForHarvest,
        "expected_harvest": expectedHarvest,
        "img1": img1,
        "img2": img2,
        "upload_status": uploadStatus,
        "job_id": jobId,
        "person_id": userId,
        "apiary_name": apiaryName
      };
}
