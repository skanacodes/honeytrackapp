import 'dart:convert';
import 'dart:io' as Io;

List<HarvestingModal> harvestingModalFromJson(String str) =>
    List<HarvestingModal>.from(
        json.decode(str).map((x) => HarvestingModal.fromJson(x)));

String harvestingModalToJson(List<HarvestingModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HarvestingModal {
  // int id;
  String apiaryName;
  String hiveCode;
  String jobId;
  String userId;
  String apiaryId;
  String noOfHives;
  String moistureContent;
  String equipmentUsed;
  String? otherBeeProductHarvested;
  String isComplete;
  String transportationMeans;
  String? otherTransportationMeans;

  String transportationTime;
  int harvestingCost;

  String uploadStatus;
  String img1;
  String img2;
  String taskActivityId;
  HarvestingModal(
      {required this.transportationTime,
      required this.apiaryName,
      required this.isComplete,
      required this.equipmentUsed,
      required this.harvestingCost,
      required this.img1,
      required this.apiaryId,
      required this.img2,
      required this.hiveCode,
      required this.moistureContent,
      required this.noOfHives,
      required this.taskActivityId,
      this.otherBeeProductHarvested,
      this.otherTransportationMeans,
      required this.transportationMeans,
      required this.uploadStatus,
      required this.jobId,
      required this.userId});

  factory HarvestingModal.fromJson(Map<String, dynamic> json) =>
      HarvestingModal(
          apiaryName: json["apiary_name"],
          equipmentUsed: json["equipmentUsed"],
          harvestingCost: json["certifiedDate"],
          hiveCode: json["certifiedDate"],
          moistureContent: json["certifiedDate"],
          noOfHives: json["certifiedDate"],
          img2: json["certifiedDate"],
          img1: json["certifiedDate"],
          otherBeeProductHarvested: json["certifiedDate"],
          otherTransportationMeans: json["certifiedDate"],
          transportationMeans: json["certifiedDate"],
          transportationTime: json["certifiedDate"],
          uploadStatus: json["certifiedDate"],
          jobId: json["certifiedDate"],
          userId: json["certifiedDate"],
          apiaryId: json["apiaryId"],
          isComplete: json["is_complete"],
          taskActivityId: json["bdfc"]);

  Map<String, dynamic> toJson() => {
        'apiary_name': apiaryName.toString(),
        'apiary_id': apiaryId,
        'hive_code': hiveCode.toString(),
        'moisture_content': moistureContent.toString(),
        'equipment_used': equipmentUsed.toString(),
        'no_of_hives': noOfHives,
        'bee_products': otherBeeProductHarvested.toString(),
        'transport_mean': transportationMeans.toString(),
        'otherMeans': otherTransportationMeans.toString(),
        'transport_time': transportationTime.toString(),
        'harvesting_cost': harvestingCost.toString(),
        'upload_status': uploadStatus.toString(),
        'img1': img1,
        'img2': img2,
        'job_id': jobId,
        'person_id': userId,
        'is_complete': isComplete,
        'task_activity_id': taskActivityId,
        "file1": base64.encode(
          Io.File(img1).readAsBytesSync(),
        ),
        "file2": base64.encode(
          Io.File(img2).readAsBytesSync(),
        ),
      };
}
