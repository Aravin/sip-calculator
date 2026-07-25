import 'dart:math';
import '../models/calculator_models.dart';

class MonteCarloService {

  static double _nextGaussian(Random random) {
    double u1 = 0;
    double u2 = 0;
    while (u1 == 0) u1 = random.nextDouble();
    while (u2 == 0) u2 = random.nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }

  MonteCarloResult simulate({
    required double monthlyInvestment,
    required int years,
    double expectedReturn = 12,
    double volatility = 15,
    int simulations = 1000,
    double stepUp = 0,
    double targetCorpus = 0,
  }) {
    Random random = Random();
    List<double> outcomes = [];

    for (int sim = 0; sim < simulations; sim++) {
      double corpus = 0;
      double r = expectedReturn / 100;
      double currentMonthly = monthlyInvestment;

      int totalMonths = years * 12;
      int monthsInCurrentYear = 0;

      for (int m = 0; m < totalMonths; m++) {
        double monthlyReturn = (r + _nextGaussian(random) * (volatility / 100) / sqrt(12)) / 12;
        corpus = (corpus + currentMonthly) * (1 + monthlyReturn);
        monthsInCurrentYear++;

        if (monthsInCurrentYear == 12 && stepUp > 0) {
          monthsInCurrentYear = 0;
          currentMonthly *= (1 + stepUp / 100);
        }
      }

      if (corpus > 0) outcomes.add(corpus);
    }

    outcomes.sort();

    if (outcomes.isEmpty) {
      return MonteCarloResult(
        medianCorpus: 0,
        p10Corpus: 0,
        p90Corpus: 0,
        probabilityOfSuccess: 0,
      );
    }

    double median = outcomes[outcomes.length ~/ 2];
    double p10 = outcomes[outcomes.length * 10 ~/ 100];
    double p90 = outcomes[outcomes.length * 90 ~/ 100];

    int successCount = targetCorpus > 0
        ? outcomes.where((c) => c >= targetCorpus).length
        : outcomes.length;
    double probSuccess = successCount / outcomes.length;

    return MonteCarloResult(
      medianCorpus: median,
      p10Corpus: p10,
      p90Corpus: p90,
      probabilityOfSuccess: probSuccess,
    );
  }
}
