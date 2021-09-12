import 'dart:convert';

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  int id;
  String email;
  String firstName;
  String lastName;
  String password;
  String stationName;
  User(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.password,
      required this.stationName});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json["id"],
      email: json["email"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      password: json["password"],
      stationName: json["stationName"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "password": password,
        "stationName": stationName
      };
}
