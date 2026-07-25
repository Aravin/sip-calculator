import 'package:flutter_test/flutter_test.dart';
import 'package:sip_calculator/models/calculator_models.dart';

void main() {
  group('YearData', () {
    test('toJson and fromJson roundtrip', () {
      final original = YearData(
        year: 5,
        investedThisYear: 60000,
        totalInvested: 300000,
        interestThisYear: 15000,
        totalInterest: 80000,
        corpus: 380000,
      );

      final json = original.toJson();
      final reconstructed = YearData.fromJson(json);

      expect(reconstructed.year, original.year);
      expect(reconstructed.investedThisYear, original.investedThisYear);
      expect(reconstructed.totalInvested, original.totalInvested);
      expect(reconstructed.interestThisYear, original.interestThisYear);
      expect(reconstructed.totalInterest, original.totalInterest);
      expect(reconstructed.corpus, original.corpus);
    });

    test('fromJson handles double values stored as int', () {
      final json = {
        'year': 3,
        'investedThisYear': 60000,
        'totalInvested': 180000,
        'interestThisYear': 9000,
        'totalInterest': 25000,
        'corpus': 205000,
      };

      final data = YearData.fromJson(json);
      expect(data.investedThisYear, 60000.0);
      expect(data.corpus, 205000.0);
    });
  });

  group('CalcResult', () {
    test('toJson and fromJson roundtrip', () {
      final original = CalcResult(
        totalInvestment: 500000,
        totalReturns: 350000,
        totalValue: 850000,
        yearlyBreakdown: [
          YearData(year: 1, investedThisYear: 60000, totalInvested: 60000,
              interestThisYear: 3000, totalInterest: 3000, corpus: 63000),
          YearData(year: 2, investedThisYear: 60000, totalInvested: 120000,
              interestThisYear: 7500, totalInterest: 10500, corpus: 130500),
        ],
      );

      final json = original.toJson();
      final reconstructed = CalcResult.fromJson(json);

      expect(reconstructed.totalInvestment, original.totalInvestment);
      expect(reconstructed.totalReturns, original.totalReturns);
      expect(reconstructed.totalValue, original.totalValue);
      expect(reconstructed.yearlyBreakdown.length, original.yearlyBreakdown.length);
      expect(reconstructed.yearlyBreakdown[1].corpus, original.yearlyBreakdown[1].corpus);
    });

    test('fromJson handles empty yearly breakdown', () {
      final json = {
        'totalInvestment': 100000.0,
        'totalReturns': 50000.0,
        'totalValue': 150000.0,
        'yearlyBreakdown': [],
      };

      final result = CalcResult.fromJson(json);
      expect(result.yearlyBreakdown, isEmpty);
      expect(result.totalValue, 150000.0);
    });

    test('toJsonString produces valid JSON', () {
      final result = CalcResult(
        totalInvestment: 1000,
        totalReturns: 100,
        totalValue: 1100,
      );

      final jsonStr = result.toJsonString();
      expect(jsonStr, contains('totalInvestment'));
      expect(jsonStr, contains('1100'));
    });
  });

  group('SavedCalculation', () {
    test('toJson and fromJson roundtrip', () {
      final original = SavedCalculation(
        id: 'sip-123',
        name: 'My SIP Plan',
        type: 'SIP',
        params: '₹5000/mo, 12%, 10y',
        result: CalcResult(
          totalInvestment: 600000,
          totalReturns: 500000,
          totalValue: 1100000,
        ),
        savedAt: DateTime(2025, 7, 15, 14, 30, 0, 0, 0),
      );

      final json = original.toJson();
      final reconstructed = SavedCalculation.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.name, original.name);
      expect(reconstructed.type, original.type);
      expect(reconstructed.params, original.params);
      expect(reconstructed.result.totalValue, original.result.totalValue);
      expect(reconstructed.savedAt.toIso8601String(), original.savedAt.toIso8601String());
    });

    test('fromJson handles all field types correctly', () {
      final json = {
        'id': 'emi-456',
        'name': 'Home Loan',
        'type': 'EMI',
        'params': '₹50L, 9%, 20y',
        'result': {
          'totalInvestment': 5000000.0,
          'totalReturns': 5790000.0,
          'totalValue': 10790000.0,
          'yearlyBreakdown': [],
        },
        'savedAt': '2025-01-01T00:00:00.000',
      };

      final calc = SavedCalculation.fromJson(json);
      expect(calc.id, 'emi-456');
      expect(calc.type, 'EMI');
      expect(calc.result.totalValue, 10790000.0);
      expect(calc.savedAt.year, 2025);
    });
  });

  group('NriConfig', () {
    test('presets contains all countries', () {
      expect(NriConfig.presets.length, 6);
      expect(NriConfig.presets.containsKey('India'), true);
      expect(NriConfig.presets.containsKey('USA'), true);
      expect(NriConfig.presets.containsKey('UAE'), true);
    });

    test('India has INR currency', () {
      final india = NriConfig.presets['India']!;
      expect(india.currencyCode, 'INR');
      expect(india.currencySymbol, '₹');
    });

    test('UAE has zero tax rate', () {
      final uae = NriConfig.presets['UAE']!;
      expect(uae.taxRate, 0.0);
    });

    test('USA has 20% tax rate', () {
      final usa = NriConfig.presets['USA']!;
      expect(usa.taxRate, 0.20);
    });
  });

  group('MonteCarloResult', () {
    test('constructor assigns values correctly', () {
      final result = MonteCarloResult(
        medianCorpus: 5000000,
        p10Corpus: 2000000,
        p90Corpus: 9000000,
        probabilityOfSuccess: 0.85,
      );

      expect(result.medianCorpus, 5000000);
      expect(result.p10Corpus, 2000000);
      expect(result.p90Corpus, 9000000);
      expect(result.probabilityOfSuccess, 0.85);
    });
  });

  group('AiInsight', () {
    test('constructor assigns values correctly', () {
      final insight = AiInsight(
        title: 'Test',
        description: 'Test description',
        emoji: '📈',
      );

      expect(insight.title, 'Test');
      expect(insight.description, 'Test description');
      expect(insight.emoji, '📈');
    });

    test('emoji can be null', () {
      final insight = AiInsight(
        title: 'No Emoji',
        description: 'No emoji provided',
      );

      expect(insight.emoji, isNull);
    });
  });
}
