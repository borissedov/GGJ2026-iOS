# HungryGodMask

An AR game for Global Game Jam 2026 where players throw fruits into an animated mask's mouth displayed on a TV/projector.

## Game Concept

- **AR Image Tracking**: Track an animated mask displayed on a TV/projector screen
- **Physics-Based Throwing**: Swipe to throw fruits with realistic physics
- **Collision Detection**: Score points by hitting the invisible mouth gate
- **4 Fruit Types**: Banana, Peach, Coconut, Watermelon (each with unique mass/size)

## Setup Requirements

### Hardware
- iOS device with ARKit support (iPhone 6s or later)
- TV, projector, or large screen
- Device to play mask animation video (laptop, Apple TV, etc.)

### Software
- Xcode 14.0+
- iOS 15.0+

### Assets Needed
1. Mask animation video (MP4, looping)
2. AR reference image (extracted from video frame)
3. 4 fruit sprite images (PNG with transparency)

**See [ASSETS_SETUP_GUIDE.md](ASSETS_SETUP_GUIDE.md) for detailed instructions**

## How It Works

### Architecture
```
TV/Projector (Mask Video) 
    ↓ (tracked by)
ARKit Image Tracking
    ↓
Invisible Collision Gate (at mouth position)
    ↓
Physics Simulation (fruits + throwing)
    ↓
Score on successful hits
```

### Key Components

- **ARImageTrackingView**: Manages AR session and image tracking
- **MouthGateEntity**: Invisible collision trigger at mouth location
- **FruitEntity**: Physics-enabled 2D sprites with billboarding
- **FruitSpawner**: Manages fruit spawning and respawning
- **ThrowGestureHandler**: Converts swipe gestures to physics impulses
- **GameManager**: Collision detection and score tracking

## Project Structure

```
HungryGodMask/
├── AppDelegate.swift
├── ContentView.swift (Main UI with score overlay)
├── Views/
│   └── ARImageTrackingView.swift
├── Entities/
│   ├── FruitType.swift (Enum with physics properties)
│   ├── FruitEntity.swift (2D sprite with physics)
│   └── MouthGateEntity.swift (Invisible collision gate)
├── Systems/
│   ├── GameManager.swift (Score tracking & collision)
│   ├── FruitSpawner.swift (Fruit lifecycle management)
│   └── ThrowGestureHandler.swift (Gesture → physics)
└── Assets.xcassets/
    ├── AR Resources.arresourcegroup/
    └── [Fruit sprites]
```

## Building and Running

1. Complete asset setup (see ASSETS_SETUP_GUIDE.md)
2. Open `HungryGodMask.xcodeproj` in Xcode
3. Connect iOS device
4. Select your device as the build target
5. Build and Run (⌘R)

## Playing the Game

1. Start mask video playing on TV/projector (looping)
2. Launch app on iOS device
3. Point camera at TV screen showing the mask
4. Wait for tracking to activate (score counter appears)
5. See 4 fruits at bottom of screen
6. Swipe on a fruit to throw it
7. Aim for the mask's mouth to score points!

## Customization

### Adjust Mouth Gate Position
Edit `Entities/MouthGateEntity.swift`:
```swift
static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0)  // X, Y, Z in meters
```

### Adjust Gate Size
```swift
static let gateWidth: Float = 0.15   // 15cm
static let gateHeight: Float = 0.10  // 10cm
```

### Enable Debug Visualization
In `MouthGateEntity.swift`, uncomment line 49:
```swift
addDebugVisualization()  // Shows green box at gate location
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

## Troubleshooting

### AR Image Tracking Issues
See [AR_TRACKING_GUIDE.md](AR_TRACKING_GUIDE.md) for:
- Debug console output interpretation
- Physical size calibration
- Optimal lighting and screen setup
- Common tracking problems and solutions

### Asset Setup
See [ASSETS_SETUP_GUIDE.md](ASSETS_SETUP_GUIDE.md) for sprite and reference image preparation.

## Technical Details

- **AR Framework**: ARKit with ARImageTrackingConfiguration
- **3D Engine**: RealityKit with physics simulation
- **UI**: SwiftUI overlays on AR view
- **Physics**: Dynamic rigid bodies with collision detection
- **Gesture Recognition**: UIPanGestureRecognizer

## Development Notes

### Animation Handling
The mask video has subtle animation (~1-3cm movement). The collision gate uses a fixed position with slightly oversized dimensions (1.2× mouth size) to account for drift. ARKit continuously re-tracks, so minor position drift is acceptable.

### Performance Optimizations
- Maximum 4 active fruits (one per type)
- Simple sphere collision shapes
- Automatic despawn at 3m distance
- Billboard rendering for 2D sprites

## Documentation

- **[AR_TRACKING_GUIDE.md](AR_TRACKING_GUIDE.md)** - AR image tracking troubleshooting and debug guide
- **[ASSETS_SETUP_GUIDE.md](ASSETS_SETUP_GUIDE.md)** - Asset preparation instructions
- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide

## Credits

Created for Global Game Jam 2026
