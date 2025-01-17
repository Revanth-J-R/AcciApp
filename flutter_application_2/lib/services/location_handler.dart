import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHandler {
  String? currentAddress;
  Position? currentPosition;
  double? latitude; // Variable to store latitude
  double? longitude; // Variable to store longitude


  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      return Future.error('Location services are disabled.');
    }

    // Check location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, don't continue
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position of the device
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Store latitude and longitude
    latitude = currentPosition!.latitude;
    longitude = currentPosition!.longitude;


    // Convert coordinates to a human-readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentPosition!.latitude,
      currentPosition!.longitude,
    );

    Placemark place = placemarks[0];
    currentAddress =
        '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
  }
}
