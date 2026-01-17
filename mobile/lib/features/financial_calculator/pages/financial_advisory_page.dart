import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Financial Advisory page with Q&A, income inputs, and personalized allocation
class FinancialAdvisoryPage extends StatefulWidget {
  const FinancialAdvisoryPage({super.key});

  @override
  State<FinancialAdvisoryPage> createState() => _FinancialAdvisoryPageState();
}

class _FinancialAdvisoryPageState extends State<FinancialAdvisoryPage> {
  final _incomeController = TextEditingController();
  final _investmentController = TextEditingController();
  final _horizonController = TextEditingController();

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Do you have an emergency fund?',
      'answer': null,
      'longWeight': 1
    },
    {
      'question': 'Do you have health insurance?',
      'answer': null,
      'longWeight': 1,
      'insuranceType': 'health'
    },
    {
      'question': 'Do you have term insurance?',
      'answer': null,
      'longWeight': 1,
      'insuranceType': 'term'
    },
    {
      'question': 'Are you saving for retirement?',
      'answer': null,
      'longWeight': 2
    },
    {
      'question': 'Do you have any outstanding loans?',
      'answer': null,
      'longWeight': -1
    },
    {
      'question': 'Are you comfortable with stock market corrections?',
      'answer': null,
      'longWeight': 2
    },
    {
      'question': 'Do you have a fixed income?',
      'answer': null,
      'longWeight': 1
    },
    {
      'question': 'Are you okay with being invested for long term?',
      'answer': null,
      'longWeight': 3
    },
  ];

  @override
  void dispose() {
    _incomeController.dispose();
    _investmentController.dispose();
    _horizonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Personalized Investment Planner',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Get a customized investment allocation based on your profile',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Income Inputs Section
              _buildSectionHeader(
                  'Financial Details', Icons.account_balance_wallet),
              const SizedBox(height: 12),
              _buildNumericInput(
                  _incomeController, 'Annual Income (₹)', 'e.g. 1000000'),
              _buildNumericInput(_investmentController,
                  'Yearly Investment Budget (₹)', 'e.g. 300000'),
              _buildNumericInput(
                  _horizonController, 'Investment Horizon (Years)', 'e.g. 5'),

              const SizedBox(height: 24),
              _buildSectionHeader('Financial Health Questions', Icons.quiz),
              const SizedBox(height: 12),

              // Questions
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

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generatePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Generate My Investment Plan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 22),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNumericInput(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      onTap: () => setState(() => _questions[index]['answer'] = value),
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

  void _generatePlan() {
    final income = double.tryParse(_incomeController.text) ?? 0;
    final investment = double.tryParse(_investmentController.text) ?? 0;
    final horizon = int.tryParse(_horizonController.text) ?? 0;

    if (income <= 0 || investment <= 0 || horizon <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all financial details')),
      );
      return;
    }

    final answered = _questions.where((q) => q['answer'] != null).length;
    if (answered < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    // Calculate investor type score
    int score = 0;
    for (var q in _questions) {
      if (q['answer'] == true) {
        score += (q['longWeight'] as int);
      }
    }

    // Check insurance needs
    bool needsHealthInsurance = _questions
            .firstWhere((q) => q['insuranceType'] == 'health')['answer'] ==
        false;
    bool needsTermInsurance =
        _questions.firstWhere((q) => q['insuranceType'] == 'term')['answer'] ==
            false;

    // Determine investor type based on score AND horizon
    String investorType;
    Color typeColor;

    if (horizon <= 3 || score <= 3) {
      investorType = 'Short-Term';
      typeColor = Colors.blue;
    } else if (horizon <= 7 || score <= 7) {
      investorType = 'Medium-Term';
      typeColor = Colors.orange;
    } else {
      investorType = 'Long-Term';
      typeColor = Colors.green;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PersonalizedPlanPage(
          annualIncome: income,
          investmentBudget: investment,
          horizon: horizon,
          investorType: investorType,
          typeColor: typeColor,
          needsHealthInsurance: needsHealthInsurance,
          needsTermInsurance: needsTermInsurance,
        ),
      ),
    );
  }
}

class _PersonalizedPlanPage extends StatelessWidget {
  final double annualIncome;
  final double investmentBudget;
  final int horizon;
  final String investorType;
  final Color typeColor;
  final bool needsHealthInsurance;
  final bool needsTermInsurance;

  const _PersonalizedPlanPage({
    required this.annualIncome,
    required this.investmentBudget,
    required this.horizon,
    required this.investorType,
    required this.typeColor,
    required this.needsHealthInsurance,
    required this.needsTermInsurance,
  });

