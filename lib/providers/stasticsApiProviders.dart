import 'package:honeytrackapp/providers/db_provider.dart';
import 'package:honeytrackapp/services/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatisticsApiProvider {
  Future<String> getstats(String token) async {
    try {
      print("stats");
      var headers = {"Authorization": "Bearer " + token};
      var url = Uri.parse('$baseUrl/api/v1/dashboard');
      var response = await http.get(url, headers: headers);
      print(response.body);
      print(response.statusCode);
      var res = json.decode(response.body);
      print(res);
      print(res['apiaries']);
      print(res['beekeepers']);
      print(res['dealers']);
      print(res['transitPass']);
      var resul = {
        "apiaries": 20,
        "beekeepers": 239,
        "dealers": 34,
        "transitPass": 78
      };
      print(resul);
      if (response.statusCode == 200) {
        DBProvider.db.createStats(resul);
        return 'Success';
      } else {
        return "failed";
      }
    } catch (e) {
      return 'Failed';
    }
  }
}
