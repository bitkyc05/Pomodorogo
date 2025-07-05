# 🍅 Pomodorogo - Native macOS Pomodoro Timer

<div align="center">

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-macOS%2013.0+-blue.svg)](https://developer.apple.com/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-v0.8.0-brightgreen.svg)](https://github.com/bitkyc05/Pomodorogo/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%2013.0+-lightgrey.svg)](https://developer.apple.com/macos/)

**A sophisticated native macOS Pomodoro timer that transforms your productivity workflow**

Pomodorogo brings the time-tested Pomodoro Technique to your Mac with modern SwiftUI design, comprehensive tracking, and seamless macOS integration. Whether you're a developer, student, or knowledge worker, Pomodorogo helps you maintain focus and track your productivity journey.

[Download Latest Release](https://github.com/bitkyc05/Pomodorogo/releases) • [Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation)

</div>

## 🎯 Why Pomodorogo?

- **🎨 Native macOS Experience**: Built with SwiftUI for smooth performance and system integration
- **🔥 Menu Bar Integration**: Quick access from your menu bar without cluttering your dock
- **📊 Smart Analytics**: Detailed session tracking with daily reviews and productivity insights  
- **🎵 Focus Enhancement**: Built-in ambient sounds to boost concentration
- **⚡ Keyboard-First**: Global shortcuts for seamless workflow integration
- **📝 Session Reviews**: Reflect on your work with individual session notes

## 📱 Screenshots

> *Beautiful screenshots showcasing the app in action coming soon*

## ✨ Features

### 🍅 **Core Timer Functionality**
- **Pomodoro Timer**: Classic 25-minute work sessions with 5-minute short breaks and 15-minute long breaks
- **Precise Time Tracking**: Date.now() based calculation excludes pause time for accurate session recording
- **Overtime Mode**: Continue working beyond set time with separate overtime tracking
- **Auto-Progression**: Intelligent transitions between work and break periods (4 work sessions → long break)
- **Visual Progress**: Beautiful circular progress indicator with real-time countdown
- **Session Management**: Track current session number with automatic cycle management
- **Smart Statistics**: Only work sessions count toward productivity metrics (breaks excluded)
- **Dual Time Display**: Session format shows pure work time + overtime (e.g., "25:00 (+3:15)")

### 🏢 **Work Area Management**
- **Project Organization**: Create and manage multiple work areas (projects, subjects, clients)
- **Quick Switching**: Effortlessly switch between different work contexts
- **Individual Tracking**: Separate statistics and session logs for each work area
- **Default Setup**: "General Work" area always available as fallback

### 🎵 **Advanced Audio System**
- **Smart Session Alerts**: Notifications trigger only when pure work time is completed (not wall-clock time)
- **Dual Notification System**: First alert when target time reached, second when overtime session stops
- **Customizable Completion Sounds**: Default Beep, Bell, Chime, or Silent options
- **Ambient Soundscape**: Focus-enhancing background audio (work sessions only)
  - 🌧️ **Rain**: Gentle rainfall for calm concentration
  - 🌊 **Ocean**: Rhythmic waves for deep focus
  - 🌲 **Forest**: Natural woodland ambiance
  - ☕ **Cafe**: Coffee shop background chatter
  - 📻 **White Noise**: Clean sound masking
- **Volume Control**: Fine-tune ambient sound levels (0-100%)
- **Auto-Start**: Ambient sounds begin automatically with work sessions

### 🖥️ **Menu Bar Integration**
- **Status Bar Icon**: 🍅 icon shows current timer state in your menu bar
- **Quick Controls**: Start, pause, reset timer without opening main window
- **Popover Interface**: Compact timer view with full controls and statistics
- **Context Menu**: Right-click for quick actions and app navigation
- **Dynamic Icons**: Visual feedback for running/paused states
- **Always Accessible**: Timer controls available even when app is minimized

### ⌨️ **Powerful Keyboard Shortcuts**
- **Global Shortcuts** (when app is focused):
  - `Space`: Start/pause timer (work mode) or Start/Stop (break mode)
  - `R`: Reset current session
  - `S`: Open settings
  - `V`: Open review interface
- **App Menu Shortcuts**:
  - `⌘+Space`: Start/pause timer
  - `⌘+R`: Reset timer
  - `⌘+1/2/3`: Switch to Work/Short Break/Long Break
  - `⌘+,`: Preferences
  - `⌘+D`: Daily Review
- **Mode-Specific Controls**:
  - **Work Mode**: Full pause/resume functionality for flexible timing
  - **Break Mode**: Simple Start/Stop workflow (no pause option)

### 📊 **Comprehensive Analytics & Review**
- **Session Statistics**: Track completed sessions, total focused time, and current streak
- **Smart Streak Calculation**: Daily continuity tracking (resets if no work sessions for a day)
- **Precise Time Recording**: Pure work time + overtime separated for accurate productivity metrics
- **Daily Review System**: Calendar-based interface for tracking daily productivity
- **Session Logs**: Detailed view of all sessions with dual time format (e.g., "25:03 (+2:15)")
- **Individual Session Reviews**: Double-click work sessions to add reflection notes
- **Export Capabilities**: Backup all data to JSON format for external analysis
- **Historical Tracking**: Long-term productivity trends and patterns

### ⚙️ **Customization & Settings**
- **Timer Durations**: Customize work (1-60 min), short break (1-30 min), and long break (1-60 min)
- **Notification System**: Toggle notifications and choose alert sounds
- **Menu Bar Mode**: Enable/disable menu bar app with dock icon hiding
- **Data Management**: Reset today's statistics or all data from settings
- **Focus Mode Integration**: macOS Do Not Disturb mode activation
- **Advanced Options**: Global shortcuts toggle and system integration preferences

## 💻 System Requirements

- **macOS**: 13.0 (Ventura) or later
- **Processor**: Apple Silicon (M1/M2) or Intel (64-bit)
- **Storage**: 50MB available space
- **Memory**: 100MB RAM (typical usage)

## 📦 Installation

### Option 1: Download Release (Recommended)
1. Visit [Releases](https://github.com/bitkyc05/Pomodorogo/releases)
2. Download the latest `Pomodorogo.app` file
3. Drag to your **Applications** folder
4. **First launch**: Right-click → "Open" (security verification)
5. **Enable Menu Bar** (optional): Settings → Advanced → Enable Menu Bar App

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/bitkyc05/Pomodorogo.git
cd Pomodorogo

# Open in Xcode
open Pomodorogo.xcodeproj

# Build and run (⌘+R)
```

**Requirements for building:**
- Xcode 15.0+
- Swift 5.9+
- macOS Sonoma SDK

## 🚀 Quick Start Guide

### 1. **Basic Operation**
1. **Choose Work Area**: Select or create a work area for your current project
2. **Start Session**: Click the play button or press `Space` to begin a 25-minute focus session
3. **Take Breaks**: App automatically transitions to breaks after work sessions
4. **Track Progress**: View your statistics in real-time

### 2. **Menu Bar Setup** (Recommended)
1. Open **Settings** → **Advanced**
2. Enable **"Menu Bar App"**
3. Optionally enable **"Hide Dock Icon"** for minimal interface
4. Access timer from the 🍅 icon in your menu bar

### 3. **Daily Review Workflow**
1. Open **Review** tab or press `⌘+D`
2. Select any date from the calendar
3. View all sessions (work and break) for that day
4. **Double-click work sessions** to add reflection notes
5. Export data for external analysis if needed

### 4. **Power User Tips**
- **Global Shortcuts**: Keep app focused for `Space`, `R`, `S`, `V` shortcuts
- **Menu Bar Mode**: Right-click menu bar icon for context menu
- **Ambient Sounds**: Try different sounds to find your optimal focus environment
- **Work Areas**: Create separate areas for different projects or subjects

## 🔧 Architecture & Technical Details

### **Frontend Architecture**
- **SwiftUI**: Modern declarative UI framework for macOS
- **MVVM Pattern**: Clean separation with ViewModels for business logic
- **Combine Framework**: Reactive programming for state management
- **AppKit Integration**: NSStatusItem for menu bar functionality

### **Data & Persistence**
- **UserDefaults**: Lightweight storage for settings and session data
- **JSON Export**: Structured data export for backup and analysis
- **Memory Efficient**: Optimized for long-running background operation

### **Audio Implementation**
- **AVFoundation**: Native audio framework for sound management
- **Programmatic Generation**: Real-time ambient sound synthesis
- **Background Playback**: Continuous audio during work sessions
- **System Integration**: Proper audio session handling

### **Menu Bar Integration**
- **NSStatusItem**: Native macOS status bar integration
- **Template Images**: Automatic dark/light mode adaptation
- **Popover Interface**: Compact SwiftUI view in status bar
- **Event Handling**: Mouse and keyboard interaction support

## 📈 Version History

### v0.8.0 (Latest) - Precise Time Tracking & Overtime Mode
- ⏱️ **Precise Time Tracking**: Date.now() based calculation excludes pause time from session recording
- 🚀 **Overtime Mode**: Continue working beyond set time with separate overtime tracking
- 🎯 **Smart Notifications**: Alerts trigger only when pure work time is completed (not wall-clock time)
- 📊 **Dual Time Display**: Session format shows pure work time + overtime (e.g., "25:00 (+3:15)")
- 🔄 **Mode-Specific Controls**: Work mode supports pause/resume, break mode uses start/stop workflow
- 📈 **Enhanced Analytics**: Accurate productivity metrics with pause time exclusion

### v0.7.2 - App Restoration & Build Recovery
- 🔧 **App Recovery**: Restored missing Pomodoro.app after cleanup
- 📦 **Build Process**: Rebuilt app with all menu bar features intact
- ✅ **Functionality Verified**: All v0.7.0 features working properly
- 🚀 **Release Ready**: Complete app package available for download

### v0.7.1 - Project Cleanup & Optimization
- 🧹 **Repository Cleanup**: Removed unnecessary build artifacts and temporary files
- 📁 **File Organization**: Deleted unused icon generation scripts and build directories
- 🔧 **Development Cleanup**: Improved repository structure for better maintainability
- ⚡ **Performance**: Reduced repository size and improved clone times

### v0.7.0 - Professional README & Documentation
- 📚 **Professional Documentation**: Complete rewrite of README following GitHub best practices
- 🎯 **Clear Value Proposition**: Enhanced project description with user-focused benefits
- 📖 **Comprehensive Guide**: Added Quick Start Guide and Power User Tips
- 🏗️ **Technical Architecture**: Detailed technical documentation for developers
- 📞 **Community Support**: Added proper contact and support information
- 🎨 **Visual Enhancement**: Better organization with emojis and structured sections

### v0.6.0 - Menu Bar Integration & Enhanced Experience
- 🖥️ **Menu Bar App**: Complete status bar integration with 🍅 icon and quick controls
- 🎛️ **Custom App Menus**: Timer and Focus menus replacing standard File/Edit menus
- ⌨️ **Enhanced Shortcuts**: New keyboard shortcuts with app menu integration
- 📊 **Session Reviews**: Double-click work sessions to add individual review notes
- 🔇 **Smart Audio**: Ambient sounds only during work sessions (not breaks)
- 🐛 **Statistics Fix**: Break sessions no longer count toward productivity metrics
- 🎨 **UI Polish**: Better visual feedback and status indicators

### v0.5.3 - Data Export & Backup
- 📤 **JSON Export**: Export all review data for backup and external analysis
- 🔒 **Enhanced Security**: Proper file system permissions for data export
- 📱 **UI Improvements**: Enhanced ReviewView with export functionality

### v0.5.2 - Data Management
- 🗑️ **Smart Deletion**: Delete all reviews or specific date data with confirmation
- 🛡️ **Safe Operations**: Confirmation dialogs prevent accidental data loss
- 🔄 **Clean Reset**: Comprehensive data reset functionality

### v0.5.1 - Critical Bug Fixes
- 🔧 **App Icon Fix**: Resolved missing app icon in release builds
- 🧹 **Build Optimization**: Improved asset compilation and cache management

### v0.5.0 - Keyboard Shortcuts Foundation
- ⌨️ **Global Shortcuts**: Space, R, S, V shortcuts when app is focused
- 🎮 **Smart Detection**: Shortcuts disabled during text input
- ⚙️ **Settings Control**: Toggle shortcuts on/off in Advanced settings

## 🛠️ Development & Contributing

This project showcases modern macOS development practices and serves as a reference for:

- **SwiftUI Architecture**: MVVM pattern with proper separation of concerns
- **Menu Bar Integration**: NSStatusItem implementation with SwiftUI
- **Audio System Design**: AVFoundation integration for ambient sounds
- **Data Persistence**: UserDefaults and JSON export strategies
- **User Experience**: Native macOS design patterns and interactions

### **Development Setup**
```bash
git clone https://github.com/bitkyc05/Pomodorogo.git
cd Pomodorogo
open Pomodorogo.xcodeproj
```

### **Contributing Guidelines**
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'feat: Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Francesco Cirillo** - Creator of the Pomodoro Technique
- **Apple Developer Documentation** - SwiftUI and AppKit guidance
- **macOS Human Interface Guidelines** - Design inspiration
- **Open Source Community** - Continuous learning and inspiration

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/bitkyc05/Pomodorogo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/bitkyc05/Pomodorogo/discussions)
- **Author**: [GitHub Profile](https://github.com/bitkyc05)

---

<div align="center">

**🍅 Built with passion for productivity and focus**

*Transform your work sessions into focused, productive experiences*

[⬆ Back to top](#-pomodorogo---native-macos-pomodoro-timer)

</div>