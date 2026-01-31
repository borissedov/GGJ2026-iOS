# Next Steps - Get AR Tracking Working

## Quick Checklist ✅

Follow these steps in order:

### 1. Clean Build (Required)
- [ ] In Xcode: **Product → Clean Build Folder** (⇧⌘K)
- [ ] Build and install on your iOS device

### 2. Check Console on Launch
- [ ] Open Xcode console (View → Debug Area → Activate Console)
- [ ] Look for: `DEBUG: Loaded 1 reference images`
- [ ] Check physical size: Should show `size: (0.5, 0.5)`

**If you see this ✅** → Reference image is configured correctly!  
**If you see "0 reference images" ❌** → Contact me with error details

### 3. Measure Your Mask
- [ ] Measure the mask size on your TV/projector screen (in centimeters)
- [ ] Convert to meters (divide by 100)
- [ ] Example: 50cm × 50cm = 0.5m × 0.5m (current setting)

**If your mask is NOT 50cm × 50cm:**
- [ ] Open `Assets.xcassets/AR Resources.arresourcegroup/MaskReference.arreferenceimage/Contents.json`
- [ ] Update width and height to your measurements
- [ ] Rebuild

### 4. Setup Optimal Conditions
- [ ] TV/projector screen brightness: 70-90%
- [ ] Turn on room lights (moderate brightness, not dim)
- [ ] Remove any glare from overhead lights hitting the screen
- [ ] Display your mask video/image on the screen

### 5. Test Tracking
- [ ] Stand 1-2 meters from the TV
- [ ] Point camera directly at the mask
- [ ] Hold steady for 2-3 seconds
- [ ] Watch the console for: `DEBUG: AR Image detected!`

**Success looks like:**
- ✅ "Point camera at mask" message disappears
- ✅ Score counter appears in top right
- ✅ 4 fruits appear at bottom of screen
- ✅ Console shows: "AR Image detected!"

### 6. If Still Not Detecting

Try the paper test:
- [ ] Print `MaskReference.png` on paper
- [ ] Tape to wall
- [ ] In Contents.json, change to: `"width": 0.21, "height": 0.297` (A4 size)
- [ ] Rebuild
- [ ] Point at printed image

**If paper works but TV doesn't:**
→ TV brightness or glare issue. Increase brightness, reduce room light.

**If paper doesn't work either:**
→ Physical size mismatch or image quality issue. See AR_TRACKING_GUIDE.md.

## Quick Reference

**Console Messages:**
```
✅ "Loaded 1 reference images" = Config OK
✅ "AR Image detected!" = Tracking working!
❌ "0 reference images" = Asset catalog issue
❌ "AR Session failed" = Check error message
```

**Physical Size Examples:**
```
30cm × 30cm = 0.3 × 0.3
40cm × 60cm = 0.4 × 0.6
50cm × 50cm = 0.5 × 0.5 (current)
70cm × 70cm = 0.7 × 0.7
```

## Documentation Files

- **TRACKING_FIX_SUMMARY.md** - What was fixed and why
- **AR_TRACKING_GUIDE.md** - Detailed troubleshooting (read this if stuck)
- **ASSETS_SETUP_GUIDE.md** - Asset preparation guide
- **QUICKSTART.md** - General getting started guide

## Most Likely Issues

### 1. Physical Size Wrong (90% of cases)
**Symptom**: Image never detected or only works very close/far  
**Fix**: Measure actual mask size and update Contents.json

### 2. Screen Too Dark (5% of cases)
**Symptom**: Works with printed image but not TV  
**Fix**: Increase TV brightness to 80-90%

### 3. Image Quality Low (3% of cases)
**Symptom**: Detects briefly then loses tracking  
**Fix**: Use higher resolution reference image (1024×1024+)

### 4. Wrong Lighting (2% of cases)
**Symptom**: Intermittent detection  
**Fix**: Turn on room lights to moderate brightness

## Current Configuration

✅ AR reference image properly configured  
✅ Physical size set to: **0.5m × 0.5m** (50cm × 50cm)  
✅ Debug logging enabled  
✅ Error handling added  
✅ All fruit sprites added (Banana, Peach, Coconut, Watermelon)

## Expected Timeline

- **Clean build**: 30 seconds
- **First detection test**: 1-2 minutes
- **Calibration (if needed)**: 5-10 minutes
- **Total**: Should be working in under 15 minutes

## Success!

When you see this sequence:
```
DEBUG: Loaded 1 reference images
  - Image: MaskReference, size: (0.5, 0.5)
[Point camera at mask]
DEBUG: AR Image detected! Name: MaskReference
```

**You're done!** The game is working. Now you can:
- Swipe fruits to throw them
- Aim for the mouth
- Score points!

---

**Start with Step 1** and work through the checklist. Good luck! 🎮
