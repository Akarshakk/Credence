import 'package:flutter/material.dart';

/// ITR Planning Page with comprehensive tax saving information
class ItrPlanningPage extends StatelessWidget {
  const ItrPlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.indigo.shade500],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Complete ITR Planning Guide',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'All tax-saving sections & deductions for FY 2024-25',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 80C
          _buildSection('Section 80C - Investment Deductions', Colors.green,
              Icons.savings, 'Max: ₹1,50,000', [
            _InfoItem('EPF/VPF', 'Employee & Voluntary Provident Fund'),
            _InfoItem('PPF', 'Public Provident Fund (15-year lock-in)'),
            _InfoItem('ELSS', 'Equity Linked Savings Scheme (3-year lock-in)'),
            _InfoItem('NSC', 'National Savings Certificate'),
            _InfoItem('Tax Saving FD', '5-year Fixed Deposits'),
            _InfoItem('Life Insurance', 'Premium for self, spouse & children'),
            _InfoItem('ULIP', 'Unit Linked Insurance Plans'),
            _InfoItem('SSY', 'Sukanya Samriddhi Yojana'),
            _InfoItem('Home Loan Principal', 'Principal repayment'),
            _InfoItem('Tuition Fees', 'For up to 2 children'),
            _InfoItem('Stamp Duty', 'During property registration'),
          ]),

          // Section 80CCC & 80CCD
          _buildSection('Section 80CCC & 80CCD - Pension', Colors.purple,
              Icons.elderly, 'Extra ₹50,000 NPS', [
            _InfoItem('80CCC', 'Pension fund (within 80C limit)'),
            _InfoItem('80CCD(1)', 'NPS employee contribution (within 80C)'),
            _InfoItem('80CCD(1B)', 'Additional NPS up to ₹50,000 (EXTRA!)'),
            _InfoItem('80CCD(2)', 'Employer NPS (up to 10% salary, no limit)'),
          ]),

          // Section 80D
          _buildSection('Section 80D - Health Insurance', Colors.red,
              Icons.health_and_safety, 'Max: ₹1,00,000', [
            _InfoItem('Self & Family', 'Up to ₹25,000 (₹50,000 if senior)'),
            _InfoItem('Parents', 'Additional ₹25,000 (₹50,000 if senior)'),
            _InfoItem('Health Checkup', '₹5,000 within above limits'),
          ]),

          // Home Loan
          _buildSection('Section 24 & 80EE/80EEA - Home Loan Interest',
              Colors.blue, Icons.home, 'Max: ₹2,00,000+', [
            _InfoItem('Section 24(b)', 'Home loan interest up to ₹2,00,000'),
            _InfoItem('Let-out Property', 'No limit on interest deduction'),
            _InfoItem('80EE', 'First-time buyers: Extra ₹50,000'),
            _InfoItem('80EEA', 'Affordable housing: Extra ₹1,50,000'),
          ]),

          // Other Deductions
          _buildSection('Education, Donations & Others', Colors.orange,
              Icons.school, 'Various Limits', [
            _InfoItem('80E', 'Education loan interest, NO upper limit'),
            _InfoItem('80G', '50% or 100% for eligible charities'),
            _InfoItem('80GG', 'Rent up to ₹5,000/month if no HRA'),
            _InfoItem('80TTA', 'Up to ₹10,000 savings interest'),
            _InfoItem('80TTB', '₹50,000 for senior citizens'),
            _InfoItem('80U', '₹75,000-₹1,25,000 for self disability'),
            _InfoItem('80DD', '₹75,000-₹1,25,000 for dependent'),
            _InfoItem('80DDB', 'Up to ₹1,00,000 for medical treatment'),
          ]),

          // Standard Deduction
          _buildSection('Standard Deduction', Colors.teal, Icons.receipt_long,
              'Automatic', [
            _InfoItem('Salaried', 'Flat ₹50,000 (no documents needed)'),
            _InfoItem('Pensioners', 'Also eligible for ₹50,000'),
          ]),

          // Capital Gains
          _buildCapitalGainsSection(),

          // Tax Regime
          _buildTaxRegimeSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Color color, IconData icon, String limit,
      List<_InfoItem> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: color))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text(limit,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                children:
                    items.map((item) => _buildInfoRow(item, color)).toList()),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                      text: '${item.title}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: item.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapitalGainsSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green.shade700),
                const SizedBox(width: 10),
                Text('Capital Gains Taxation',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAssetRow('Equity/MF', 'STCG: 15% (≤1yr) | LTCG: 10% >₹1L',
                    Colors.blue),
                _buildAssetRow(
                    'Debt Funds', 'Taxed as per income slab', Colors.orange),
                _buildAssetRow('Gold/REITs', 'Taxed as per income slab',
                    Colors.amber.shade700),
                _buildAssetRow('Real Estate',
                    'STCG: Slab (≤2yr) | LTCG: 20% indexed', Colors.purple),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tax Saving Strategies:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      _buildTipRow('LTCG Harvesting',
                          'Book ₹1L gains yearly (zero tax)'),
                      _buildTipRow(
                          'Loss Harvesting', 'Offset gains with losses'),
                      _buildTipRow('Section 54', 'Reinvest in new property'),
                      _buildTipRow(
                          'Section 54EC', 'Invest in capital gain bonds'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(String asset, String tax, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 13)),
                Text(tax, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.teal),
          const SizedBox(width: 6),
          Expanded(
              child:
                  Text('$title: $desc', style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildTaxRegimeSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Row(
              children: [
                Icon(Icons.compare_arrows, color: Colors.indigo.shade700),
                const SizedBox(width: 10),
                Text('Old vs New Tax Regime',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _buildRegimeCard('Old Regime ✓', Colors.blue, [
                  'Full 80C, 80D, NPS',
                  'Home loan interest',
                  'HRA exemption',
                  'LTA benefits'
                ])),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildRegimeCard('New Regime ✓', Colors.green, [
                  'Lower tax rates',
                  'No investment lock-in',
                  'Higher cash flow',
                  'Simple filing'
                ])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, size: 18, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Compare BOTH regimes before filing!',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegimeCard(String title, Color color, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          const SizedBox(height: 6),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 12, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(p, style: const TextStyle(fontSize: 11))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String title;
  final String description;

  _InfoItem(this.title, this.description);
}


