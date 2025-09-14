# Pnird Lab Flutter App

The frontend mobile and web application for the Pnird Lab Social Media Platform, built with Flutter for cross-platform compatibility (iOS, Android, Web).

## 📱 About

This Flutter app provides the user interface for the Pnird Lab social media platform, featuring role-based authentication, real-time messaging, cognitive games, and research study participation tools.

## ✨ Features

### 🎯 Core Functionality
- **Multi-platform Support**: iOS, Android, and Web
- **Role-based UI**: Different interfaces for staff and students
- **Real-time Messaging**: Socket.io powered chat system
- **Social Media**: Posts, comments, user profiles
- **Cognitive Games**: Brain training exercises including chess

### 🎮 Games & Cognitive Training
- **Chess Game**: Full chess implementation for cognitive training
- **Memory Games**: Various attention and memory exercises
- **Reaction Tests**: Cognitive performance measurement
- **Problem Solving**: Logic and reasoning challenges

### 🔬 Research Features
- **Study Participation**: Join and participate in research studies
- **Data Collection**: Automated performance tracking
- **Progress Monitoring**: Track cognitive improvement over time

## 🏗️ Architecture

### State Management
- **Provider**: For global state management
- **GetX**: For navigation and reactive programming

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  socket_io_client: ^3.1.1
  provider: ^6.1.2
  get: ^4.6.6
  http: ^1.2.1
  image_picker: ^1.1.2
  flutter_secure_storage: ^9.2.2
  flame: ^1.17.0  # For games
  flutter_stateless_chessboard: ^1.1.2
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.0.0 or higher)
- Dart SDK (comes with Flutter)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

2. **Environment Setup**
   Create a `.env` file in the root directory:
   ```env
   API_BASE_URL=http://localhost:3000/api
   SOCKET_URL=http://localhost:3000
   ```

3. **Platform Setup**

   **Android:**
   - Ensure `google-services.json` is in `android/app/`
   - Run `flutter run` for Android

   **iOS:**
   - Navigate to `ios/` directory
   - Run `pod install`
   - Open `ios/Runner.xcworkspace` in Xcode
   - Run `flutter run -d ios`

   **Web:**
   - Run `flutter run -d web`

## 📁 Project Structure

```
lib/
├── components/          # Reusable UI components
│   ├── allowbutton.dart
│   ├── button_controller.dart
│   └── nextbutton.dart
├── model/              # Data models
│   ├── comment_model.dart
│   ├── post_model.dart
│   ├── study_model.dart
│   └── user_model.dart
├── pages/              # App screens
│   ├── games/          # Game implementations
│   ├── loginpages/     # Authentication screens
│   ├── home.dart       # Main feed
│   ├── studies.dart    # Research studies
│   ├── events_page.dart
│   └── ...
├── services/           # API and business logic
│   ├── auth.dart
│   ├── api_service.dart
│   └── ...
├── widgets/            # Custom widgets
└── main.dart          # App entry point
```

## 🎮 Games Implementation

### Chess Game
- Full chess implementation using `flutter_stateless_chessboard`
- Move validation and game state management
- Cognitive performance tracking

### Memory Games
- Various memory and attention exercises
- Performance metrics collection
- Adaptive difficulty levels

## 🔐 Authentication Flow

1. **Account Type Selection**: Choose between Student or Staff
2. **Registration/Login**: Firebase Auth integration
3. **Role-based Navigation**: Different UI based on user role
4. **Session Management**: Secure token storage

## 📱 UI/UX Features

### Theme
- **Dark Theme**: Custom dark theme optimized for research environments
- **Custom Fonts**: Roboto font family for readability
- **Color Scheme**: Black background with yellow accents

### Navigation
- **Bottom Navigation**: 5 main sections (Home, Studies, Events, About, Games)
- **IndexedStack**: Preserves widget state during navigation
- **Custom App Bar**: Search functionality and messaging access

## 🔧 Development

### Hot Reload
```bash
flutter run  # Enables hot reload for quick development
```

### Building
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Web build
flutter build web
```

### Testing
```bash
flutter test
```

## 📊 Performance Considerations

- **State Preservation**: IndexedStack maintains widget state
- **Image Optimization**: Efficient image loading and caching
- **Memory Management**: Proper disposal of resources
- **Network Optimization**: Efficient API calls and caching

## 🐛 Troubleshooting

### Common Issues
- **Dependencies**: Run `flutter clean` then `flutter pub get`
- **iOS Build**: Ensure `pod install` is run in `ios/` directory
- **Android Build**: Check `google-services.json` is present
- **Web Build**: Ensure all web-specific dependencies are installed

### Debug Mode
```bash
flutter run --debug  # Enable debug logging
```

## 📱 Platform-Specific Notes

### Android
- Minimum SDK: 21
- Target SDK: 33
- Package: `com.example.flutternativesplash`

### iOS
- Minimum iOS: 11.0
- Bundle ID: `com.example.flutternativesplash`
- Requires Xcode 12+

### Web
- Responsive design for various screen sizes
- Firebase web configuration included

## 🤝 Contributing

1. Follow Flutter/Dart style guidelines
2. Add tests for new features
3. Update documentation as needed
4. Test on multiple platforms

## 📞 Support

For Flutter-specific issues:
- Check [Flutter Documentation](https://docs.flutter.dev/)
- Review the main project [Setup Instructions](../SETUP_INSTRUCTIONS.md)
- Contact the development team

---

**Part of the Pnird Lab Social Media Platform** 🧠
