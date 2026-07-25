import 'dart:convert';

class YearData {
  final int year;
  final double investedThisYear;
  final double totalInvested;
  final double interestThisYear;
  final double totalInterest;
  final double corpus;

  YearData({
    required this.year,
    required this.investedThisYear,
    required this.totalInvested,
    required this.interestThisYear,
    required this.totalInterest,
    required this.corpus,
  });

  Map<String, dynamic> toJson() => {
        'year': year,
        'investedThisYear': investedThisYear,
        'totalInvested': totalInvested,
        'interestThisYear': interestThisYear,
        'totalInterest': totalInterest,
        'corpus': corpus,
      };

  factory YearData.fromJson(Map<String, dynamic> json) => YearData(
        year: (json['year'] as num?)?.toInt() ?? 0,
        investedThisYear: (json['investedThisYear'] as num?)?.toDouble() ?? 0,
        totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0,
        interestThisYear: (json['interestThisYear'] as num?)?.toDouble() ?? 0,
        totalInterest: (json['totalInterest'] as num?)?.toDouble() ?? 0,
        corpus: (json['corpus'] as num?)?.toDouble() ?? 0,
      );
}

class CalcResult {
  final double totalInvestment;
  final double totalReturns;
  final double totalValue;
  final List<YearData> yearlyBreakdown;

  CalcResult({
    required this.totalInvestment,
    required this.totalReturns,
    required this.totalValue,
    this.yearlyBreakdown = const [],
  });

  Map<String, dynamic> toJson() => {
        'totalInvestment': totalInvestment,
        'totalReturns': totalReturns,
        'totalValue': totalValue,
        'yearlyBreakdown': yearlyBreakdown.map((y) => y.toJson()).toList(),
      };

  factory CalcResult.fromJson(Map<String, dynamic> json) => CalcResult(
        totalInvestment: (json['totalInvestment'] as num?)?.toDouble() ?? 0,
        totalReturns: (json['totalReturns'] as num?)?.toDouble() ?? 0,
        totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0,
        yearlyBreakdown: (json['yearlyBreakdown'] as List<dynamic>?)
                ?.map((y) => YearData.fromJson(y as Map<String, dynamic>))
                .toList() ??
            [],
      );

  String toJsonString() => jsonEncode(toJson());
}

class SavedCalculation {
  final String id;
  final String name;
  final String type;
  final String params;
  final CalcResult result;
  final DateTime savedAt;

  SavedCalculation({
    required this.id,
    required this.name,
    required this.type,
    required this.params,
    required this.result,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'params': params,
        'result': result.toJson(),
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedCalculation.fromJson(Map<String, dynamic> json) =>
      SavedCalculation(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        type: (json['type'] as String?) ?? '',
        params: (json['params'] as String?) ?? '',
        result: json['result'] != null
            ? CalcResult.fromJson(json['result'] as Map<String, dynamic>)
            : CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0),
        savedAt: json['savedAt'] != null
            ? DateTime.tryParse(json['savedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

class MonteCarloResult {
  final double medianCorpus;
  final double p10Corpus;
  final double p90Corpus;
  final double probabilityOfSuccess;

  MonteCarloResult({
    required this.medianCorpus,
    required this.p10Corpus,
    required this.p90Corpus,
    required this.probabilityOfSuccess,
  });
}

class NriConfig {
  final String country;
  final String currencyCode;
  final String currencySymbol;
  final double taxRate;
  final double exemptionLimit;

  NriConfig({
    required this.country,
    required this.currencyCode,
    required this.currencySymbol,
    required this.taxRate,
    required this.exemptionLimit,
  });

  static final Map<String, NriConfig> presets = {
    'India': NriConfig(
        country: 'India',
        currencyCode: 'INR',
        currencySymbol: '₹',
        taxRate: 0.125,
        exemptionLimit: 125000),
    'USA': NriConfig(
        country: 'USA',
        currencyCode: 'USD',
        currencySymbol: '\$',
        taxRate: 0.20,
        exemptionLimit: 0),
    'UAE': NriConfig(
        country: 'UAE',
        currencyCode: 'AED',
        currencySymbol: 'د.إ',
        taxRate: 0.0,
        exemptionLimit: 0),
    'UK': NriConfig(
        country: 'UK',
        currencyCode: 'GBP',
        currencySymbol: '£',
        taxRate: 0.20,
        exemptionLimit: 0),
    'Canada': NriConfig(
        country: 'Canada',
        currencyCode: 'CAD',
        currencySymbol: 'C\$',
        taxRate: 0.15,
        exemptionLimit: 0),
    'Singapore': NriConfig(
        country: 'Singapore',
        currencyCode: 'SGD',
        currencySymbol: 'S\$',
        taxRate: 0.0,
        exemptionLimit: 0),
  };
}

class AiInsight {
  final String title;
  final String description;
  final String? emoji;

  AiInsight({
    required this.title,
    required this.description,
    this.emoji,
  });
}
