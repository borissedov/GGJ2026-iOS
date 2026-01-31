# Fruit Visibility Debugging

## Changes Applied

### 1. Added Comprehensive Debug Logging
All fruit-related operations now log to console with 🍎 prefix for easy filtering.

### 2. Made Fruits 3x Larger
Temporary size increase to make them impossible to miss if they exist.

### 3. Bright Fallback Colors
Using solid colors (yellow, orange, brown, green) instead of textures for maximum visibility.

### 4. World Anchor with Manual Tracking
Changed from `.camera` anchor to `.world` anchor with manual position updates.

### 5. Simplified Billboard Effect
Using RealityKit's built-in `look(at:from:relativeTo:)` method.

### 6. Delayed Spawning
Fruits spawn 0.5 seconds after image detection to ensure camera is ready.

## Expected Console Output

When you run the app and point at the mask, you should see:

```
🍎 DEBUG: Image detected, setting up AR content
🍎 DEBUG: Mouth gate created
[0.5 second delay]
🍎 DEBUG: Initializing fruit spawner...
🍎 DEBUG: Setting up fruit spawner
🍎 DEBUG: Fruit anchor created at position: (0.0, 0.0, 0.0)
🍎 DEBUG: Creating banana model, size: 0.24
🍎 DEBUG: Created bright banana sprite
🍎 DEBUG: Spawned banana at local position (-0.18, -0.3, 0.5)
🍎 DEBUG: Creating peach model, size: 0.18
🍎 DEBUG: Created bright peach sprite
🍎 DEBUG: Spawned peach at local position (-0.06, -0.3, 0.5)
🍎 DEBUG: Creating coconut model, size: 0.36
🍎 DEBUG: Created bright coconut sprite
🍎 DEBUG: Spawned coconut at local position (0.06, -0.3, 0.5)
🍎 DEBUG: Creating watermelon model, size: 0.75
🍎 DEBUG: Created bright watermelon sprite
🍎 DEBUG: Spawned watermelon at local position (0.18, -0.3, 0.5)
🍎 DEBUG: Spawned 4 fruits
🍎 DEBUG: Fruit spawner setup complete
```

## What You Should See

After the console messages:
- **4 large colored circles** at bottom of screen
- Yellow (banana), Orange (peach), Brown (coconut), Green (watermelon)
- Aligned horizontally in a row
- Each circle is 3x larger than normal (24cm, 18cm, 36cm, 75cm)

## Troubleshooting

### If Console Shows Nothing
- Image detection not working
- Check AR tracking is active (score counter visible?)

### If Console Shows "Image detected" but No Fruit Messages
- Spawner not being called
- Check the 0.5 second delay timing

### If All Debug Messages Appear but No Fruits Visible
**This means:**
- Fruits ARE being created
- Fruits ARE positioned
- BUT: They're not visible to camera

**Possible causes:**
1. Position is behind camera (Z should be positive, forward)
2. Fruits too small (now 3x larger, so unlikely)
3. Material issue (using solid colors, so unlikely)
4. Anchor positioning issue

**Next diagnostic step:**
Check the actual world positions by adding to `updateFruitPositions`:

```swift
// Add this line temporarily:
print("🍎 Fruit world positions: \(fruits.map { "\($0.key.rawValue): \($0.value.position(relativeTo: nil))" })")
```

### If Fruits Appear But Wrong Location
Adjust these values in `FruitSpawner.swift`:
```swift
fruit.position = SIMD3<Float>(
    xPosition,  // X: horizontal spread
    -0.3,       // Y: Try -0.2, -0.4, -0.5
    0.5         // Z: Try 0.3, 0.6, 0.8
)
```

## Current Configuration

- **Size multiplier**: 3x (temporary)
- **Spacing**: 12cm between fruits
- **Y position**: -0.3m (below camera)
- **Z position**: 0.5m (in front of camera)
- **Anchor type**: World anchor with manual tracking
- **Materials**: Solid bright colors (no textures yet)

## What to Report Back

Please copy and paste the fruit-related console output (all lines with 🍎) so I can diagnose further.

Look for:
1. Did all 4 fruits spawn?
2. What are their positions?
3. Any error messages?

## Quick Visual Check

Even if positioned wrong, the fruits should be SOMEWHERE in 3D space. Try:
- Moving the camera around
- Looking up/down/left/right
- Moving closer/farther from mask

The bright large colored circles should be visible somewhere if they exist.

---

**Build and run the app, then report the console output with 🍎 symbols.**
