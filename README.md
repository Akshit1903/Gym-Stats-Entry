# Gym Stats Entry Client

A Flutter application for tracking workout details and body measurements, with Google Sign-In authentication and the ability to submit data to a backend service.

## Features

- **Google Sign-In Authentication**: Secure authentication using Google accounts
- **Beautiful Modern UI**: Clean, responsive design with Material Design 3
- **Workout Tracking Form**: Comprehensive form for recording:
  - Date
  - Bodyweight (kg)
  - Skeletal Mass (kg)
  - Fat Mass (kg)
  - Body Water (kg)
  - Fat Percentage (%)
  - BMR (Basal Metabolic Rate)
  - Workout details
  - Energy expenditure (kcal)
  - Notes

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.9.0 or higher)
- Android Studio / VS Code
- Google Cloud Project with Google Sign-In API enabled

### 2. Installation
```bash
flutter pub get
```

### 3. Configuration

#### Google Sign-In Setup
1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sign-In API
3. Create OAuth 2.0 credentials
4. Add your app's SHA-1 fingerprint to the credentials

#### API Endpoint Configuration
In `lib/workout_form_page.dart`, replace the placeholder API endpoint:
```dart
const String apiUrl = 'YOUR_API_ENDPOINT_HERE';
```

### 4. Running the App
```bash
flutter run
```

## App Flow

1. **Sign-In Page**: Users authenticate with their Google account
2. **Workout Form**: After successful authentication, users can fill out the workout details form
3. **Data Submission**: Form data is sent via POST request to your backend service
4. **Sign-Out**: Users can sign out and return to the authentication page

## Dependencies

- `flutter`: Core Flutter framework
- `google_sign_in: ^6.0.2`: Google Sign-In authentication
- `http: ^1.1.0`: HTTP requests for API communication

## Project Structure

```
lib/
├── main.dart              # Main app entry point with navigation logic
├── auth.dart              # Authentication service
├── sign_in_view.dart      # Google Sign-In UI
└── workout_form_page.dart # Workout details form
```

## API Request Format

The app sends workout data in the following JSON format:

```json
{
  "date": "2024-01-15",
  "bodyweight": 70.5,
  "skeletalMass": 25.2,
  "fatMass": 15.8,
  "bodyWater": 42.3,
  "fatPercentage": 22.4,
  "bmr": 1650,
  "workout": "Upper body, chest, triceps",
  "energy": 450,
  "notes": "Felt strong today, increased weight on bench press"
}
```

## Customization

- **Theme**: Modify `ThemeData.dark()` in `main.dart` for different themes
- **Form Fields**: Add or remove fields in `workout_form_page.dart`
- **Validation**: Customize form validation rules
- **API Integration**: Modify the HTTP request logic for your specific backend

## Troubleshooting

- Ensure Google Sign-In API is enabled in Google Cloud Console
- Check that your app's SHA-1 fingerprint is correctly added to OAuth credentials
- Verify the API endpoint URL is accessible and accepts POST requests
- Check network permissions in your app's manifest files

## Contributing

Feel free to submit issues and enhancement requests!
