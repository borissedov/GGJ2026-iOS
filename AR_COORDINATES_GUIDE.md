# AR Coordinate System & Implementation Guide

Technical guide for understanding the AR coordinate system and implementation decisions in HungryGodMask.

## ARKit Coordinate System Basics

### World Coordinate System

ARKit uses a **right-handed coordinate system** in meters:

```
       Y (Up)
       |
       |
       |______ X (Right)
      /
     /
    Z (Forward/Toward Camera)
```

**Important:** Z is **forward** (toward the camera), **not away from it**.

### In Practice for iPhone Portrait Mode

When holding the phone in portrait orientation and pointing at a TV:

- **X axis**: Horizontal (left/right on screen)
  - Positive X = Right
  - Negative X = Left

- **Y axis**: Vertical (up/down on screen)
  - Positive Y = Up
  - Negative Y = Down

- **Z axis**: Depth (perpendicular to screen)
  - Positive Z = Toward camera (out of screen)
  - Negative Z = Away from camera (into screen)

---

## AR Image Tracking

### How It Works

1. ARKit detects the reference image on the TV/projector
2. Creates an `ARImageAnchor` at the detected position
3. Provides a 4x4 transformation matrix describing:
   - Position (translation)
   - Rotation (orientation)
   - Scale (image size in world space)

### Image Anchor Coordinate Frame

The anchor is placed at the **center of the detected image** with:
- X axis: Horizontal across image
- Y axis: Vertical across image  
- Z axis: Perpendicular to image plane (points **toward** camera)

---

## Component Positioning

### 1. Mouth Gate Entity

**Location:** `Entities/MouthGateEntity.swift`

#### Current Configuration

```swift
static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0.05)
static let gateWidth: Float = 0.25   // X axis - 25cm wide
static let gateHeight: Float = 0.20  // Y axis - 20cm tall
static let gateDepth: Float = 0.15   // Z axis - 15cm deep
```

#### Why These Values?

**Offset Explanation (SIMD3<Float>(X, Y, Z)):**
- **X = 0**: Centered horizontally on the image
- **Y = -0.05**: **5cm DOWN** from image center (mouth is in lower half of mask)
  - Negative Y moves DOWN in the image coordinate frame
  - Positive Y would move UP
- **Z = 0.05**: **5cm FORWARD** from the screen surface (toward camera)
  - This creates a "catch zone" in front of the screen
  - Fruits passing through this zone trigger collision

**Size Explanation (RealityKit generateBox parameters):**
- **Width = 25cm**: Maps to **X axis** - horizontal coverage across screen
- **Height = 20cm**: Maps to **Y axis** - vertical coverage up/down screen
- **Depth = 15cm**: Maps to **Z axis** - forward/back from screen surface
  - Creates a 15cm deep zone extending from the screen
  - Gives fruits time to be detected as they pass through

**Important:** In RealityKit's `generateBox(width:height:depth:)`:
- width → X axis
- height → Y axis
- depth → Z axis

**Visual Representation:**

```
        Screen Surface
        |
        |    [===Gate===]  <-- 15cm deep zone
        |    [           ]      5cm forward from screen
        |    [  Mouth    ]      5cm down from center
        |    [           ]
        |
```

#### Calibration Tips

If the gate seems misaligned:

1. **Vertical adjustment** (Y): Mouth higher/lower than expected
   ```swift
   static let defaultMouthOffset = SIMD3<Float>(0, -0.08, 0.05)  // Lower
   static let defaultMouthOffset = SIMD3<Float>(0, -0.02, 0.05)  // Higher
   ```

2. **Horizontal adjustment** (X): Gate left/right of mouth
   ```swift
   static let defaultMouthOffset = SIMD3<Float>(0.03, -0.05, 0.05)  // Slightly right
   static let defaultMouthOffset = SIMD3<Float>(-0.03, -0.05, 0.05) // Slightly left
   ```

3. **Forward/back** (Z): Gate too far forward or embedded in screen
   ```swift
   static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0.08)  // Further from screen
   static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0.02)  // Closer to screen
   ```

4. **Size adjustment**: Increase if missing hits
   ```swift
   static let gateWidth: Float = 0.30   // Wider (X axis)
   static let gateHeight: Float = 0.25  // Taller (Y axis)
   static let gateDepth: Float = 0.20   // Deeper (Z axis)
   ```

---

### 2. Fruit Panel (Bottom Thumbnails)

**Location:** `Systems/FruitSpawner.swift`

#### Camera-Relative Positioning

The fruit panel follows the camera and stays at the bottom of the screen.

