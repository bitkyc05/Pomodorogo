# Pomodoro Focus - macOS SwiftUI App

A sophisticated Pomodoro timer application built with SwiftUI for macOS. This app provides comprehensive productivity tracking, work area management, and ambient sound support to enhance your focus sessions.

## Features

### Core Timer Functionality
- **Pomodoro Timer**: 25-minute work sessions with 5-minute short breaks and 15-minute long breaks
- **Session Management**: Automatic transitions between work and break periods
- **Progress Tracking**: Visual circular progress indicator with real-time updates
- **Session Counter**: Track current session number with automatic reset after long breaks

### Work Area Management
- **Multiple Work Areas**: Organize your work by project or category
- **Quick Switching**: Easily switch between different work areas
- **Session Tracking**: Individual statistics for each work area
- **Default Area**: "General Work" area always available

### Sound System
- **Notification Sounds**: Customizable session completion alerts
- **Ambient Sounds**: Built-in ambient sounds for focus enhancement
  - Rain
  - Ocean waves
  - Forest sounds
  - Cafe ambiance
  - White noise
- **Volume Control**: Adjustable volume for all sound types
- **Auto-start**: Ambient sounds automatically start with timer sessions

### Settings & Customization
- **Timer Durations**: Customize work, short break, and long break durations
- **Notification Preferences**: Enable/disable notifications and choose sound types
- **Focus Mode**: Optional full-screen focus overlay during work sessions
- **Distraction Alerts**: Periodic reminders to stay focused
- **Advanced Options**: Menu bar app mode, global shortcuts, dock icon hiding

### Statistics & Review
- **Session Statistics**: Track completed sessions, total time, and current streak
- **Daily Review System**: Calendar-based review interface with mood tracking
- **Achievement System**: Monitor productivity goals and achievements
- **Historical Data**: Comprehensive session logs with actual vs planned duration

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework for macOS
- **MVVM Pattern**: Clean separation of concerns with ViewModels
- **Data Persistence**: UserDefaults for settings and lightweight data storage
- **Combine Framework**: Reactive programming for state management

### Audio Implementation
- **AVFoundation**: Native audio framework for sound management
- **Real-time Generation**: Programmatic ambient sound generation
- **Background Playback**: Continuous ambient sound during sessions
- **System Integration**: Proper audio session handling for macOS

### UI/UX Features
- **Fixed Window Management**: Popup windows with consistent, non-resizable behavior
- **Modern SwiftUI**: NavigationStack and contemporary UI patterns
- **Responsive Design**: Content automatically fills available window space
- **Dark Mode**: Native macOS dark mode support
- **Glassmorphism**: Modern visual effects with backdrop blur
- **Accessibility**: VoiceOver support and keyboard navigation
- **Animations**: Smooth transitions and progress animations

## System Requirements

- macOS 13.0 or later
- Apple Silicon or Intel processor
- 50MB available storage space

## Installation

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

## Usage

### Basic Operation
1. Select work mode (default: 25 minutes)
2. Choose or create a work area
3. Click the play button to start your focus session
4. Take breaks when the timer completes
5. Review your progress in the statistics section

### Keyboard Shortcuts
- **Space**: Start/pause timer
- **R**: Reset current session
- **S**: Open settings
- **V**: Open review interface
- **⌘+,**: Application preferences

### Work Area Management
- Click on the work area name to switch between projects
- Add new work areas for different types of work
- Remove unused work areas (except "General Work")
- View individual statistics for each work area

## Version History

### v0.4.1 (Current)
- 📄 Updated documentation and README
- 🔧 Minor version maintenance update

### v0.4 - UI/UX Major Improvements
- 🪟 **Fixed popup window resizing issues**: Implemented separate WindowGroup for Settings and Review
- 🚫 **Prevented user window resizing**: Added `windowResizability(.contentSize)` for consistent UI
- 🎨 **Modern SwiftUI patterns**: Replaced NavigationView with NavigationStack
- 📐 **Improved layout consistency**: Added `frame(maxWidth: .infinity)` to all sections
- ✨ **Enhanced popup content**: Content now properly fills window width
- 🗓️ **Optimized calendar grid**: Better spacing and aspect ratio handling
- 🎯 **Better user experience**: Consistent popup behavior across all windows

### v0.3 - Audio & Responsive Design
- ✅ Fixed ambient sound not starting with timer sessions
- ✅ Added responsive UI that adapts to window size changes
- ✅ Improved sound system integration
- ✅ Enhanced error handling in audio management
- ✅ Added dynamic font sizing based on window geometry
- ✅ Implemented proper session completion sound playback

### v0.2 - Work Areas & Statistics
- ✅ Work area management system
- ✅ Enhanced statistics tracking
- ✅ Daily review system with calendar interface

### v0.1 - Initial Release
- ✅ Core Pomodoro timer functionality
- ✅ Basic settings and preferences
- ✅ Sound system foundation

## Development

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

## Contributing

This is a personal project for learning SwiftUI development. However, feedback and suggestions are welcome through issues.

## License

This project is for educational purposes. Please respect the learning journey and use responsibly.

---

Built with ❤️ using SwiftUI and modern macOS development practices.