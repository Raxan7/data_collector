# Tanga Tech Tool (Data Collector)

A Flutter-based mobile application designed for field technicians to collect and report technical data from remote sites. The app specializes in capturing and managing data about LUKU (electricity) and FUEL consumption readings for technical monitoring and maintenance.

## Overview

Tanga Tech Tool is a robust data collection application that allows technicians to:

- Capture and upload photos of PLC displays and LUKU meters
- Record LUKU units before and after service
- Document fuel remaining and added during site visits
- Track generator running hours
- Operate offline with local data storage using Hive
- Sync data to Firebase when connectivity is available

## Features

- **Authentication System**: Secure login system for technicians
- **Multi-Report Types**: Support for both LUKU (electricity) and FUEL report types
- **Photo Integration**: Camera integration for capturing technical readings
- **Offline Support**: Full offline functionality with Hive database
- **Cloud Sync**: Automatic data synchronization with Firebase
- **Dark Mode**: Optimized interface for field work in various lighting conditions
- **Form Validation**: Comprehensive validation to ensure data integrity
- **Admin Dashboard**: List view for administrators to review submitted reports

## Technical Stack

- **Frontend**: Flutter framework
- **State Management**: Standard Flutter state management
- **Local Database**: Hive for offline storage
- **Cloud Database**: Firebase Firestore
- **Authentication**: Firebase Authentication
- **Image Storage**: Cloudinary
- **Form Handling**: Flutter Form Builder

## Usage

Technicians can:
1. Log in with their credentials
2. Select the report type (LUKU or FUEL)
3. Enter site identification and technical readings
4. Capture required photographs as evidence
5. Submit reports, which are stored locally and uploaded when connectivity is available

Administrators can:
1. Access the admin dashboard
2. View all submitted reports
3. Analyze data and track site maintenance history

## Getting Started

### Prerequisites
- Flutter SDK (version ^3.7.0)
- Firebase account with Firestore enabled
- Android Studio or VS Code with Flutter extensions

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase using the provided `firebase_options.dart`
4. Build and deploy to your device using `flutter build apk` or `flutter run`

## Resources

For Flutter development resources:
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Online documentation](https://docs.flutter.dev/)
