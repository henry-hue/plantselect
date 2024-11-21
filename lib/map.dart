import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.data});
  final List<List<String>> data;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};

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

      int lengthData = widget.data.length;
      for (var i = 0; i < lengthData; i++) {
        double latitude = double.parse(widget.data[i][6]);
        double longitude = double.parse(widget.data[i][7]);
        LatLng plant = LatLng(latitude, longitude);

        _markers.add(
          Marker(
            point: plant,
            child: Text(widget.data[i][1]),
            width: 60,
            height: 60,
            //builder: (ctx) => Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
      }

      _markers.add(
        Marker(point: _currentPosition!, child: ClipOval(child:ColoredBox(color: Colors.blue))
            //builder: (ctx) => Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
      );
    });

    // Move the map's camera to the current location
    _mapController.move(_currentPosition!, 60);
  }

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? Center(child: CircularProgressIndicator())
        : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition!,
              // center: _currentPosition,
              maxZoom: 60,
              //interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers.toList()),
            ],
          );
  }
}
