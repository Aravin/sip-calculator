# Financial Calculator

An all-in-one Flutter financial planning app with 14 calculators, Monte Carlo simulation, AI insights, multi-goal planner, and tax calculator.

## Calculators

| Calculator | Description |
|---|---|
| **SIP** | Step-up SIP, Goal Mode (Reverse SIP), Inflation-adjusted value, Sensitivity analysis, AI Insights, Monte Carlo (1000 runs), SIP→SWP bridge, Delay cost |
| **Lumpsum** | One-time investment with compounding, LTCG tax impact, year breakdown |
| **SWP** | Systematic Withdrawal Plan with depletion tracking |
| **STP** | Systematic Transfer Plan |
| **PPF** | Public Provident Fund calculator |
| **EMI** | Loan EMI with full amortization table |
| **FD** | Fixed Deposit with cumulative/quarterly payout, multiple compounding frequencies |
| **RD** | Recurring Deposit with quarterly compounding |
| **Compound Interest** | Daily/Monthly/Quarterly/Half-Yearly/Yearly compounding with bar chart |
| **Goal Planner** | Multi-goal tracking with progress bars, target dates, persistence |
| **SIP vs Lumpsum** | Side-by-side comparison with bar chart and winner highlight |
| **Tax Calculator** | Old vs New regime comparison with 80C/80D deductions |
| **Combined** | SIP + Lumpsum combined investment planner |
| **Saved Plans** | Bookmarked calculations with CSV export |

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
- Goal Planner with persistence (add/edit/delete financial goals)
- Tax comparison (Old vs New regime with 80C/80D deductions)
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
│   └── calculator_models.dart # YearData, CalcResult, SavedCalculation, MonteCarloResult, NriConfig, AiInsight, ComparisonResult, FinancialGoal, TaxResult
├── services/
│   ├── calculator_service.dart # Core calculation engine (all calculators + tax + comparison)
│   ├── monte_carlo_service.dart # Box-Muller normal RNG simulation
│   ├── export_service.dart     # CSV generation + Indian number-to-words
│   └── persistence_service.dart # SharedPreferences save/load/delete
├── screens/
│   ├── home.dart                # Grid home screen (14 cards)
│   ├── sip.dart                 # Main SIP screen with all features
│   ├── lumpsum.dart
│   ├── swp.dart
│   ├── stp.dart
│   ├── ppf.dart
│   ├── emi_screen.dart
│   ├── fd_screen.dart
│   ├── rd_screen.dart
│   ├── compound_interest_screen.dart
│   ├── goal_planner_screen.dart
│   ├── sip_vs_lumpsum_screen.dart
│   ├── tax_calculator_screen.dart
│   ├── combined_screen.dart
│   └── savings_screen.dart
├── widgets/
│   ├── input_row.dart          # Reusable labelled slider + text field
│   ├── year_table.dart         # Horizontal-scroll DataTable
│   └── sensitivity_card.dart   # 3-column worst/expected/best display
└── shared/
    ├── constants.dart          # Theme data (light/dark, Material 3)
    ├── drawer.dart             # Navigation drawer with all calculators
    └── result_helpers.dart     # Shared formatting helpers
```

## Tests

115 tests across 6 test files covering all calculation engines, edge cases, and UI smoke test.

```
test/
├── services/
│   ├── calculator_service_test.dart   # 49 tests (SIP, Lumpsum, SWP, STP, PPF, EMI, Combined, LTCG, FD, RD, Compound, Comparison, Tax, Insights)
│   ├── monte_carlo_service_test.dart  # 10 tests
│   ├── export_service_test.dart       # 6 tests
│   └── persistence_service_test.dart  # 8 tests
├── models/
│   └── calculator_models_test.dart    # 21 tests
└── widget_test.dart                   # 1 smoke test
```

## Dependencies

- `share_plus` — CSV export & app sharing
- `in_app_review` — In-app Play Store review
- `fl_chart` — Bar chart visualizations
- `shared_preferences` — Local persistence
- `path_provider` — Temporary file storage
