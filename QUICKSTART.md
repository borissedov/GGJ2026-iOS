# Quick Start Guide

## What's Been Implemented

✅ **Complete AR Mask Feeding Game** - All code is ready!

### Features Implemented:
1. ✅ AR Image Tracking for TV/projector screens
2. ✅ Invisible collision gate at mouth position
3. ✅ 4 physics-enabled fruit types (Banana, Peach, Coconut, Watermelon)
4. ✅ Swipe-to-throw gesture mechanics
5. ✅ Collision detection and scoring system
6. ✅ Score display UI with instructions
7. ✅ Automatic fruit respawning

### Code Structure Created:
```
✅ Entities/FruitType.swift           - Fruit properties and physics
✅ Entities/FruitEntity.swift         - 2D sprite with physics simulation
✅ Entities/MouthGateEntity.swift     - Invisible collision gate
✅ Systems/GameManager.swift          - Score tracking & collisions
✅ Systems/FruitSpawner.swift         - Fruit lifecycle management
✅ Systems/ThrowGestureHandler.swift  - Gesture recognition
✅ Views/ARImageTrackingView.swift    - AR session management
✅ ContentView.swift                  - Main UI (updated)
```

## What You Need to Do Now

### Step 1: Add Assets to Xcode (Required)

The code is ready but **needs visual assets**. You must add:

1. **AR Reference Image** - for tracking the TV/projector
   - Extract a frame from your mask animation video
   - Add to Assets.xcassets as AR Resource Group
   - **CRITICAL**: Set physical size to match your actual screen dimensions

2. **4 Fruit Sprites** - PNG images with transparency
   - Banana.imageset
   - Peach.imageset
   - Coconut.imageset
   - Watermelon.imageset

**📖 See [ASSETS_SETUP_GUIDE.md](ASSETS_SETUP_GUIDE.md) for detailed step-by-step instructions**

### Step 2: Prepare External Video

Create/obtain a looping mask animation video:
- Format: MP4, 1920×1080 or higher
- Duration: 5-15 seconds, seamless loop
- Animation: Subtle breathing/idle motion
- Play on TV/projector (not in the app)

### Step 3: Build and Test

1. Open `HungryGodMask.xcodeproj` in Xcode
2. Connect your iOS device (ARKit requires real hardware)
3. Select device as build target
4. Build & Run (⌘R)
5. Point at TV screen with mask video playing
6. Swipe fruits to throw!

## Current Status

| Component | Status |
|-----------|--------|
| Code Implementation | ✅ 100% Complete |
| Asset Integration | ⚠️ Requires manual addition in Xcode |
| Testing | ⏳ Ready to test once assets are added |

## How the Game Works

1. **Start**: Mask video loops on TV/projector
2. **Track**: App detects the screen using AR image tracking
3. **Spawn**: 4 fruits appear at bottom of screen
4. **Throw**: Swipe on fruit to throw it with physics
5. **Score**: Hit the invisible mouth gate to earn points
6. **Respawn**: Fruits respawn after scoring or going out of bounds

## Customization Options

### Adjust Mouth Position
If the collision gate isn't aligned with your mask's mouth:

1. Open `Entities/MouthGateEntity.swift`
2. Modify line 15:
   ```swift
   static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0)
   // X: left/right, Y: up/down, Z: forward/back (in meters)
   ```

### Enable Debug Mode
To see the invisible collision gate:

1. Open `Entities/MouthGateEntity.swift`
2. Uncomment line 49:
   ```swift
   addDebugVisualization()
   ```
3. Run app - you'll see a green box showing gate position

### Adjust Throwing Feel
Edit `Systems/ThrowGestureHandler.swift` lines 18-19:
```swift
private let velocityMultiplier: Float = 0.003  // Higher = faster throws
private let maxThrowVelocity: Float = 10.0     // Max speed limit
```

## Troubleshooting

### Won't detect the mask
- ✅ **FIXED**: AR reference image configuration corrected
- 📖 See [AR_TRACKING_GUIDE.md](AR_TRACKING_GUIDE.md) for detailed troubleshooting
- Check Xcode console for debug messages (should see "Loaded 1 reference images")
- Adjust physical size in Contents.json if needed (currently 0.5m × 0.5m)
- Screen brightness: 70-90%, moderate room lighting

### Fruits don't appear
- ❌ Sprites not added → Add Banana, Peach, Coconut, Watermelon to Assets.xcassets
- ❌ Wrong names → Must match exactly (capitalized)

### Can't throw fruits
- ❌ Swipe faster or directly on the fruit sprites
- ❌ Make sure tracking is active (score counter visible)

## Next Steps

1. 📁 Add assets (see ASSETS_SETUP_GUIDE.md)
2. 🎮 Build and test on device
3. 🎯 Calibrate mouth gate position if needed
4. 🎨 Optionally customize physics/throwing feel
5. 🎉 Play and enjoy!

## Support Files

- **[ASSETS_SETUP_GUIDE.md](ASSETS_SETUP_GUIDE.md)** - Detailed asset preparation instructions
- **[README.md](README.md)** - Full project documentation

---

**Ready to go!** Just add the assets and you can start playing. 🎮
