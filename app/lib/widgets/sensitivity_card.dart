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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Scenario Analysis (±2%)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildScenario(context, 'Pessimistic', worstCorpus, colorScheme.error)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(width: 1, height: 48, color: colorScheme.outlineVariant),
                ),
                Expanded(child: _buildScenario(context, 'Expected', expectedCorpus, colorScheme.primary)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(width: 1, height: 48, color: colorScheme.outlineVariant),
                ),
                Expanded(child: _buildScenario(context, 'Optimistic', bestCorpus, colorScheme.tertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenario(BuildContext context, String label, double value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          format.format(value),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
