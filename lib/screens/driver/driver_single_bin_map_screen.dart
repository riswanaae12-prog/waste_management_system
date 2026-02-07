import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/bin.dart';

class DriverSingleBinMapScreen extends StatefulWidget {
  final Bin bin;

  const DriverSingleBinMapScreen({Key? key, required this.bin}) : super(key: key);

  @override
  State<DriverSingleBinMapScreen> createState() => _DriverSingleBinMapScreenState();
}

class _DriverSingleBinMapScreenState extends State<DriverSingleBinMapScreen> {
  late GoogleMapController _mapController;

  Future<void> _launchGoogleMaps() async {
    final lat = widget.bin.latitude;
    final lng = widget.bin.longitude;

    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch a map application. Please ensure one is installed.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = CameraPosition(
      target: LatLng(widget.bin.latitude, widget.bin.longitude),
      zoom: 16,
    );

    final marker = Marker(
      markerId: MarkerId(widget.bin.id),
      position: LatLng(widget.bin.latitude, widget.bin.longitude),
      infoWindow: InfoWindow(
        title: widget.bin.location,
        snippet: 'Fill Level: ${widget.bin.fillLevel.toStringAsFixed(1)}%',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Location of Bin ${widget.bin.id}'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {marker},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launchGoogleMaps,
        label: const Text('Get Directions'),
        icon: const Icon(Icons.directions),
        backgroundColor: Colors.blue.shade700,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
