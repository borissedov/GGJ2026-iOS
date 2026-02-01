# HungryGodMask

An AR game for Global Game Jam 2026 where players throw fruits into an animated mask's mouth displayed on a TV/projector.

## Game Concept

- **AR Image Tracking**: Track an animated mask displayed on a TV/projector screen
- **Physics-Based Throwing**: Swipe to throw fruits with realistic physics
- **Collision Detection**: Score points by hitting the invisible mouth gate
- **Multiplayer**: Work together with other players to fulfill orders

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

See **[MULTIPLAYER_SETUP.md](MULTIPLAYER_SETUP.md)** for detailed deployment and connection instructions.

## Project Structure

```
HungryGodMask/
├── AppDelegate.swift
├── ContentView.swift           # Main entry view
├── Views/
│   ├── ARImageTrackingView.swift # AR view & session management
│   ├── WelcomeView.swift       # Initial landing screen
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
│   ├── FruitSpawner.swift      # Fruit lifecycle management
│   └── ThrowGestureHandler.swift # Gesture → physics
└── Assets.xcassets/
    ├── AR Resources.arresourcegroup/
    └── [Fruit sprites]
```

## Building and Running

1.  Open `HungryGodMask.xcodeproj` in Xcode.
2.  Ensure you have the SignalR Swift package added (see `MULTIPLAYER_SETUP.md`).
3.  Connect your iOS device.
4.  Select your device as the build target.
5.  Build and Run (⌘R).

## Playing the Game

1.  **Join a Room**: Scan the QR code on the Host Display or enter the code manually.
2.  **Lobby**: Wait for other players and tap "Ready".
3.  **AR Mode**: When the game starts, point your camera at the TV screen showing the mask.
4.  **Throw**: Swipe on the fruits at the bottom of your screen to throw them into the mask's mouth.
5.  **Collaborate**: Work with your team to fulfill the orders displayed on the screen!

## Customization

### Adjust Mouth Gate Position
Edit `Entities/MouthGateEntity.swift`:
```swift
static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0)  // X, Y, Z in meters
```

### Adjust Fruit Physics
Edit values in `Entities/FruitType.swift`:
- `size`: Physical dimensions
- `mass`: Weight for throw physics

### Tune Throwing Feel
Edit `Systems/ThrowGestureHandler.swift`:
```swift
private let velocityMultiplier: Float = 0.003
private let maxThrowVelocity: Float = 10.0
```

## Documentation

- **[MULTIPLAYER_README.md](MULTIPLAYER_README.md)** - Overview of the multiplayer architecture
- **[MULTIPLAYER_SETUP.md](MULTIPLAYER_SETUP.md)** - Detailed setup guide
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - High-level architectural overview
- **[GAME_DESCRIPTION.md](GAME_DESCRIPTION.md)** - Game design document

## Credits

Created for Global Game Jam 2026
