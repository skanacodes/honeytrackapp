import 'dart:convert';

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
  String noOfHives;
  String weightOfCombHoney;
  String moistureContent;
  String generalcondition;
  String equipmentUsed;
  String otherBeeProductHarvested;
  String beeVenomweight;
  String pollenWeight;
  String propolisWeight;
  String royalJellyweight;
  String transportationMeans;
  String otherTransportationMeans;
  String stationAberyApiary;
  String transportationTime;
  int harvestingCost;
  String harvestedByName;
  String harvestedByTitle;
  String harvestedByDate;
  String certifiedByName;
  String certifiedBytitle;
  String certifiedByDate;
  String uploadStatus;
  String img1;
  String img2;
  HarvestingModal(
      {required this.transportationTime,
      required this.apiaryName,
      required this.beeVenomweight,
      required this.certifiedByDate,
      required this.certifiedByName,
      required this.certifiedBytitle,
      required this.equipmentUsed,
      required this.generalcondition,
      required this.harvestedByDate,
      required this.harvestedByName,
      required this.harvestedByTitle,
      required this.harvestingCost,
      required this.img1,
      required this.img2,
      required this.hiveCode,
      required this.moistureContent,
      required this.noOfHives,
      required this.otherBeeProductHarvested,
      required this.otherTransportationMeans,
      required this.pollenWeight,
      required this.propolisWeight,
      required this.royalJellyweight,
      required this.stationAberyApiary,
      required this.transportationMeans,
      required this.weightOfCombHoney,
      required this.uploadStatus,
      required this.jobId,
      required this.userId});

  factory HarvestingModal.fromJson(Map<String, dynamic> json) =>
      HarvestingModal(
        apiaryName: json["apiary_name"],
        beeVenomweight: json["beeweight"],
        certifiedByDate: json["certifiedDate"],
        certifiedByName: json["certifiedName"],
        certifiedBytitle: json["certifiedBytitle"],
        equipmentUsed: json["equipmentUsed"],
        generalcondition: json["general condition"],
        harvestedByDate: json["harvestedByDate"],
        harvestedByName: json["certifiedDate"],
        harvestedByTitle: json["certifiedDate"],
        harvestingCost: json["certifiedDate"],
        hiveCode: json["certifiedDate"],
        moistureContent: json["certifiedDate"],
        noOfHives: json["certifiedDate"],
        img2: json["certifiedDate"],
        img1: json["certifiedDate"],
        otherBeeProductHarvested: json["certifiedDate"],
        otherTransportationMeans: json["certifiedDate"],
        pollenWeight: json["certifiedDate"],
        propolisWeight: json["certifiedDate"],
        royalJellyweight: json["certifiedDate"],
        stationAberyApiary: json["certifiedDate"],
        transportationMeans: json["certifiedDate"],
        transportationTime: json["certifiedDate"],
        weightOfCombHoney: json["certifiedDate"],
        uploadStatus: json["certifiedDate"],
        jobId: json["certifiedDate"],
        userId: json["certifiedDate"],
      );

  Map<String, dynamic> toJson() => {
        'apiary_name': apiaryName,
        'hive_code': hiveCode,
        'no_of_hives': noOfHives,
        'weight_of_comb_honey': weightOfCombHoney,
        'moisture_content': moistureContent,
        'weather_condition': generalcondition,
        'equipment_used': equipmentUsed,
        'other_bee_product': otherBeeProductHarvested,
        'beevenom_weight': beeVenomweight,
        'pollenweight': pollenWeight,
        'propolisweight': propolisWeight,
        'royaljelly_weight': royalJellyweight,
        'transportation_means': transportationMeans,
        'otherMeans': otherTransportationMeans,
        'transportation_time': transportationTime,
        'stationapiary': stationAberyApiary,
        'harvesting_cost': harvestingCost,
        'harvestedby_name': harvestedByName,
        'harvestedby_title': harvestedByTitle,
        'harvestedby_date': harvestedByDate,
        'certifiedby_name': certifiedByName,
        'certifiedby_title': certifiedBytitle,
        'certifiedby_date': certifiedByDate,
        'upload_status': uploadStatus,
        'img1': img1,
        'img2': img2,
        'job_id': jobId,
        'person_id': userId,
      };
}
