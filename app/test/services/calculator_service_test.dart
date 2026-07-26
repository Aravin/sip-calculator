import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';

void main() {
  final service = CalculatorService.instance;

  group('SIP', () {
    test('basic SIP calculation matches formula', () {
      // FV = P * (((1 + r)^n - 1) / r) * (1 + r)
      // P=5000, r=12%/12=1%, n=2*12=24
      // FV = 5000 * ((1.01^24 - 1) / 0.01) * 1.01
      final result = service.calculateSip(
        monthlyInvestment: 5000,
        rateOfReturn: 12,
        years: 2,
      );

      double r = 12 / 100 / 12;
      int n = 2 * 12;
      double expected = 5000 * ((pow(1 + r, n) - 1) / r) * (1 + r);

      expect(result.totalInvestment, closeTo(120000, 0.5));
      expect(result.totalValue, closeTo(expected, 0.5));
      expect(result.totalReturns, closeTo(expected - 120000, 0.5));
    });

    test('SIP with 10% step-up increases corpus vs flat SIP', () {
      final flat = service.calculateSip(
        monthlyInvestment: 10000,
        rateOfReturn: 12,
        years: 10,
        stepUp: 0,
      );

      final stepped = service.calculateSip(
        monthlyInvestment: 10000,
        rateOfReturn: 12,
        years: 10,
        stepUp: 10,
      );

      expect(stepped.totalValue, greaterThan(flat.totalValue));
      expect(stepped.totalInvestment, greaterThan(flat.totalInvestment));
    });

    test('SIP step-up produces correct yearly breakdown', () {
      final result = service.calculateSip(
        monthlyInvestment: 10000,
        rateOfReturn: 12,
        years: 3,
        stepUp: 10,
      );

      expect(result.yearlyBreakdown.length, 3);
      // Year 1: monthly = 10000, Year 2: monthly = 11000, Year 3: monthly = 12100
      expect(result.yearlyBreakdown[0].investedThisYear, closeTo(120000, 1));
      expect(result.yearlyBreakdown[1].investedThisYear, closeTo(132000, 1));
      expect(result.yearlyBreakdown[2].investedThisYear, closeTo(145200, 1));
    });

    test('SIP yearly breakdown totals match final values', () {
      final result = service.calculateSip(
        monthlyInvestment: 5000,
        rateOfReturn: 15,
        years: 5,
      );

      double totalFromBreakdown = result.yearlyBreakdown.fold(0, (sum, y) => sum + y.investedThisYear);
      expect(totalFromBreakdown, closeTo(result.totalInvestment, 0.5));

      double lastCorpus = result.yearlyBreakdown.last.corpus;
      expect(lastCorpus, closeTo(result.totalValue, 0.5));
    });

    test('SIP handles minimum values', () {
      final result = service.calculateSip(
        monthlyInvestment: 500,
        rateOfReturn: 1,
        years: 1,
      );
      expect(result.totalValue, greaterThan(0));
      expect(result.totalInvestment, closeTo(6000, 0.5));
    });

    test('SIP handles maximum values', () {
      final result = service.calculateSip(
        monthlyInvestment: 500000,
        rateOfReturn: 30,
        years: 30,
      );
      expect(result.totalValue, greaterThan(0));
      expect(result.yearlyBreakdown.length, 30);
    });
  });

  group('Goal Mode (Reverse SIP)', () {
    test('findGoalSip returns SIP that achieves target corpus', () {
      double target = 10000000; // ₹1 Cr
      double rate = 12;
      int years = 15;

      double sipAmount = service.findGoalSip(
        targetCorpus: target,
        rateOfReturn: rate,
        years: years,
      );

      final result = service.calculateSip(
        monthlyInvestment: sipAmount,
        rateOfReturn: rate,
        years: years,
      );

      expect(result.totalValue, closeTo(target, target * 0.01)); // within 1%
    });

    test('findGoalSip works with step-up', () {
      double target = 50000000; // ₹5 Cr
      double rate = 12;
      int years = 20;

      double sipAmount = service.findGoalSip(
        targetCorpus: target,
        rateOfReturn: rate,
        years: years,
        stepUp: 10,
      );

      final result = service.calculateSip(
        monthlyInvestment: sipAmount,
        rateOfReturn: rate,
        years: years,
        stepUp: 10,
      );

      expect(result.totalValue, closeTo(target, target * 0.01));
    });

    test('findGoalSip returns lower SIP for longer tenure', () {
      double target = 10000000;

      double sip10 = service.findGoalSip(
        targetCorpus: target, rateOfReturn: 12, years: 10);
      double sip20 = service.findGoalSip(
        targetCorpus: target, rateOfReturn: 12, years: 20);

      expect(sip20, lessThan(sip10));
    });
  });

  group('SIP Delay Cost', () {
    test('delaying 1 year reduces corpus', () {
      final noDelay = service.calculateSip(
        monthlyInvestment: 10000, rateOfReturn: 12, years: 10);

      final delayed = service.calculateSipDelay(
        monthlyInvestment: 10000, rateOfReturn: 12,
        actualYears: 10, delayYears: 1);

      expect(delayed.totalValue, greaterThan(0));
      expect(delayed.totalValue, lessThan(noDelay.totalValue));
    });

    test('delay cost increases with longer delay', () {
      final delay1 = service.calculateSipDelay(
        monthlyInvestment: 10000, rateOfReturn: 12,
        actualYears: 10, delayYears: 1);

      final delay3 = service.calculateSipDelay(
        monthlyInvestment: 10000, rateOfReturn: 12,
        actualYears: 10, delayYears: 3);

      expect(delay3.totalValue, greaterThan(delay1.totalValue));
    });

    test('delay >= actual years costs the entire corpus', () {
      final actual = service.calculateSip(
        monthlyInvestment: 10000, rateOfReturn: 12, years: 5);

      final result = service.calculateSipDelay(
        monthlyInvestment: 10000, rateOfReturn: 12,
        actualYears: 5, delayYears: 5);

      expect(result.totalValue, closeTo(actual.totalValue, 0.5));
    });
  });

  group('Inflation Adjusted', () {
    test('real value is less than nominal corpus', () {
      final result = service.calculateInflationAdjusted(
        corpus: 10000000, years: 10, totalInvested: 10000000);

      expect(result.totalValue, lessThan(10000000));
      expect(result.totalValue, greaterThan(0));
    });

    test('higher inflation = lower real value', () {
      final lowInfl = service.calculateInflationAdjusted(
        corpus: 10000000, years: 10, inflationRate: 4, totalInvested: 10000000);

      final highInfl = service.calculateInflationAdjusted(
        corpus: 10000000, years: 10, inflationRate: 10, totalInvested: 10000000);

      expect(highInfl.totalValue, lessThan(lowInfl.totalValue));
    });

    test('zero years means no inflation impact', () {
      final result = service.calculateInflationAdjusted(
        corpus: 100000, years: 0, totalInvested: 100000);

      expect(result.totalValue, closeTo(100000, 0.5));
    });
  });

  group('Sensitivity', () {
    test('best > expected > worst', () {
      final result = service.calculateSensitivity(
        monthlyInvestment: 10000, rateOfReturn: 12, years: 10);

      expect(result.yearlyBreakdown.length, 3);
      double worst = result.yearlyBreakdown[0].corpus;
      double expected = result.yearlyBreakdown[1].corpus;
      double best = result.yearlyBreakdown[2].corpus;

      expect(best, greaterThan(expected));
      expect(expected, greaterThan(worst));
    });
  });

  group('Lumpsum', () {
    test('basic lumpsum calculation', () {
      // FV = P * (1 + r)^t
      // P=100000, r=12%, t=5
      double expected = (100000 * pow(1 + 0.12, 5)).toDouble();

      final result = service.calculateLumpsum(
        investment: 100000, rateOfReturn: 12, years: 5);

      expect(result.totalInvestment, closeTo(100000, 0.5));
      expect(result.totalValue, closeTo(expected, 0.5));
      expect(result.totalReturns, closeTo(expected - 100000, 0.5));
    });

    test('lumpsum yearly breakdown is correct', () {
      final result = service.calculateLumpsum(
        investment: 100000, rateOfReturn: 10, years: 3);

      expect(result.yearlyBreakdown.length, 3);
      // Year 1: 100000 * 1.1 = 110000
      expect(result.yearlyBreakdown[0].corpus, closeTo(110000, 0.5));
      // Year 2: 100000 * 1.1^2 = 121000
      expect(result.yearlyBreakdown[1].corpus, closeTo(121000, 0.5));
      // Year 3: 100000 * 1.1^3 = 133100
      expect(result.yearlyBreakdown[2].corpus, closeTo(133100, 0.5));
    });

    test('lumpsum with zero return equals investment', () {
      final result = service.calculateLumpsum(
        investment: 500000, rateOfReturn: 0, years: 10);

      expect(result.totalValue, closeTo(500000, 0.5));
      expect(result.totalReturns, closeTo(0, 0.5));
    });
  });

  group('SWP', () {
    test('basic SWP calculation', () {
      final result = service.calculateSwp(
        totalInvestment: 500000,
        monthlyWithdraw: 2000,
        rateOfReturn: 10,
        years: 5,
      );

      expect(result.totalInvestment, closeTo(500000, 0.5));
      expect(result.totalReturns, greaterThan(0));
      // Total withdrawn = 2000 * 12 * 5 = 120000
      expect(result.totalReturns, closeTo(120000, 1));
    });

    test('SWP high withdrawal depletes corpus', () {
      // Withdrawing 5% of corpus monthly — corpus should deplete
      final result = service.calculateSwp(
        totalInvestment: 500000,
        monthlyWithdraw: 25000,
        rateOfReturn: 8,
        years: 5,
      );

      expect(result.totalValue, lessThan(500000));
    });

    test('SWP corpus does not go negative', () {
      final result = service.calculateSwp(
        totalInvestment: 100000,
        monthlyWithdraw: 5000,
        rateOfReturn: 6,
        years: 10,
      );

      expect(result.totalValue, greaterThanOrEqualTo(0));
    });
  });

  group('STP', () {
    test('STP returns exceed total investment', () {
      final result = service.calculateStp(
        totalInvestment: 120000,
        rateOfReturn: 12,
        years: 1,
      );

      expect(result.totalInvestment, closeTo(120000, 0.5));
      expect(result.totalValue, greaterThan(120000));
      expect(result.totalReturns, greaterThan(0));
    });

    test('STP longer tenure = larger corpus', () {
      final short = service.calculateStp(
        totalInvestment: 120000, rateOfReturn: 12, years: 1);

      final long = service.calculateStp(
        totalInvestment: 120000, rateOfReturn: 12, years: 10);

      expect(long.totalValue, greaterThan(short.totalValue));
    });
  });

  group('PPF', () {
    test('basic PPF calculation', () {
      // PPF formula: FV = ((YI * ((1+r)^t - 1)) / r) * (1+r)
      // YI=24000, r=7.1%, t=15
      double r = 7.1 / 100;
      double expected = ((24000 * (pow(1 + r, 15) - 1)) / r) * (1 + r);

      final result = service.calculatePpf(
        yearlyInvestment: 24000, rateOfReturn: 7.1, years: 15);

      expect(result.totalInvestment, closeTo(360000, 0.5));
      expect(result.totalValue, closeTo(expected, 100));
    });

    test('PPF yearly breakdown matches total', () {
      final result = service.calculatePpf(
        yearlyInvestment: 24000, rateOfReturn: 7.1, years: 15);

      expect(result.yearlyBreakdown.length, 15);
      double lastCorpus = result.yearlyBreakdown.last.corpus;
      expect(lastCorpus, closeTo(result.totalValue, 0.5));
    });

    test('PPF with 0% return equals total investment', () {
      final result = service.calculatePpf(
        yearlyInvestment: 24000, rateOfReturn: 0, years: 15);

      expect(result.totalValue, closeTo(360000, 0.5));
    });
  });

  group('EMI', () {
    test('basic EMI calculation', () {
      // EMI = P * r * (1+r)^n / ((1+r)^n - 1)
      // P=500000, r=9%/12=0.75%, n=5*12=60
      double r = 9 / 12 / 100;
      int n = 5 * 12;
      double expectedEmi = 500000 * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
      double expectedTotal = expectedEmi * n;

      final result = service.calculateEmi(
        principal: 500000, annualRate: 9, years: 5);

      double monthlyEmi = result.totalValue / (5 * 12);
      expect(monthlyEmi, closeTo(expectedEmi, 1));
      expect(result.totalValue, closeTo(expectedTotal, 100));
    });

    test('EMI amortization schedule principal + interest = payment', () {
      final result = service.calculateEmi(
        principal: 1000000, annualRate: 10, years: 10);

      double totalPayments = result.totalValue;
      expect(totalPayments, closeTo(result.totalInvestment + result.totalReturns, 1));
    });

    test('EMI yearly breakdown totals are consistent', () {
      final result = service.calculateEmi(
        principal: 500000, annualRate: 9, years: 5);

      double totalInterest = result.yearlyBreakdown.fold(0.0, (sum, y) => sum + y.interestThisYear);
      expect(totalInterest, closeTo(result.totalReturns, 10));
    });

    test('EMI with zero interest equals principal', () {
      final result = service.calculateEmi(
        principal: 100000, annualRate: 0, years: 5);

      expect(result.totalValue, closeTo(100000, 0.5));
      expect(result.totalReturns, closeTo(0, 0.5));
    });

    test('last EMI year balance is ~0', () {
      final result = service.calculateEmi(
        principal: 1000000, annualRate: 10, years: 5);

      double lastBalance = result.yearlyBreakdown.last.corpus;
      expect(lastBalance, lessThan(100)); // nearly paid off
    });
  });

  group('Combined (SIP + Lumpsum)', () {
    test('combined corpus equals sum of individual', () {
      final combined = service.calculateCombined(
        lumpsumInvestment: 200000,
        monthlySip: 10000,
        rateOfReturn: 12,
        years: 10,
      );

      final lumpsum = service.calculateLumpsum(
        investment: 200000, rateOfReturn: 12, years: 10);

      final sip = service.calculateSip(
        monthlyInvestment: 10000, rateOfReturn: 12, years: 10);

      double expectedTotal = lumpsum.totalValue + sip.totalValue;
      expect(combined.totalValue, closeTo(expectedTotal, expectedTotal * 0.001));
    });

    test('combined with step-up exceeds flat combined', () {
      final flat = service.calculateCombined(
        lumpsumInvestment: 100000,
        monthlySip: 5000,
        rateOfReturn: 12,
        years: 15,
      );

      final stepped = service.calculateCombined(
        lumpsumInvestment: 100000,
        monthlySip: 5000,
        rateOfReturn: 12,
        years: 15,
        stepUp: 10,
      );

      expect(stepped.totalValue, greaterThan(flat.totalValue));
    });
  });

  group('LTCG Tax', () {
    test('tax is applied only on gains above exemption', () {
      CalcResult result = CalcResult(
        totalInvestment: 100000,
        totalReturns: 50000,
        totalValue: 150000,
      );

      final postTax = service.calculateLtcgTax(result: result);

      // Gains = 50000, exemption = 125000, taxable = max(0, 50000-125000) = 0
      expect(postTax.totalValue, closeTo(150000, 0.5));
    });

    test('tax reduces corpus for large gains', () {
      CalcResult result = CalcResult(
        totalInvestment: 100000,
        totalReturns: 1000000,
        totalValue: 1100000,
      );

      final postTax = service.calculateLtcgTax(result: result);

      // Gains = 1000000, taxable = 1000000-125000 = 875000, tax = 875000*0.125 = 109375
      // Post-tax = 1100000-109375 = 990625
      expect(postTax.totalValue, lessThan(1100000));
      expect(postTax.totalReturns, greaterThan(0));
    });

    test('tax respects custom tax rate and exemption', () {
      CalcResult result = CalcResult(
        totalInvestment: 500000,
        totalReturns: 2000000,
        totalValue: 2500000,
      );

      final postTax = service.calculateLtcgTax(
        result: result, taxRate: 0.10, exemption: 100000);

      double expectedTax = (2000000 - 100000) * 0.10;
      double expectedValue = 2500000 - expectedTax;
      expect(postTax.totalValue, closeTo(expectedValue, 0.5));
    });
  });

  group('SWP from Corpus', () {
    test('returns positive monthly withdrawal', () {
      double monthly = service.calculateSwpFromCorpus(
        corpus: 10000000, rateOfReturn: 8, years: 20);

      expect(monthly, greaterThan(0));
    });

    test('smaller corpus = smaller monthly withdrawal', () {
      double high = service.calculateSwpFromCorpus(
        corpus: 5000000, rateOfReturn: 8, years: 20);

      double low = service.calculateSwpFromCorpus(
        corpus: 1000000, rateOfReturn: 8, years: 20);

      expect(high, greaterThan(low));
    });

    test('longer tenure = smaller monthly withdrawal', () {
      double short = service.calculateSwpFromCorpus(
        corpus: 10000000, rateOfReturn: 8, years: 10);

      double long = service.calculateSwpFromCorpus(
        corpus: 10000000, rateOfReturn: 8, years: 30);

      expect(long, lessThan(short));
    });
  });

  group('AI Insights', () {
    test('returns insights for valid inputs', () {
      final insights = service.generateInsights(
        monthlyInvestment: 10000,
        rateOfReturn: 12,
        years: 15,
        stepUp: 0,
      );

      expect(insights.isNotEmpty, true);
      // Always has Cost of Delay
      expect(insights.any((i) => i.title == 'Cost of Delay'), true);
    });

    test('includes Step-Up Impact when stepUp > 0', () {
      final insights = service.generateInsights(
        monthlyInvestment: 10000,
        rateOfReturn: 12,
        years: 15,
        stepUp: 10,
      );

      expect(insights.any((i) => i.title == 'Step-Up Impact'), true);
    });

    test('includes Power of Compounding for long tenure', () {
      final insights = service.generateInsights(
        monthlyInvestment: 10000,
        rateOfReturn: 12,
        years: 15,
      );

      expect(insights.any((i) => i.title == 'Power of Compounding'), true);
    });

    test('excludes Power of Compounding for short tenure', () {
      final insights = service.generateInsights(
        monthlyInvestment: 10000,
        rateOfReturn: 12,
        years: 5,
      );

      expect(insights.any((i) => i.title == 'Power of Compounding'), false);
    });
  });
}
