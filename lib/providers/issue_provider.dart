import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/issue.dart';
import '../models/bin.dart';
import '../services/issue_service.dart';
import 'package:uuid/uuid.dart';
import 'bin_provider.dart';

class IssueProvider extends ChangeNotifier {
  final IssueService _issueService = IssueService();

  List<Issue> _userIssues = [];
  List<Issue> _allOpenIssues = [];
  Issue? _selectedIssue;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Issue> get userIssues => _userIssues;
  List<Issue> get allOpenIssues => _allOpenIssues;
  Issue? get selectedIssue => _selectedIssue;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserIssues(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userIssues = await _issueService.getIssuesByUserId(userId);
      _userIssues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveIssues() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allOpenIssues = await _issueService.getActiveIssues();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createIssue({
    required String userId,
    required String binId,
    required String title,
    required String description,
    required String issueType,
    required List<String> imageUrls,
  }) async {
    try {
      await _issueService.createIssue(
        userId: userId,
        binId: binId,
        title: title,
        description: description,
        issueType: issueType,
        imageUrls: imageUrls,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteIssue(String issueId) async {
    try {
      await _issueService.deleteIssue(issueId);
      _userIssues.removeWhere((issue) => issue.id == issueId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateIssueStatus({
    required String issueId,
    required String status,
    String? resolution,
    required BinProvider binProvider,
  }) async {
    try {
      await _issueService.updateIssueStatus(
        issueId: issueId,
        status: status,
        resolution: resolution,
      );

      Issue? issueToUpdate;

      final userIndex = _userIssues.indexWhere((issue) => issue.id == issueId);
      if (userIndex != -1) {
        issueToUpdate = _userIssues[userIndex];
        _userIssues[userIndex] = issueToUpdate.copyWith(
          status: status,
          resolution: resolution,
        );
      }

      final openIndex = _allOpenIssues.indexWhere((issue) => issue.id == issueId);
      if (openIndex != -1) {
        if (issueToUpdate == null) {
          issueToUpdate = _allOpenIssues[openIndex];
        }
        _allOpenIssues[openIndex] = _allOpenIssues[openIndex].copyWith(
          status: status,
          resolution: resolution,
        );
      }

      if (issueToUpdate != null &&
          status == 'resolved' &&
          issueToUpdate.issueType == 'bin_full') {
        final bin = binProvider.allBins.firstWhere((b) => b.id == issueToUpdate!.binId);
        final updatedBin = bin.copyWith(status: 'available', fillLevel: 0.0);
        await binProvider.updateBin(updatedBin);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> selectIssue(String issueId) async {
    try {
      _selectedIssue = _userIssues.firstWhere((issue) => issue.id == issueId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearSelectedIssue() {
    _selectedIssue = null;
    notifyListeners();
  }

  void listenToUserIssues(String userId) {
    _issueService.listenToUserIssues(userId).listen((issues) {
      _userIssues = issues;
      _userIssues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
