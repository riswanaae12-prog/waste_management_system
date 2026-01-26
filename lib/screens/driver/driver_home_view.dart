import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bin_provider.dart';
import '../../models/bin.dart';
import 'driver_single_bin_map_screen.dart';

class DriverHomeView extends StatefulWidget {
  const DriverHomeView({Key? key}) : super(key: key);

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BinProvider>().fetchFullBins();
    });
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

        final fullBins = binProvider.fullBins
            .where((bin) => bin.status != 'resolved')
            .toList();

        if (fullBins.isEmpty) {
          return const Center(
            child: Text(
              'No full bins to collect.',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => binProvider.fetchFullBins(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: fullBins.length,
            itemBuilder: (context, index) {
              final bin = fullBins[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bin ID: ${bin.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Location: ${bin.location}'),
                      const SizedBox(height: 8),
                      Text(
                        'Fill Level: ${bin.fillLevel.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DriverSingleBinMapScreen(bin: bin),
                              ),
                            );
                          },
                          icon: const Icon(Icons.location_on),
                          label: const Text('Locate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
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
