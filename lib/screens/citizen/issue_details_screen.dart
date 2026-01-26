import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/bin_provider.dart';
import '../../models/issue.dart';
import '../../models/bin.dart';

class IssueDetailsScreen extends StatelessWidget {
  final Issue issue;

  const IssueDetailsScreen({Key? key, required this.issue}) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Issue'),
          content: const Text('Are you sure you want to delete this issue?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                final issueProvider = context.read<IssueProvider>();
                issueProvider.deleteIssue(issue.id);
                Navigator.of(dialogContext).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issue Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Status', issue.status),
                    const SizedBox(height: 12),
                    _buildDetailRow('Location', bin?.location ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Bin ID', issue.binId),
                    const SizedBox(height: 12),
                    _buildDetailRow('Description', issue.description),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Reported At',
                      issue.createdAt.toLocal().toString(),
                    ),
                    if (issue.resolution != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: _buildDetailRow('Resolution', issue.resolution!),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
