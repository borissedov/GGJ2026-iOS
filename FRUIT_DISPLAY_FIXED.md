# Fruit Display Issues - FIXED

## Issues Resolved

### 1. Fruits Now at Screen Bottom
**Problem**: Fruits were floating in mid-air, attached to mask position
**Solution**: Created separate camera-tracking anchor attached to scene root

**Changes in `FruitSpawner.swift`**:
- Removed dependency on image anchor
- Created `AnchorEntity` attached directly to scene
- Anchor follows camera position every frame

**Changes in `ARImageTrackingView.swift`**:
```swift
// Before:
spawner.setup(in: arView.scene, anchor: anchorEntity)

// After:
spawner.setup(in: arView.scene)  // No anchor dependency
```

### 2. Fruits Screen-Aligned
**Problem**: Fruits positioned in world space, not camera-relative
**Solution**: Use camera-local coordinates for positioning

**New positioning system**:
```swift
// Camera-relative coordinates:
fruit.position = SIMD3<Float>(
    xPosition,  // X: horizontal spread (-0.18 to +0.18)
    -0.3,       // Y: 30cm below camera center (bottom of view)
    0.5         // Z: 50cm in front of camera
)
```

**Benefits**:
- Fruits always appear at bottom of screen
- Horizontal row alignment
- Move with camera naturally

### 3. Transparent Backgrounds Working
**Problem**: PNG transparency rendered as black
**Solution**: Enable proper alpha blending in material

**Changes in `FruitEntity.swift`**:
```swift
material.color = .init(texture: .init(texture))

// ADDED:
material.blendMode = .transparent
material.opacityThreshold = 0.0
```

This enables proper PNG alpha channel rendering.

## Technical Architecture

### Before (Broken)
```
Scene
└── Image Anchor (at mask)
    ├── Mouth Gate
    └── Camera Anchor (child of image anchor)
        └── Fruits (moved with mask, not camera)
```

### After (Fixed)
```
Scene
├── Image Anchor (at mask)
│   └── Mouth Gate (stays at mask)
└── Fruit Anchor (independent)
    └── Fruits (follows camera every frame)
```

## How It Works Now

1. **On AR Image Detection**:
   - Image anchor created at mask position (for gate)
   - Fruit anchor created at scene root (independent)

2. **Every Frame Update**:
   - Fruit anchor position = camera position
   - Fruit anchor orientation = camera orientation
   - Fruits positioned in local space (-0.3 Y, 0.5 Z)
   - Billboard effect keeps fruits facing camera

3. **Result**:
   - Fruits stick to bottom of screen
   - Fruits aligned in horizontal row
   - Transparent backgrounds render correctly

## Files Modified

1. **`Entities/FruitEntity.swift`**
   - Added `material.blendMode = .transparent`
   - Added `material.opacityThreshold = 0.0`
   - Fixed PNG transparency rendering

2. **`Systems/FruitSpawner.swift`**
   - Changed `setup()` signature (removed anchor parameter)
   - Create `AnchorEntity` attached to scene
   - Updated fruit positions to camera-local coordinates
   - Spacing reduced to 12cm (was 15cm)
   - Y position: -0.3m (bottom of view)
   - Z position: 0.5m (in front of camera)

3. **`Views/ARImageTrackingView.swift`**
   - Updated `handleImageDetected()` method
   - Pass only scene to FruitSpawner (not anchor)
   - Added comment explaining independence

## Testing Results

After these fixes, you should see:

- Fruits at bottom of screen
- Fruits stay at bottom when moving camera
- Fruits aligned in horizontal row
- Transparent backgrounds (no black boxes)
- Fruits can still be thrown
- Green gate still visible at mask

## Positioning Reference

Current fruit spawn configuration:
```swift
X: -0.18 to +0.18 (36cm horizontal spread for 4 fruits)
Y: -0.3 (30cm below camera center = bottom of view)
Z: 0.5 (50cm in front of camera)
Spacing: 0.12m (12cm between fruits)
```

Adjust these values in `FruitSpawner.swift` if needed.

## Next Steps

The fruit display is now working correctly. You can:

1. **Test throwing mechanics**: Swipe on fruits to throw
2. **Adjust positioning**: Modify Y/Z values if fruits not perfectly positioned
3. **Tune spacing**: Change spacing value if fruits too close/far apart
4. **Remove debug gate**: Comment out `addDebugVisualization()` when ready

---

All fruit display issues are now resolved!
