import 'package:geolocator/geolocator.dart';

class Place {
  String title;
  double lat;
  double long;

  Place(String title, double lat, double long) {
    this.title = title;
    this.lat = lat;
    this.long = long;
  }

  getTitle(){
    return this.title;
  }

  // Future<Position> getCurrentLocation() async {
  //   Position res = await geolocator.getCurrentPosition();
  //   position = res;

  //   // String lul = position.latitude.toString();
  //   print(position);
  //   return position;
  // }
}
