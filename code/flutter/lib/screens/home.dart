import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/lumpsum.dart';
import 'package:sip_calculator/screens/sip.dart';
import 'package:sip_calculator/screens/stp.dart';
import 'package:sip_calculator/screens/swp.dart';
import 'package:sip_calculator/shared/constants.dart';
import 'package:sip_calculator/shared/drawer.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Home'.text.make(),
      ),
      drawer: CustomAppDrawer(),
      body: GridView.count(
        padding: kAppPadding,
        crossAxisCount: 2,
        // Generate 100 widgets that display their index in the List.
        children: [
          GestureDetector(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  'SIP Calculator'.text.bold.center.make(),
                  'Systematic Investment Plan'.text.center.make(),
                ],
              ),
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => SIPScreen())),
          ),
          GestureDetector(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  'Lumpsum Calculator'.text.bold.center.make(),
                  'One-Time Investment Plan'.text.center.make(),
                ],
              ),
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => LumpSumScreen())),
          ),
          GestureDetector(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  'SWP Calculator'.text.bold.center.make(),
                  'Systematic Withdraw Plan'.text.center.make(),
                ],
              ),
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => SWPScreen())),
          ),
          GestureDetector(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  'STP Calculator'.text.bold.center.make(),
                  'Systematic Transfer Plan'.text.center.make(),
                ],
              ),
            ),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => STPScreen())),
          ),
          // Card(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       'DTP Calculator'.text.bold.center.make(),
          //       'Divident Transfer Plan'.text.center.make(),
          //     ],
          //   ),
          // ),
          // Card(
          //   color: kSecondaryLiteColor,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       'Savings'.text.white.bold.center.make(),
          //       'Saved SIP/SWP/STP/DTP/LumpSum'.text.white.center.make(),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
