import 'package:flutter/material.dart';

// Data model for a garbage bin
class Bin {
  final String id;
  final String location;
  final BinStatus status;

  const Bin({required this.id, required this.location, required this.status});
}

// Enum for bin status
enum BinStatus { Empty, Half, Full, Overflowing }

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({Key? key}) : super(key: key);

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  // Sample data for the bins
  final List<Bin> _bins = [
    const Bin(id: 'BIN-001', location: 'Main Street Plaza', status: BinStatus.Full),
    const Bin(id: 'BIN-002', location: 'Central Park Entrance', status: BinStatus.Half),
    const Bin(id: 'BIN-003', location: 'City Hall Parking', status: BinStatus.Empty),
    const Bin(id: 'BIN-004', location: 'Library Courtyard', status: BinStatus.Overflowing),
    const Bin(id: 'BIN-005', location: 'Market Square', status: BinStatus.Half),
    const Bin(id: 'BIN-006', location: 'Bus Terminal', status: BinStatus.Full),
  ];

  // Helper to get status color
  Color _getStatusColor(BinStatus status) {
    switch (status) {
      case BinStatus.Full:
        return Colors.orange;
      case BinStatus.Overflowing:
        return Colors.red;
      case BinStatus.Half:
        return Colors.yellow.shade700;
      case BinStatus.Empty:
      default:
        return Colors.green;
    }
  }

  // Helper to get status icon
  IconData _getStatusIcon(BinStatus status) {
    switch (status) {
      case BinStatus.Full:
        return Icons.delete;
      case BinStatus.Overflowing:
        return Icons.delete_forever;
      case BinStatus.Half:
        return Icons.delete_outline;
      case BinStatus.Empty:
      default:
        return Icons.check_circle_outline;
    }
  }

  // Helper to get status text
  String _getStatusText(BinStatus status) {
    return status.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    // Removed the Scaffold and AppBar from this widget.
    // It will now be displayed correctly within the main screen's Scaffold.
    return RefreshIndicator(
      onRefresh: () async {
        // In a real app, you would fetch updated data here.
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _bins.length,
        itemBuilder: (context, index) {
          final bin = _bins[index];
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
                  _getStatusText(bin.status),
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
  }
}
