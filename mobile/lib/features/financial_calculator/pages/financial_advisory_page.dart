import 'package:flutter/material.dart';

/// Financial Advisory page with Q&A section
class FinancialAdvisoryPage extends StatefulWidget {
  const FinancialAdvisoryPage({super.key});

  @override
  State<FinancialAdvisoryPage> createState() => _FinancialAdvisoryPageState();
}

class _FinancialAdvisoryPageState extends State<FinancialAdvisoryPage> {
  // Placeholder questions - user will provide actual questions later
  final List<Map<String, dynamic>> _questions = [
    {'question': 'Do you have an emergency fund?', 'answer': null},
    {'question': 'Do you have health insurance?', 'answer': null},
    {'question': 'Do you have term insurance?', 'answer': null},
    {'question': 'Are you saving for retirement?', 'answer': null},
    {'question': 'Do you have any outstanding loans?', 'answer': null},
    {'question': 'Do you file your taxes on time?', 'answer': null},
    {'question': 'Do you track your monthly expenses?', 'answer': null},
    {'question': 'Do you have investments in mutual funds?', 'answer': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Financial Health Check',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Answer these questions to assess your financial health',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            // Questions list - not using Expanded
            ...List.generate(_questions.length, (index) {
              final q = _questions[index];
              return Column(
                children: [
                  if (index > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${q['question']}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildYesNoButtons(index, q['answer']),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Get Advisory',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYesNoButtons(int index, bool? currentAnswer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChoiceButton('Yes', true, currentAnswer, index),
        const SizedBox(width: 8),
        _buildChoiceButton('No', false, currentAnswer, index),
      ],
    );
  }

  Widget _buildChoiceButton(
      String label, bool value, bool? currentAnswer, int index) {
    final isSelected = currentAnswer == value;
    final isYes = value == true;

    return GestureDetector(
      onTap: () {
        setState(() {
          _questions[index]['answer'] = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isYes ? Colors.green.shade100 : Colors.red.shade100)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isYes ? Colors.green : Colors.red)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isYes ? Colors.green.shade700 : Colors.red.shade700)
                : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showResult() {
    final answered = _questions.where((q) => q['answer'] != null).length;
    final yesCount = _questions.where((q) => q['answer'] == true).length;

    if (answered < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    final score = (yesCount / _questions.length * 100).round();
    String advice;
    Color color;

    if (score >= 80) {
      advice = 'Excellent! Your financial health is strong.';
      color = Colors.green;
    } else if (score >= 60) {
      advice = 'Good! But there\'s room for improvement.';
      color = Colors.orange;
    } else {
      advice = 'Needs attention. Consider consulting a financial advisor.';
      color = Colors.red;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Financial Health Score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score%',
              style: TextStyle(
                  fontSize: 48, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 16),
            Text(advice, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
