# Gym Stats Entry Client

A Flutter application for tracking workout details and body measurements, with Google Sign-In authentication, Samsung Health integration, and the ability to submit data to a backend service.

## Features

- **Google Sign-In Authentication**: Secure authentication using Google accounts
- **Beautiful Modern UI**: Clean, responsive design with Material Design 3
- **Samsung Health Integration**: Import health data directly from Samsung Health app
- **Persistent Settings**: Store API configuration using shared preferences
- **Workout Tracking Form**: Comprehensive form for recording:
  - Date (formatted as "July 18", "August 20", etc.)
  - Bodyweight (kg)
  - Skeletal Mass (kg)
  - Fat Mass (kg)
  - Body Water (kg)
  - Fat Percentage (%)
  - BMR (Basal Metabolic Rate)
  - Workout Type (Upper, Lower, Push, Pull, Legs, Active)
  - Energy expenditure (kcal)
  - Notes

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.9.0 or higher)
- Android Studio / VS Code
- Google Cloud Project with Google Sign-In API enabled
- Samsung Health app installed (for health data integration)

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

#### Samsung Health SDK Integration
1. **Current Implementation**: The app includes a placeholder Samsung Health service
2. **Production Setup**: Replace the placeholder with actual Samsung Health SDK:
   - Add Samsung Health SDK dependencies
   - Configure app ID and secret
   - Implement actual data fetching methods
   - Handle permissions and authentication

#### API Endpoint Configuration
1. Launch the app and sign in with Google
2. Tap the settings icon in the app bar
3. Enter your backend API endpoint URL
4. Save the configuration

### 4. Running the App
```bash
flutter run
```

## App Flow

1. **Sign-In Page**: Users authenticate with their Google account
2. **Workout Form**: After successful authentication, users can:
   - Fill out the workout details form
   - Import data from Samsung Health (if available)
   - Select workout type from predefined options
   - Choose date in readable format (e.g., "July 18")
3. **Data Submission**: Form data is sent via POST request to your backend service
4. **Settings**: Configure API endpoint and other app settings
5. **Sign-Out**: Users can sign out and return to the authentication page

## Dependencies

- `flutter`: Core Flutter framework
- `google_sign_in: ^6.0.2`: Google Sign-In authentication
- `http: ^1.1.0`: HTTP requests for API communication
- `shared_preferences: ^2.2.2`: Persistent storage for settings

## Project Structure

```
lib/
├── main.dart                    # Main app entry point with navigation logic
├── auth.dart                    # Authentication service
├── sign_in_view.dart           # Google Sign-In UI
├── workout_form_page.dart      # Workout details form with Samsung Health integration
├── settings_page.dart          # Settings page for API configuration
├── settings_service.dart       # Service for managing app settings
└── samsung_health_service.dart # Samsung Health integration service
```

## Key Features

### Date Format
- Dates are displayed in user-friendly format: "July 18", "August 20"
- Date picker for easy date selection
- Automatic formatting and parsing

### Workout Types
- **Upper**: Upper body workouts
- **Lower**: Lower body workouts  
- **Push**: Push exercises (chest, shoulders, triceps)
- **Pull**: Pull exercises (back, biceps)
- **Legs**: Leg-focused workouts
- **Active**: Active recovery or cardio

### Samsung Health Integration
- **Data Import**: Automatically populate form fields with health data
- **Date-Specific**: Fetch data for the selected date
- **Permission Handling**: Request and manage Samsung Health permissions
- **Error Handling**: Graceful fallback when data is unavailable

### Settings Management
- **API Configuration**: Store and manage backend endpoint URL
- **Persistent Storage**: Settings are saved locally using shared preferences
- **Validation**: URL validation to ensure proper API endpoint format
- **User-Friendly**: Clear instructions and helpful information

## API Request Format

The app sends workout data in the following JSON format:

```json
{
  "date": "July 18",
  "bodyweight": 70.5,
  "skeletalMass": 25.2,
  "fatMass": 15.8,
  "bodyWater": 42.3,
  "fatPercentage": 22.4,
  "bmr": 1650,
  "workout": "Upper",
  "energy": 450,
  "notes": "Felt strong today, increased weight on bench press"
}
```

## Samsung Health Integration

### Current Implementation
The app includes a comprehensive placeholder service that demonstrates:
- Permission handling
- Data availability checking
- Health data fetching
- Error handling
- Mock data for testing

### Production Implementation
To integrate with actual Samsung Health SDK:

1. **Add SDK Dependencies**:
   ```yaml
   dependencies:
     samsung_health: ^latest_version
   ```

2. **Configure App Credentials**:
   - Samsung Developer account
   - App ID and secret
   - OAuth configuration

3. **Replace Placeholder Methods**:
   - `initialize()`: SDK initialization
   - `isAvailable()`: Device compatibility check
   - `requestPermissions()`: Permission management
   - `fetchDataForDate()`: Actual data retrieval

4. **Handle Real Data**:
   - Body composition measurements
   - Activity calories
   - Weight tracking
   - Health metrics

## Customization

- **Theme**: Modify `ThemeData.dark()` in `main.dart` for different themes
- **Form Fields**: Add or remove fields in `workout_form_page.dart`
- **Workout Types**: Modify the `WorkoutType` enum for different workout categories
- **Validation**: Customize form validation rules
- **API Integration**: Modify the HTTP request logic for your specific backend
- **Samsung Health**: Extend the service for additional health metrics

## Troubleshooting

- **Google Sign-In**: Ensure Google Sign-In API is enabled in Google Cloud Console
- **SHA-1 Fingerprint**: Verify your app's SHA-1 is correctly added to OAuth credentials
- **API Endpoint**: Check that the URL is accessible and accepts POST requests
- **Samsung Health**: Verify the app is installed and permissions are granted
- **Network Permissions**: Check manifest files for proper network access
- **Settings**: Use the settings page to configure API endpoint if form submission fails

## Future Enhancements

- **Additional Health Platforms**: Apple Health, Google Fit integration
- **Data Export**: Export workout data to various formats
- **Progress Tracking**: Charts and analytics for fitness progress
- **Workout Templates**: Predefined workout routines
- **Social Features**: Share progress with friends or trainers

## Contributing

Feel free to submit issues and enhancement requests!
