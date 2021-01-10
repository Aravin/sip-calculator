import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sip_calculator/screens/lumpsum.dart';
import 'package:sip_calculator/screens/sip.dart';
import 'package:sip_calculator/screens/stp.dart';
import 'package:sip_calculator/shared/constants.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:share/share.dart';

class CustomAppDrawer extends StatefulWidget {
  @override
  _CustomAppDrawerState createState() => _CustomAppDrawerState();
}

class _CustomAppDrawerState extends State<CustomAppDrawer> {
  _shareApp() async {
    Share.share('https://play.google.com/store/apps/details?id=io.epix.sip',
        subject:
            'Share the Application - TRAI Channel and Package Pricing Information');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: 'Menu'.text.xl.bold.white.make(),
            decoration: BoxDecoration(
              color: kSecondaryColor,
            ),
          ),
          ListTile(
            title: Text('SIP Calculator'),
            subtitle: 'Systematic Investment Plan'.text.make(),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SIPScreen()));
            },
          ),
          ListTile(
            title: Text('Lumpsum Calculator'),
            subtitle: 'One-Time Investment Plan'.text.make(),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LumpSumScreen()));
            },
          ),
          ListTile(
            title: Text('SWP Calculator'),
            subtitle: 'Systematic Withdraw Plan'.text.make(),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SIPScreen()));
            },
          ),
          ListTile(
            title: Text('STP Calculator'),
            subtitle: 'Systematic Transfer Plan'.text.make(),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => STPScreen()));
            },
          ),
          // ListTile(
          //   title: Text('DTP Calculator'),
          //   subtitle: 'Dividend Transfer Plan'.text.make(),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => SIPScreen()));
          //   },
          // ),
          Divider(),
          ListTile(
            title: Text('Share the App'),
            leading: Icon(Icons.share),
            onTap: () {
              Navigator.pop(context);
              _shareApp();
            },
          ),
          ListTile(
              title: Text('Rate the App'),
              leading: Icon(Icons.star_rate),
              onTap: () async {
                Navigator.pop(context);
                final InAppReview inAppReview = InAppReview.instance;

                inAppReview.openStoreListing();
              })
        ],
      ),
    );
  }
}
