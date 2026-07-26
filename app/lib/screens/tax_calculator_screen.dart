import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  double _income = 800000;
  double _deduction80C = 100000;
  double _deduction80D = 15000;

  late final _incomeCtrl =
      TextEditingController(text: _income.toInt().toString());
  late final _ded80CCtrl =
      TextEditingController(text: _deduction80C.toInt().toString());
  late final _ded80DCtrl =
      TextEditingController(text: _deduction80D.toInt().toString());

  TaxResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    setState(() {
      _result = CalculatorService.instance.calculateTax(
        grossIncome: _income,
        deduction80C: _deduction80C,
        deduction80D: _deduction80D,
      );
    });
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    _ded80CCtrl.dispose();
    _ded80DCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Calculator'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _calculate,
              tooltip: 'Calculate'),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildInputSection(context),
          const SizedBox(height: 8),
          if (_result != null) _buildResultSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.input,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Income Details',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            _inputField('Annual Gross Income', _incomeCtrl, (v) {
              _income = v;
              if (_incomeCtrl.text != v.toInt().toString()) {
                _incomeCtrl.text = v.toInt().toString();
              }
              _calculate();
            }, 100000, 10000000),
            const SizedBox(height: 12),
            _inputField('Section 80C (Max ₹1.5L)', _ded80CCtrl, (v) {
              _deduction80C = v;
              if (_ded80CCtrl.text != v.toInt().toString()) {
                _ded80CCtrl.text = v.toInt().toString();
              }
              _calculate();
            }, 0, 150000),
            const SizedBox(height: 12),
            _inputField('Section 80D (Max ₹25K)', _ded80DCtrl, (v) {
              _deduction80D = v;
              if (_ded80DCtrl.text != v.toInt().toString()) {
                _ded80DCtrl.text = v.toInt().toString();
              }
              _calculate();
            }, 0, 25000),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Standard deduction of ₹50,000 (Old) / ₹75,000 (New) is auto-applied. Returns for FY 2024-25.',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl,
      ValueChanged<double> onChanged, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹ '),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
          ],
          onChanged: (v) {
            final parsed = double.tryParse(v);
            if (parsed != null) onChanged(parsed);
          },
        ),
      ],
    );
  }

  Widget _buildResultSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final r = _result!;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.scale, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Old Regime',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                _row('Gross Income', curFormat.format(r.grossIncome),
                    colorScheme),
                _row('Less: Deductions', '(${curFormat.format(r.deductions)})',
                    colorScheme),
                _row('Taxable Income', curFormat.format(r.taxableIncomeOld),
                    colorScheme),
                const Divider(height: 12),
                _row('Income Tax', curFormat.format(r.taxOld), colorScheme),
                _row('Health & Education Cess (4%)',
                    curFormat.format(r.cessOld), colorScheme),
                const Divider(height: 12),
                _row('Total Tax Payable', curFormat.format(r.totalTaxOld),
                    colorScheme,
                    valueColor: colorScheme.error),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.scale, size: 20, color: colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Text('New Regime',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                _row('Gross Income', curFormat.format(r.grossIncome),
                    colorScheme),
                _row('Less: Standard Deduction', '(${curFormat.format(75000)})',
                    colorScheme),
                _row('Taxable Income', curFormat.format(r.taxableIncomeNew),
                    colorScheme),
                const Divider(height: 12),
                _row('Income Tax', curFormat.format(r.taxNew), colorScheme),
                _row('Health & Education Cess (4%)',
                    curFormat.format(r.cessNew), colorScheme),
                const Divider(height: 12),
                _row('Total Tax Payable', curFormat.format(r.totalTaxNew),
                    colorScheme,
                    valueColor: colorScheme.tertiary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: r.newRegimeBetter
              ? colorScheme.tertiaryContainer
              : colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  r.newRegimeBetter ? Icons.check_circle : Icons.info,
                  size: 24,
                  color: r.newRegimeBetter
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.newRegimeBetter
                            ? 'New Regime is Better'
                            : 'Old Regime is Better',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: r.newRegimeBetter
                              ? colorScheme.onTertiaryContainer
                              : colorScheme.onErrorContainer,
                        ),
                      ),
                      Text(
                        'Save ${curFormat.format(r.savings)} by choosing the ${r.newRegimeBetter ? "New" : "Old"} regime',
                        style: TextStyle(
                            fontSize: 13,
                            color: r.newRegimeBetter
                                ? colorScheme.onTertiaryContainer
                                : colorScheme.onErrorContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, ColorScheme cs, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? cs.onSurface)),
        ],
      ),
    );
  }
}
