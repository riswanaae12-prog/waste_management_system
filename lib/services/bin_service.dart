import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bin.dart';

class BinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBin(Bin bin) async {
    try {
      await _firestore.collection('bins').doc(bin.id).set(bin.toJson());
    } catch (e) {
      throw Exception('Failed to create bin: $e');
    }
  }

  Future<List<Bin>> getAllBins() async {
    try {
      final snapshot = await _firestore
          .collection('bins')
          .orderBy('lastUpdated', descending: true)
          .limit(50) // Limit the number of bins fetched
          .get();
      return snapshot.docs.map((doc) => Bin.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch bins: $e');
    }
  }

  Future<Bin?> getBinById(String binId) async {
    try {
      final doc = await _firestore.collection('bins').doc(binId).get();
      if (doc.exists) {
        return Bin.fromJson(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch bin: $e');
    }
  }

  Future<List<Bin>> getNearbyBins({
    required double userLat,
    required double userLng,
    double radiusInKm = 5.0,
  }) async {
    try {
      final allBins = await getAllBins();
      
      return allBins.where((bin) {
        final distance = calculateDistance(
          userLat,
          userLng,
          bin.latitude,
          bin.longitude,
        );
        return distance <= radiusInKm;
      }).toList()
        ..sort((a, b) {
          final distA = calculateDistance(
            userLat,
            userLng,
            a.latitude,
            a.longitude,
          );
          final distB = calculateDistance(
            userLat,
            userLng,
            b.latitude,
            b.longitude,
          );
          return distA.compareTo(distB);
        });
    } catch (e) {
      throw Exception('Failed to fetch nearby bins: $e');
    }
  }

  Future<List<Bin>> getFullBins() async {
    try {
      final snapshot = await _firestore
          .collection('bins')
          .where('status', isEqualTo: 'full')
          .orderBy('lastUpdated', descending: true)
          .limit(50) // Limit the number of full bins fetched
          .get();
      return snapshot.docs.map((doc) => Bin.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch full bins: $e');
    }
  }

  Future<void> updateBinStatus({
    required String binId,
    required String status,
    required double fillLevel,
  }) async {
    try {
      await _firestore.collection('bins').doc(binId).update({
        'status': status,
        'fillLevel': fillLevel,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update bin status: $e');
    }
  }

  Future<void> emptyBin(String binId) async {
    try {
      await _firestore.collection('bins').doc(binId).update({
        'status': 'available',
        'fillLevel': 0,
        'lastEmptied': DateTime.now().toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to empty bin: $e');
    }
  }

  Stream<Bin?> listenToBin(String binId) {
    return _firestore.collection('bins').doc(binId).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          return Bin.fromJson(snapshot.data() ?? {});
        }
        return null;
      },
    ).handleError((error) {
      throw Exception('Failed to listen to bin: $error');
    });
  }

  Stream<List<Bin>> listenToAllBins() {
    return _firestore
        .collection('bins')
        .orderBy('lastUpdated', descending: true)
        .limit(50) // Also limit the stream
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => Bin.fromJson(doc.data())).toList(),
    ).handleError((error) {
      throw Exception('Failed to listen to bins: $error');
    });
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}