  String _formatCurrency(double amount) {
    if (amount >= 10000000)
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)} L';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate insurance allocation if needed
    double insuranceAllocation = 0;
    double healthPremium = 0;
    double termPremium = 0;

    if (needsHealthInsurance) {
      healthPremium = 15000; // Approx annual health insurance
      insuranceAllocation += healthPremium;
    }
    if (needsTermInsurance) {
      termPremium = annualIncome * 0.005; // 0.5% of income for term insurance
      insuranceAllocation += termPremium;
    }

    double remainingForInvestment = investmentBudget - insuranceAllocation;
    if (remainingForInvestment < 0) remainingForInvestment = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Investment Plan'),
        backgroundColor: typeColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 20),

            // Insurance Allocation (if needed)
            if (needsHealthInsurance || needsTermInsurance) ...[
              _buildInsuranceSection(
                  healthPremium, termPremium, insuranceAllocation),
              const SizedBox(height: 20),
            ],

            // Investment Allocation
            _buildInvestmentAllocation(remainingForInvestment),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      color: typeColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  investorType == 'Short-Term'
                      ? Icons.speed
                      : investorType == 'Medium-Term'
                          ? Icons.trending_up
                          : Icons.rocket_launch,
                  size: 40,
                  color: typeColor,
                ),
                const SizedBox(width: 12),
                Text(
                  '$investorType Investor',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: typeColor),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('Annual Income', _formatCurrency(annualIncome)),
                _buildInfoItem('Investment', _formatCurrency(investmentBudget)),
                _buildInfoItem('Horizon', '$horizon Years'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildInsuranceSection(
      double healthPremium, double termPremium, double total) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text('Insurance First!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Before investing, secure yourself with insurance:',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            if (needsHealthInsurance)
              _buildAllocationRow('Health Insurance Premium', healthPremium,
                  Colors.red.shade400),
            if (needsTermInsurance)
              _buildAllocationRow(
                  'Term Insurance Premium', termPremium, Colors.red.shade400),
            const Divider(),
            _buildAllocationRow(
                'Total Insurance Allocation', total, Colors.red.shade700,
                isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentAllocation(double amount) {
    // Calculate allocations based on investor type
    Map<String, double> allocations;

    if (investorType == 'Short-Term') {
      allocations = {
        'Liquid Funds': amount * 0.30,
        'Ultra-Short Debt Funds': amount * 0.25,
        'Short-Term FDs': amount * 0.25,
        'Arbitrage Funds': amount * 0.20,
      };
    } else if (investorType == 'Medium-Term') {
      allocations = {
        'Debt Funds': amount * 0.40,
        'Hybrid Funds': amount * 0.30,
        'Equity Savings Funds': amount * 0.20,
        'Balanced Advantage': amount * 0.10,
      };
    } else {
      allocations = {
        'Index Funds (Core)': amount * 0.30,
        'Flexi-Cap Funds': amount * 0.25,
        'Large & Mid-Cap': amount * 0.20,
        'Small-Cap Funds': amount * 0.10,
        'International Funds': amount * 0.05,
        'PPF/NPS (Safety)': amount * 0.10,
      };
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: typeColor),
                const SizedBox(width: 8),
                Text('Investment Allocation',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: typeColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total for Investment: ${_formatCurrency(amount)}',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ...allocations.entries.map((entry) =>
                _buildAllocationRow(entry.key, entry.value, typeColor)),
            const Divider(),
            const SizedBox(height: 12),
            _buildRecommendedFunds(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationRow(String label, double amount, Color color,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatCurrency(amount),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedFunds() {
    List<String> funds;

    if (investorType == 'Short-Term') {
      funds = [
        'HDFC Liquid Fund',
        'Axis Liquid Fund',
        'ICICI Prudential Ultra Short Term',
        'Kotak Equity Arbitrage Fund',
      ];
    } else if (investorType == 'Medium-Term') {
      funds = [
        'ICICI Prudential Equity & Debt Fund',
        'SBI Equity Hybrid Fund',
        'HDFC Equity Savings Fund',
        'Kotak Balanced Advantage Fund',
      ];
    } else {
      funds = [
        'Nifty 50 Index Fund',
        'Parag Parikh Flexi Cap Fund',
        'Mirae Asset Large & Midcap Fund',
        'Nippon India Small Cap Fund',
        'Motilal Oswal Nasdaq 100 Fund',
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recommended Funds:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: funds
              .map((fund) => Chip(
                    label: Text(fund, style: const TextStyle(fontSize: 12)),
                    backgroundColor: typeColor.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  ))
              .toList(),
        ),
      ],
    );
  }
}