**Key Concept:** Panel is positioned **relative to camera**, not the image anchor.

#### Camera Transform Vectors

```swift
let cameraForward = -columns.2  // -Z column (forward from camera)
let cameraRight = columns.0      // X column (right in camera space)
let cameraUp = columns.1         // Y column (up in camera space)
```

**In Portrait Mode:**
- `cameraUp` = Screen horizontal (left/right of screen)
- `cameraRight` = Screen vertical (up/down of screen)
- `cameraForward` = Out from screen toward scene

#### Panel Position Formula

```swift
let forwardOffset = cameraForward * 0.25      // 25cm in front of camera
let horizontalOffset = cameraUp * xOffset     // Spread left-right
let verticalOffset = cameraRight * 0.12       // Move DOWN on screen
let worldPosition = cameraPosition + forwardOffset + horizontalOffset + verticalOffset
```

**Why These Values?**
- **0.25m forward**: Close enough to see clearly, far enough to not clip
- **0.12m down** (cameraRight): Bottom of screen in portrait mode
- **xOffset varies**: Spreads fruits horizontally (4cm spacing)

#### Portrait Mode Quirk

On iOS in portrait orientation:
- Phone's physical UP = `cameraRight` (positive direction)
- Phone's physical RIGHT = `cameraUp` (positive direction)
- This is because the camera sensor is landscape-oriented

---

### 3. Throw Gesture

**Location:** `Systems/ThrowGestureHandler.swift`

#### Screen Touch to 3D Velocity

**Challenge:** Convert 2D screen swipe velocity to 3D world velocity.

#### Algorithm

```swift
// 1. Get 2D screen velocity from gesture
let screenVelocity = gesture.velocity(in: arView)  // CGPoint (x, y)

// 2. Map to camera space
let horizontalVelocity = cameraUp * Float(screenVelocity.x) * velocityMultiplier
let verticalVelocity = cameraRight * Float(screenVelocity.y) * velocityMultiplier

// 3. Add forward component (toward TV)
let forwardVelocity = cameraForward * 3.0

// 4. Combine and clamp
var totalVelocity = horizontalVelocity + verticalVelocity + forwardVelocity
if speed > maxThrowVelocity {
    totalVelocity = normalize(totalVelocity) * maxThrowVelocity
}
```

#### Parameters

```swift
private let velocityMultiplier: Float = 0.003  // Scale down touch velocity
private let maxThrowVelocity: Float = 10.0     // Max 10 m/s
```

**Why multiply by 0.003?**
- Screen velocity is in points/second (~1000-5000 for fast swipe)
- Need to convert to meters/second (1-5 m/s is realistic throw speed)
- 0.003 scales appropriately

**Why 3.0 m/s forward velocity?**
- Ensures fruits always travel toward the TV
- Without this, sideways swipes wouldn't reach the screen
- Can be adjusted for faster/slower throws

---

## Implementation Decisions

### Why World Anchor Instead of Image Anchor?

**Decision:** Use `AnchorEntity(world: .zero)` positioned at image location, not `AnchorEntity(.image(imageAnchor))`.

**Reason:**
1. ARKit can remove image anchors when tracking is lost
2. World anchor persists even when image isn't visible
3. Manually update world anchor position when image is tracked
4. Gate stays in last known position during brief tracking losses

**Code:**
```swift
let anchorEntity = AnchorEntity(world: .zero)
anchorEntity.transform = Transform(matrix: imageAnchor.transform)
```

### Why Billboard Sprites?

**Decision:** Fruits always face the camera (2D sprites, not 3D models).

**Reason:**
1. Simpler to create (just PNG images)
2. Better performance (no 3D rendering)
3. Look consistent from any angle
4. Easier to recognize at a glance

**Implementation:**
```swift
let awayFromCamera = worldPosition + (worldPosition - cameraPosition)
fruit.look(at: awayFromCamera, from: worldPosition, relativeTo: nil)
```

This makes the sprite's -Z axis point toward camera (sprite faces camera).

### Why Two Fruit Sizes?

**Decision:** Thumbnails (4cm) in panel, expand to full size (10-25cm) when thrown.

**Reason:**
1. **Thumbnails** are compact and fit in bottom panel
2. **Full size** makes thrown fruits visible and easier to track in flight
3. Creates satisfying "expansion" animation on throw
4. Physics collision uses appropriate size for each state

**State Management:**
```swift
var isExpanded: Bool  // Tracks current size state
func expandAndThrow(velocity:)  // Switches to full size + dynamic physics
func resetToThumbnail()         // Returns to panel size + kinematic physics
```

