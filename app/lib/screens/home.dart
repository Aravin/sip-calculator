import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/combined_screen.dart';
import 'package:sip_calculator/screens/emi_screen.dart';
import 'package:sip_calculator/screens/lumpsum.dart';
import 'package:sip_calculator/screens/ppf.dart';
import 'package:sip_calculator/screens/savings_screen.dart';
import 'package:sip_calculator/screens/sip.dart';
import 'package:sip_calculator/screens/stp.dart';
import 'package:sip_calculator/screens/swp.dart';
import 'package:sip_calculator/shared/constants.dart';
import 'package:sip_calculator/shared/drawer.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomAppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              padding: kAppPadding,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _card(context, 'SIP', 'Systematic\nInvestment Plan', Icons.trending_up, colorScheme.primary, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SIPScreen()));
                }),
                _card(context, 'Lumpsum', 'One-Time\nInvestment', Icons.monetization_on, colorScheme.tertiary, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LumpSumScreen()));
                }),
                _card(context, 'SWP', 'Systematic\nWithdraw Plan', Icons.arrow_downward, colorScheme.error, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SWPScreen()));
                }),
                _card(context, 'STP', 'Systematic\nTransfer Plan', Icons.swap_horiz, colorScheme.secondary, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const STPScreen()));
                }),
                _card(context, 'PPF', 'Public\nProvident Fund', Icons.savings, Color(0xFF2E7D32), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PPFScreen()));
                }),
                _card(context, 'EMI', 'Loan EMI &\nAmortization', Icons.home, Color(0xFFC62828), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EMIScreen()));
                }),
                _card(context, 'SIP+Lumpsum', 'Combined Planner', Icons.merge, colorScheme.primary, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CombinedScreen()));
                }),
                _card(context, 'Saved Plans', 'Bookmarked Calcs', Icons.bookmark, Color(0xFFF9A825), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()));
                }),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, String subtitle, IconData icon, Color iconColor, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
