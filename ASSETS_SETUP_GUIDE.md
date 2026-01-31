# Assets Setup Guide for HungryGodMask

This guide will help you prepare and add all required assets to the project.

## Overview

You need to add the following assets to make the game work:
1. **AR Reference Image** - for tracking the TV/projector display
2. **4 Fruit Sprite Images** - Banana, Peach, Coconut, Watermelon

## Step 1: Prepare the Mask Animation Video (External)

**This is NOT added to Xcode - it plays on your TV/projector**

1. Create or obtain a looping mask animation video:
   - Format: MP4, H.264 codec
   - Resolution: 1920×1080 or higher
   - Duration: 5-15 seconds (seamless loop)
   - Animation: Subtle breathing/idle motion (1-3cm movement)

2. Transfer to playback device:
   - USB drive → plug into smart TV
   - Laptop connected to projector
   - Apple TV, Chromecast, etc.

3. Set video to loop continuously

## Step 2: Create AR Reference Image

### Extract a Frame from Your Video:

1. Play your mask animation video
2. Pause on a clear, well-lit frame with good detail
3. Take a screenshot or export the frame
4. Crop to just the mask region (square aspect ratio recommended)
5. Save as `MaskReference.png` (minimum 1024×1024px)

### Add to Xcode:

1. Open `HungryGodMask.xcodeproj` in Xcode
2. In Project Navigator, click `Assets.xcassets`
3. Click the `+` button at bottom → **New AR Resource Group**
4. Name it: `AR Resources`
5. Select the AR Resources group, click `+` → **New AR Reference Image**
6. Drag your `MaskReference.png` into the image well
7. In Attributes Inspector (right panel):
   - **Name**: `MaskReference`
   - **Physical Size**: Enter the actual dimensions of your TV/screen area
     - Example: Width: 0.5m, Height: 0.5m (measure your actual screen!)
     - This is CRITICAL for accurate AR tracking

## Step 3: Add Fruit Sprite Images

You need 4 fruit sprites with transparent backgrounds (PNG with alpha channel).

### Asset Specifications:

| Fruit      | Size      | Description                           |
|------------|-----------|---------------------------------------|
| Banana     | 512×512   | Elongated curved yellow shape         |
| Peach      | 512×512   | Round peachy-orange with leaf         |
| Coconut    | 512×512   | Brown hairy sphere                    |
| Watermelon | 1024×1024 | Green striped sphere (larger)         |

### Where to Get Fruit Sprites:

**Option 1: AI Generation** (Recommended for consistency)
- Use DALL-E, Midjourney, or Stable Diffusion
- Prompt example: "cartoon banana sprite, transparent background, 2D game asset, flat design"
- Generate all 4 in the same art style

**Option 2: Free Asset Sites**
- OpenGameArt.org
- Kenney.nl (look for "food" or "fruit" packs)
- itch.io free game assets

**Option 3: Quick Placeholder**
- Use emoji screenshots temporarily
- Find fruit emojis: 🍌 🍑 🥥 🍉
- Screenshot each on white background
- Remove background using Preview or online tool (remove.bg)

**Option 4: Commission an Artist**
- Fiverr: ~$20-50 for a set of 4 sprites
- Specify: "2D game sprites, transparent PNG, cartoon style"

### Add to Xcode:

For each fruit (Banana, Peach, Coconut, Watermelon):

1. Open `Assets.xcassets` in Xcode
2. Click `+` → **New Image Set**
3. Name it exactly as listed below:
   - `Banana`
   - `Peach`
   - `Coconut`
   - `Watermelon`
4. Drag your PNG file into the **2x** slot (or **Universal** slot)
5. In Attributes Inspector:
   - **Render As**: Default
   - **Resizing**: Not needed for these sprites

## Step 4: Verify Setup

### Check AR Resources:
- Assets.xcassets → AR Resources.arresourcegroup
- Should contain: MaskReference (with physical size set!)

### Check Fruit Sprites:
- Assets.xcassets should contain:
  - Banana.imageset
  - Peach.imageset
  - Coconut.imageset
  - Watermelon.imageset

## Step 5: Test the App

1. Make sure your mask video is playing on the TV/projector
2. Set screen brightness: 70-90%
3. Moderate room lighting (not too dark/bright)
4. Build and run on a physical iOS device (AR requires real hardware)
5. Point camera at the TV screen
6. Wait for detection (green "tracking" indicator)
7. Swipe fruits to throw at the mouth!

## Troubleshooting

### "Point camera at mask" message won't go away
- AR image not detected. Check:
  - Is the reference image added correctly with physical size?
  - Is the video playing on TV/projector?
  - Is screen brightness adequate (70-90%)?
  - Is room lighting moderate?
  - Try getting closer or adjusting angle

### Fruits don't appear
- Check that all 4 fruit sprites are added to Assets.xcassets
- Check exact naming: Banana, Peach, Coconut, Watermelon (capitalized)

### Fruits appear as colored squares
- Sprites not loading - check that images are in correct slots
- Make sure images have transparent backgrounds

### Throwing doesn't work
- Make sure you're swiping on the fruits themselves
- Try a faster swipe gesture
- Fruits need to be visible on screen bottom

## Optional: Debug Mode

To see the invisible collision gate (helpful for calibration):

1. Open `Entities/MouthGateEntity.swift`
2. Find line 49: `// addDebugVisualization()`
3. Uncomment it: `addDebugVisualization()`
4. Run the app
5. You'll see a semi-transparent green box at the mouth location
6. Adjust the `defaultMouthOffset` value if needed

## Tips for Best Experience

- **Screen Tracking**: Works best with clear, detailed imagery on screen
- **Lighting**: Avoid glare from overhead lights on TV screen  
- **Calibration**: The mouth gate is positioned 5cm below anchor center by default
  - Adjust `MouthGateEntity.defaultMouthOffset` if your mask mouth is elsewhere
- **Gate Size**: Default is 15cm × 10cm with 1.2× tolerance for animation drift
  - Adjust `gateWidth` and `gateHeight` if needed
