# Go Skiing - Flutter Game

A complete Flutter skiing game app with gyroscope controls, invincibility mode, and screen recording capabilities.

## Features

- **Game Mechanics**
  - Skiing gameplay with jumping, obstacles, and coin collection
  - Gyroscope-based slope control (tilt left to slow down, tilt right to restore)
  - Speed boost on swipe down
  - Invincibility mode (long-press, consumes coins)
  - Parallax scrolling background
  - Dynamic slope rendering with tilt

- **Audio & Feedback**
  - Background music (BGM) with volume tied to game speed
  - Sound effects for jump, coin collection, and game over
  - Vibration on game start and game over

- **Screen Recording**
  - Best-effort in-app recording (captures frames to PNG sequence)
  - Graceful fallback if recording unavailable (shows "REC OFF")
  - Saves to app documents directory

- **Rankings**
  - Persistent leaderboard sorted by duration
  - Highlights latest game record
  - Stored in SharedPreferences

- **Settings**
  - Customizable skier jacket color
  - Color preference persists across sessions

## Build & Run

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / Xcode (for platform builds)
- Physical device recommended for gyroscope testing

### Setup

1. **Install dependencies:**
   ```bash
   cd go_skiing
   flutter pub get
   ```

2. **Run on device:**
   ```bash
   flutter run
   ```

   For Android:
   ```bash
   flutter run -d android
   ```

   For iOS:
   ```bash
   flutter run -d ios
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21
- Portrait orientation locked in `AndroidManifest.xml`
- Permissions for photos, vibration, and internet

#### iOS
- Minimum iOS: 12.0
- Portrait orientation locked in `Info.plist`
- Motion usage description for gyroscope
- Photo library usage description for recording export

## Assets

The app expects the following assets (placeholder images are included):

- `assets/icons/go_skiing.png` - App launcher icon
- `assets/images/home_bg.jpg` - Home page background
- `assets/images/game_bg_trees.png` - Parallax tree background (tileable)
- `assets/images/skier.png` - Skier sprite
- `assets/images/obstacle.png` - Obstacle sprite
- `assets/images/coin.png` - Coin sprite
- `assets/audio/bgm.mp3` - Background music
- `assets/audio/jump.wav` - Jump sound effect
- `assets/audio/coin.wav` - Coin collection sound
- `assets/audio/game_over.wav` - Game over sound

**Note:** Placeholder solid-color images are provided. Replace with actual game assets for production.

## Testing Interactions

### Basic Controls
- **Tap anywhere** - Jump (plays jump.wav)
- **Swipe down** - Temporary speed boost
- **Swipe left to right** - Show exit confirmation dialog
- **Long-press (hold)** - Activate invincibility mode (consumes 1 coin/second)

### Gyroscope Controls
- **Tilt device left** - Decreases slope angle, slows movement, reduces BGM volume
  - Can reach horizontal (movement stops)
- **Tilt device right** - Restores default slope angle and speed

### Game Flow
1. Enter player name on Home page
2. Tap "Start Game" (validates name)
3. Game starts with 10 coins, BGM starts, recording attempts
4. Play until collision with obstacle (or quit)
5. Game Over dialog shows stats
6. Choose "Restart" or "Go To Rankings"

### Debug Features
- Tap title "Go Skiing" 5 times on Home page to open debug panel
- Options: Reset rankings, toggle hitboxes (future)

## Screen Recording

The app implements a best-effort screen recording system:

- **Primary method:** Captures frames from RepaintBoundary at ~20 FPS
- **Export:** Saves PNG sequence to app documents directory
- **Status:** Shows "REC" when recording, "REC OFF" when unavailable
- **Limitations:**
  - Does not export directly to system gallery (requires platform channels)
  - Frames saved to: `{app_documents}/go_skiing_recording_{timestamp}/`
  - Actual MP4 muxing would require native platform code

To access recordings on Android:
- Use device file manager or ADB: `adb pull /data/data/com.example.go_skiing/app_flutter/go_skiing_recording_*`

To access recordings on iOS:
- Use Xcode Device window or iTunes File Sharing

## Known Limitations

1. **Screen Recording:** Currently saves PNG frames, not MP4 video. Full video export requires platform-specific native code.

2. **Audio Files:** Placeholder empty files are included. Replace with actual audio assets.

3. **Image Assets:** Placeholder solid-color images. Replace with actual game sprites.

4. **Gyroscope:** Requires physical device; emulators don't support motion sensors.

5. **Recording Export:** Does not automatically add to system photo gallery. Manual export required.

## Architecture

```
lib/
  main.dart              - App entry point
  app.dart               - App configuration & routing
  core/                  - Core services
    audio/               - Audio playback
    record/              - Screen recording
    sensors/             - Gyroscope handling
    storage/             - Preferences
    utils/               - Time utilities
  data/                  - Data layer
    models/              - Data models
    repositories/        - Data persistence
  game/                  - Game logic
    engine/              - Game loop, physics, spawning
    rendering/           - CustomPainter, sprites
    input/               - Gesture handling
    domain/              - Game controller, invincibility
  ui/                    - UI pages and widgets
  theme/                 - App theming
```

## Dependencies

- `provider` - State management
- `sensors_plus` - Gyroscope access
- `audioplayers` - Audio playback
- `shared_preferences` - Data persistence
- `vibration` - Haptic feedback
- `permission_handler` - Permission requests
- `path_provider` - File system access
- `image` - Image encoding (for recording)

## License

This is a complete Flutter game implementation. Use as needed.

## Support

For issues or questions, check:
- Flutter documentation: https://flutter.dev/docs
- Package documentation for each dependency
- Platform-specific setup guides in Flutter docs

