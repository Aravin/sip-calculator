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
import 'package:sip_calculator/widgets/ad_banner.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
      ),
      drawer: CustomAppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              padding: kAppPadding,
              crossAxisCount: 2,
              children: [
                _card('SIP Calculator', 'Systematic Investment Plan', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SIPScreen()));
                }, Icons.trending_up, Colors.teal),
                _card('Lumpsum', 'One-Time Investment', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LumpSumScreen()));
                }, Icons.monetization_on, Colors.blue),
                _card('SWP Calculator', 'Systematic Withdraw Plan', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SWPScreen()));
                }, Icons.arrow_downward, Colors.orange),
                _card('STP Calculator', 'Systematic Transfer Plan', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => STPScreen()));
                }, Icons.swap_horiz, Colors.purple),
                _card('PPF Calculator', 'Public Provident Fund', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PPFScreen()));
                }, Icons.savings, Colors.green),
                _card('EMI Calculator', 'Loan EMI & Amortization', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EMIScreen()));
                }, Icons.home, Colors.red),
                _card('SIP + Lumpsum', 'Combined Planner', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CombinedScreen()));
                }, Icons.merge, Colors.indigo),
                _card('Saved Plans', 'Bookmarked Calcs', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SavingsScreen()));
                }, Icons.bookmark, Colors.amber),
              ],
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }

  Widget _card(String title, String subtitle, VoidCallback onTap, IconData icon, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
