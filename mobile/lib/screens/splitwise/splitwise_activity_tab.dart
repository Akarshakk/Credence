import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/splitwise_provider.dart';
import '../../providers/auth_provider.dart';

class SplitwiseActivityTab extends StatelessWidget {
  const SplitwiseActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColorsDark.background : const Color.fromARGB(255, 228, 228, 228);
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final textPrimaryColor = isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.surface;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;

    return Consumer2<SplitWiseProvider, AuthProvider>(
      builder: (context, splitwiseProvider, authProvider, _) {
        final groups = splitwiseProvider.groups;
        final userId = authProvider.user?.id ?? '';

        // Collect all recent activities
        List<Map<String, dynamic>> activities = [];

        // Add recent expenses from all groups
        for (var group in groups) {
          for (var expense in group.expenses) {
            activities.add({
              'type': 'expense',
              'groupName': group.name,
              'description': expense.description,
              'amount': expense.amount,
              'paidBy': expense.paidByName,
              'date': expense.date,
              'category': expense.category,
              'isYou': expense.paidBy == userId,
            });
          }
        }

        // Add settlement suggestions
        for (var group in groups) {
          for (var member in group.members) {
            if (member.userId == userId && member.balance.abs() > 0.01) {
              activities.add({
                'type': 'settlement',
                'groupName': group.name,
                'balance': member.balance,
                'date': DateTime.now(),
              });
            }
          }
        }

        // Sort by date (most recent first)
        activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

        if (activities.isEmpty) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 64,
                    color: textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Activity Yet',
                    style: AppTextStyles.heading3.copyWith(color: textPrimaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your activity will appear here',
                    style: AppTextStyles.body2.copyWith(color: textSecondaryColor),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: bgColor,
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length > 20 ? 20 : activities.length, // Show latest 20
            itemBuilder: (context, index) {
              final activity = activities[index];
              final type = activity['type'] as String;

              if (type == 'expense') {
                return _buildExpenseCard(
                  context,
                  activity,
                  surfaceColor,
                  textPrimaryColor,
                  textSecondaryColor,
                  primaryColor,
                );
              } else {
                return _buildSettlementCard(
                  context,
                  activity,
                  surfaceColor,
                  textPrimaryColor,
                  textSecondaryColor,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    Map<String, dynamic> activity,
    Color surfaceColor,
    Color textPrimaryColor,
    Color textSecondaryColor,
    Color primaryColor,
  ) {
    final date = activity['date'] as DateTime;
    final formattedDate = DateFormat('MMM d, h:mm a').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activity['isYou'] 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt,
              color: activity['isYou'] ? Colors.green : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['description'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity['paidBy']} paid in ${activity['groupName']}',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${(activity['amount'] as double).toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: activity['isYou'] ? Colors.green : primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementCard(
    BuildContext context,
    Map<String, dynamic> activity,
    Color surfaceColor,
    Color textPrimaryColor,
    Color textSecondaryColor,
  ) {
    final balance = activity['balance'] as double;
    final isOwed = balance >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwed ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOwed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOwed ? Icons.notifications_active : Icons.notification_important,
              color: isOwed ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwed ? '💰 Settlement Pending' : '⚠️ Payment Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOwed ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOwed 
                      ? 'You are owed in ${activity['groupName']}'
                      : 'You owe in ${activity['groupName']}',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${balance.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOwed ? Colors.green : Colors.orange,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}


