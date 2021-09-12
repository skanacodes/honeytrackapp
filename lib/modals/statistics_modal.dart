import 'dart:convert';

List<StatisticsModal> statisticsModalFromJson(String str) =>
    List<StatisticsModal>.from(
        json.decode(str).map((x) => StatisticsModal.fromJson(x)));

String statisticsModalToJson(List<StatisticsModal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StatisticsModal {
  int apiaries;
  int beekepers;
  int dealers;
  int tp;

  StatisticsModal({
    required this.apiaries,
    required this.beekepers,
    required this.dealers,
    required this.tp,
  });

  factory StatisticsModal.fromJson(Map<String, dynamic> json) =>
      StatisticsModal(
        apiaries: json["apiaries"],
        beekepers: json["beekepers"],
        dealers: json["dealers"],
        tp: json["transitPass"],
      );

  Map<String, dynamic> toJson() => {
        "apiaries": apiaries,
        "beekepers": beekepers,
        "dealers": dealers,
        "transitPass": tp,
      };
}
