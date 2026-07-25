import 'dart:math';
import '../models/calculator_models.dart';

class CalculatorService {
  CalcResult calculateSip({
    required double monthlyInvestment,
    required double rateOfReturn,
    required int years,
    double stepUp = 0,
  }) {
    double r = rateOfReturn / 100 / 12;
    double totalInvestment = 0;
    double corpus = 0;
    List<YearData> breakdown = [];

    for (int y = 1; y <= years; y++) {
      double yearlyInvestment = 0;
      double startCorpus = corpus;
      double currentMonthly = monthlyInvestment * pow(1 + stepUp / 100, y - 1);

      for (int m = 1; m <= 12; m++) {
        totalInvestment += currentMonthly;
        yearlyInvestment += currentMonthly;
        corpus = (corpus + currentMonthly) * (1 + r);
      }

      double interestThisYear = corpus - startCorpus - yearlyInvestment;
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
    double r = rateOfReturn / 100 / 12;
    int months = years * 12;
    if (months == 0) return 0;
    if (r == 0) {
      return targetCorpus / months;
    }
    double approxFactor = stepUp > 0
        ? ((pow(1 + stepUp / 100, years) - 1) / (stepUp / 100) / years)
        : 1.0;
    double low = 0;
    double high = targetCorpus / (approxFactor * ((pow(1 + r, months) - 1) / r) * (1 + r) / months);
    for (int i = 0; i < 100; i++) {
      double mid = (low + high) / 2;
      double corpus = calculateSip(
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
    CalcResult actual = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: actualYears,
      stepUp: stepUp,
    );
    CalcResult delayed = calculateSip(
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
    required int years,
    double inflationRate = 6.5,
  }) {
    double realValue = corpus / pow(1 + inflationRate / 100, years);
    return CalcResult(
      totalInvestment: corpus,
      totalReturns: 0,
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
    CalcResult best = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn + range,
      years: years,
      stepUp: stepUp,
    );
    CalcResult expected = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: years,
      stepUp: stepUp,
    );
    CalcResult worst = calculateSip(
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
    double r = rateOfReturn / 100;
    double totalValue = investment * pow(1 + r, years);
    List<YearData> breakdown = [];

    for (int y = 1; y <= years; y++) {
      double startOfYear = investment * pow(1 + r, y - 1);
      double yearEnd = startOfYear * (1 + r);
      double interestThisYear = yearEnd - startOfYear;
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
    double r = rateOfReturn / 100;
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
    double monthlyR = pow(1 + r, 1 / 12) - 1;

    double corpus = totalInvestment;
    double totalWithdrawn = 0;
    List<YearData> breakdown = [];

    for (int y = 1; y <= years; y++) {
      double startCorpus = corpus;
      double yearWithdraw = 0;

      for (int m = 1; m <= 12; m++) {
        corpus = corpus * (1 + monthlyR);
        double withdraw = min(monthlyWithdraw, corpus);
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
    if (years < 1) {
      return CalcResult(totalInvestment: totalInvestment, totalReturns: 0, totalValue: 0);
    }
    double monthlyAmount = totalInvestment / (years * 12);
    return CalcResult(
      totalInvestment: totalInvestment,
      totalReturns: 0,
      totalValue: monthlyAmount,
    );
  }

  CalcResult calculatePpf({
    required double yearlyInvestment,
    required double rateOfReturn,
    required int years,
  }) {
    double r = rateOfReturn / 100;
    double totalInvestment = yearlyInvestment * years;
    List<YearData> breakdown = [];

    double corpus = 0;
    for (int y = 1; y <= years; y++) {
      double startCorpus = corpus;
      corpus = ((corpus + yearlyInvestment) * (1 + r));
      double interestThisYear = corpus - startCorpus - yearlyInvestment;
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
    double r = annualRate / 12 / 100;
    int months = years * 12;
    if (months == 0) {
      return CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
    }
    if (annualRate == 0) {
      double monthlyEmi = principal / months;
      return CalcResult(
        totalInvestment: principal,
        totalReturns: 0,
        totalValue: principal,
        yearlyBreakdown: List.generate(years, (y) {
          double yearlyPaid = monthlyEmi * 12;
          double remaining = principal - (monthlyEmi * 12 * (y + 1));
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
    double emi = principal * r * pow(1 + r, months) / (pow(1 + r, months) - 1);
    double totalPayment = emi * months;
    double totalInterest = totalPayment - principal;

    List<YearData> breakdown = [];
    double balance = principal;
    double cumulativeInterest = 0;
    for (int y = 1; y <= years; y++) {
      double yearPrincipal = 0;
      double yearInterest = 0;
      for (int m = 1; m <= 12; m++) {
        double interest = balance * r;
        double principalPaid = emi - interest;
        balance -= principalPaid;
        yearPrincipal += principalPaid;
        yearInterest += interest;
      }
      cumulativeInterest += yearInterest;
      breakdown.add(YearData(
        year: y,
        investedThisYear: yearPrincipal * 12,
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
    CalcResult lumpsum = calculateLumpsum(
      investment: lumpsumInvestment,
      rateOfReturn: rateOfReturn,
      years: years,
    );
    CalcResult sip = calculateSip(
      monthlyInvestment: monthlySip,
      rateOfReturn: rateOfReturn,
      years: years,
      stepUp: stepUp,
    );

    List<YearData> combined = [];
    int minYears = min(lumpsum.yearlyBreakdown.length, sip.yearlyBreakdown.length);
    for (int y = 0; y < minYears; y++) {
      YearData l = lumpsum.yearlyBreakdown[y];
      YearData s = sip.yearlyBreakdown[y];
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
    double r = rateOfReturn / 100;
    if (1 + r <= 0) return 0;
    double monthlyR = pow(1 + r, 1 / 12) - 1;
    int months = years * 12;
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
    double gains = result.totalReturns;
    double taxableGains = max(0, gains - exemption);
    double tax = taxableGains * taxRate;
    double postTax = max(0, result.totalValue - tax);

    return CalcResult(
      totalInvestment: result.totalInvestment,
      totalReturns: max(0, postTax - result.totalInvestment),
      totalValue: postTax,
    );
  }

  List<AiInsight> generateInsights({
    required double monthlyInvestment,
    required double rateOfReturn,
    required int years,
    double stepUp = 0,
  }) {
    List<AiInsight> insights = [];

    CalcResult base = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: years,
      stepUp: 0,
    );

    if (stepUp > 0) {
      CalcResult stepped = calculateSip(
        monthlyInvestment: monthlyInvestment,
        rateOfReturn: rateOfReturn,
        years: years,
        stepUp: stepUp,
      );
      double extra = stepped.totalValue - base.totalValue;
      String extraText = extra.isFinite ? extra.toStringAsFixed(0) : '0';
      insights.add(AiInsight(
        title: 'Step-Up Impact',
        description:
            'Increasing investment by $stepUp% annually adds $extraText to your corpus.',
        emoji: '📈',
      ));
    }

    if (years >= 10) {
      double halfTime = calculateSip(
        monthlyInvestment: monthlyInvestment,
        rateOfReturn: rateOfReturn,
        years: years ~/ 2,
        stepUp: stepUp,
      ).totalValue;
      double fullTime = base.totalValue;
      String secondHalf = (fullTime - halfTime).isFinite ? (fullTime - halfTime).toStringAsFixed(0) : '0';
      String pct = '0';
      if (fullTime > 0) {
        double pctVal = (fullTime - halfTime) / fullTime * 100;
        pct = pctVal.isFinite ? pctVal.toStringAsFixed(0) : '0';
      }
      insights.add(AiInsight(
        title: 'Power of Compounding',
        description:
            'In the second half of your tenure, you earn $secondHalf — $pct% of your total corpus.',
        emoji: '💪',
      ));
    }

    CalcResult delayed = calculateSip(
      monthlyInvestment: monthlyInvestment,
      rateOfReturn: rateOfReturn,
      years: max(1, years - 1),
      stepUp: stepUp,
    );
    double delayCost = base.totalValue - delayed.totalValue;
    String delayText = delayCost.isFinite ? delayCost.toStringAsFixed(0) : '0';
    insights.add(AiInsight(
      title: 'Cost of Delay',
      description:
          'Delaying your SIP by just 1 year costs you approximately $delayText.',
      emoji: '⏰',
    ));

    return insights;
  }
}
