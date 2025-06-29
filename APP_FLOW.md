# Cherubgyre App Flow Documentation

## Updated Application Flow

### 1. Splash Screen
- **Displayed on app launch**
- Shows Cherubgyre logo and loading indicator for 2 seconds
- After 2 seconds, shows authentication options:
  - **"Register" button** for new users
  - **"I already have an account"** link for existing users

### 2. New User Flow (Registration)

#### Step 1: Invite Code Entry
- User enters alphanumeric invite code
- Validates format (4-20 characters, letters and numbers only)
- Calls API to verify invite code validity
- Progress indicator shows current step (1 of 3)

#### Step 2: Normal PIN Setup
- User sets 4-6 digit PIN for app access
- Confirms PIN with validation
- Back button to return to previous step
- Progress indicator shows current step (2 of 3)

#### Step 3: Duress PIN Setup + Privacy Policy
- User sets different PIN for emergency alerts
- Must be different from normal PIN
- **Required checkbox**: "I agree to the Privacy Policy and Terms & Conditions"
- Complete registration button
- Progress indicator shows current step (3 of 3)
- On successful registration, navigates to Home Screen

### 3. Existing User Flow (PIN Input)

#### PIN Input Screen
- User enters their PIN
- System determines PIN type:
  - **Normal PIN**: Navigates to Home Screen
  - **Duress PIN**: Navigates to Duress Alert Screen
- Error handling for invalid PINs
- Back button to return to splash screen

### 4. Duress Alert Screen
- **Shows when duress PIN is entered**
- Emergency alert interface with:
  - Warning icon and "DURESS ALERT" title
  - Status information (location tracking, network notification)
  - Instructions for user
  - Cancel alert button (for testing purposes)

## Technical Implementation

### Architecture
- **MVVM Pattern** with Provider state management
- **Responsive Design** using MediaQuery for all UI elements
- **Secure Storage** for PINs and authentication tokens
- **Modular Structure** with separate ViewModels for each feature

### Key Components

#### ViewModels
- `AppState`: Global application state
- `AuthViewModel`: Handles PIN verification and type detection
- `RegisterViewModel`: Manages registration flow and validation

#### Views
- `SplashView`: Initial screen with auth options
- `PinInputView`: PIN entry for existing users
- `RegisterView`: Multi-step registration process
- `DuressAlertView`: Emergency alert interface
- `MainPageView`: Home screen (existing)

#### Services
- `ApiClient`: Handles all API communication
- `RegisterService`: Registration-specific API calls

### Security Features
- PINs stored securely using Flutter Secure Storage
- PIN type detection (normal vs duress)
- Privacy policy acceptance required for registration
- Proper error handling and validation

### Responsive Design
- All UI elements use MediaQuery for responsive sizing
- Consistent spacing and typography scaling
- Cross-platform compatibility (iOS and Android)

## API Integration Ready

The app is prepared for backend integration with these endpoints:
- `POST /auth/verify-invite` - Verify invite code
- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication (if needed)

To integrate with your backend:
1. Set the `API_BASE_URL` in your `.env` file
2. Ensure your API endpoints match the expected request/response formats
3. Test the integration with real invite codes and user data

## Testing the Flow

### New User Registration
1. Launch app → Splash screen
2. Tap "Register" → Invite code entry
3. Enter valid invite code → Normal PIN setup
4. Set and confirm normal PIN → Duress PIN setup
5. Set duress PIN, accept privacy policy → Complete registration
6. Navigate to Home Screen

### Existing User Login
1. Launch app → Splash screen
2. Tap "I already have an account" → PIN input
3. Enter normal PIN → Home Screen
4. OR enter duress PIN → Duress Alert Screen

This flow ensures a secure, user-friendly experience while maintaining the critical duress functionality for emergency situations. 