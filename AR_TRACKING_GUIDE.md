# AR Image Tracking Troubleshooting Guide

## What Was Fixed

The AR reference image configuration has been corrected:

### 1. Fixed Contents.json
- **Before**: Empty images array (ARKit couldn't find the image)
- **After**: Properly references MaskReference.png
- **Physical Size**: Set to 0.5m × 0.5m (50cm × 50cm)

### 2. Added Debug Logging
The app now prints helpful debug information to the console:
- How many reference images were loaded
- Image names and physical sizes
- When images are detected/lost
- AR session errors

## Testing Steps

### 1. Clean Build
Before testing, do a clean build:
1. In Xcode: **Product → Clean Build Folder** (⇧⌘K)
2. Rebuild and install on your device

### 2. Check Console Output
When the app launches, look for this in Xcode console:

**Expected (Good):**
```
DEBUG: Loaded 1 reference images
  - Image: MaskReference, size: (0.5, 0.5)
```

**Problem (Bad):**
```
DEBUG: ERROR - No reference images found in 'AR Resources'
```

### 3. Point at Mask
Point your device camera at the TV/projector showing the mask.

**When detection succeeds, you'll see:**
```
DEBUG: AR Image detected! Name: MaskReference
```

And in the app:
- "Point camera at mask" message disappears
- Score counter appears in top right
- Fruits appear at bottom of screen

## Physical Size Adjustment

The reference image is currently set to **0.5m × 0.5m (50cm × 50cm)**.

**If tracking doesn't work, you may need to adjust this:**

1. Measure the actual size of the mask on your TV/projector screen
2. Update the values in:
   `Assets.xcassets/AR Resources.arresourcegroup/MaskReference.arreferenceimage/Contents.json`

**Example adjustments:**

```json
// For a smaller mask (30cm × 30cm)
"properties" : {
  "width" : 0.3,
  "height" : 0.3
}

// For a larger mask (70cm × 70cm)
"properties" : {
  "width" : 0.7,
  "height" : 0.7
}

// For a rectangular mask (60cm wide × 40cm tall)
"properties" : {
  "width" : 0.6,
  "height" : 0.4
}
```

**Critical:** The physical size MUST be accurate for ARKit to properly detect the image at the right distance.

## Optimal Tracking Conditions

### Screen Setup
- **Brightness**: 70-90% (not too dim, not blindingly bright)
- **No glare**: Avoid overhead lights reflecting on screen
- **Stable**: TV/projector should not move

### Room Lighting
- **Moderate ambient light** (not pitch dark, not super bright)
- **Avoid**: Direct sunlight on screen
- **Avoid**: Very dim rooms (AR tracking needs light)

### Camera Technique
- **Distance**: Start 1-2 meters away from screen
- **Angle**: Point directly at mask (not at extreme angle)
- **Steady**: Hold device stable for initial detection
- **Wait**: Give ARKit 2-3 seconds to analyze the image

### Reference Image Quality
Your MaskReference.png should be:
- **High resolution**: At least 1024×1024 pixels
- **High contrast**: Clear details, not blurry
- **Distinctive**: Unique patterns (not symmetrical or plain)
- **Matches reality**: Should look like what's on the TV

## Common Issues & Solutions

### Issue: "0 reference images" in console

**Cause**: Asset catalog not properly configured or group name mismatch

**Fix:**
1. Open Assets.xcassets in Xcode
2. Verify the group is named exactly: `AR Resources` (case-sensitive)
3. Verify MaskReference.arreferenceimage exists inside it
4. Clean build and retry

### Issue: Image detected but immediately lost

**Cause**: Physical size is incorrect

**Fix:**
1. Measure your actual mask size on the TV screen
2. Update width/height in Contents.json to match
3. Rebuild

### Issue: Image never detected

**Possible causes:**
- Physical size way off (image appears too big/small to ARKit)
- Reference image doesn't match what's on TV
- Screen too dark or has glare
- Room too dark

**Fix:**
1. Increase screen brightness to 80-90%
2. Turn on room lights (moderate, not bright)
3. Check that MaskReference.png matches what's on TV
4. Try printing the reference image on paper first to test

### Issue: Works with printed image but not TV

**Cause**: Screen tracking is harder than paper due to refresh rates and light emission

**Fix:**
1. Increase screen brightness
2. Reduce room lighting slightly
3. Use a static image on TV instead of video (for testing)
4. Ensure no screen glare

## Testing with Printed Image

To quickly test if tracking works at all:

1. Print MaskReference.png on A4/Letter paper
2. Tape it to a wall
3. In Contents.json, temporarily change physical size:
   ```json
   "properties" : {
     "width" : 0.21,    // A4 width
     "height" : 0.297   // A4 height
   }
   ```
4. Point camera at printed image
5. Should detect immediately

If this works, the problem is TV-specific (brightness/glare).

## Debug Console Reference

### Startup Messages
```
DEBUG: Loaded 1 reference images
  - Image: MaskReference, size: (0.5, 0.5)
```
This confirms the reference image loaded correctly.

### Detection Messages
```
DEBUG: AR Image detected! Name: MaskReference
```
This means ARKit found your image! Tracking should now be active.

### Tracking Loss
```
DEBUG: AR Image tracking lost! Name: MaskReference
```
The image was detected but is now out of view or too far.

### Errors
```
DEBUG: AR Session failed with error: [error message]
```
Something went wrong with AR setup - read the error message.

## Next Steps After Successful Tracking

Once you see "DEBUG: AR Image detected!" and the UI changes:

1. **Verify fruits appear** at bottom of screen
2. **Try throwing a fruit** by swiping on it
3. **Aim for the mouth** (invisible collision gate)
4. **Score should increment** when fruit hits the gate

If tracking works but fruits don't appear, check the fruit sprite assets are properly added to Assets.xcassets.

## Contact Info

If tracking still doesn't work after trying all troubleshooting steps, check:
- Xcode console output (copy all DEBUG messages)
- Physical size of mask on TV (measure it!)
- Quality of MaskReference.png (open it and check)
- ARKit support on your device (iPhone 6s or later)
