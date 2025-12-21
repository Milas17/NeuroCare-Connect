import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:nb_utils/nb_utils.dart';

Future<bool> handlePermission() async {
  final GeolocatorPlatform geoLocator = GeolocatorPlatform.instance;

  bool serviceEnabled = await geoLocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    appStore.setLocationPermission(false);

    try {
      toast('Location services are disabled. Opening settings...');
      bool opened = await Geolocator.openLocationSettings();

      if (!opened) {
        toast('Unable to open settings automatically. Please enable location services manually.');
      }
    } catch (e) {
      log('Error opening location settings: $e');
      toast('Please enable location services in your device settings.');
    }

    return false;
  }

  LocationPermission permission = await geoLocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await geoLocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      appStore.setLocationPermission(false);
      return false;
    }
  } else if (permission == LocationPermission.deniedForever) {
    appStore.setLocationPermission(false);

    try {
      toast('Location permission required. Opening app settings...');
      bool opened = await Geolocator.openAppSettings();

      if (!opened) {
        toast('Unable to open settings automatically. Please enable location permission in app settings.');
      }
    } catch (e) {
      log('Error opening app settings: $e');
      toast('Please enable location permission in your device settings.');
    }

    return false;
  }

  appStore.setLocationPermission(true);
  return true;
}

Future<Position> getUserLocationPosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  LocationPermission permission = await Geolocator.checkPermission();
  if (!serviceEnabled) {
    appStore.setLocationPermission(false);
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.openAppSettings();
      throw locale.lblPermissionDenied;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Location Permission Denied Permanently';
  }

  return await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high)).then((value) {
    return value;
  }).catchError((e) async {
    return await Geolocator.getLastKnownPosition().then((value) async {
      if (value != null) {
        return value;
      } else {
        throw 'Enable Location';
      }
    // ignore: body_might_complete_normally_catch_error
    }).catchError((e) {
      toast(e.toString());
    });
  }).whenComplete(() {
    appStore.setLoading(false);
  });
}

Future<String> getUserLocation() async {
  Position position = await getUserLocationPosition().catchError((e) {
    throw e.toString();
  });

  return await buildFullAddressFromLatLong(position.latitude, position.longitude);
}

Future<String> buildFullAddressFromLatLong(double latitude, double longitude) async {
  List<Placemark> placeMark = await placemarkFromCoordinates(latitude, longitude).catchError((e) async {
    log(e);
    throw errorSomethingWentWrong;
  });

  setValue(SharedPreferenceKey.latitudeKey, latitude);
  setValue(SharedPreferenceKey.longitudeKey, longitude);

  Placemark place = placeMark[0];

  log(place.toJson());

  String address = '';

  if (!place.name.isEmptyOrNull && !place.street.isEmptyOrNull && place.name != place.street) address = '${place.name.validate()}, ';
  if (!place.street.isEmptyOrNull) address = '$address${place.street.validate()}';
  if (!place.locality.isEmptyOrNull) address = '$address, ${place.locality.validate()}';
  if (!place.administrativeArea.isEmptyOrNull) address = '$address, ${place.administrativeArea.validate()}';
  if (!place.postalCode.isEmptyOrNull) address = '$address, ${place.postalCode.validate()}';
  if (!place.country.isEmptyOrNull) address = '$address, ${place.country.validate()}';

  setValue(SharedPreferenceKey.currentAddressKey, address);

  return address;
}
