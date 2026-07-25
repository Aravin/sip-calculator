import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sip_calculator/main.dart';
import 'package:sip_calculator/screens/combined_screen.dart';
import 'package:sip_calculator/screens/emi_screen.dart';
import 'package:sip_calculator/screens/lumpsum.dart';
import 'package:sip_calculator/screens/ppf.dart';
import 'package:sip_calculator/screens/savings_screen.dart';
import 'package:sip_calculator/screens/sip.dart';
import 'package:sip_calculator/screens/stp.dart';
import 'package:sip_calculator/screens/swp.dart';
import 'package:sip_calculator/shared/constants.dart';
import 'package:share_plus/share_plus.dart';

class CustomAppDrawer extends StatefulWidget {
  @override
  State<CustomAppDrawer> createState() => _CustomAppDrawerState();
}

class _CustomAppDrawerState extends State<CustomAppDrawer> {
  void _shareApp() {
    Share.share('https://play.google.com/store/apps/details?id=io.epix.sip',
        subject: 'SIP & Lumpsum Calculator - Financial Planning Tool');
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = MyApp.of(context);
    if (themeMode == null) return const SizedBox.shrink();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('Menu', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            decoration: const BoxDecoration(color: kSecondaryColor),
          ),
          _item('SIP Calculator', 'Systematic Investment Plan', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SIPScreen()));
          }),
          _item('Lumpsum Calculator', 'One-Time Investment Plan', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LumpSumScreen()));
          }),
          _item('SWP Calculator', 'Systematic Withdraw Plan', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SWPScreen()));
          }),
          _item('STP Calculator', 'Systematic Transfer Plan', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const STPScreen()));
          }),
          _item('PPF Calculator', 'Public Provident Fund', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PPFScreen()));
          }),
          _item('EMI Calculator', 'Loan EMI & Amortization', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EMIScreen()));
          }),
          _item('SIP + Lumpsum', 'Combined Investment Planner', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CombinedScreen()));
          }),
          _item('Saved Plans', 'Bookmarked Calculations', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()));
          }),
          const Divider(),
          _item('Toggle Dark Mode', 'Switch Theme', () {
            Navigator.pop(context);
            themeMode.toggleTheme();
          }, leading: Icons.dark_mode),
          ListTile(
            title: const Text('Share the App'),
            leading: const Icon(Icons.share),
            onTap: () {
              Navigator.pop(context);
              _shareApp();
            },
          ),
          ListTile(
            title: const Text('Rate the App'),
            leading: const Icon(Icons.star_rate),
            onTap: () async {
              Navigator.pop(context);
              await InAppReview.instance.openStoreListing();
            },
          ),
        ],
      ),
    );
  }

  Widget _item(String title, String subtitle, VoidCallback onTap, {IconData? leading}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      leading: leading != null ? Icon(leading) : null,
      onTap: onTap,
    );
  }
}