---

## Common Issues & Solutions

### Fruits Not Hitting Gate

**Symptoms:** Fruits pass through without collision detection.

**Check:**
1. Gate position relative to image:
   ```swift
   print("Gate position: \(mouthGate.position)")
   print("Image position: \(imageAnchor.transform.translation)")
   ```

2. Fruit velocity direction:
   ```swift
   print("Throw velocity: \(velocity)")
   // Should have negative Z component to go toward TV
   ```

3. Enable debug visualization:
   ```swift
   // In MouthGateEntity.swift
   addDebugVisualization()  // Shows green semi-transparent box
   ```

### Panel Not Following Camera

**Symptoms:** Fruits stay in one place instead of moving with view.

**Check:**
1. Update loop is running:
   ```swift
   print("Update frame called")  // In ARImageTrackingView.updateFrame()
   ```

2. Camera transform is valid:
   ```swift
   print("Camera position: \(cameraTransform.translation)")
   ```

### Throws Going Wrong Direction

**Symptoms:** Swipe up but fruit goes down, etc.

**Likely Cause:** Portrait mode orientation mapping.

**Solution:** The current implementation accounts for this:
- Screen X → `cameraUp` (horizontal movement)
- Screen Y → `cameraRight` (vertical movement)

**Test:** Try landscape mode to see if it improves (may need different mapping).

### Tracking Frequently Lost

**Symptoms:** Green "Point camera..." message appears frequently.

**Solutions:**
1. **Better lighting** on the TV screen
2. **Increase reference image size** in Assets.xcassets
3. **Reduce screen brightness** (too bright can wash out features)
4. **Steady hands** (phone movement causes tracking loss)
5. **Physical size calibration** in AR Resources:
   ```
   Assets.xcassets/AR Resources.arresourcegroup/MaskReference.arreferenceimage/
   Set physical size to actual TV display size
   ```

---

## Physics Configuration

### Collision Categories

**Bit masks** for collision filtering:

```swift
// Fruits
group: 1 << 1  (binary: 0010)
mask:  1 << 2  (binary: 0100) - collides with gate

// Gate
group: 1 << 2  (binary: 0100)
mask:  1 << 1  (binary: 0010) - collides with fruits
```

This ensures:
- ✅ Fruits collide with gate
- ❌ Fruits don't collide with each other
- ❌ Gate doesn't collide with gate (only one anyway)

### Physics Modes

**Kinematic** (Panel state):
- Not affected by gravity
- Position controlled by code
- No physics simulation

**Dynamic** (Thrown state):
- Affected by gravity
- Affected by velocity/impulse
- Full physics simulation
- Automatically despawns >3m from camera

---

## Tuning Guide

### Make Throws Easier to Hit

1. **Increase gate size:**
   ```swift
   static let gateWidth: Float = 0.35   // Even wider
   static let gateDepth: Float = 0.25   // Deeper catch zone
   ```

2. **Increase forward velocity:**
   ```swift
   let forwardVelocity = cameraForward * 5.0  // Faster toward screen
   ```

3. **Move gate forward:**
   ```swift
   static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0.10)  // Further out
   ```

### Make Throws Feel Better

1. **Faster response:**
   ```swift
   private let velocityMultiplier: Float = 0.005  // More sensitive
   ```

2. **Stronger throws:**
   ```swift
   private let maxThrowVelocity: Float = 15.0  // Higher max speed
   ```

3. **More arc:**
   ```swift
   let forwardVelocity = cameraForward * 2.0  // Less forward
   // Gravity will create more arc
   ```

### Adjust Panel Position

**Lower on screen:**
```swift
let verticalOffset = cameraRight * 0.15  // Further down
```

**Closer to camera:**
```swift
let forwardOffset = cameraForward * 0.20  // Closer
```

**Wider spacing:**
```swift
let spacing: Float = 0.06  // 6cm between fruits
```

---

## Debug Commands

### Print Coordinate Information

Add to `ARImageTrackingView.swift`:

```swift
// In handleImageDetected:
print("🍎 Image at: \(imageAnchor.transform.translation)")
print("🍎 Image rotation: \(imageAnchor.transform.rotation)")
print("🍎 Gate offset: \(MouthGateEntity.defaultMouthOffset)")
print("🍎 Final gate position: \(gate.position(relativeTo: nil))")
```

### Print Throw Information

Add to `ThrowGestureHandler.swift`:

