import 'package:honeytrackapp/providers/db_provider.dart';

class JobsApiProvider {
  static Future<void> storeJob(
      String personId,
      String id,
      String activity,
      String jobname,
      String tasktype,
      String ids,
      String hiveNo,
      String taskActivityId,
      String role) async {
    var x = await DBProvider.db.checkJob(id);
    if (x! > 0) {
      print("job Exists");
    } else {
      var resul = {
        "person_id": personId,
        "job_id": id,
        "activity": activity,
        "jobname": jobname,
        "tasktype": tasktype,
        "apiary_id": ids,
        "hiveNo": hiveNo,
        "role": role,
        "hive_attended": "1",
        "task_activity_id": taskActivityId
      };
      DBProvider.db.createJobs(resul);
    }
  }
}
