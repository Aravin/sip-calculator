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
import 'package:share_plus/share_plus.dart';

class CustomAppDrawer extends StatefulWidget {
  const CustomAppDrawer({super.key});

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
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationDrawer(
      onDestinationSelected: (index) {},
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
          child: Text(
            'SIP Calculator',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: Text(
            'Financial Planning Tools',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const Divider(),
        NavigationDrawerDestination(
          icon: Icon(Icons.trending_up),
          selectedIcon: Icon(Icons.trending_up, color: colorScheme.primary),
          label: const Text('SIP'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.monetization_on),
          selectedIcon: Icon(Icons.monetization_on, color: colorScheme.primary),
          label: const Text('Lumpsum'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.arrow_downward),
          selectedIcon: Icon(Icons.arrow_downward, color: colorScheme.primary),
          label: const Text('SWP'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.swap_horiz),
          selectedIcon: Icon(Icons.swap_horiz, color: colorScheme.primary),
          label: const Text('STP'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.savings),
          selectedIcon: Icon(Icons.savings, color: colorScheme.primary),
          label: const Text('PPF'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.home),
          selectedIcon: Icon(Icons.home, color: colorScheme.primary),
          label: const Text('EMI'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.merge),
          selectedIcon: Icon(Icons.merge, color: colorScheme.primary),
          label: const Text('SIP + Lumpsum'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.bookmark),
          selectedIcon: Icon(Icons.bookmark, color: colorScheme.primary),
          label: const Text('Saved Plans'),
        ),
        const Divider(),
        NavigationDrawerDestination(
          icon: Icon(Icons.dark_mode),
          selectedIcon: Icon(Icons.dark_mode, color: colorScheme.primary),
          label: const Text('Toggle Theme'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.share),
          selectedIcon: Icon(Icons.share, color: colorScheme.primary),
          label: const Text('Share App'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.star_rate),
          selectedIcon: Icon(Icons.star_rate, color: colorScheme.primary),
          label: const Text('Rate App'),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'v5.5.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
