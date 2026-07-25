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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: Text(label, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: prefix,
                    suffixText: suffix,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  inputFormatters: [
                    if (maxLength != null)
                      LengthLimitingTextInputFormatter(maxLength),
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
        ),
        if (showSlider)
          Slider(
            value: sliderValue.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions ?? (max.round() - min.round()).clamp(1, 1000),
            label: sliderValue.toStringAsFixed(sliderValue < 100 ? 1 : 0),
            onChanged: (value) => onChanged(value),
          ),
      ],
    );
  }
}
