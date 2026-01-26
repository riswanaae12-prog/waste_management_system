import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../providers/bin_provider.dart';
import '../../models/issue.dart';
import 'driver_issue_details_screen.dart';

class DriverActivitiesView extends StatefulWidget {
  const DriverActivitiesView({Key? key}) : super(key: key);

  @override
  State<DriverActivitiesView> createState() => _DriverActivitiesViewState();
}

class _DriverActivitiesViewState extends State<DriverActivitiesView> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.user != null && !_hasFetched) {
      setState(() {
        _hasFetched = true;
      });
      _fetchIssues();
    }
  }

  Future<void> _fetchIssues() async {
    await context.read<IssueProvider>().fetchActiveIssues();
  }

  void _showCloseIssueDialog(BuildContext context, Issue issue) {
    final resolutionController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Close Issue'),
          content: TextField(
            controller: resolutionController,
            decoration: const InputDecoration(
              hintText: 'Add a comment (e.g., \'Collected the garbage\')',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (resolutionController.text.isNotEmpty) {
                  context.read<IssueProvider>().updateIssueStatus(
                        issueId: issue.id,
                        status: 'resolved',
                        resolution: resolutionController.text,
                        binProvider: context.read<BinProvider>(),
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueProvider>(
      builder: (context, issueProvider, _) {
        if (issueProvider.isLoading && issueProvider.allOpenIssues.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (issueProvider.error != null) {
          return Center(child: Text('Error: ${issueProvider.error}'));
        }

        final binFullIssues = issueProvider.allOpenIssues
            .where((issue) => issue.issueType == 'bin_full')
            .toList();

        if (binFullIssues.isEmpty) {
          return const Center(
            child: Text(
              'No active issues to display.',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchIssues,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: binFullIssues.length,
            itemBuilder: (context, index) {
              final issue = binFullIssues[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('Issue ID: ${issue.id}'),
                  subtitle: Text(issue.title),
                  trailing: issue.status == 'open'
                      ? ElevatedButton(
                          onPressed: () {
                            issueProvider.updateIssueStatus(
                              issueId: issue.id,
                              status: 'in_progress',
                              binProvider: context.read<BinProvider>(),
                            );
                          },
                          child: const Text('Accept'),
                        )
                      : issue.status == 'in_progress'
                          ? ElevatedButton(
                              onPressed: () =>
                                  _showCloseIssueDialog(context, issue),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text('Close Issue'),
                            )
                          : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            DriverIssueDetailsScreen(issue: issue),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
