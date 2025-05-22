# RTM – Route-To-Market App 📊

![RTM Banner](https://github.com/user-attachments/assets/b1605a34-b67a-4680-8e2c-4612ba8262a3)

A powerful Flutter-based cross-platform application designed for real-time data visualization and streamlined workflow management. RTM delivers critical insights instantly with an elegant, intuitive interface featuring fluid animations and role-based navigation.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-2.17+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Release](https://img.shields.io/badge/Release-v1.0.0-orange.svg)](https://github.com/xi9d/Visit-Tracker-using-flutter/releases/tag/appv1)

## 📱 Download

Get the application from our [latest release](https://github.com/xi9d/Visit-Tracker-using-flutter/releases/tag/appv1).

## ✨ Features

### 📈 Real-Time Analytics Dashboard
- Interactive, responsive charts with live data updates
- Customizable metrics and KPI cards
- Filter and sort capabilities for targeted analysis
- Comprehensive visualization of customer visit data

### 👥 Intelligent Role-Based Access
- Automatic routing to appropriate screens (Manager/Representative)
- Permission-aware UI elements and functionality
- Context-specific tools and reports for each role
- Streamlined workflows based on user responsibilities

### 🎨 Modern UI/UX with Animations
- Liquid animation logo and elegant wave effects
- Smooth transitions between screens and states
- Thoughtfully designed color schemes and typography
- Engaging user interface with interactive elements

### 📱 Responsive Cross-Platform Design
- Seamless experience across mobile and tablet devices
- Adaptive layouts for different screen sizes
- Consistent performance on both Android and iOS
- Optimized rendering for various device capabilities

### 🔐 Secure Authentication
- Email/password authentication with real-time validation
- Visual loading states and error handling
- Account management functionality
- Role-based security and access control

## 📸 Screenshots

<div align="center">
  <div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
    <img src="https://github.com/user-attachments/assets/c8691e89-c58e-4242-ad2a-94ed80c085c9" width="180" alt="Login Screen"/>
    <img src="https://github.com/user-attachments/assets/4ecbfc54-3e27-4277-90f2-9efafc8cab6a" width="180" alt="Dashboard"/>
    <img src="https://github.com/user-attachments/assets/917045b7-8afd-418b-bad1-6aae59e841a6" width="180" alt="Analytics"/>
    <img src="https://github.com/user-attachments/assets/56ff6ad6-2bf3-4440-81c1-6d3986494e7e" width="180" alt="Reports"/>
  </div>
  <div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px; margin-top: 10px;">
    <img src="https://github.com/user-attachments/assets/202516c7-299a-4a2e-8f3b-44678e110a7d" width="180" alt="Details View"/>
    <img src="https://github.com/user-attachments/assets/5749a1ee-7e80-489c-975f-ae293e32c21d" width="180" alt="Calendar"/>
    <img src="https://github.com/user-attachments/assets/8b231b40-df66-42ee-8cb0-a3668b4885cb" width="180" alt="User Profile"/>
    <img src="https://github.com/user-attachments/assets/2abde254-f0e0-4237-8f85-1b350ee2d253" width="180" alt="Customer Details"/>
  </div>
</div>

## 🛠️ Technology Stack

### Frontend
- **Flutter Framework** for cross-platform mobile development
- **Provider** for state management
- **fl_chart** for data visualization components
- **shared_preferences** for local storage
- Custom animations using Flutter's animation framework

### Backend
- **Python Flask** RESTful API
- **Supabase** for database management
- Four core database tables:
  - `users` - Authentication and role management
  - `customers` - Customer information storage
  - `visits` - Visit records with location data
  - `activities` - Tracking of representative activities

### API Endpoints
```
https://xi9d.pythonanywhere.com/api/customers        # Customer management
https://xi9d.pythonanywhere.com/api/visits/stats     # Visit statistics
https://xi9d.pythonanywhere.com/api/signup           # User registration
https://xi9d.pythonanywhere.com/api/signin           # Authentication
https://xi9d.pythonanywhere.com/api/visits           # Visit management
https://xi9d.pythonanywhere.com/api/visits/search    # Visit search functionality
https://xi9d.pythonanywhere.com/api/customers/1      # Individual customer details
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / Xcode for native builds

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/xi9d/Visit-Tracker-using-flutter.git
   cd Visit-Tracker-using-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Authentication Credentials

#### Manager Access
- **Email:** admin@gmail.com
- **Password:** 123456
- Full access to all features, analytics, and user management

#### Representative Access
- **Email:** user@gmail.com
- **Password:** 123456
- Access to customer visits, data entry, and personal metrics


```
API_BASE_URL=https://xi9d.pythonanywhere.com
ENABLE_ANALYTICS=true
```

## 💡 Advanced Features

### Offline Capabilities
The application supports offline mode with local data storage and synchronization when connectivity is restored.

### Location Services
Integrated geolocation for tracking visit locations and calculating travel metrics.

### Custom Animations
- Liquid animation for the app logo
- Wave effects for visual appeal
- Smooth transition animations between screens

### Analytics Dashboard
Real-time visualization of:
- Visit frequency by customer
- Geographic distribution of visits
- Performance metrics by representative
- Time-based trend analysis

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

## 📱 Supported Platforms

- Android 5.0+
- iOS 11.0+

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications
- [Provider](https://pub.dev/packages/provider) - State management solution
- [fl_chart](https://pub.dev/packages/fl_chart) - Chart visualization library
- [shared_preferences](https://pub.dev/packages/shared_preferences) - Local storage solution
- [Python Flask](https://flask.palletsprojects.com/) - Backend API framework
- [Supabase](https://supabase.io/) - Open source Firebase alternative

---

<div align="center">
  <p>
    <a href="https://github.com/xi9d/Visit-Tracker-using-flutter">
      <img src="https://img.shields.io/github/stars/xi9d/Visit-Tracker-using-flutter?style=social" alt="GitHub stars">
    </a>
    <a href="https://github.com/xi9d/Visit-Tracker-using-flutter/issues">
      <img src="https://img.shields.io/github/issues/xi9d/Visit-Tracker-using-flutter?style=social" alt="GitHub issues">
    </a>
  </p>
  <sub>Built with ❤️ by Paul Webo</sub>
</div>