```swift
// In handleGestureEnded:
print("🎯 Screen velocity: \(velocity)")
print("🎯 3D velocity: \(throwVelocity)")
print("🎯 Camera forward: \(forward)")
print("🎯 Fruit start position: \(fruit.position)")
```

### Print Collision Information

Already enabled in `GameManager.swift`:

```swift
print("💥 Collision detected: \(type(of: entityA)) vs \(type(of: entityB))")
print("💥 Fruit-Gate collision! Fruit: \(fruit.fruitType)")
```

---

## Advanced: Manual Gate Positioning

If you need to manually adjust the gate during runtime:

```swift
// In GameManager or ARImageTrackingView
let customOffset = SIMD3<Float>(0, -0.08, 0.10)  // Your values
mouthGate?.updateOffset(customOffset)
```

For dynamic adjustment based on user input or calibration UI, you could:

1. Add sliders to ContentView
2. Pass values to GameManager
3. Call `mouthGate.updateOffset()` with new values
4. Store calibrated values in UserDefaults

---

## Reference: Transform Matrix Structure

ARKit's 4x4 transformation matrix:

```
| Xx  Yx  Zx  Tx |    Column 0: X axis (right vector)
| Xy  Yy  Zy  Ty |    Column 1: Y axis (up vector)
| Xz  Yz  Zz  Tz |    Column 2: Z axis (forward vector)
| 0   0   0   1  |    Column 3: Translation (position)
```

**Accessing in code:**
```swift
let position = transform.columns.3  // Translation (x, y, z, w)
let forward = -transform.columns.2   // Forward vector (negated!)
let up = transform.columns.1         // Up vector
let right = transform.columns.0      // Right vector
```

**Note:** Forward is **negated** because:
- Camera looks down **-Z axis** by convention
- We want forward to point **away from camera** (toward scene)

---

## Best Practices

### 1. Always Test on Physical Device

- AR doesn't work in iOS Simulator
- Physics behaves differently on real hardware
- Touch gestures need actual touch input

### 2. Calibrate for Your Specific Mask

Each mask video may have mouth in slightly different position:
- Use debug visualization (green box)
- Adjust Y offset until gate covers mouth
- Adjust Z offset based on throw distance

### 3. Consider Screen Size Variation

TVs and projectors have different sizes:
- Reference image physical size should match actual display
- Larger displays = larger world-space distances
- May need different gate sizes for different setups

### 4. Account for Tracking Drift

- ARKit image tracking can drift slightly during animation
- Gate is intentionally oversized to compensate
- World anchor approach keeps gate stable

---

## Troubleshooting Checklist

- [ ] Reference image is high-contrast and has clear features
- [ ] Physical size in Assets.xcassets matches actual TV display
- [ ] Gate debug visualization shows it's positioned at mouth
- [ ] Fruits expand when thrown (check size change in logs)
- [ ] Throw velocity has negative Z component (toward TV)
- [ ] Collision subscription is created (check logs)
- [ ] Collision groups/masks are correct (fruits = 0010, gate = 0100)
- [ ] Both entities have collision components
- [ ] AR session is running in world tracking mode

---

## Performance Considerations

### Collision Detection

- Simple box shapes (not complex meshes)
- Only 4 fruits maximum
- Trigger mode for gate (no physics response)
- Automatic despawn at 3m distance

### Update Loop

- Runs at 60 FPS when ARKit updates
- Only updates kinematic fruits (not thrown ones)
- Billboard calculation is simple vector math
- No expensive operations in update loop

### Memory Management

- Fruits are reused, not destroyed/recreated
- `resetToThumbnail()` recycles entities
- No memory leaks from AR content

---

## Future Improvements

### Dynamic Difficulty

Adjust gate size based on player performance:
```swift
if successRate < 0.5 {
    gateWidth *= 1.2  // Make easier
} else if successRate > 0.9 {
    gateWidth *= 0.8  // Make harder
}
```

### Multi-Gate Support

For multiple target zones:
```swift
let gates: [MouthGateEntity] = [
    MouthGateEntity(at: SIMD3(0, -0.05, 0.05)),      // Mouth
    MouthGateEntity(at: SIMD3(0.15, 0.1, 0.05)),     // Right eye
    MouthGateEntity(at: SIMD3(-0.15, 0.1, 0.05))     // Left eye
]
```

### Throw Trajectory Prediction

Show arc preview before throwing:
- Calculate ballistic curve
- Draw line renderer
- Update on drag gesture

---

## Credits

ARKit and RealityKit documentation:
- https://developer.apple.com/documentation/arkit/
- https://developer.apple.com/documentation/realitykit/

Created for Global Game Jam 2026
