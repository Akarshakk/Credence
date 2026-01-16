import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../screens/feature_selection_screen.dart';
import 'calculators/inflation_calculator.dart';
import 'calculators/investment_return_calculator.dart';
import 'calculators/retirement_calculator.dart';
import 'calculators/sip_calculator.dart';
import 'calculators/emi_calculator.dart';
import 'calculators/emergency_fund_calculator.dart';
import 'calculators/health_insurance_calculator.dart';
import 'calculators/term_insurance_calculator.dart';
import 'calculators/motor_insurance_calculator.dart';
import 'pages/coming_soon_page.dart';
import 'pages/financial_advisory_page.dart';

/// Personal Finance Manager Screen with top navigation bar
class FinanceManagerScreen extends StatefulWidget {
  const FinanceManagerScreen({super.key});

  @override
  State<FinanceManagerScreen> createState() => _FinanceManagerScreenState();
}

class _FinanceManagerScreenState extends State<FinanceManagerScreen> {
  String _selectedCategory = 'advisory';
  String _selectedItem = 'advisory';

  // Navigation structure
  final List<_NavCategory> _navCategories = [
    _NavCategory(
      id: 'advisory',
      title: 'Financial Advisory',
      items: [],
    ),
    _NavCategory(
      id: 'calculators',
      title: 'Financial Calculators',
      items: [
        _NavItem(id: 'inflation', title: 'Inflation Calculator'),
        _NavItem(id: 'investment', title: 'Investment Return'),
        _NavItem(id: 'retirement', title: 'Retirement Corpus'),
        _NavItem(id: 'sip', title: 'SIP Calculator'),
        _NavItem(id: 'emi', title: 'EMI Calculator'),
        _NavItem(id: 'emergency', title: 'Emergency Fund'),
      ],
    ),
    _NavCategory(
      id: 'insurance',
      title: 'Insurance Management',
      items: [
        _NavItem(id: 'term_insurance', title: 'Life - Term Insurance'),
        _NavItem(id: 'health_insurance', title: 'Health Insurance Premium'),
        _NavItem(id: 'motor_insurance', title: 'Motor Insurance Premium'),
      ],
    ),
    _NavCategory(
      id: 'loans',
      title: 'Loan Management',
      items: [
        _NavItem(id: 'home_loan', title: 'Home Loan'),
        _NavItem(id: 'vehicle_loan', title: 'Vehicle Loan'),
        _NavItem(id: 'gold_loan', title: 'Gold Loan'),
      ],
    ),
    _NavCategory(
      id: 'tax',
      title: 'Tax Management',
      items: [
        _NavItem(id: 'itr_planning', title: 'ITR Planning'),
        _NavItem(id: 'itr_filing', title: 'ITR Filing'),
      ],
    ),
  ];

  Widget _getContentWidget() {
    switch (_selectedItem) {
      case 'advisory':
        return const FinancialAdvisoryPage();
      case 'inflation':
        return const InflationCalculator();
      case 'investment':
        return const InvestmentReturnCalculator();
      case 'retirement':
        return const RetirementCalculator();
      case 'sip':
        return const SipCalculator();
      case 'emi':
        return const EmiCalculator();
      case 'emergency':
        return const EmergencyFundCalculator();
      case 'term_insurance':
        return const TermInsuranceCalculator();
      case 'health_insurance':
        return const HealthInsuranceCalculator();
      case 'motor_insurance':
        return const MotorInsuranceCalculator();
      case 'home_loan':
        return const ComingSoonPage(
            title: 'Home Loan',
            description: 'Calculate home loan EMI',
            icon: Icons.home);
      case 'vehicle_loan':
        return const ComingSoonPage(
            title: 'Vehicle Loan',
            description: 'Calculate vehicle loan EMI',
            icon: Icons.directions_car);
      case 'gold_loan':
        return const ComingSoonPage(
            title: 'Gold Loan',
            description: 'Calculate gold loan amount',
            icon: Icons.diamond);
      case 'itr_planning':
        return const ComingSoonPage(
            title: 'ITR Planning',
            description: 'Plan income tax efficiently',
            icon: Icons.account_balance);
      case 'itr_filing':
        return const ComingSoonPage(
            title: 'ITR Filing',
            description: 'File income tax returns',
            icon: Icons.description);
      default:
        return const FinancialAdvisoryPage();
    }
  }

  void _goBack() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FeatureSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColorsDark.background : const Color(0xFFF5F5F5);
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.surface;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: _goBack,
          tooltip: 'Back to Menu',
        ),
        title: Text(
          'Personal Finance Manager',
          style: AppTextStyles.heading2.copyWith(color: primaryColor),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Top Navigation Bar with Tabs
          Container(
            color: surfaceColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: _navCategories.map((category) {
                  final isSelected = _selectedCategory == category.id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: category.items.isEmpty
                        ? _buildSimpleTab(
                            category, isSelected, primaryColor, isDark)
                        : _buildDropdownTab(category, isSelected, primaryColor,
                            isDark, surfaceColor),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: _getContentWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTab(
      _NavCategory category, bool isSelected, Color primaryColor, bool isDark) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category.id;
          _selectedItem = category.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          category.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTab(_NavCategory category, bool isSelected,
      Color primaryColor, bool isDark, Color surfaceColor) {
    return PopupMenuButton<String>(
      tooltip: category.title,
      offset: const Offset(0, 50),
      color: surfaceColor,
      onSelected: (itemId) {
        setState(() {
          _selectedCategory = category.id;
          _selectedItem = itemId;
        });
      },
      itemBuilder: (context) => category.items.map((item) {
        final isItemSelected = _selectedItem == item.id;
        return PopupMenuItem<String>(
          value: item.id,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              item.title,
              style: TextStyle(
                fontWeight:
                    isItemSelected ? FontWeight.bold : FontWeight.normal,
                color: isItemSelected ? primaryColor : null,
              ),
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCategory {
  final String id;
  final String title;
  final List<_NavItem> items;

  _NavCategory({required this.id, required this.title, required this.items});
}

class _NavItem {
  final String id;
  final String title;

  _NavItem({required this.id, required this.title});
}
