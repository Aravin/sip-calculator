import 'dart:math';
import '../models/calculator_models.dart';

class CalculatorService {
  static final CalculatorService instance = CalculatorService._();
  CalculatorService._();
  CalcResult calculateSip({
    required double monthlyInvestment,
    required double rateOfReturn,
    required int years,
    double stepUp = 0,
  }) {
    final double r = rateOfReturn / 100 / 12;
    double totalInvestment = 0;
    double corpus = 0;
    final List<YearData> breakdown = [];

    for (int y = 1; y <= years; y++) {
      double yearlyInvestment = 0;
      final double startCorpus = corpus;
      final double currentMonthly = monthlyInvestment * pow(1 + stepUp / 100, y - 1);

      for (int m = 1; m <= 12; m++) {
        totalInvestment += currentMonthly;
        yearlyInvestment += currentMonthly;
        corpus = (corpus + currentMonthly) * (1 + r);
      }

      final double interestThisYear = corpus - startCorpus - yearlyInvestment;
      breakdown.add(YearData(
        year: y,
        investedThisYear: yearlyInvestment,
        totalInvested: totalInvestment,
        interestThisYear: interestThisYear,
        totalInterest: corpus - totalInvestment,
        corpus: corpus,
      ));
    }

    return CalcResult(
      totalInvestment: totalInvestment,
      totalReturns: corpus - totalInvestment,
      totalValue: corpus,
      yearlyBreakdown: breakdown,
    );
  }

  double findGoalSip({
    required double targetCorpus,
    required double rateOfReturn,
    required int years,
    double stepUp = 0,
  }) {
    final double r = rateOfReturn / 100 / 12;
    final int months = years * 12;
    if (months == 0) return 0;
    if (r == 0) {
      return targetCorpus / months;
    }
    final double approxFactor = stepUp > 0
        ? ((pow(1 + stepUp / 100, years) - 1) / (stepUp / 100) / years)
        : 1.0;
    double low = 0;
    double high = targetCorpus / (approxFactor * ((pow(1 + r, months) - 1) / r) * (1 + r) / months);
    for (int i = 0; i < 100; i++) {
      final double mid = (low + high) / 2;
      final double corpus = calculateSip(
        monthlyInvestment: mid,
        rateOfReturn: rateOfReturn,
        years: years,
        stepUp: stepUp,
      ).totalValue;
      if (corpus > targetCorpus) {
        high = mid;
      } else {
        low = mid;
      }
    }
    return (low + high) / 2;
  }

