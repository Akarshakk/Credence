import 'package:flutter/material.dart';
import '../models/group.dart';

class SplitWiseProvider extends ChangeNotifier {
  List<Group> _groups = [];
  Group? _currentGroup;
  bool _isLoading = false;
  String? _errorMessage;

  List<Group> get groups => _groups;
  Group? get currentGroup => _currentGroup;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Generate a unique 6-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecond;
    final codeList = <String>[];
    var seed = random;
    for (int i = 0; i < 6; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      codeList.add(chars[seed % chars.length]);
    }
    return codeList.join();
  }

  // Fetch all groups for current user
  Future<void> fetchGroups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Call API to fetch groups
      // For now, return local groups
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get group by ID
  Future<void> fetchGroupById(String groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Call API to fetch group details
      _currentGroup = _groups.firstWhere((g) => g.id == groupId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new group
  Future<bool> createGroup({
    required String name,
    required String description,
    required List<String> memberEmails,
    required String userId,
    required String userName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Generate ID and invite code
      final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
      final inviteCode = _generateInviteCode();
      
      // Create group with current user as creator and member
      final group = Group(
        id: groupId,
        name: name,
        description: description,
        members: [
          GroupMember(
            userId: userId,
            name: userName,
            email: memberEmails.isNotEmpty ? memberEmails.first : 'user@example.com',
          ),
        ],
        expenses: [],
        createdAt: DateTime.now(),
        createdBy: userId,
        imageUrl: '',
        inviteCode: inviteCode,
      );

      // Add to local groups
      _groups.add(group);
      
      // TODO: Call API to create group
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add expense to group with split
  Future<bool> addGroupExpense({
    required String groupId,
    required String description,
    required double amount,
    required String category,
    required String paidBy,
    required String paidByName,
    required List<GroupExpenseSplit> splits,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Find group
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex == -1) {
        throw Exception('Group not found');
      }

      // Create expense
      final expense = GroupExpense(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        groupId: groupId,
        paidBy: paidBy,
        paidByName: paidByName,
        amount: amount,
        description: description,
        splits: splits,
        date: DateTime.now(),
        category: category,
      );

      // Add expense to group
      _groups[groupIndex].expenses.add(expense);

      // Update member balances
      for (var split in splits) {
        final memberIndex = _groups[groupIndex].members
            .indexWhere((m) => m.userId == split.memberId);
        if (memberIndex != -1) {
          final member = _groups[groupIndex].members[memberIndex];
          _groups[groupIndex].members[memberIndex] = GroupMember(
            userId: member.userId,
            name: member.name,
            email: member.email,
            amountOwed: member.amountOwed + split.amount,
            amountLent: member.amountLent,
          );
        }
      }

      // Update payer's balance
      final payerIndex = _groups[groupIndex].members
          .indexWhere((m) => m.userId == paidBy);
      if (payerIndex != -1) {
        final member = _groups[groupIndex].members[payerIndex];
        _groups[groupIndex].members[payerIndex] = GroupMember(
          userId: member.userId,
          name: member.name,
          email: member.email,
          amountOwed: member.amountOwed,
          amountLent: member.amountLent + amount,
        );
      }

      // TODO: Call API to add expense
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Settle up between two members
  Future<bool> settleExpense({
    required String groupId,
    required String fromMemberId,
    required String toMemberId,
    required double amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Call API to settle expense
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add member to group
  void addMemberToGroup({
    required String groupId,
    required String userId,
    required String name,
    required String email,
  }) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      final newMember = GroupMember(
        userId: userId,
        name: name,
        email: email,
      );
      _groups[groupIndex].members.add(newMember);
      notifyListeners();
    }
  }

  // Join group using invite code
  Future<bool> joinGroupByCode({
    required String inviteCode,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Find group by invite code
      final groupIndex = _groups.indexWhere((g) => g.inviteCode == inviteCode);
      
      if (groupIndex == -1) {
        _errorMessage = 'Invalid invite code';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if user is already a member
      final group = _groups[groupIndex];
      final isMember = group.members.any((m) => m.userId == userId);
      
      if (isMember) {
        _errorMessage = 'You are already a member of this group';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Add user to group
      final newMember = GroupMember(
        userId: userId,
        name: userName,
        email: userEmail,
      );
      _groups[groupIndex].members.add(newMember);

      // TODO: Call API to join group
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a group
  void deleteGroup(String groupId) {
    _groups.removeWhere((g) => g.id == groupId);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
