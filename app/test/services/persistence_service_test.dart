import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/persistence_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PersistenceService', () {
    test('loadAll returns empty list when no data saved', () async {
      final items = await PersistenceService.loadAll();
      expect(items, isEmpty);
    });

    test('save and load returns saved calculation', () async {
      final calc = SavedCalculation(
        id: 'test-1',
        name: 'Test SIP',
        type: 'SIP',
        params: '₹5000/mo, 12%, 5y',
        result: CalcResult(
          totalInvestment: 300000,
          totalReturns: 200000,
          totalValue: 500000,
        ),
        savedAt: DateTime(2025, 1, 1),
      );

      await PersistenceService.save(calc);
      final items = await PersistenceService.loadAll();

      expect(items.length, 1);
      expect(items[0].id, 'test-1');
      expect(items[0].name, 'Test SIP');
      expect(items[0].type, 'SIP');
      expect(items[0].result.totalValue, closeTo(500000, 0.5));
    });

    test('delete removes specific item', () async {
      final calc1 = SavedCalculation(
        id: '1',
        name: 'First',
        type: 'SIP',
        params: '',
        result:
            CalcResult(totalInvestment: 100, totalReturns: 10, totalValue: 110),
        savedAt: DateTime.now(),
      );
      final calc2 = SavedCalculation(
        id: '2',
        name: 'Second',
        type: 'EMI',
        params: '',
        result:
            CalcResult(totalInvestment: 200, totalReturns: 20, totalValue: 220),
        savedAt: DateTime.now(),
      );

      await PersistenceService.save(calc1);
      await PersistenceService.save(calc2);
      await PersistenceService.delete('1');

      final items = await PersistenceService.loadAll();
      expect(items.length, 1);
      expect(items[0].id, '2');
    });

    test('delete non-existent id does nothing', () async {
      final calc = SavedCalculation(
        id: '1',
        name: 'Test',
        type: 'SIP',
        params: '',
        result:
            CalcResult(totalInvestment: 100, totalReturns: 10, totalValue: 110),
        savedAt: DateTime.now(),
      );

      await PersistenceService.save(calc);
      await PersistenceService.delete('non-existent');

      final items = await PersistenceService.loadAll();
      expect(items.length, 1);
    });

    test('enforces max items limit (50)', () async {
      for (int i = 0; i < 55; i++) {
        final calc = SavedCalculation(
          id: '$i',
          name: 'Calc $i',
          type: 'SIP',
          params: '',
          result: CalcResult(
              totalInvestment: 100.0 * i,
              totalReturns: 10.0 * i,
              totalValue: 110.0 * i),
          savedAt: DateTime.now(),
        );
        await PersistenceService.save(calc);
      }

      final items = await PersistenceService.loadAll();
      expect(items.length, 50);
      // Most recent 50 items should remain (ids 5..54)
      expect(items[0].id, '5');
      expect(items[49].id, '54');
    });

    test('persists serialized data correctly (JSON roundtrip)', () async {
      final yearlyBreakdown = [
        YearData(
            year: 1,
            investedThisYear: 60000,
            totalInvested: 60000,
            interestThisYear: 3000,
            totalInterest: 3000,
            corpus: 63000),
        YearData(
            year: 2,
            investedThisYear: 60000,
            totalInvested: 120000,
            interestThisYear: 7500,
            totalInterest: 10500,
            corpus: 130500),
      ];

      final calc = SavedCalculation(
        id: 'roundtrip-1',
        name: 'Roundtrip Test',
        type: 'SIP',
        params: 'test',
        result: CalcResult(
          totalInvestment: 120000,
          totalReturns: 10500,
          totalValue: 130500,
          yearlyBreakdown: yearlyBreakdown,
        ),
        savedAt: DateTime(2025, 6, 15, 10, 30, 0),
      );

      await PersistenceService.save(calc);
      final items = await PersistenceService.loadAll();

      expect(items.length, 1);
      expect(items[0].result.yearlyBreakdown.length, 2);
      expect(items[0].result.yearlyBreakdown[0].corpus, closeTo(63000, 0.5));
      expect(items[0].result.yearlyBreakdown[1].corpus, closeTo(130500, 0.5));
      expect(items[0].savedAt.year, 2025);
      expect(items[0].savedAt.month, 6);
      expect(items[0].savedAt.day, 15);
    });

    test('handles corrupt data gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'saved_calculations': '{this is not valid json',
      });

      final items = await PersistenceService.loadAll();
      expect(items, isEmpty);
    });

    test('save with null or empty result works', () async {
      final calc = SavedCalculation(
        id: 'empty-test',
        name: 'Empty Result',
        type: 'SIP',
        params: '',
        result: CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0),
        savedAt: DateTime.now(),
      );

      await PersistenceService.save(calc);
      final items = await PersistenceService.loadAll();

      expect(items.length, 1);
      expect(items[0].result.totalValue, 0);
    });
  });
}