  CalcResult calculateSipDelay({
    required double monthlyInvestment,
    required double rateOfReturn,
    required int actualYears,
    required int delayYears,
    double stepUp = 0,
  }) {
    final CalcResult actual = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: actualYears,
      stepUp: stepUp,
    );
    final CalcResult delayed = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: max(0, actualYears - delayYears),
      stepUp: stepUp,
    );
    return CalcResult(
      totalInvestment: actual.totalInvestment - delayed.totalInvestment,
      totalReturns: actual.totalValue - delayed.totalValue,
      totalValue: actual.totalValue - delayed.totalValue,
      yearlyBreakdown: [],
    );
  }

  CalcResult calculateInflationAdjusted({
    required double corpus,
    required double totalInvested,
    required int years,
    double inflationRate = 6.5,
  }) {
    final double realValue = corpus / pow(1 + inflationRate / 100, years);
    return CalcResult(
      totalInvestment: totalInvested,
      totalReturns: max(0, realValue - totalInvested),
      totalValue: realValue,
    );
  }

  CalcResult calculateSensitivity({
    required double monthlyInvestment,
    required double rateOfReturn,
    required int years,
    double stepUp = 0,
    double range = 2,
  }) {
    final CalcResult best = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn + range,
      years: years,
      stepUp: stepUp,
    );
    final CalcResult expected = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: years,
      stepUp: stepUp,
    );
    final CalcResult worst = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: max(0, rateOfReturn - range),
      years: years,
      stepUp: stepUp,
    );

    return CalcResult(
      totalInvestment: expected.totalInvestment,
      totalReturns: expected.totalReturns,
      totalValue: expected.totalValue,
      yearlyBreakdown: [
        YearData(
          year: 0,
          investedThisYear: 0,
          totalInvested: 0,
          interestThisYear: 0,
          totalInterest: 0,
          corpus: worst.totalValue,
        ),
        YearData(
          year: 1,
          investedThisYear: 0,
          totalInvested: 0,
          interestThisYear: 0,
          totalInterest: 0,
          corpus: expected.totalValue,
        ),
        YearData(
          year: 2,
          investedThisYear: 0,
          totalInvested: 0,
          interestThisYear: 0,
          totalInterest: 0,
          corpus: best.totalValue,
        ),
      ],
    );
  }

  CalcResult calculateLumpsum({
    required double investment,
    required double rateOfReturn,
    required int years,
  }) {
    final double r = rateOfReturn / 100;
    final double totalValue = investment * pow(1 + r, years);
    final List<YearData> breakdown = [];

    for (int y = 1; y <= years; y++) {
      final double startOfYear = investment * pow(1 + r, y - 1);
      final double yearEnd = startOfYear * (1 + r);
      final double interestThisYear = yearEnd - startOfYear;
      breakdown.add(YearData(
        year: y,
        investedThisYear: y == 1 ? investment : 0,
        totalInvested: investment,
        interestThisYear: interestThisYear,
        totalInterest: yearEnd - investment,
        corpus: yearEnd,
      ));
    }

    return CalcResult(
      totalInvestment: investment,
      totalReturns: totalValue - investment,
      totalValue: totalValue,
      yearlyBreakdown: breakdown,
    );
  }

  CalcResult calculateSwp({
    required double totalInvestment,
    required double monthlyWithdraw,
    required double rateOfReturn,
    required int years,
  }) {
    if (years <= 0) {
      return CalcResult(
        totalInvestment: totalInvestment, totalReturns: 0, totalValue: 0);
    }
    final double r = rateOfReturn / 100;
    if (1 + r <= 0) {
      return CalcResult(
        totalInvestment: totalInvestment,
        totalReturns: 0,
        totalValue: totalInvestment,
        yearlyBreakdown: List.generate(years, (y) => YearData(
          year: y + 1, investedThisYear: 0, totalInvested: totalInvestment,
          interestThisYear: 0, totalInterest: 0, corpus: 0,
        )),
      );
    }
    final double monthlyR = pow(1 + r, 1 / 12) - 1;

    double corpus = totalInvestment;
    double totalWithdrawn = 0;
    final List<YearData> breakdown = [];

    for (int y = 1; y <= years; y++) {
      final double startCorpus = corpus;
      double yearWithdraw = 0;

      for (int m = 1; m <= 12; m++) {
        corpus = corpus * (1 + monthlyR);
        final double withdraw = min(monthlyWithdraw, corpus);
        corpus -= withdraw;
        yearWithdraw += withdraw;
      }
      totalWithdrawn += yearWithdraw;

      breakdown.add(YearData(
        year: y,
        investedThisYear: 0,
        totalInvested: totalInvestment,
        interestThisYear: corpus - startCorpus + yearWithdraw,
        totalInterest: corpus + totalWithdrawn - totalInvestment,
        corpus: corpus > 0 ? corpus : 0,
      ));
    }

    return CalcResult(
      totalInvestment: totalInvestment,
      totalReturns: totalWithdrawn,
      totalValue: corpus > 0 ? corpus : 0,
      yearlyBreakdown: breakdown,
    );
  }

  CalcResult calculateStp({
    required double totalInvestment,
    required double rateOfReturn,
    required int years,
  }) {
    if (years < 1 || totalInvestment <= 0) {
      return CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
    }
    final double r = rateOfReturn / 100;
    final int months = years * 12;
    final double monthlyTransfer = totalInvestment / months;
    
    // Effective monthly rate for annual compounding
    final double monthlyR = pow(1 + r, 1 / 12) - 1;

    final List<YearData> breakdown = [];
    double corpus = 0;
    double cumulativeInvested = 0;

    for (int y = 1; y <= years; y++) {
      final double startCorpus = corpus;
      final double yearInvested = monthlyTransfer * 12;
      
      for (int m = 1; m <= 12; m++) {
        corpus = (corpus + monthlyTransfer) * (1 + monthlyR);
      }

      cumulativeInvested += yearInvested;
      final double interestThisYear = corpus - startCorpus - yearInvested;

      breakdown.add(YearData(
        year: y,
        investedThisYear: yearInvested,
        totalInvested: cumulativeInvested,
        interestThisYear: interestThisYear,
        totalInterest: corpus - cumulativeInvested,
        corpus: corpus,
      ));
    }

    return CalcResult(
      totalInvestment: totalInvestment,
      totalReturns: corpus - totalInvestment,
      totalValue: corpus,
      yearlyBreakdown: breakdown,
    );
  }

  CalcResult calculatePpf({
    required double yearlyInvestment,
    required double rateOfReturn,
    required int years,
  }) {
    final double r = rateOfReturn / 100;
    final double totalInvestment = yearlyInvestment * years;
    final List<YearData> breakdown = [];

    double corpus = 0;
    for (int y = 1; y <= years; y++) {
      final double startCorpus = corpus;
      corpus = ((corpus + yearlyInvestment) * (1 + r));
      final double interestThisYear = corpus - startCorpus - yearlyInvestment;
      breakdown.add(YearData(
        year: y,
        investedThisYear: yearlyInvestment,
        totalInvested: yearlyInvestment * y,
        interestThisYear: interestThisYear,
        totalInterest: corpus - (yearlyInvestment * y),
        corpus: corpus,
      ));
    }

    return CalcResult(
      totalInvestment: totalInvestment,
      totalReturns: corpus - totalInvestment,
      totalValue: corpus,
      yearlyBreakdown: breakdown,
    );
  }

  CalcResult calculateEmi({
    required double principal,
    required double annualRate,
    required int years,
  }) {
    final double r = annualRate / 12 / 100;
    final int months = years * 12;
    if (months == 0) {
      return CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
    }
    if (annualRate == 0) {
      final double monthlyEmi = principal / months;
      return CalcResult(
        totalInvestment: principal,
        totalReturns: 0,
        totalValue: principal,
        yearlyBreakdown: List.generate(years, (y) {
          final double yearlyPaid = monthlyEmi * 12;
          final double remaining = principal - (monthlyEmi * 12 * (y + 1));
          return YearData(
            year: y + 1,
            investedThisYear: yearlyPaid,
            totalInvested: monthlyEmi * 12 * (y + 1),
            interestThisYear: 0,
            totalInterest: 0,
            corpus: remaining > 0 ? remaining : 0,
          );
        }),
      );
    }
    final double emi = principal * r * pow(1 + r, months) / (pow(1 + r, months) - 1);
    final double totalPayment = emi * months;
    final double totalInterest = totalPayment - principal;

    final List<YearData> breakdown = [];
    double balance = principal;
    double cumulativeInterest = 0;
    for (int y = 1; y <= years; y++) {
      double yearInterest = 0;
      for (int m = 1; m <= 12; m++) {
        final double interest = balance * r;
        final double principalPaid = emi - interest;
        balance -= principalPaid;
        yearInterest += interest;
      }
      cumulativeInterest += yearInterest;
      breakdown.add(YearData(
        year: y,
        investedThisYear: emi * 12,
        totalInvested: emi * y * 12,
        interestThisYear: yearInterest,
        totalInterest: cumulativeInterest,
        corpus: balance > 0 ? balance : 0,
      ));
    }

    return CalcResult(
      totalInvestment: principal,
      totalReturns: totalInterest,
      totalValue: totalPayment,
      yearlyBreakdown: breakdown,
    );
  }

  CalcResult calculateCombined({
    required double lumpsumInvestment,
    required double monthlySip,
    required double rateOfReturn,
    required int years,
    double stepUp = 0,
  }) {
    final CalcResult lumpsum = calculateLumpsum(
      investment: lumpsumInvestment,
      rateOfReturn: rateOfReturn,
      years: years,
    );
    final CalcResult sip = calculateSip(
      monthlyInvestment: monthlySip,
      rateOfReturn: rateOfReturn,
      years: years,
      stepUp: stepUp,
    );

    final List<YearData> combined = [];
    final int minYears = min(lumpsum.yearlyBreakdown.length, sip.yearlyBreakdown.length);
    for (int y = 0; y < minYears; y++) {
      final YearData l = lumpsum.yearlyBreakdown[y];
      final YearData s = sip.yearlyBreakdown[y];
      combined.add(YearData(
        year: y + 1,
        investedThisYear: l.investedThisYear + s.investedThisYear,
        totalInvested: l.totalInvested + s.totalInvested,
        interestThisYear: l.interestThisYear + s.interestThisYear,
        totalInterest: l.totalInterest + s.totalInterest,
        corpus: l.corpus + s.corpus,
      ));
    }

    return CalcResult(
      totalInvestment: lumpsum.totalInvestment + sip.totalInvestment,
      totalReturns: lumpsum.totalReturns + sip.totalReturns,
      totalValue: lumpsum.totalValue + sip.totalValue,
      yearlyBreakdown: combined,
    );
  }

  double calculateSwpFromCorpus({
    required double corpus,
    required double rateOfReturn,
    required int years,
  }) {
    if (corpus.isNaN || corpus.isInfinite || corpus <= 0) return 0;
    final double r = rateOfReturn / 100;
    if (1 + r <= 0) return 0;
    final double monthlyR = pow(1 + r, 1 / 12) - 1;
    final int months = years * 12;
    if (months == 0) return 0;
    if (monthlyR == 0) return corpus / months;
    return corpus * monthlyR * pow(1 + monthlyR, months) /
        (pow(1 + monthlyR, months) - 1);
  }

  CalcResult calculateLtcgTax({
    required CalcResult result,
    double taxRate = 0.125,
    double exemption = 125000,
  }) {
    final double gains = result.totalReturns;
    final double taxableGains = max(0, gains - exemption);
    final double tax = taxableGains * taxRate;
    final double postTax = max(0, result.totalValue - tax);

    return CalcResult(
      totalInvestment: result.totalInvestment,
      totalReturns: max(0, postTax - result.totalInvestment),
      totalValue: postTax,
    );
  }

  CalcResult calculateFd({
    required double principal,
    required double rateOfReturn,
    required int years,
    String compounding = 'quarterly',
    String payout = 'cumulative',
  }) {
    final double r = rateOfReturn / 100;
    final List<YearData> breakdown = [];

    if (payout == 'quarterly') {
      final double quarterlyRate = r / 4;
      final double quarterlyInterest = principal * quarterlyRate;
      double totalInterest = 0;
      for (int y = 1; y <= years; y++) {
        double yearInterest = 0;
        for (int q = 1; q <= 4; q++) {
          totalInterest += quarterlyInterest;
          yearInterest += quarterlyInterest;
        }
        breakdown.add(YearData(
          year: y,
          investedThisYear: 0,
          totalInvested: principal,
          interestThisYear: yearInterest,
          totalInterest: totalInterest,
          corpus: principal,
        ));
      }
      return CalcResult(
        totalInvestment: principal,
        totalReturns: totalInterest,
        totalValue: principal + totalInterest,
        yearlyBreakdown: breakdown,
      );
    }

    int n;
    switch (compounding) {
      case 'monthly':
        n = 12;
        break;
      case 'half_yearly':
        n = 2;
        break;
      case 'yearly':
        n = 1;
        break;
      default:
        n = 4;
    }

    double totalValue = principal;
    for (int y = 1; y <= years; y++) {
      final double startOfYear = totalValue;
      totalValue = startOfYear * pow(1 + r / n, n);
      final double interestThisYear = totalValue - startOfYear;
      breakdown.add(YearData(
        year: y,
        investedThisYear: 0,
        totalInvested: principal,
        interestThisYear: interestThisYear,
        totalInterest: totalValue - principal,
        corpus: totalValue,
      ));
    }

    return CalcResult(
      totalInvestment: principal,
      totalReturns: totalValue - principal,
      totalValue: totalValue,
      yearlyBreakdown: breakdown,
    );
  }

  CalcResult calculateRd({
    required double monthlyDeposit,
    required double rateOfReturn,
    required int years,
  }) {
    final double r = rateOfReturn / 100;
    final int totalMonths = years * 12;
    final double totalInvestment = monthlyDeposit * totalMonths;
    
    // Effective monthly rate for quarterly compounding
    final double monthlyR = pow(1 + r / 4, 1 / 3) - 1;

    final List<YearData> breakdown = [];
    double corpus = 0;
    double cumulativeInvested = 0;

    for (int y = 1; y <= years; y++) {
      final double startCorpus = corpus;
      final double yearInvested = monthlyDeposit * 12;

      for (int m = 1; m <= 12; m++) {
        corpus = (corpus + monthlyDeposit) * (1 + monthlyR);
      }

      cumulativeInvested += yearInvested;
      final double interestThisYear = corpus - startCorpus - yearInvested;

      breakdown.add(YearData(
        year: y,
        investedThisYear: yearInvested,
        totalInvested: cumulativeInvested,
        interestThisYear: interestThisYear,
        totalInterest: corpus - cumulativeInvested,
        corpus: corpus,
      ));
    }

    return CalcResult(
      totalInvestment: totalInvestment,
      totalReturns: corpus - totalInvestment,
      totalValue: corpus,
      yearlyBreakdown: breakdown,
    );
  }

  CalcResult calculateCompoundInterest({
    required double principal,
    required double rateOfReturn,
    required int years,
    String frequency = 'monthly',
  }) {
    final double r = rateOfReturn / 100;
    int n;
    switch (frequency) {
      case 'daily':
        n = 365;
        break;
      case 'monthly':
        n = 12;
        break;
      case 'quarterly':
        n = 4;
        break;
      case 'half_yearly':
        n = 2;
        break;
      case 'yearly':
        n = 1;
        break;
      default:
        n = 12;
    }

    double totalValue = principal;
    final List<YearData> breakdown = [];
    for (int y = 1; y <= years; y++) {
      final double startOfYear = totalValue;
      totalValue = startOfYear * pow(1 + r / n, n);
      final double interestThisYear = totalValue - startOfYear;
      breakdown.add(YearData(
        year: y,
        investedThisYear: 0,
        totalInvested: principal,
        interestThisYear: interestThisYear,
        totalInterest: totalValue - principal,
        corpus: totalValue,
      ));
    }

    return CalcResult(
      totalInvestment: principal,
      totalReturns: totalValue - principal,
      totalValue: totalValue,
      yearlyBreakdown: breakdown,
    );
  }

  ComparisonResult compareSipVsLumpsum({
    required double monthlySip,
    required double lumpsumInvestment,
    required double rateOfReturn,
    required int years,
    double stepUp = 0,
  }) {
    final CalcResult lumpsum = calculateLumpsum(
      investment: lumpsumInvestment,
      rateOfReturn: rateOfReturn,
      years: years,
    );
    final CalcResult sip = calculateSip(
      monthlyInvestment: monthlySip,
      rateOfReturn: rateOfReturn,
      years: years,
      stepUp: stepUp,
    );

    return ComparisonResult(
      lumpsumCorpus: lumpsum.totalValue,
      sipCorpus: sip.totalValue,
      lumpsumInvestment: lumpsumInvestment,
      sipTotalInvestment: sip.totalInvestment,
      rateOfReturn: rateOfReturn,
      years: years,
      lumpsumBreakdown: lumpsum.yearlyBreakdown,
      sipBreakdown: sip.yearlyBreakdown,
    );
  }

  TaxResult calculateTax({
    required double grossIncome,
    double deduction80C = 0,
    double deduction80D = 0,
  }) {
    const standardDeductionOld = 50000.0;
    const standardDeductionNew = 75000.0;
    final double totalDeductions =
        min(deduction80C, 150000.0) + min(deduction80D, 25000.0);

    final double taxableIncomeOld =
        max(0.0, grossIncome - totalDeductions - standardDeductionOld);
    final double taxableIncomeNew =
        max(0.0, grossIncome - standardDeductionNew);

    double computeTaxOld(double income) {
      double tax = 0;
      if (income > 1000000) {
        tax += (income - 1000000) * 0.30;
        income = 1000000;
      }
      if (income > 500000) {
        tax += (income - 500000) * 0.20;
        income = 500000;
      }
      if (income > 250000) {
        tax += (income - 250000) * 0.05;
      }
      if (taxableIncomeOld <= 500000) {
        tax = max(0.0, tax - 12500);
      }
      return tax;
    }

    double computeTaxNew(double income) {
      double tax = 0;
      if (income > 1500000) {
        tax += (income - 1500000) * 0.30;
        income = 1500000;
      }
      if (income > 1200000) {
        tax += (income - 1200000) * 0.20;
        income = 1200000;
      }
      if (income > 1000000) {
        tax += (income - 1000000) * 0.15;
        income = 1000000;
      }
      if (income > 700000) {
        tax += (income - 700000) * 0.10;
        income = 700000;
      }
      if (income > 300000) {
        tax += (income - 300000) * 0.05;
      }
      if (taxableIncomeNew <= 700000) {
        tax = max(0.0, tax - 25000);
      }
      return tax;
    }

    final double taxOld = computeTaxOld(taxableIncomeOld);
    final double taxNew = computeTaxNew(taxableIncomeNew);
    final double cessOld = taxOld * 0.04;
    final double cessNew = taxNew * 0.04;

    return TaxResult(
      grossIncome: grossIncome,
      taxableIncomeOld: taxableIncomeOld,
      taxableIncomeNew: taxableIncomeNew,
      taxOld: taxOld,
      taxNew: taxNew,
      cessOld: cessOld,
      cessNew: cessNew,
      totalTaxOld: taxOld + cessOld,
      totalTaxNew: taxNew + cessNew,
      deductions: totalDeductions + standardDeductionOld,
    );
  }

  List<AiInsight> generateInsights({
    required double monthlyInvestment,
    required double rateOfReturn,
    required int years,
    double stepUp = 0,
  }) {
    final List<AiInsight> insights = [];

    final CalcResult base = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: years,
      stepUp: 0,
    );

    if (stepUp > 0) {
      final CalcResult stepped = calculateSip(
        monthlyInvestment: monthlyInvestment,
        rateOfReturn: rateOfReturn,
        years: years,
        stepUp: stepUp,
      );
      final double extra = stepped.totalValue - base.totalValue;
      final String extraText = extra.isFinite ? extra.toStringAsFixed(0) : '0';
      insights.add(AiInsight(
        title: 'Step-Up Impact',
        description:
            'Increasing investment by $stepUp% annually adds $extraText to your corpus.',
        emoji: '📈',
      ));
    }

    if (years >= 10) {
      final double halfTime = calculateSip(
        monthlyInvestment: monthlyInvestment,
        rateOfReturn: rateOfReturn,
        years: years ~/ 2,
        stepUp: stepUp,
      ).totalValue;
      final double fullTime = base.totalValue;
      final String secondHalf = (fullTime - halfTime).isFinite ? (fullTime - halfTime).toStringAsFixed(0) : '0';
      String pct = '0';
      if (fullTime > 0) {
        final double pctVal = (fullTime - halfTime) / fullTime * 100;
        pct = pctVal.isFinite ? pctVal.toStringAsFixed(0) : '0';
      }
      insights.add(AiInsight(
        title: 'Power of Compounding',
        description:
            'In the second half of your tenure, you earn $secondHalf — $pct% of your total corpus.',
        emoji: '💪',
      ));
    }

    final CalcResult delayed = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: max(1, years - 1),
      stepUp: stepUp,
    );
    final double delayCost = base.totalValue - delayed.totalValue;
    final String delayText = delayCost.isFinite ? delayCost.toStringAsFixed(0) : '0';
    insights.add(AiInsight(
      title: 'Cost of Delay',
      description:
          'Delaying your SIP by just 1 year costs you approximately $delayText.',
      emoji: '⏰',
    ));

    return insights;
  }
}
