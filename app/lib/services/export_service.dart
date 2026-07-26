import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/calculator_models.dart';
import 'package:intl/intl.dart';

class ExportService {
  static final _curFormat = NumberFormat.simpleCurrency(locale: 'en_IN');

  static String _toCsvRow(List<String> values) {
    return values.map((v) {
      if (v.contains(',') || v.contains('"') || v.contains('\n')) {
        return '"${v.replaceAll('"', '""')}"';
      }
      return v;
    }).join(',');
  }

  static String generateCsv(CalcResult result, String calculatorName) {
    final List<String> lines = [];

    lines.add(_toCsvRow([
      '$calculatorName - Projection Report',
      'Generated: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
    ]));
    lines.add('');

    lines.add(_toCsvRow([
      'Total Investment',
      _curFormat.format(result.totalInvestment),
    ]));
    lines.add(_toCsvRow([
      'Total Returns',
      _curFormat.format(result.totalReturns),
    ]));
    lines.add(_toCsvRow([
      'Total Value',
      _curFormat.format(result.totalValue),
    ]));
    lines.add('');

    if (result.yearlyBreakdown.isNotEmpty) {
      lines.add(_toCsvRow([
        'Year',
        'Invested This Year',
        'Total Invested',
        'Interest This Year',
        'Total Interest',
        'Corpus',
      ]));

      for (var y in result.yearlyBreakdown) {
        lines.add(_toCsvRow([
          y.year.toString(),
          _curFormat.format(y.investedThisYear),
          _curFormat.format(y.totalInvested),
          _curFormat.format(y.interestThisYear),
          _curFormat.format(y.totalInterest),
          _curFormat.format(y.corpus),
        ]));
      }
    }

    return lines.join('\n');
  }

  static Future<void> shareAsCsv(
      CalcResult result, String calculatorName) async {
    final String csv = generateCsv(result, calculatorName);

    if (!kIsWeb) {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          '${calculatorName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)],
          text: '$calculatorName Report');
    } else {
      await Share.share(csv, subject: '$calculatorName Report');
    }
  }

  static String generateNumberToWords(double amount) {
    if (amount.isNaN || amount.isInfinite) return '—';
    if (amount == 0) return 'Zero';

    int num = amount.round();
    if (num == 0) return 'Zero';
    if (num < 0) return 'Minus ${generateNumberToWords(-(num.toDouble()))}';
    if (num < 100) return _belowHundred(num);

    String result = '';
    if (num >= 10000000) {
      result += '${_belowHundred(num ~/ 10000000)} Crore ';
      num %= 10000000;
    }
    if (num >= 100000) {
      result += '${_belowHundred(num ~/ 100000)} Lakh ';
      num %= 100000;
    }
    if (num >= 1000) {
      result += '${_belowHundred(num ~/ 1000)} Thousand ';
      num %= 1000;
    }
    if (num >= 100) {
      result += '${_belowHundred(num ~/ 100)} Hundred ';
      num %= 100;
    }
    if (num > 0) {
      result += _belowHundred(num);
    }

    return result.trim();
  }

  static String _belowHundred(int num) {
    final List<String> ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    final List<String> tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    if (num < 20) return ones[num];
    if (num < 100) {
      final int t = num ~/ 10;
      final int o = num % 10;
      return o == 0 ? tens[t] : '${tens[t]} ${ones[o]}';
    }
    return num.toString();
  }
}
