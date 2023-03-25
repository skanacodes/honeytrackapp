import 'package:honeytrackapp/modals/job_modals.dart';
import 'package:honeytrackapp/providers/db_provider.dart';

class ApiaryJobsApiProvider {
  Future<void> getAllJobs(data, String? userId) async {
    data.map((inventory) async {
      // print('Inserting $inventory');
      await DBProvider.db
          .createJobsList(JobModals.fromJson(inventory, userId: userId));
      //print("djbj");
    }).toList();
  }
}
