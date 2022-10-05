import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;

List<InspectionModal> inspectionModalFromJson(String str) =>
    List<InspectionModal>.from(
        json.decode(str).map((x) => InspectionModal.fromJson(x)));

String inspectionModalToJson(List<InspectionModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InspectionModal {
  // int id;
  String inspectionSeason;
  String generalCondition;
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
          jobId: json["job_id"] == null ? '' : json["job_id"],
          actionsTaken: json["action_taken"],
          userId: json["person_id"] == null ? '' : json["person_id"],
          bloomingspecies: json["blooming_species"],
          inspectionSeason: json["inspection_seasons"] == null
              ? ''
              : json["inspection_seasons"],
          colonizationDate: json["colonization_date"],
          expectedForHarvest: json["expected_for_harvest"] == null
              ? ''
              : json["expected_for_harvest"],
          apiaryId: json["apiary_id"],
          expectedHarvest: json["harvest_weight"],
          expectedObservation: json["expected_observations"],
          generalCondition: json["general_condition"],
          hiveCode: json["hive_code"],
          specifyActionTaken: json["specify_action"],
          specifyExpectedObservation: json["specify_observation"],
          img1: json["img1"],
          img2: json["img2"],
          uploadStatus: json["upload_status"],
          insetingWay: json["inserting_way"],
          apiaryName: json["apiary_name"]);

  Map<String, dynamic> toJson() => {
        // "id": id,
        "inspection_season": inspectionSeason,
        "general_condition": generalCondition,
        "hive_code": hiveCode,
        "colonization_date": colonizationDate,
        "expected_observations": expectedObservation,
        "specify_observation": specifyExpectedObservation,
        "action_taken": actionsTaken,
        "specify_action": specifyActionTaken,
        "blooming_species": bloomingspecies,
        "expected_for_Harvest": expectedForHarvest,
        "harvest_weight": expectedHarvest,
        "img1": base64Encode(File(img1).readAsBytesSync()),
        "img2": base64Encode(File(img1).readAsBytesSync()),
        "upload_status": uploadStatus,
        "job_id": jobId,
        "person_id": userId,
        "apiary_id": apiaryId,
        "apiary_name": apiaryName,
        "inserting_way": insetingWay
      };
  // Future<Map<String, dynamic>> toJsons()  => {
  //       "inspection_season": inspectionSeason,
  //       "general_condition": generalCondition,
  //       "hive_code": hiveCode,
  //       "colonization_date": colonizationDate,
  //       "expected_observations": expectedObservation,
  //       "specify_observation": specifyExpectedObservation,
  //       "action_taken": actionsTaken,
  //       "specify_action": specifyActionTaken,
  //       "blooming_species": bloomingspecies,
  //       "expected_for_Harvest": expectedForHarvest,
  //       "harvest_weight": expectedHarvest,
  //       "img1": base64Encode(File(img1).readAsBytes()),
  //       "img2": base64Encode(File(img2).readAsBytes()),
  //       "upload_status": uploadStatus,
  //       "job_id": jobId,
  //       "person_id": userId,
  //       "apiary_id": apiaryId,
  //       "apiary_name": apiaryName,
  //       "inserting_way": insetingWay
  //     };
}
