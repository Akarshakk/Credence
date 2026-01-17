import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/splitwise_provider.dart';
import '../../providers/auth_provider.dart';

class SplitwisFriendsTab extends StatelessWidget {
  const SplitwisFriendsTab({super.key});

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

        // Get all unique friends (members from all groups, excluding current user)
        Map<String, Map<String, dynamic>> friendsMap = {};
        
        for (var group in groups) {
          for (var member in group.members) {
            if (member.userId != userId) {
              if (!friendsMap.containsKey(member.userId)) {
                friendsMap[member.userId] = {
                  'name': member.name,
                  'email': member.email,
                  'totalOwed': 0.0,
                  'totalLent': 0.0,
                  'groups': <String>[],
                };
              }
              friendsMap[member.userId]!['totalOwed'] = 
                  (friendsMap[member.userId]!['totalOwed'] as double) + member.amountOwed;
              friendsMap[member.userId]!['totalLent'] = 
                  (friendsMap[member.userId]!['totalLent'] as double) + member.amountLent;
              (friendsMap[member.userId]!['groups'] as List<String>).add(group.name);
            }
          }
        }

        if (friendsMap.isEmpty) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Friends Yet',
                    style: AppTextStyles.heading3.copyWith(color: textPrimaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join groups to see friends here',
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
            itemCount: friendsMap.length,
            itemBuilder: (context, index) {
              final friendId = friendsMap.keys.elementAt(index);
              final friend = friendsMap[friendId]!;
              final balance = (friend['totalLent'] as double) - (friend['totalOwed'] as double);

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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(
                        (friend['name'] as String).substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(friend['groups'] as List).length} group(s)',
                            style: TextStyle(
                              color: textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          balance >= 0 ? 'Gets' : 'Owes',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${balance.abs().toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: balance >= 0 ? Colors.green : Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}


