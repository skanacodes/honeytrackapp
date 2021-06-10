import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:honeytrackapp/modals/user_modal.dart';

class UserApiProvider {
  Future<String> getAllEmployees() async {
    // var url = Uri.parse('http://41.59.227.103:9092/api/login');
    // final response = await http.post(
    //   url,
    //   body: {'email': 'barakasikana@gmail.com', 'password': 'baraka540'},
    // );

    // var res = json.decode(response.body);

    // return (res as List).map((employee) {
    //   print('Inserting $employee');
    //   DBProvider.db.createEmployee(User.fromJson(employee));
    // }).toList();

    try {
      var url = Uri.parse('http://41.59.227.103:9092/api/login');
      final response = await http.post(
        url,
        body: {'email': 'barakasikana@gmail.com', 'password': 'baraka540'},
      );

      print(response.body);
      print(response.statusCode);
      var res = json.decode(response.body);
      List output = [
        {
          'email': 'barakasikana@gmail.com',
          'id': 373,
          'firstName': 'baraka',
          'lastName': 'sikana'
        }
      ];
      print(res);
      if (response.statusCode == 200) {
        print('sm in');
        var result = (output as List).map((user) {
          print('Inserting $user');

          DBProvider.db.createUser(User.fromJson(user));
        }).toList();
        print(result);
        return 'Success';
      } else {
        return "failed";
      }
    } catch (e) {
      return 'Failed';
    }
  }
}
