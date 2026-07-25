import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SensitivityCard extends StatelessWidget {
  final double worstCorpus;
  final double expectedCorpus;
  final double bestCorpus;
  final NumberFormat format;

  const SensitivityCard({
    super.key,
    required this.worstCorpus,
    required this.expectedCorpus,
    required this.bestCorpus,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade100,
            Colors.green.shade100,
            Colors.teal.shade100,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Scenario Analysis (±2%)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScenario('Pessimistic', worstCorpus, Colors.red),
              _buildScenario('Expected', expectedCorpus, Colors.green),
              _buildScenario('Optimistic', bestCorpus, Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenario(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(format.format(value),
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
