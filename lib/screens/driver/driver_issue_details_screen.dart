import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/issue.dart';
import '../../providers/bin_provider.dart';
import '../../models/bin.dart';

class DriverIssueDetailsScreen extends StatelessWidget {
  final Issue issue;

  const DriverIssueDetailsScreen({Key? key, required this.issue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Bin? bin;
    try {
      bin = context.watch<BinProvider>().allBins.firstWhere((b) => b.id == issue.binId);
    } catch (e) {
      bin = null; // Bin not found, which is a valid case
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(issue.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Status', issue.status),
                const SizedBox(height: 12),
                _buildDetailRow('Location', bin?.location ?? 'N/A'),
                const SizedBox(height: 12),
                _buildDetailRow('Bin ID', issue.binId),
                const SizedBox(height: 12),
                _buildDetailRow('Description', issue.description),
                const SizedBox(height: 12),
                _buildDetailRow('Reported At', issue.createdAt.toLocal().toString()),
                if (issue.resolution != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: _buildDetailRow('Resolution', issue.resolution!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
