# مسار - Msar

A Flutter application designed to help Palestinian travelers in the West Bank check real-time checkpoint statuses before traveling.

## Features

- **Interactive Map**: View all checkpoints on Flutter Map with color-coded markers
- **Real-time Status**: Check if checkpoints are Open (سالك), Crowded (أزمة), or Closed (مغلق)
- **Dual Direction Tracking**: Separate statuses for Entrance (للداخل) and Exit (للخارج)
- **Voting System**: Users can vote from anywhere (for state fullfilling)
- **Smart Aggregation**: 7-minute voting window with percentage-based status calculation
- **Admin Panel**: Admins can add checkpoints and override statuses
- **Arabic Interface**: Fully localized for Palestinian users

## Tech Stack

- Flutter 3.x
- Firebase Authentication (Google Sign-In + Phone Sign-In with verification code (test only -> number:+972 599497524,    verification code: 123456))
- Cloud Firestore
- Geolocator

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get`
3. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Add your Google Maps API key in `AndroidManifest.xml` and `AppDelegate.swift`
5. Run `flutter run`

## App Icon
<img src="assets/image.png" width="200" height="200">


## Team Members

- Muhammad Ayyad
- BahaAbu Eida
- Adam Alafandi

## Course

Advanced Web Development - Flutter Project
