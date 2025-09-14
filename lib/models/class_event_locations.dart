import 'package:latlong2/latlong.dart';

class EventLocation {
  final String name;
  final String date;
  final LatLng location;

  EventLocation(
      {required this.name, required this.date, required this.location});
}
