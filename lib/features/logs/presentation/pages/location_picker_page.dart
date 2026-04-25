import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    final newLoc = LatLng(position.latitude, position.longitude);
    
    setState(() {
      _pickedLocation = newLoc;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLoc, 15));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Location', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        actions: [
          if (_pickedLocation != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _pickedLocation),
              child: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation ?? const LatLng(0, 0),
              zoom: widget.initialLocation != null ? 15 : 2,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (loc) => setState(() => _pickedLocation = loc),
            markers: _pickedLocation == null ? {} : {
              Marker(markerId: const MarkerId('picked'), position: _pickedLocation!),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_pickedLocation == null)
            const Center(
              child: Card(
                color: Colors.black87,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Tap on map to pick a location', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
