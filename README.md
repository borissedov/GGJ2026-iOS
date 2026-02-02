# HungryGodMask

An AR game for Global Game Jam 2026 where players throw fruits into an animated mask's mouth displayed on a TV/projector.

## Game Concept

- **AR Image Tracking**: Track an animated mask displayed on a TV/projector screen
- **Physics-Based Throwing**: Swipe to throw fruits with realistic physics
- **Sound Effects**: Audio feedback for touch, throw, hit, and miss
- **Dynamic Fruit Panel**: Randomized fruit order for each order
- **Collision Detection**: Score points by hitting the invisible mouth gate
- **Multiplayer**: Work together with other players to fulfill orders with player names
- **Visual Enhancements**: Screen frame overlay, How To Play guide, About screen

## Setup Requirements

### Hardware
- iOS device with ARKit support (iPhone 6s or later)
- TV, projector, or large screen (for the Host Display)
- Internet connection

### Software
- Xcode 14.0+
- iOS 15.0+

## Multiplayer Setup

This app is designed to work with the **Oh My Hungry God** multiplayer system.

1.  **Host Display**: Runs on a web browser (TV/Projector).
2.  **Backend**: .NET 9 server managing game state.
3.  **iOS Client**: This app, connecting via SignalR.

See **[MULTIPLAYER_SETUP.md](https://github.com/borissedov/GGJ2026/blob/main/MULTIPLAYER_SETUP.md)** for detailed deployment and connection instructions.

## Project Structure

```
HungryGodMask/
├── AppDelegate.swift
├── ContentView.swift           # Main entry view with frame overlay
├── Views/
│   ├── ARImageTrackingView.swift # AR view & session management
│   ├── WelcomeView.swift       # Welcome with How To Play & Share
│   ├── AboutView.swift         # About screen with GGJ info
│   ├── VideoSplashView.swift   # Intro video
│   ├── QRScannerView.swift     # Scanner for joining rooms
│   ├── PlayerNameView.swift    # Name entry
│   └── Multiplayer/
│       ├── LobbyView.swift     # Waiting room UI
│       └── OrderOverlayView.swift # In-game order UI
├── Networking/
│   ├── SignalRClient.swift     # WebSocket connection manager
│   └── Events/                 # Network event models
├── Entities/
│   ├── FruitType.swift         # Enum with physics properties
│   ├── FruitEntity.swift       # 2D sprite with physics
│   └── MouthGateEntity.swift   # Invisible collision gate
├── Systems/
│   ├── GameManager.swift       # Game logic & state management
│   ├── FruitSpawner.swift      # Fruit lifecycle with randomization
│   ├── ThrowGestureHandler.swift # Gesture → physics
│   └── SoundManager.swift      # Audio playback for sound effects
├── Sounds/                     # Sound effect files
│   ├── touch.mp3
│   ├── throw.mp3
│   ├── hit.mp3
│   └── miss.mp3
└── Assets.xcassets/
    ├── AR Resources.arresourcegroup/
    ├── Logo.imageset/
    ├── ScreenFrame.imageset/   # Leaves border overlay
    └── [Fruit sprites]
```

## Building and Running

1.  Open `HungryGodMask.xcodeproj` in Xcode.
2.  Ensure you have the SignalR Swift package added (see `MULTIPLAYER_SETUP.md`).
3.  Connect your iOS device.
4.  Select your device as the build target.
5.  Build and Run (⌘R).

## Playing the Game

1.  **Welcome**: Read "How To Play" guide and optionally share host URL to TV/projector.
2.  **Join a Room**: Scan the QR code on the Host Display or enter the code manually.
3.  **Enter Name**: Provide your player name for the leaderboard.
4.  **Lobby**: Wait for other players and tap "Ready".
5.  **AR Mode**: When the 6-second countdown completes, point your camera at the TV screen showing the mask.
6.  **Throw**: Swipe on the randomized fruits at the bottom of your screen to throw them into the mask's mouth.
7.  **Listen**: Enjoy sound effects for touch, throw, hit, and miss!
8.  **Results**: View your individual contribution and team stars.
9.  **Restart**: Tap "Play Again" to start a new game!

## Customization

### AR Coordinates and Positioning

See **[AR_COORDINATES_GUIDE.md](AR_COORDINATES_GUIDE.md)** for comprehensive guide on:
- ARKit coordinate system explained
- How gate positioning works
- Tuning gate size and position
- Throw gesture calculations
- Troubleshooting tracking and collision issues

### Quick Adjustments

**Mouth Gate Position** (`Entities/MouthGateEntity.swift`):
```swift
static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0.05)  // X, Y, Z in meters
// Y: negative = down, positive = up
// Z: distance from screen surface
```

**Gate Size** (if missing hits):
```swift
static let gateWidth: Float = 0.25   // Horizontal width
static let gateHeight: Float = 0.20  // Vertical height
static let gateDepth: Float = 0.15   // Forward depth
```

**Throw Sensitivity** (`Systems/ThrowGestureHandler.swift`):
```swift
private let velocityMultiplier: Float = 0.003  // Higher = more sensitive
private let maxThrowVelocity: Float = 10.0     // Maximum throw speed
```

## Assets Required

Place in `Assets.xcassets/`:
- **Logo.imageset**: Game logo for About screen
- **ScreenFrame.imageset**: Leaves border overlay PNG

Place in `Sounds/` folder:
- `touch.mp3` - Touch sound effect
- `throw.mp3` - Throw sound effect
- `hit.mp3` - Hit sound effect
- `miss.mp3` - Miss sound effect

## Documentation

- **[AR_COORDINATES_GUIDE.md](AR_COORDINATES_GUIDE.md)** - AR coordinate system, positioning, and troubleshooting
- **[MULTIPLAYER_README.md](https://github.com/borissedov/GGJ2026/blob/main/MULTIPLAYER_README.md)** - Overview of the multiplayer architecture
- **[ARCHITECTURE.md](https://github.com/borissedov/GGJ2026/blob/main/ARCHITECTURE.md)** - High-level architectural overview
- **[GAME_DESCRIPTION.md](https://github.com/borissedov/GGJ2026/blob/main/GAME_DESCRIPTION.md)** - Game design document

## Credits

Created for Global Game Jam 2026
