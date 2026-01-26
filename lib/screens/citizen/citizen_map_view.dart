import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/bin_provider.dart';

class CitizenMapView extends StatelessWidget {
  const CitizenMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BinProvider>(
      builder: (context, binProvider, _) {
        // Show a loading indicator while the user's location and bins are being fetched.
        if (binProvider.isLoading || binProvider.currentPosition == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Create map markers from the list of nearby bins.
        final markers = binProvider.nearbyBins.map((bin) {
          return Marker(
            markerId: MarkerId(bin.id),
            position: LatLng(bin.latitude, bin.longitude),
            infoWindow: InfoWindow(
              title: bin.location,
              snippet: 'Fill Level: ${bin.fillLevel.toStringAsFixed(1)}% (${bin.status})',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              bin.status == 'full' ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
            ),
          );
        }).toSet();

        // Set the initial camera position to the user's current location.
        final initialCameraPosition = CameraPosition(
          target: LatLng(
            binProvider.currentPosition!.latitude,
            binProvider.currentPosition!.longitude,
          ),
          zoom: 14.0, // A comfortable zoom level to see the neighborhood.
        );

        return GoogleMap(
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          myLocationEnabled: true, // Show the user's blue dot on the map.
          myLocationButtonEnabled: true, // Show the button to center on the user's location.
        );
      },
    );
  }
}
