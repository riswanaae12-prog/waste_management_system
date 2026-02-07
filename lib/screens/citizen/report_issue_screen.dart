import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/bin.dart';
import '../../models/issue.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bin_provider.dart';
import '../../providers/issue_provider.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({Key? key}) : super(key: key);

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueDescriptionController = TextEditingController();
  final _otherLocationController = TextEditingController();
  final _binIdController = TextEditingController();
  Bin? _selectedBin;
  bool _isOtherLocation = false;
  String _issueType = 'general';
  String? _selectedDescription;
  bool _isSubmitting = false;

  final Map<String, List<String>> _descriptionOptions = {
    'general': [],
    'bin_full': ['Bin is overflowing', 'Bin is almost full'],
    'maintenance': ['Lid is broken', 'Sensor not working', 'Bin is damaged'],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BinProvider>().fetchAllBins();
    });
  }

  @override
  void dispose() {
    _issueDescriptionController.dispose();
    _otherLocationController.dispose();
    _binIdController.dispose();
    super.dispose();
  }

  Future<void> _submitIssue() async {
    if (_formKey.currentState!.validate()) {
      if (!_isOtherLocation && _selectedBin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location.')),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final authProvider = context.read<AuthProvider>();
      final issueProvider = context.read<IssueProvider>();
      final binProvider = context.read<BinProvider>();

      if (authProvider.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to report an issue.')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      try {
        Bin binToReport;
        if (_isOtherLocation) {
          List<Location> locations = await locationFromAddress(_otherLocationController.text);
          if (locations.isEmpty) {
            throw Exception('Could not determine location from the address.');
          }
          Location location = locations.first;

          final newBin = Bin(
            id: _binIdController.text,
            location: _otherLocationController.text,
            latitude: location.latitude,
            longitude: location.longitude,
            status: _issueType == 'bin_full' ? 'full' : 'available',
            fillLevel: _issueType == 'bin_full' ? 100.0 : 0.0,
            wasteType: 'general',
            capacity: 100.0,
            lastEmptied: DateTime.now(),
            lastUpdated: DateTime.now(),
          );
          await binProvider.addBin(newBin);
          binToReport = newBin;
        } else {
          binToReport = _selectedBin!;
          if (_issueType == 'bin_full') {
            final updatedBin =
                binToReport.copyWith(status: 'full', fillLevel: 100.0);
            await binProvider.updateBin(updatedBin);
          }
        }

        String description = _issueType == 'general'
            ? _issueDescriptionController.text
            : _selectedDescription ?? '';

        final success = await issueProvider.createIssue(
          userId: authProvider.user!.id,
          binId: binToReport.id,
          title: _issueType == 'bin_full' ? 'Bin Full' : 'General Issue',
          description: description,
          issueType: _issueType,
          imageUrls: [],
        );

        if (success) {
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to report issue. Please try again.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Stack(
        children: [
          Consumer<BinProvider>(
            builder: (context, binProvider, _) {
              if (binProvider.isLoading && binProvider.allBins.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final dropdownItems = binProvider.allBins.map((Bin bin) {
                return DropdownMenuItem<Bin>(
                  value: bin,
                  child: Text(bin.location),
                );
              }).toList();

              dropdownItems.insert(
                0,
                const DropdownMenuItem<Bin>(
                  value: null, // Representing "Other"
                  child: Text('Other Location'),
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<Bin?>(
                        value: _selectedBin,
                        decoration: const InputDecoration(labelText: 'Location'),
                        items: dropdownItems,
                        onChanged: (Bin? newValue) {
                          setState(() {
                            _selectedBin = newValue;
                            if (newValue == null) {
                              _isOtherLocation = true;
                              _binIdController.text = '';
                              _otherLocationController.text = '';
                            } else {
                              _isOtherLocation = false;
                              _binIdController.text = newValue.id;
                            }
                          });
                        },
                      ),
                      if (_isOtherLocation)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _otherLocationController,
                                decoration: const InputDecoration(
                                  labelText: 'Location Name',
                                  hintText: 'Enter a full address for accurate location',
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a location name'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _binIdController,
                          decoration: const InputDecoration(labelText: 'Bin ID'),
                          readOnly: !_isOtherLocation,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bin ID is required';
                            }
                            return null;
                          }),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _issueType,
                        decoration: const InputDecoration(labelText: 'Issue Type'),
                        items: const [
                          DropdownMenuItem(
                            value: 'general',
                            child: Text('General Issue'),
                          ),
                          DropdownMenuItem(
                            value: 'bin_full',
                            child: Text('Bin Full'),
                          ),
                          DropdownMenuItem(
                            value: 'maintenance',
                            child: Text('Needs Maintenance'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _issueType = newValue;
                              _selectedDescription = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_issueType == 'general')
                        TextFormField(
                          controller: _issueDescriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Issue Description',
                            hintText: 'Describe the issue in detail',
                          ),
                          maxLines: 5,
                          validator: (value) =>
                              value!.isEmpty ? 'Please describe the issue' : null,
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedDescription,
                          decoration: const InputDecoration(
                              labelText: 'Issue Description'),
                          items: _descriptionOptions[_issueType]!
                              .map((String description) {
                            return DropdownMenuItem<String>(
                              value: description,
                              child: Text(description),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDescription = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a description' : null,
                        ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitIssue,
                          child: const Text('Submit Issue'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
