import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import 'report_issue_screen.dart';
import 'issue_details_screen.dart';

class CitizenIssuesView extends StatefulWidget {
  const CitizenIssuesView({Key? key}) : super(key: key);

  @override
  State<CitizenIssuesView> createState() => _CitizenIssuesViewState();
}

class _CitizenIssuesViewState extends State<CitizenIssuesView> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This method is called when dependencies change, including when the user logs in.
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.user != null && !_hasFetched) {
      // We have a user and we haven't fetched the data yet.
      setState(() {
        _hasFetched = true; // Mark as fetched to prevent multiple calls.
      });
      // Fetch the issues for the logged-in user.
      context.read<IssueProvider>().fetchUserIssues(authProvider.user!.id);
    }
  }

  void _fetchIssues() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<IssueProvider>().fetchUserIssues(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueProvider>(
      builder: (context, issueProvider, _) {
        final authProvider = context.watch<AuthProvider>();

        // If we are still waiting for a user, show a simple loading indicator.
        if (authProvider.user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => _fetchIssues(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (context) => const ReportIssueScreen(),
                        ),
                      );
                      if (result == true) {
                        _fetchIssues();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Report Issue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Issues',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (issueProvider.isLoading && issueProvider.userIssues.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (issueProvider.userIssues.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No issues reported yet'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: issueProvider.userIssues.length,
                      itemBuilder: (context, index) {
                        final issue = issueProvider.userIssues[index];
                        final statusColor = issue.status == 'open'
                            ? Colors.orange
                            : issue.status == 'in_progress'
                                ? Colors.blue
                                : Colors.green;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: statusColor,
                              child: Icon(
                                _getIssueIcon(issue.issueType),
                                color: Colors.white,
                              ),
                            ),
                            title: Text('Issue ID: ${issue.id}'),
                            subtitle: Text(issue.title),
                            trailing: Icon(
                              Icons.arrow_forward,
                              color: Colors.green.shade700,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      IssueDetailsScreen(issue: issue),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIssueIcon(String issueType) {
    switch (issueType) {
      case 'overflow':
        return Icons.water;
      case 'damage':
        return Icons.build;
      case 'sensor_malfunction':
        return Icons.sensors;
      case 'bin_full':
        return Icons.delete_sweep;
      default:
        return Icons.warning;
    }
  }
}
