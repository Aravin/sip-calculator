# SIP & Financial Calculator

A comprehensive Flutter financial planning app with 7 calculators, Monte Carlo simulation, AI insights, and NRI currency support.

## Calculators

| Calculator | Description |
|---|---|
| **SIP** | Step-up SIP, Goal Mode (Reverse SIP), Inflation-adjusted value, Sensitivity analysis, AI Insights, Monte Carlo (1000 runs), SIP→SWP bridge, Delay cost |
| **Lumpsum** | One-time investment with compounding and year breakdown |
| **SWP** | Systematic Withdrawal Plan with depletion tracking |
| **STP** | Systematic Transfer Plan |
| **PPF** | Public Provident Fund calculator |
| **EMI** | Loan EMI with full amortization table |
| **Combined** | SIP + Lumpsum combined investment planner |

## Features

- Step-Up SIP (annual increase 0–25%)
- Goal Mode — find required SIP for a target corpus
- Quick Goal presets (Retirement, Education, ₹1 Crore, etc.)
- Inflation-adjusted real value (2–12% slider)
- LTCG tax impact (12.5% after ₹1.25L exemption)
- SIP delay cost visualization
- Year-by-year projection tables
- Sensitivity analysis (±2% scenarios)
- Monte Carlo simulation (1000 runs, configurable volatility)
- AI Insights (step-up impact, power of compounding, cost of delay)
- NRI mode — 6 currencies (INR, USD, AED, GBP, CAD, SGD)
- Dark mode toggle
- Bookmark/save calculations (capped at 50)
- CSV export with share
- Number-to-words (Indian system, up to Crore)
- SIP → SWP bridge (corpus → monthly income)

## Architecture

```
lib/
├── main.dart                  # App entry, theme toggle
├── models/
│   └── calculator_models.dart # YearData, CalcResult, SavedCalculation, MonteCarloResult, NriConfig, AiInsight
├── services/
│   ├── calculator_service.dart # Core calculation engine (SIP, Lumpsum, SWP, STP, PPF, EMI, LTCG, Combined, Insights)
│   ├── monte_carlo_service.dart # Box-Muller normal RNG simulation
│   ├── export_service.dart     # CSV generation + Indian number-to-words
│   └── persistence_service.dart # SharedPreferences save/load/delete
├── screens/
│   ├── home.dart               # Grid home screen
│   ├── sip.dart                 # Main SIP screen with all features
│   ├── lumpsum.dart
│   ├── swp.dart
│   ├── stp.dart
│   ├── ppf.dart
│   ├── emi_screen.dart
│   ├── combined_screen.dart
│   └── savings_screen.dart
├── widgets/
│   ├── ad_banner.dart
│   ├── input_row.dart
│   ├── year_table.dart
│   └── sensitivity_card.dart
└── shared/
    ├── constants.dart           # Theme data (light/dark)
    ├── drawer.dart
    └── ads.dart
```

## Tests

91 unit tests across 5 test files covering all calculation engines and edge cases.

```
test/
├── services/
│   ├── calculator_service_test.dart   # 34 tests
│   ├── monte_carlo_service_test.dart  # 10 tests
│   ├── export_service_test.dart       # 6 tests
│   └── persistence_service_test.dart  # 8 tests
└── models/
    └── calculator_models_test.dart    # 14 tests
```

## Dependencies

- `share_plus`, `in_app_review`, `google_mobile_ads`
- `fl_chart`, `shared_preferences`, `path_provider`
