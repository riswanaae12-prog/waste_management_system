import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bin.dart';
import '../../providers/bin_provider.dart';

class CitizenHomeView extends StatefulWidget {
  const CitizenHomeView({Key? key}) : super(key: key);

  @override
  State<CitizenHomeView> createState() => _CitizenHomeViewState();
}

class _CitizenHomeViewState extends State<CitizenHomeView> {

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely access the provider after the build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch nearby bins when the screen loads.
      context.read<BinProvider>().fetchNearbyBins();
    });
  }

  // Helper to get status color from the Bin model's string status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'full':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      case 'available':
      default:
        return Colors.green;
    }
  }

  // Helper to get status icon from the Bin model's string status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'full':
        return Icons.delete_forever;
      case 'maintenance':
        return Icons.build;
      case 'available':
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BinProvider>(
      builder: (context, binProvider, _) {
        if (binProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (binProvider.error != null) {
          return Center(child: Text('Error: ${binProvider.error}'));
        }

        final bins = binProvider.nearbyBins;

        if (bins.isEmpty) {
          return const Center(child: Text('No nearby bins found.'));
        }

        return RefreshIndicator(
          onRefresh: () => binProvider.fetchNearbyBins(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: bins.length,
            itemBuilder: (context, index) {
              final bin = bins[index];
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  leading: Icon(
                    _getStatusIcon(bin.status),
                    color: _getStatusColor(bin.status),
                    size: 40,
                  ),
                  title: Text(
                    bin.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(bin.location),
                  trailing: Chip(
                    label: Text(
                      bin.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(bin.status),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
