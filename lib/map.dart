import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';


class MapPage extends StatefulWidget {
   const MapPage(
      {super.key,
      required this.data});
    final List<List<String>> data;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;
  late LatLng _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  // Get the current location of the device
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          point: _currentPosition,
          child: ColoredBox(color: Colors.black)
          //builder: (ctx) => Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
    });

    // Move the map's camera to the current location
    _mapController.move(_currentPosition, 14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Map with GPS Coordinates')),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
               // center: _currentPosition,
                maxZoom: 14,
                //interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: _markers.toList()),
              ],
            ),
    );
  }
}
