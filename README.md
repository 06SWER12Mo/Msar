# حالة الحواجز - Smart Checkpoint Status App

A Flutter application designed to help Palestinian travelers in the West Bank check real-time checkpoint statuses before traveling.

## Features

- **Interactive Map**: View all checkpoints on Google Maps with color-coded markers
- **Real-time Status**: Check if checkpoints are Open (سالك), Crowded (أزمة), or Closed (مغلق)
- **Dual Direction Tracking**: Separate statuses for Entrance (للداخل) and Exit (للخارج)
- **Voting System**: Users within 3km can vote on checkpoint status
- **Smart Aggregation**: 7-minute voting window with percentage-based status calculation
- **Admin Panel**: Admins can add checkpoints and override statuses
- **Arabic Interface**: Fully localized for Palestinian users

## Tech Stack

- Flutter 3.x
- Firebase Authentication (Google Sign-In)
- Cloud Firestore
- Google Maps Flutter
- Geolocator

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get`
3. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Add your Google Maps API key in `AndroidManifest.xml` and `AppDelegate.swift`
5. Run `flutter run`

## Screenshots

[Add 3+ screenshots here for grading]

## Team Members

- [Your Name]
- [Team Member 2]
- [Team Member 3]

## Course

Advanced Web Development - Flutter Project
Deadline: May 15, 2026