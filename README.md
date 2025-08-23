# RouteN 🗺️

A comprehensive Flutter travel planning app that helps users discover, plan, and share their travel experiences with an integrated community platform.

## Features ✨

### 🎯 Trip Planning
- **Smart Search**: Search for destinations by city, travel dates, and travel theme (Alone, Couple, Family, Business, Friends)
- **Personalized Recommendations**: Get curated place recommendations based on your travel preferences
- **Interactive Maps**: View recommended places on Google Maps with detailed location information
- **Save & Manage**: Save your travel plans and access them anytime from your personal list

### 🏙️ Destination Coverage
Currently supports popular destinations including:
- **Seoul** - Traditional villages, nature parks, trendy neighborhoods
- **New York** - Iconic landmarks, museums, parks, and cultural sites  
- **Tokyo** - Modern attractions, romantic spots, and group-friendly venues
- **Paris, London, Madrid, LA, Austin** - And more cities coming soon!

### 👥 Community Features
- **Share Reviews**: Write and share detailed reviews of your travel experiences
- **Photo Sharing**: Upload multiple photos to showcase your trips
- **Rating System**: Rate locations and experiences with a 5-star system
- **Social Interaction**: Like reviews and engage with other travelers through comments
- **Course-based Reviews**: Link reviews to specific saved travel courses

### 🔐 User Management
- **Firebase Authentication**: Secure user registration and login
- **User Profiles**: Personalized profiles with profile pictures
- **Personal Dashboard**: Manage your saved trips and review history

## Tech Stack 🛠️

- **Framework**: Flutter
- **Backend**: Firebase
  - Firestore (Database)
  - Firebase Auth (Authentication)
  - Firebase Storage (Image storage)
- **Maps**: Google Maps Flutter
- **UI Components**: 
  - Syncfusion Flutter DatePicker
  - Flutter Rating Bar
  - Image Picker
- **Architecture**: Stateful/Stateless Widget architecture with Firebase integration

## Screenshots 📱

*Add your app screenshots here*

## Getting Started 🚀

### Prerequisites
- Flutter SDK (>=2.0.0)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/routen.git
   cd routen
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, and Storage
   - Download and add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. **Google Maps Setup**
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add the API key to your `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_API_KEY_HERE"/>
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── screens/
│   ├── home_screen.dart              # Main dashboard
│   ├── search_screen.dart            # Trip search interface
│   ├── result_screen.dart            # Search results and recommendations
│   ├── map_screen.dart               # Google Maps integration
│   ├── my_list_screen.dart           # User's saved trips
│   ├── community_screen.dart         # Community reviews feed
│   ├── add_edit_review_screen.dart   # Review creation/editing
│   ├── review_detail_screen.dart     # Individual review details
│   └── upload_itinerary_screen.dart  # Admin tool for data upload
└── main.dart                         # App entry point
```

## Key Features Explained 🔍

### Search & Planning Flow
1. **Search Screen**: Users select destination, travel dates, and theme
2. **Result Screen**: Displays personalized recommendations based on selections  
3. **Map Integration**: View all recommended places on interactive Google Maps
4. **Save Plans**: Users can save their itineraries for future reference

### Community Platform
1. **Review System**: Users can write detailed reviews with photos and ratings
2. **Course Integration**: Reviews are linked to specific saved travel courses
3. **Social Features**: Like, comment, and engage with other travelers
4. **Content Management**: Users can edit/delete their own reviews

### Data Management
- **Firestore Collections**:
  - `users/{userId}/course` - User's saved travel plans
  - `reviews` - Community reviews with nested comments
  - `itineraries` - Pre-populated destination data
- **Storage**: User-uploaded images stored in Firebase Storage

## Contributing 🤝

We welcome contributions! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Future Enhancements 🚀

- [ ] Integration with real-time flight and hotel APIs
- [ ] AI-powered itinerary optimization
- [ ] Offline map support
- [ ] Multi-language support
- [ ] Advanced filtering and sorting options
- [ ] Social features expansion (follow users, travel groups)
- [ ] Integration with travel booking platforms

## Contact 📧

Joonhyung Park: 0314pjh@gmail.com
Minsoo Ku: ku.minsoo0314@gmail.com

Project Link: (https://github.com/0314pjh/routen)

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Firebase for backend services
- Google Maps Platform for location services
- The Flutter community for invaluable packages and support

---

**Made with ❤️ and Flutter**
