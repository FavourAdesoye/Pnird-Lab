# Pnird Lab Social Media App

A comprehensive social media platform designed specifically for the Pnird Lab at Virginia State University's Psychology Department. This application facilitates research collaboration, social interaction, and cognitive training among lab members.

## 🧠 About the Project

The Pnird Lab Social Media App is a full-stack application that combines social networking features with research tools and cognitive games. It serves as a central hub for lab members to collaborate, participate in studies, and engage in brain training activities.

### Key Features

- **🔐 Role-Based Authentication**: Separate interfaces for staff and students
- **📱 Social Media Platform**: Posts, comments, user profiles, and real-time messaging
- **🔬 Research Studies**: Study management and participation system
- **📅 Event Management**: Lab events and announcements
- **🎮 Cognitive Games**: Brain training games including chess and other cognitive exercises
- **💬 Real-time Communication**: Socket.io powered messaging and notifications
- **📁 File Sharing**: Image and document uploads via Cloudinary
- **📊 Study Analytics**: Research data collection and analysis tools

## 🏗️ Tech Stack

### Backend
- **Node.js** with Express.js
- **MongoDB** for database
- **Socket.io** for real-time communication
- **Firebase Admin SDK** for authentication
- **Cloudinary** for file storage
- **Multer** for file uploads

### Frontend
- **Flutter** (iOS, Android, Web)
- **Firebase Auth** for user authentication
- **Socket.io Client** for real-time features
- **Provider** for state management
- **Custom UI components** with dark theme

## 🚀 Quick Start

### Prerequisites
- Node.js (v16+)
- Flutter SDK (v3.0+)
- MongoDB
- Android Studio (for Android)
- Xcode (for iOS, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Pnird-Lab
   ```

2. **Backend Setup**
   ```bash
   cd pnird_lab_backend
   npm install
   # Create .env file with required variables
   npm start
   ```

3. **Flutter Setup**
   ```bash
   cd pnird_lab_flutter
   flutter pub get
   # Create .env file with API URLs
   flutter run
   ```

For detailed setup instructions, see [SETUP_INSTRUCTIONS.md](./SETUP_INSTRUCTIONS.md).

## 📱 App Structure

### Main Navigation
- **Home**: Social media feed with posts and interactions
- **Studies**: Research studies and participation
- **Events**: Lab events and announcements  
- **About Us**: Lab information and team details
- **Games**: Brain training and cognitive games

### User Roles
- **Students**: Can participate in studies, view events, use social features
- **Staff**: Full access including study creation, event management, analytics

## 🔧 Development

### Backend Development
```bash
cd pnird_lab_backend
npm start  # Uses nodemon for auto-restart
```

### Flutter Development
```bash
cd pnird_lab_flutter
flutter run  # Hot reload enabled
```

### Firebase CLI (only when regenerating config)
If you need to regenerate Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`, `lib/firebase_options.dart`),
install the Firebase CLI and FlutterFire CLI locally, then run:
```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```

### Database
- MongoDB collections: users, posts, comments, studies, events, messages, notifications
- Use MongoDB Compass for database management

## 📁 Project Structure

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
│
└── SETUP_INSTRUCTIONS.md       # Detailed setup guide
```

## 🔐 Environment Variables

### Backend (.env)
```env
MONGO_URL=mongodb://localhost:27017/pnirdlab
PORT=3000
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_UPLOAD_URL=https://api.cloudinary.com/v1_1/dky55f2w4/image/upload
UPLOAD_PRESET=pnird_lab
```

### Flutter (.env)
```env
API_BASE_URL=http://localhost:3000/api
SOCKET_URL=http://localhost:3000
MONGO_URL=mongodb://localhost:27017/pnirdlab
PORT=3000
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_UPLOAD_URL=https://api.cloudinary.com/v1_1/dky55f2w4/image/upload
UPLOAD_PRESET=pnird_lab
```

## 🎮 Games & Cognitive Training

The app includes several brain training games:
- **Chess**: Full chess implementation for cognitive training
- **Memory Games**: Various memory and attention exercises
- **Reaction Time Tests**: Cognitive performance measurement
- **Problem Solving**: Logic and reasoning challenges

## 📊 Research Features

- **Study Management**: Create and manage research studies
- **Data Collection**: Automated data gathering from user interactions
- **Participant Management**: Track study participation
- **Analytics Dashboard**: Research insights and statistics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For questions or issues:
- Check the [Setup Instructions](./SETUP_INSTRUCTIONS.md)
- Review the troubleshooting section
- Contact the development team

## 📄 License

This project is developed for the Pnird Lab at Virginia State University's Psychology Department.

---

**Built with ❤️ for the Pnird Lab Research Community**
