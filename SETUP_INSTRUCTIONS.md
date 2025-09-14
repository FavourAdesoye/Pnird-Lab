# Pnird Lab Social Media App - Setup Instructions

Welcome to the Pnird Lab social media application! This guide will help you set up the development environment for both the backend and Flutter frontend.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software
- **Node.js** (v16 or higher) - [Download here](https://nodejs.org/)
- **Flutter SDK** (v3.0.0 or higher) - [Installation guide](https://flutter.dev/docs/get-started/install)
- **Git** - [Download here](https://git-scm.com/)
- **MongoDB** - [Installation guide](https://docs.mongodb.com/manual/installation/)
- **Android Studio** (for Android development) - [Download here](https://developer.android.com/studio)
- **Xcode** (for iOS development, macOS only) - Available on Mac App Store

### Development Tools (Recommended)
- **VS Code** with Flutter and Dart extensions
- **Postman** or **Insomnia** for API testing
- **MongoDB Compass** for database management

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd Pnird-Lab
```

### 2. Backend Setup

#### Navigate to Backend Directory
```bash
cd pnird_lab_backend
```

#### Install Dependencies
```bash
npm install
```

#### Environment Configuration
Create a `.env` file in the `pnird_lab_backend` directory with the following variables:

```env
# Database
MONGO_URL=mongodb://localhost:27017/pnirdlab

# Server
PORT=3000

# Cloudinary (for image storage)
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
```

**Note**: You'll need to obtain these credentials from:
- MongoDB: Set up a local MongoDB instance or use MongoDB Atlas
- Cloudinary: Sign up at [cloudinary.com](https://cloudinary.com) for free

#### Firebase Configuration
The Firebase Admin SDK is already configured with the service account file. Make sure the `pnird-lab-firebase-adminsdk-avod6-157fc3b4bb.json` file is present in the backend directory.

#### Start the Backend Server
```bash
npm start
```

The backend will run on `http://localhost:3000`

### 3. Flutter App Setup

#### Navigate to Flutter Directory
```bash
cd pnird_lab_flutter
```

#### Install Flutter Dependencies
```bash
flutter pub get
```

#### Environment Configuration
Create a `.env` file in the `pnird_lab_flutter` directory:

```env
# Backend API URL
API_BASE_URL=http://localhost:3000/api

# Socket.io URL
SOCKET_URL=http://localhost:3000
```

#### Firebase Configuration
The Firebase configuration is already set up for:
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`
- **Web**: Configured in `main.dart`

#### Platform-Specific Setup

##### Android Setup
1. Open Android Studio
2. Open the `android` folder in Android Studio
3. Let Gradle sync complete
4. Ensure you have an Android emulator or physical device connected

##### iOS Setup (macOS only)
1. Navigate to the `ios` directory
2. Run `pod install` to install iOS dependencies
3. Open `ios/Runner.xcworkspace` in Xcode
4. Ensure you have an iOS simulator or physical device

#### Run the Flutter App
```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios

# For Web
flutter run -d web
```

## 🏗️ Project Structure

```
Pnird-Lab/
├── pnird_lab_backend/          # Node.js Backend
│   ├── controllers/            # Route controllers
│   ├── middleware/             # Authentication & validation
│   ├── models/                 # MongoDB schemas
│   ├── routes/                 # API endpoints
│   ├── utils/                  # Utility functions
│   └── uploads/                # File uploads
│
├── pnird_lab_flutter/          # Flutter Frontend
│   ├── lib/
│   │   ├── components/         # Reusable UI components
│   │   ├── model/              # Data models
│   │   ├── pages/              # App screens
│   │   ├── services/           # API services
│   │   └── widgets/            # Custom widgets
│   ├── assets/                 # Images, fonts, etc.
│   └── android/ios/web/        # Platform-specific code
```

## 🔧 Development Workflow

### Backend Development
1. Make changes to backend code
2. The server will auto-restart with nodemon
3. Test API endpoints using Postman or similar tool

### Flutter Development
1. Make changes to Flutter code
2. Use `flutter hot reload` for quick testing
3. Use `flutter hot restart` for full app restart

### Database Management
- Use MongoDB Compass to view and manage data
- Default database: `pnirdlab`
- Collections: users, posts, comments, studies, events, messages, notifications

## 🐛 Troubleshooting

### Common Issues

#### Backend Issues
- **MongoDB Connection Error**: Ensure MongoDB is running locally or check your connection string
- **Port Already in Use**: Change the PORT in your `.env` file
- **Firebase Admin Error**: Verify the service account JSON file is present

#### Flutter Issues
- **Dependencies Error**: Run `flutter clean` then `flutter pub get`
- **Build Errors**: Check that you have the correct Flutter version
- **iOS Build Issues**: Run `cd ios && pod install` then try again

#### Environment Issues
- **Missing .env files**: Create them with the required variables
- **API Connection Issues**: Verify backend is running and URLs are correct

### Getting Help
1. Check the console logs for error messages
2. Ensure all prerequisites are installed correctly
3. Verify all environment variables are set
4. Check that all services (MongoDB, backend server) are running

## 📱 App Features Overview

### Main Navigation
- **Home**: Social media feed with posts
- **Studies**: Research studies and participation
- **Events**: Lab events and announcements
- **About Us**: Lab information and team
- **Games**: Brain training and cognitive games

### User Features
- **Authentication**: Student and Staff login/signup
- **Profile Management**: Customizable user profiles
- **Social Interaction**: Posts, comments, likes
- **Real-time Messaging**: Direct messaging between users
- **Notifications**: Real-time notifications
- **File Uploads**: Image and document sharing

## 🔐 Security Notes

- Never commit `.env` files to version control
- Keep Firebase service account files secure
- Use environment variables for all sensitive data
- Regularly update dependencies for security patches

## 📞 Support

If you encounter issues not covered in this guide:
1. Check the project's issue tracker
2. Review the Flutter and Node.js documentation
3. Contact the development team

---

**Happy Coding! 🚀**

*This app is designed for the Pnird Lab at Virginia State University's Psychology Department to facilitate research collaboration and social interaction among lab members.*
