import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/issue.dart';

class IssueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createIssue({
    required String userId,
    required String binId,
    required String title,
    required String description,
    required String issueType,
    required List<String> imageUrls,
  }) async {
    try {
      final docRef = await _firestore.collection('issues').add({
        'userId': userId,
        'binId': binId,
        'title': title,
        'description': description,
        'issueType': issueType,
        'images': imageUrls,
        'status': 'open',
        'createdAt': DateTime.now().toIso8601String(),
        'resolvedAt': null,
        'resolution': null,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create issue: $e');
    }
  }

  Future<void> deleteIssue(String issueId) async {
    try {
      await _firestore.collection('issues').doc(issueId).delete();
    } catch (e) {
      throw Exception('Failed to delete issue: $e');
    }
  }

  Future<List<Issue>> getIssuesByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('issues')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50) // Limit the number of issues fetched
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Issue.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user issues: $e');
    }
  }

  Future<List<Issue>> getActiveIssues() async {
    try {
      final snapshot = await _firestore
          .collection('issues')
          .where('status', whereIn: ['open', 'in_progress'])
          .orderBy('createdAt', descending: true)
          .limit(50) // Limit the number of issues fetched
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Issue.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch active issues: $e');
    }
  }

  Future<void> updateIssueStatus({
    required String issueId,
    required String status,
    String? resolution,
  }) async {
    try {
      final updateData = {
        'status': status,
        if (status == 'resolved') 'resolvedAt': DateTime.now().toIso8601String(),
        if (resolution != null) 'resolution': resolution,
      };

      await _firestore.collection('issues').doc(issueId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update issue: $e');
    }
  }

  Future<Issue?> getIssueById(String issueId) async {
    try {
      final doc = await _firestore.collection('issues').doc(issueId).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        data['id'] = doc.id;
        return Issue.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch issue: $e');
    }
  }

  Stream<List<Issue>> listenToUserIssues(String userId) {
    return _firestore
        .collection('issues')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50) // Also limit the stream
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Issue.fromJson(data);
            }).toList())
        .handleError((error) {
      throw Exception('Failed to listen to issues: $error');
    });
  }
}
