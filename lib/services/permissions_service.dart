import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  checkPermission() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      //add more permission to request here.
    ].request();

    if (statuses[Permission.location]!.isDenied) {
      //check each permission status after.
      print("Location permission is denied.");
    }

    if (statuses[Permission.camera]!.isDenied) {
      //check each permission status after.
      print("Camera permission is denied.");
    }
  }
}
