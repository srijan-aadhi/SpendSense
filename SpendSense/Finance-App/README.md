# SpendSense (Starter iOS App - SwiftUI)

A mobile app that helps students understand and manage impulsive spending.

## Modules Included
- Spending Tracker (log purchases, modify income, view charts)
- Savings Growth Simulator (Spent vs Saved comparisons, portfolios)
- Learn (onboarding quiz, personalized modules)

## Requirements
- Xcode 15+
- iOS 16.0+ (uses Swift Charts)

## How to Use
1. In Xcode, create a new **App > iOS > App** project named `SpendSense` with SwiftUI + Swift.
2. Set `iOS Deployment Target` to **iOS 16.0** or newer.
3. Add **Charts** framework: It's included with iOS 16+ (no package needed).
4. Replace the auto-generated files with the contents of `/Sources` from this folder:
   - Copy all `.swift` files into your project (keep folder grouping if you want).
5. Run on a simulator/device.

> Data is stored locally in app documents as JSON for demo purposes.
