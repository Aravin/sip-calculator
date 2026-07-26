import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final curFormat = NumberFormat.simpleCurrency(locale: 'en_IN');

Widget buildResultRow(String label, double value, Color? color,
    {String? subtitle, NumberFormat? format}) {
  final fmt = format ?? curFormat;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          fmt.format(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ],
    ),
  );
}
