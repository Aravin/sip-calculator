import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double sliderValue;
  final double min;
  final double max;
  final int? divisions;
  final String? prefix;
  final String? suffix;
  final int? maxLength;
  final bool showSlider;
  final ValueChanged<double> onChanged;

  const InputRow({
    super.key,
    required this.label,
    required this.controller,
    required this.sliderValue,
    required this.min,
    required this.max,
    this.divisions,
    this.prefix,
    this.suffix,
    this.maxLength,
    this.showSlider = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: prefix,
                            suffixText: suffix,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          inputFormatters: [
                            if (maxLength != null)
                              LengthLimitingTextInputFormatter(maxLength),
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final v = double.tryParse(value);
                              if (v != null && v >= min && v <= max) {
                                onChanged(v);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (showSlider)
                    Slider(
                      value: sliderValue.clamp(min, max),
                      min: min,
                      max: max,
                      divisions: divisions ??
                          ((max - min) / _stepForRange(max - min)).round().clamp(1, 1000),
                      label: _formatLabel(sliderValue),
                      onChanged: (value) {
                        controller.text = _formatValue(value);
                        onChanged(value);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _stepForRange(double range) {
    if (range <= 10) return 0.1;
    if (range <= 100) return 1;
    if (range <= 1000) return 10;
    if (range <= 10000) return 100;
    return 1000;
  }

  String _formatLabel(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(value < 100 ? 1 : 0);
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}
