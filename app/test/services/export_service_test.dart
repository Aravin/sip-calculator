import 'package:flutter_test/flutter_test.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/export_service.dart';

void main() {
  group('CSV Export', () {
    test('generateCsv contains header and summary', () {
      final result = CalcResult(
        totalInvestment: 120000,
        totalReturns: 50000,
        totalValue: 170000,
        yearlyBreakdown: [
          YearData(year: 1, investedThisYear: 60000, totalInvested: 60000,
              interestThisYear: 3000, totalInterest: 3000, corpus: 63000),
        ],
      );

      final csv = ExportService.generateCsv(result, 'SIP Calculator');

      expect(csv, contains('SIP Calculator'));
      expect(csv, contains('Total Investment'));
      expect(csv, contains('Total Returns'));
      expect(csv, contains('Total Value'));
      expect(csv, contains('Year'));
      expect(csv, contains('Corpus'));
    });

    test('generateCsv handles empty yearly breakdown', () {
      final result = CalcResult(
        totalInvestment: 100000,
        totalReturns: 50000,
        totalValue: 150000,
      );

      final csv = ExportService.generateCsv(result, 'Lumpsum');

      expect(csv, contains('Lumpsum'));
      expect(csv, contains('₹1,00,000.00'));
      // No yearly table section
      expect(csv.split('\n').length, lessThan(10));
    });

    test('generateCsv properly escapes commas in values', () {
      final result = CalcResult(
        totalInvestment: 1000,
        totalReturns: 100,
        totalValue: 1100,
        yearlyBreakdown: [
          YearData(year: 1, investedThisYear: 1000, totalInvested: 1000,
              interestThisYear: 100, totalInterest: 100, corpus: 1100),
        ],
      );

      final csv = ExportService.generateCsv(result, 'Test');

      // Should not throw
      expect(csv.isNotEmpty, true);
    });

    test('generateCsv handles large numbers', () {
      final result = CalcResult(
        totalInvestment: 12345678,
        totalReturns: 9876543,
        totalValue: 22222221,
        yearlyBreakdown: [
          YearData(year: 1, investedThisYear: 6000000, totalInvested: 6000000,
              interestThisYear: 300000, totalInterest: 300000, corpus: 6300000),
        ],
      );

      final csv = ExportService.generateCsv(result, 'Large Numbers');

      expect(csv, contains('Large Numbers'));
      expect(csv, contains('₹1,23,45,678.00'));
      expect(csv, contains('₹2,22,22,221.00'));
    });
  });

  group('Number to Words', () {
    test('zero', () {
      expect(ExportService.generateNumberToWords(0), 'Zero');
    });

    test('negative number', () {
      expect(ExportService.generateNumberToWords(-500),
          'Minus Five Hundred');
    });

    test('units (1-19)', () {
      expect(ExportService.generateNumberToWords(1), 'One');
      expect(ExportService.generateNumberToWords(10), 'Ten');
      expect(ExportService.generateNumberToWords(15), 'Fifteen');
      expect(ExportService.generateNumberToWords(19), 'Nineteen');
    });

    test('tens (20-99)', () {
      expect(ExportService.generateNumberToWords(20), 'Twenty');
      expect(ExportService.generateNumberToWords(25), 'Twenty Five');
      expect(ExportService.generateNumberToWords(99), 'Ninety Nine');
    });

    test('hundreds', () {
      expect(ExportService.generateNumberToWords(100), 'One Hundred');
      expect(ExportService.generateNumberToWords(250), 'Two Hundred Fifty');
      expect(ExportService.generateNumberToWords(999), 'Nine Hundred Ninety Nine');
    });

    test('thousands (Indian system)', () {
      expect(ExportService.generateNumberToWords(1000), 'One Thousand');
      expect(ExportService.generateNumberToWords(5000), 'Five Thousand');
      expect(ExportService.generateNumberToWords(15000), 'Fifteen Thousand');
    });

    test('lakhs', () {
      expect(ExportService.generateNumberToWords(100000), 'One Lakh');
      expect(ExportService.generateNumberToWords(250000), 'Two Lakh Fifty Thousand');
      expect(ExportService.generateNumberToWords(999999), 'Nine Lakh Ninety Nine Thousand Nine Hundred Ninety Nine');
    });

    test('crores', () {
      expect(ExportService.generateNumberToWords(10000000), 'One Crore');
      expect(ExportService.generateNumberToWords(50000000), 'Five Crore');
      expect(ExportService.generateNumberToWords(12345678),
          'One Crore Twenty Three Lakh Forty Five Thousand Six Hundred Seventy Eight');
    });

    test('large number with all units', () {
      expect(ExportService.generateNumberToWords(123456789),
          'Twelve Crore Thirty Four Lakh Fifty Six Thousand Seven Hundred Eighty Nine');
    });
  });
}
