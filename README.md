# 🍅 Pomodorogo - macOS Pomodoro Timer

<div align="center">

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-macOS%2013.0+-blue.svg)](https://developer.apple.com/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-v0.6.0-brightgreen.svg)](https://github.com/bitkyc05/Pomodorogo/releases)

A sophisticated Pomodoro timer application built with SwiftUI for macOS. This app provides comprehensive productivity tracking, work area management, session review capabilities, and ambient sound support to enhance your focus sessions.

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Version History](#version-history) • [Contributing](#contributing)

</div>

## 📱 Screenshots

*Screenshots coming soon*

## ✨ Features

### 🍅 Core Timer Functionality
- **Pomodoro Timer**: 25-minute work sessions with 5-minute short breaks and 15-minute long breaks
- **Session Management**: Automatic transitions between work and break periods
- **Progress Tracking**: Visual circular progress indicator with real-time updates
- **Session Counter**: Track current session number with automatic reset after long breaks
- **Smart Statistics**: Only work sessions count toward productivity metrics

### 🏢 Work Area Management
- **Multiple Work Areas**: Organize your work by project or category
- **Quick Switching**: Easily switch between different work areas
- **Session Tracking**: Individual statistics for each work area
- **Default Area**: "General Work" area always available

### 🎵 Sound System
- **Notification Sounds**: Customizable session completion alerts
- **Ambient Sounds**: Built-in ambient sounds for focus enhancement (work sessions only)
  - 🌧️ Rain
  - 🌊 Ocean waves
  - 🌲 Forest sounds
  - ☕ Cafe ambiance
  - 📻 White noise
- **Volume Control**: Adjustable volume for all sound types
- **Auto-start**: Ambient sounds automatically start with work sessions

### ⚙️ Settings & Customization
- **Timer Durations**: Customize work, short break, and long break durations
- **Notification Preferences**: Enable/disable notifications and choose sound types
- **Advanced Options**: Menu bar app mode, global shortcuts, dock icon hiding
- **Data Management**: Reset today's or all statistics from settings

### 📊 Statistics & Review System
- **Session Statistics**: Track completed sessions, total time, and current streak
- **Daily Review System**: Calendar-based review interface with mood tracking
- **Session Logs**: View detailed logs of all daily sessions (work and break)
- **Individual Session Reviews**: Double-click work sessions to add review notes
- **Achievement System**: Monitor productivity goals and achievements
- **Historical Data**: Comprehensive session logs with actual vs planned duration
- **Data Export**: Export all review data to JSON format for backup and analysis

### ⌨️ Keyboard Shortcuts
- **Space**: Start/pause timer (global shortcut)
- **R**: Reset current session (global shortcut)
- **S**: Open settings (global shortcut)
- **V**: Open review interface (global shortcut)
- **⌘+,**: Application preferences

*Note: Global shortcuts can be enabled/disabled in Settings > Advanced > Global Shortcuts*

## 🔧 Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework for macOS
- **MVVM Pattern**: Clean separation of concerns with ViewModels
- **Data Persistence**: UserDefaults for settings and lightweight data storage
- **Combine Framework**: Reactive programming for state management

### Audio Implementation
- **AVFoundation**: Native audio framework for sound management
- **Real-time Generation**: Programmatic ambient sound generation
- **Background Playback**: Continuous ambient sound during work sessions
- **System Integration**: Proper audio session handling for macOS

### UI/UX Features
- **Fixed Window Management**: Popup windows with consistent, non-resizable behavior
- **Modern SwiftUI**: NavigationStack and contemporary UI patterns
- **Responsive Design**: Content automatically fills available window space
- **Dark Mode**: Native macOS dark mode support
- **Glassmorphism**: Modern visual effects with backdrop blur
- **Accessibility**: VoiceOver support and keyboard navigation
- **Animations**: Smooth transitions and progress animations

## 💻 System Requirements

- macOS 13.0 or later
- Apple Silicon or Intel processor
- 50MB available storage space

## 📦 Installation

### Option 1: Download Release
1. Go to [Releases](https://github.com/bitkyc05/Pomodorogo/releases)
2. Download the latest `.app` file
3. Move to Applications folder
4. Right-click and select "Open" (first time only)

### Option 2: Build from Source
1. Clone the repository:
```bash
git clone https://github.com/bitkyc05/Pomodorogo.git
cd Pomodorogo
```

2. Open the project in Xcode:
```bash
open Pomodorogo.xcodeproj
```

3. Build and run the project (⌘+R)

## 🚀 Usage

### Basic Operation
1. Select work mode (default: 25 minutes)
2. Choose or create a work area
3. Click the play button to start your focus session
4. Take breaks when the timer completes
5. Review your progress in the statistics section

### Advanced Features
- **Work Area Management**: Click on the work area name to switch between projects
- **Daily Reviews**: Use the Review button to track your daily productivity
- **Session Notes**: Double-click completed work sessions to add review notes
- **Data Management**: Reset statistics from Settings > Data Management

## 📈 Version History

### v0.6.0 (Current) - Session Review & Enhanced Logging
- 📊 **Session Logs**: View detailed daily session history (work and break sessions)
- 📝 **Session Reviews**: Double-click work sessions to add individual review notes
- 🔇 **Smart Ambient Audio**: Ambient sounds only play during work sessions, not breaks
- 🐛 **Statistics Fix**: Break sessions no longer incorrectly count toward productivity stats
- 💾 **Enhanced Data Persistence**: Session review notes are permanently saved
- 🎨 **Improved UI**: Better session visualization with icons and timing information

### v0.5.3 - Data Export Feature
- 📤 **Data Export**: Export all review data to JSON format for backup and analysis
- 📱 **UI Enhancement**: Added export button to ReviewView toolbar
- 🔒 **Security Enhancement**: Added file saving permissions to app entitlements
- 💾 **Data Management**: Users can now backup and manage their productivity data

### v0.5.2 - Review Data Management
- 🗑️ **Delete All Reviews**: Added button to delete all review data with confirmation dialog
- 🗑️ **Daily Delete**: Added button to delete specific date reviews from ReviewView
- 🔄 **Data Reset**: Reset all existing data to provide clean initial state
- 📱 **UI Enhancement**: Improved ReviewView toolbar with menu-based deletion options
- ⚠️ **Safe Deletion**: Added confirmation alerts to prevent accidental data loss

### v0.5.1 - App Icon Issue Fix
- 🔧 **Critical Bug Fix**: Fixed missing app icon issue caused by invalid JSON in Contents.json
- 🧹 **Build Cache Management**: Improved build cache handling to prevent asset compilation issues
- ✅ **Asset Validation**: Ensured proper AppIcon.appiconset configuration for all macOS icon sizes
- 🛠️ **Development Stability**: Enhanced development workflow with proper cache clearing procedures

### v0.5 - Keyboard Shortcuts Implementation
- ⌨️ **Global Keyboard Shortcuts**: Implemented NSEvent-based local keyboard shortcuts
- 🎮 **Enhanced User Control**: Space (start/pause), R (reset), S (settings), V (review)
- 🔧 **Smart Text Field Detection**: Shortcuts disabled during text editing
- ⚙️ **Settings Integration**: Toggle shortcuts on/off in Advanced settings
- 🎯 **UI Indicators**: Added keyboard shortcut hints to all control buttons
- ✅ **Comprehensive Testing**: Added KeyboardShortcutManagerTests for functionality validation
- 📱 **App-focused Mode**: Shortcuts work when app is in focus for system safety

## 🛠️ Development

This project serves as a reference implementation for converting web-based Pomodoro applications to native macOS apps. It demonstrates best practices for:

- SwiftUI app architecture
- Audio system integration
- Data persistence strategies
- Responsive UI design
- User experience optimization

### Related Documentation
- Web app reference implementation: `/pomodoro-app/`
- Development logs: `Pomodoro-macOS-Development-Log.md`
- Phase 2 planning: `Phase-2-Development-Plan.md`

### Build Requirements
- Xcode 15.0+
- Swift 5.9+
- macOS Sonoma SDK

## 🤝 Contributing

This is a personal project for learning SwiftUI development. However, feedback and suggestions are welcome through issues.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is for educational purposes. Please respect the learning journey and use responsibly.

## 🙏 Acknowledgments

- Inspired by the Pomodoro Technique by Francesco Cirillo
- Built with modern SwiftUI and macOS development practices
- Uses programmatic audio generation for ambient sounds

---

<div align="center">

**Built with ❤️ using SwiftUI and modern macOS development practices**

[⬆ Back to top](#-pomodorogo---macos-pomodoro-timer)

</div>