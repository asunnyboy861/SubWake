# SubWake - iOS Development Guide

## Executive Summary

SubWake is a privacy-first subscription and renewal reminder app for iOS. It solves the critical pain point of forgotten subscriptions, surprise charges, and missed cancellation deadlines. Unlike competitors that require bank connections or charge monthly fees, SubWake operates entirely locally with zero data collection and a one-time purchase model.

**Target Audience**: iOS users (17+) who manage multiple subscriptions and want to avoid surprise charges, forgotten free trials, and missed cancellation deadlines.

**Key Differentiators**:
- Smart tiered reminders: renewal (3/7/14/30 days), free trial (1/3/7 days), cancellation deadline (1/3/7/14 days)
- Price change monitoring and notifications (unique feature)
- Cancellation deadline tracking with notice period countdown (unique feature)
- Privacy-first: zero data collection, no bank connection, fully local
- One-time purchase ($3.99) — not a subscription itself
- Widget + Live Activity for at-a-glance renewal info
- iCloud sync (optional toggle)
- Family sharing view for shared subscriptions

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Rocket Money | Auto-detects subscriptions, bill negotiation, 3.4M+ users | $6-12/month subscription, requires bank connection, privacy concerns, 1.0/5.0 customer service | One-time $3.99, no bank needed, zero data collection, free trial reminders |
| Bobby | Simple, privacy-focused, one-time $2.99, no bank needed | Manual entry only, no free trial reminders, no price change alerts, no cancellation deadline tracking, Android abandoned | Smart tiered reminders, price monitoring, cancellation deadlines, Widget+Live Activity, iCloud sync |
| SubscriptMe | Auto-identification, subscription catalog | Low accuracy auto-detect, itself is a subscription, privacy concerns | High accuracy manual+optional email scan, one-time purchase, privacy-first |
| Subby | One-time $9.99, simple UI | No free trial alerts, no price monitoring, no widget, no iCloud sync | All core reminder types, widget, iCloud, lower price point |
| SubSorted | Free trial focus, renewal alerts | New app, limited features, no price monitoring, no cancellation deadlines | Comprehensive reminder engine, price monitoring, cancellation deadlines, widget |

## Apple Design Guidelines Compliance

- **HIG - Notifications**: Use UNUserNotificationCenter with actionable notifications (Keep, Remind Later, View Details). Respect user's notification preferences.
- **HIG - Widgets**: Provide timely, glanceable information via WidgetKit. Support small, medium, and large widget families.
- **HIG - Live Activity**: Show real-time countdown to next renewal on Lock Screen and Dynamic Island.
- **HIG - Data Entry**: Minimize manual input with smart defaults, emoji icon picker, color presets, and category templates.
- **HIG - Privacy**: Zero data collection. All data stored locally on device. iCloud sync is opt-in only.
- **HIG - Settings**: Provide clear settings for notification preferences, iCloud sync toggle, and currency selection.
- **HIG - Navigation**: Use TabView for main navigation (Dashboard, Subscriptions, Add, Settings).
- **HIG - Lists**: Use SwiftUI List with swipe actions for quick delete/edit on subscription items.
- **HIG - Color & Typography**: Use system colors with adaptive dark mode support. SF Pro font family.

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), WidgetKit, ActivityKit
- **Data**: SwiftData with optional CloudKit sync
- **Notifications**: UserNotifications framework with actionable categories
- **Minimum iOS**: 17.0
- **Architecture**: MVVM pattern
- **No third-party dependencies**

## Module Structure

```
SubWake/
├── SubWakeApp.swift
├── Models/
│   ├── Subscription.swift
│   ├── BillingCycle.swift
│   ├── SubscriptionCategory.swift
│   └── PaymentRecord.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── SubscriptionListViewModel.swift
│   ├── AddSubscriptionViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── SubscriptionList/
│   │   └── SubscriptionListView.swift
│   ├── AddSubscription/
│   │   └── AddSubscriptionView.swift
│   ├── SubscriptionDetail/
│   │   └── SubscriptionDetailView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Services/
│   ├── ReminderEngine.swift
│   └── DataManager.swift
├── Widgets/
│   ├── SubWakeWidget.swift
│   └── SubWakeLiveActivity.swift
├── Utilities/
│   ├── ColorExtensions.swift
│   └── DateExtensions.swift
└── Assets.xcassets/
```

## Implementation Flow

1. Set up SwiftData models (Subscription, PaymentRecord, BillingCycle, SubscriptionCategory)
2. Build DataManager with SwiftData container and optional CloudKit
3. Build DashboardView with monthly/yearly totals and upcoming renewals
4. Build SubscriptionListView with search, filter, and swipe actions
5. Build AddSubscriptionView with smart defaults and emoji picker
6. Build SubscriptionDetailView with edit/delete and payment history
7. Build ReminderEngine with tiered notification scheduling
8. Build SettingsView with notification prefs, iCloud toggle, currency
9. Build SubWakeWidget with WidgetKit (small/medium/large)
10. Build SubWakeLiveActivity with ActivityKit
11. Build ContactSupportView integrated into Settings
12. Test on iPhone XS Max and iPad Pro 13-inch (M4)

## UI/UX Design Specifications

- **Color Scheme**: Primary blue (#007AFF), accent orange (#FF9500) for warnings, red (#FF3B30) for urgent, green (#34C759) for active, system background adaptive
- **Typography**: SF Pro system font, large titles for dashboard numbers, body for list items
- **Layout**: TabView with 4 tabs (Dashboard, Subscriptions, Add+, Settings). Dashboard uses ScrollView with cards. Lists use SwiftUI List. iPad: max width 720pt for content.
- **Animations**: Card transitions, swipe actions, notification badge animations, renewal countdown animations
- **Dark Mode**: Full adaptive support using system colors
- **iPad Layout**: Sidebar navigation on iPadOS, content area max 720pt width

## Code Generation Rules

- No comments in code unless explicitly requested
- Use SwiftData (not CoreData) for all persistence
- All SwiftData model attributes must be optional or have default values
- All relationships must have inverse relationships
- Use MVVM pattern with @Observable macro
- Use Swift Concurrency (async/await) for all asynchronous operations
- Use UNUserNotificationCenter for all notifications
- Use WidgetKit for home screen widgets
- Use ActivityKit for Live Activity
- No third-party dependencies
- All strings in English (US)
- Support both iPhone and iPad layouts
- iPad content: .frame(maxWidth: 720).frame(maxWidth: .infinity)

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.SubWake
2. Verify Deployment Target: iOS 17.0
3. Verify Swift Language Version: 5.0+
4. Configure App Icon (1024x1024)
5. Enable Push Notifications capability
6. Enable iCloud capability (CloudKit)
7. Build and test on iPhone simulator
8. Build and test on iPad simulator
9. Push to GitHub repository
10. Deploy policy pages to GitHub Pages
11. Create App Store Connect metadata
