import 'package:flutter/material.dart';
import '../models/bin.dart';
import '../services/bin_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class BinProvider extends ChangeNotifier {
  final BinService _binService = BinService();
  final LocationService _locationService = LocationService();

  List<Bin> _allBins = [];
  List<Bin> _nearbyBins = [];
  List<Bin> _fullBins = [];
  Bin? _selectedBin;
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  // Getters
  List<Bin> get allBins => _allBins;
  List<Bin> get nearbyBins => _nearbyBins;
  List<Bin> get fullBins => _fullBins;
  Bin? get selectedBin => _selectedBin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  Future<void> initializeLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      await fetchNearbyBins();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addBin(Bin bin) async {
    try {
      await _binService.createBin(bin);
      _allBins.add(bin);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateBin(Bin bin) async {
    try {
      await _binService.updateBinStatus(
        binId: bin.id,
        status: bin.status,
        fillLevel: bin.fillLevel,
      );
      final index = _allBins.indexWhere((b) => b.id == bin.id);
      if (index != -1) {
        _allBins[index] = bin;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchAllBins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch existing bins from the database
      List<Bin> existingBins = await _binService.getAllBins();

      // Define the mock bins from your script
      final now = DateTime.now();
      final mockBins = [
        Bin(id: 'BIN-001', location: 'Main Street Park', latitude: 9.9312, longitude: 76.2673, status: 'available', fillLevel: 60.5, wasteType: 'general', capacity: 100.0, lastEmptied: now.subtract(const Duration(days: 1)), lastUpdated: now),
        Bin(id: 'BIN-007', location: 'City Center Mall', latitude: 9.9392, longitude: 76.2736, status: 'full', fillLevel: 100.0, wasteType: 'recyclable', capacity: 120.0, lastEmptied: now.subtract(const Duration(days: 2)), lastUpdated: now),
        Bin(id: 'BIN-012', location: 'Lakeside Promenade', latitude: 9.9667, longitude: 76.2844, status: 'maintenance', fillLevel: 15.0, wasteType: 'organic', capacity: 100.0, lastEmptied: now.subtract(const Duration(hours: 12)), lastUpdated: now),
      ];

      // Seed the database with mock bins if they don't exist
      for (var mockBin in mockBins) {
        if (!existingBins.any((b) => b.id == mockBin.id)) {
          await _binService.createBin(mockBin);
          existingBins.add(mockBin); // Add to the list to prevent re-fetching
        }
      }
      _allBins = existingBins;

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNearbyBins({double radiusInKm = 5.0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_allBins.isEmpty) {
        await fetchAllBins();
      }
      _nearbyBins = _allBins;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFullBins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_allBins.isEmpty) {
        await fetchAllBins();
      }
      _fullBins = _allBins.where((bin) => bin.status == 'full').toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectBin(String binId) async {
    try {
      _selectedBin = await _binService.getBinById(binId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearSelectedBin() {
    _selectedBin = null;
    notifyListeners();
  }

  void listenToAllBins() {
    _binService.listenToAllBins().listen((bins) {
      _allBins = bins;
      notifyListeners();
    }).onError((error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  void listenToSelectedBin(String binId) {
    _binService.listenToBin(binId).listen((bin) {
      _selectedBin = bin;
      notifyListeners();
    }).onError((error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
