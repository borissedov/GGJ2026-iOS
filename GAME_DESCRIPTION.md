# Oh My Hungry God

A synchronous multiplayer AR game for Global Game Jam 2026.

## Concept

Feed a hungry god by throwing fruits into their mouth! Work together with other players to fulfill orders before time runs out. But beware - make too many mistakes and the god will burn out in anger!

## How to Play

### Setup
1. **Display the game** on a TV or projector (web browser)
2. **Players join** by scanning the QR code with their iOS devices
3. **Point your phone** at the TV screen to enter AR mode
4. **Mark ready** when you're set to play

### Gameplay
- Each round presents an **order** showing which fruits are needed
- **All players work together** to throw the right fruits
- Swipe fruits from your phone toward the mask's mouth
- **10 seconds** to complete each order
- **10 orders** total per game

### Winning
- **Exact match** = Success! The god is pleased
- **Over-submission** = Instant fail! Too much of a fruit
- **Timeout** = Fail! Didn't complete in time

Keep the god happy through all 10 orders to win!

## The God's Mood

The god's mood changes based on your performance:

```
💀 BURNED  ←  😠 ANGRY  ←  😐 NEUTRAL  →  😊 HAPPY
```

### Mood Rules
- Start at **NEUTRAL**
- Every **2 successes** → Mood improves
- Every **1 failure** → Mood worsens
- **Mood drops below ANGRY** → God burns out → **GAME OVER**

The god's mood is shown on the TV display with animated video loops.

## Game Rules

### Orders
- 4 fruit types: Banana 🍌, Peach 🍑, Coconut 🥥, Watermelon 🍉
- Each order requires 0-5 of each fruit type
- At least one fruit type is always required
- All players contribute to the same shared goal

### Resolution (Immediate Rules)
- **Over-submit** any fruit → **Instant fail**
  - Example: Order wants 2 bananas, you throw 3 → Fail immediately
- **Exact match** all fruits → **Instant success**
  - No need to wait for timer
- **Timer expires** without exact match → **Fail (timeout)**

### Collaboration
- All players throw fruits into the same pool
- Communication is key!
- One player over-throwing ruins it for everyone
- Work together to match orders exactly

## Components

### Host Display (Web)
- Shows QR code for joining
- Displays current order and requirements
- Shows real-time progress (fruit counts)
- Displays god's mood with video background
- Shows final results

### iOS AR Controller
- Scans QR code to join
- Shows current order overlay in AR
- Throw fruits by swiping
- See fruits in augmented reality

### Backend Server
- Validates all actions
- Tracks game state
- Calculates mood
- Ensures fair play (authoritative)

## Technical Requirements

### For Players (iOS)
- iPhone 6s or later with ARKit support
- iOS 15.0 or later
- Internet connection

### For Host (Display)
- Modern web browser (Chrome, Safari, Edge)
- TV, projector, or large screen
- Internet connection

## Game Session

- **Room-based**: Each game creates a unique room
- **No authentication**: Anonymous play with QR codes
- **Temporary**: Rooms expire after inactivity
- **2-6 players recommended**: Works with any number but best with small groups

## Tips for Success

1. **Communicate**: Talk about who's throwing what
2. **Count together**: Track how many fruits have been thrown
3. **Don't over-throw**: One extra fruit = instant fail
4. **Watch the timer**: 10 seconds goes fast!
5. **Stay calm**: Panic leads to mistakes

## Credits

Created for Global Game Jam 2026

Technologies:
- ARKit (Apple)
- RealityKit (Physics & 3D)
- .NET 9 (Backend)
- SignalR (Real-time communication)
- TypeScript (Frontend)

---

**Ready to play?** Scan the QR code and feed the hungry god! 🍉🥥🍑🍌
