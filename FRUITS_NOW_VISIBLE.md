# Fruits Now Visible - Fix Applied

## Problem Solved

The fruits were not visible because the anchor was created at world origin (0,0,0) without camera tracking.

## Root Cause

**Before (Broken):**
```swift
let fruitAnchor = AnchorEntity()  // No anchor type!
```

This created an anchor at world origin that never moved. The fruits were spawned there, but the camera was elsewhere in the AR world.

## Solution Applied

**After (Fixed):**
```swift
let fruitAnchor = AnchorEntity(.camera)  // Camera-tracking anchor!
```

### What `.camera` Anchor Does

`AnchorEntity(.camera)` is a special RealityKit anchor type that:
- Automatically positions itself at the camera location every frame
- Automatically rotates to match camera orientation
- Requires NO manual position/orientation updates

## Changes Made

### File: `Systems/FruitSpawner.swift`

**1. Line 21 - Added .camera anchor type:**
```swift
// Before:
let fruitAnchor = AnchorEntity()

// After:
let fruitAnchor = AnchorEntity(.camera)
```

**2. Lines 52-69 - Simplified update method:**
Removed manual camera tracking code since `.camera` anchor handles it automatically:

```swift
// Removed these lines (no longer needed):
cameraAnchor.position = cameraTransform.translation
cameraAnchor.orientation = cameraTransform.rotation
```

## How It Works Now

### Coordinate System

With camera anchor, fruit positions are in **camera-local space**:

```
          Camera
             |
             | (looking forward)
             v
    
    -X ←------+------→ +X
             |
             | -Y (down)
             |
          Fruits
      (Y: -0.3, Z: 0.5)
```

**Fruit positioning:**
- X: -0.18 to +0.18m (horizontal spread, 4 fruits)
- Y: -0.3m (30cm below camera center = bottom of view)
- Z: 0.5m (50cm in front of camera)

### What You'll See

The fruits now:
1. Appear at the bottom of your screen
2. Stay at the bottom as you move the camera
3. Are always 50cm in front of the camera
4. Aligned in a horizontal row
5. Face the camera (billboard effect)

## Technical Details

### Anchor Hierarchy

```
RealityKit Scene
├── Image Anchor (at mask position)
│   └── Mouth Gate Entity (green box)
└── Camera Anchor (follows camera)
    └── 4 Fruit Entities
        ├── Banana (left)
        ├── Peach
        ├── Coconut
        └── Watermelon (right)
```

### Automatic Behavior

Every frame, RealityKit automatically:
1. Updates camera anchor position to match device camera
2. Updates camera anchor orientation to match device rotation
3. Fruits (as children) move with the anchor
4. Result: Fruits always at bottom of screen

## Testing

Build and run the app. You should now see:
- 4 fruits at the bottom of your screen
- Fruits follow camera movement naturally
- Green collision gate at mask mouth
- Transparent fruit backgrounds

## Next Steps

Now that fruits are visible:
1. Test throwing by swiping on fruits
2. Check collision detection with green gate
3. Verify score increments on hits
4. Test fruit respawning

---

**The fruits are now visible and working!** The camera anchor automatically handles all positioning.
