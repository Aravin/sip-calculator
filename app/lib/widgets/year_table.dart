import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calculator_models.dart';

class YearTable extends StatelessWidget {
  final List<YearData> data;
  final NumberFormat format;
  const YearTable({super.key, required this.data, required this.format});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 44,
            columns: const [
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Invested')),
              DataColumn(label: Text('Interest')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Corpus')),
            ],
            rows: data.map((y) {
              return DataRow(cells: [
                DataCell(Text('${y.year}')),
                DataCell(Text(format.format(y.totalInvested))),
                DataCell(Text(format.format(y.totalInterest))),
                DataCell(
                    Text(format.format(y.totalInvested + y.totalInterest))),
                DataCell(Text(format.format(y.corpus))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
