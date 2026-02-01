# Oh My Hungry God - System Architecture

Technical architecture overview for the multiplayer AR game.

## High-Level Architecture

```mermaid
graph TB
    subgraph clients [Client Layer]
        Display[Web Display<br/>TypeScript + SignalR]
        iOS1[iOS Client 1<br/>Swift + ARKit]
        iOS2[iOS Client N<br/>Swift + ARKit]
    end
    
    subgraph backend [Backend Layer - Azure]
        SignalR[SignalR Hub<br/>WebSocket Server]
        GameEngine[Game Engine<br/>State Machine]
        RoomMgr[Room Manager<br/>Lifecycle]
        State[(In-Memory State<br/>Concurrent Dict)]
    end
    
    Display -->|WSS| SignalR
    iOS1 -->|WSS| SignalR
    iOS2 -->|WSS| SignalR
    
    SignalR --> GameEngine
    GameEngine --> RoomMgr
    RoomMgr --> State
```

## Technology Stack

### Backend
- **.NET 9**: Latest C# runtime
- **ASP.NET Core**: Web framework with Minimal APIs
- **SignalR**: Real-time WebSocket communication
- **Azure App Service**: Hosting platform
- **In-Memory Storage**: ConcurrentDictionary for thread-safe state

### Frontend (Host Display)
- **TypeScript**: Type-safe JavaScript
- **Vite**: Fast build tool and dev server
- **Vanilla JS**: No framework overhead
- **SignalR Client**: JavaScript WebSocket client
- **Cloudflare Pages**: Global CDN hosting

### iOS (Mobile Controllers)
- **Swift**: Native iOS development
- **ARKit**: Image tracking and AR features
- **RealityKit**: Physics simulation and 3D rendering
- **SignalRClient-Swift**: SignalR client library
- **SwiftUI**: UI framework

## Component Details

### 1. Backend (.NET 9)

#### SignalR Hub (GameHub.cs)

Central communication hub for all clients.

**Client → Server Methods:**
- `CreateRoom()` - Display creates a new game room
- `JoinRoom(joinCode)` - Player joins with 6-character code
- `SetReady(roomId, ready)` - Player marks ready/not ready
- `ReportHit(roomId, hitId, fruitType)` - Player hit the mouth
- `Ping(roomId)` - Keep-alive heartbeat

**Server → Client Events:**
- `RoomStateUpdated` - Player joins/leaves/ready changes
- `CountdownStarted` - 10s countdown begins
- `GameStarted` - Game has started
- `OrderStarted` - New order with requirements
- `OrderTotalsUpdated` - Hit counted (live updates)
- `OrderResolved` - Order success/fail
- `MoodChanged` - God's mood changed
- `GameFinished` - All 10 orders complete
- `StateSnapshot` - Full state sync (on join/reconnect)

#### Game Engine Service

Authoritative game logic and state machine.

**Responsibilities:**
- State transitions (Welcome → Lobby → Countdown → InGame → Results)
- Order resolution (immediate fail/success rules)
- Mood calculation
- Timer management
- Event broadcasting

**Key Methods:**
- `StartCountdown()` - Begin 10s countdown when all ready
- `ProcessHit()` - Validate and count fruit hits
- `ResolveOrder()` - Determine success/fail, update mood
- `EndGame()` - Transition to results or game over

#### Room Service

Room lifecycle management.

**Responsibilities:**
- Create rooms with unique join codes
- Add/remove players
- Track player connections
- Clean up inactive rooms

**Room Lifecycle:**
- Created when display connects
- Persists while players connected
- Destroyed after 5 min inactivity or 30s post-results

#### Background Timer Service

Hosted background service for server-side timers.

**Tasks (runs every 1 second):**
- Check countdown timers (10s)
- Check order timeouts (10s)  
- Clean up inactive rooms

### 2. Frontend (TypeScript)

#### SignalR Client Wrapper

Manages WebSocket connection and event handling.

**Features:**
- Auto-reconnect on disconnect
- Event bus pattern for UI updates
- Type-safe event signatures

#### Screen Components

**WelcomeScreen:**
- Generates QR code with join link
- Displays 6-character join code
- Shown during Welcome state

**LobbyScreen:**
- Lists connected players
- Shows ready status for each
- Displays "Starting soon..." when all ready

**GameScreen:**
- Current order display with fruit requirements
- Live fruit count updates (submitted/required)
- Timer countdown
- Progress bar (orders 1-10)
- God mood indicator

**ResultsScreen:**
- Final stats (successes, failures, success rate)
- Final god mood
- Burnout message if applicable

#### Mood Video Manager

Controls background video based on god's mood.

**Videos:**
- `neutral.mp4` - Default mood
- `happy.mp4` - God is pleased
- `angry.mp4` - God is upset
- `burned.mp4` - Game over

Automatically switches videos when MoodChanged event received.

### 3. iOS App (Swift)

#### SignalR Client

Swift wrapper for SignalRClient-Swift library.

**Features:**
- Connection state tracking
- Event handler callbacks
- Async/await API for server methods
- Type-safe event models

#### AR Components

**FruitEntity:**
- 2D sprite billboarded to camera
- Physics-enabled (RealityKit)
- Two sizes: thumbnail (4cm) and full (varies by fruit)
- Expand on throw, reset on respawn

**MouthGateEntity:**
- Invisible collision trigger at mask mouth position
- Detects fruit hits
- Positioned relative to AR image anchor

**FruitSpawner:**
- Spawns one entity per fruit type
- Updates positions to follow camera (panel at bottom)
- Handles respawning after throw

**ThrowGestureHandler:**
- Converts swipe gesture to 3D velocity
- Triggers fruit expansion and physics activation

#### Multiplayer UI

**LobbyView:**
- Join code input with QR scanner button
- Ready toggle
- Connection status indicator
- Transitions to AR game when ready

**OrderOverlayView:**
- Shows current order in AR view
- Fruit requirements with progress
- Timer countdown
- Styled for AR overlay

#### Game Manager

Coordinates AR gameplay and network integration.

**Modes:**
- **Single-player**: Local scoring only
- **Multiplayer**: Reports hits to server, shows network orders

**Collision Detection:**
- Listens for fruit-gate collisions
- In multiplayer: sends `ReportHit` to server
- In single-player: increments local counters

## Data Flow

### Room Join Flow

```mermaid
sequenceDiagram
    participant D as Display
    participant B as Backend
    participant iOS as iOS Client
    
    D->>B: CreateRoom()
    B-->>D: {roomId, joinCode}
    D->>D: Show QR code
    
    iOS->>iOS: Scan QR
    iOS->>B: JoinRoom(joinCode)
    B->>B: Create player, add to room
    B-->>iOS: {roomId, playerId}
    B->>D: RoomStateUpdated
    B->>iOS: StateSnapshot
    
    iOS->>B: SetReady(true)
    B->>D: RoomStateUpdated
    B->>B: Check all ready?
    B->>D: CountdownStarted (if all ready)
```

### Gameplay Flow

```mermaid
sequenceDiagram
    participant iOS as iOS Client
    participant B as Backend
    participant D as Display
    
    Note over B: Countdown completes
    B->>iOS: GameStarted
    B->>D: GameStarted
    B->>iOS: OrderStarted
    B->>D: OrderStarted
    
    loop Each Fruit Throw
        iOS->>iOS: Detect collision
        iOS->>B: ReportHit(hitId, fruit)
        B->>B: Validate & count
        
        alt Over-submitted
            B->>iOS: OrderResolved (FailOver)
            B->>D: OrderResolved (FailOver)
            B->>D: MoodChanged
        else Exact match
            B->>iOS: OrderResolved (Success)
            B->>D: OrderResolved (Success)
            B->>D: MoodChanged
        else Still active
            B->>D: OrderTotalsUpdated
        end
    end
    
    Note over B: Next order or end game
```

## State Management

### Backend State

**In-Memory Store:**
- `ConcurrentDictionary<Guid, Room>` - All active rooms
- `ConcurrentDictionary<string, Guid>` - Join code → Room ID
- `ConcurrentDictionary<Guid, HashSet<Guid>>` - Processed hit IDs

**Thread Safety:**
- All dictionaries use concurrent collections
- State updates are atomic
- Background timer service uses scoped services

### Frontend State

**GameState class:**
- Current screen
- Room ID and join code
- Player list
- Current order
- Submitted counts
- Timer

**Reactive:**
- State changes trigger UI re-renders
- Event-driven updates via SignalR

### iOS State

**GameManager:**
- AR state (tracking, entities)
- Network state (if multiplayer enabled)
- Current order overlay data

**Published properties** trigger SwiftUI updates.

## Network Protocol

### Transport
- **Primary**: WebSockets (binary)
- **Fallback**: Server-Sent Events → Long Polling
- **SignalR handles negotiation automatically**

### Message Format
- **JSON** over WebSocket
- **Hub Protocol**: SignalR JSON protocol v1

### Idempotency
- Each hit has unique GUID (hitId)
- Server tracks processed hits per room
- Prevents duplicate scoring from network retries

### Reconnection
- SignalR auto-reconnect with exponential backoff
- Display: requests StateSnapshot on reconnect
- iOS: marked as disconnected but stays in room

## Security Model

### Authentication
- **None** (by design for game jam)
- GUID-based identifiers prevent collisions

### Authorization
- Server validates:
  - Player is in room
  - Game state is correct
  - Hit is for active order

### Data Validation
- Server is authoritative
- Clients cannot cheat (all logic server-side)
- Input validation on all commands

## Deployment Architecture

```mermaid
graph LR
    Users[Players & Display] -->|HTTPS/WSS| CF[Cloudflare CDN]
    CF -->|Static Assets| Pages[Cloudflare Pages]
    Users -->|WSS| Azure[Azure App Service]
    
    subgraph azureInfra [Azure Infrastructure]
        Azure -->|.NET 9| App[Web App]
        App -->|SignalR| Hub[SignalR Hub]
        Hub -->|In-Memory| State[(State Store)]
    end
```

### Hosting

**Backend:**
- Azure App Service (Linux, .NET 9)
- Always On enabled (no cold starts)
- WebSockets enabled
- Auto-scaling capable

**Frontend:**
- Cloudflare Pages
- Global CDN (275+ locations)
- Automatic HTTPS
- Unlimited bandwidth

**iOS:**
- Distributed via TestFlight or Ad-Hoc
- Requires ARKit device

## Performance Characteristics

### Latency
- Hit reporting: < 100ms (player → server → display)
- State updates: < 50ms broadcast
- Order resolution: Immediate (no artificial delay)

### Capacity (B1 Azure tier)
- Concurrent rooms: 20-30
- Players per room: Unlimited (2-6 recommended)
- Connections: ~200 concurrent SignalR connections

### Bandwidth
- Per player: ~1-5 KB/s (mostly keepalives)
- Per order: ~5-10 KB (order data + updates)
- Total per game: < 1 MB per player

## Fault Tolerance

### Backend
- In-memory state (lost on restart)
- Rooms auto-cleanup on timeout
- Background timer service handles crashes gracefully

### Frontend
- Auto-reconnect on disconnect
- Re-sync via StateSnapshot
- Handles missing events gracefully

### iOS
- Auto-reconnect on network loss
- Marked as disconnected but not removed from room
- Can rejoin same room after reconnect

## Monitoring

### Backend Logs
- Azure App Service → Log Stream
- SignalR connection events
- Game state transitions
- Error tracking

### Frontend Analytics
- Cloudflare Pages → Analytics
- Page views, bandwidth
- Geographic distribution

### Health Checks
- Backend: `/health` endpoint
- Returns: `{status, timestamp, version}`

---

## Design Principles

1. **Server Authority**: All game logic runs on server
2. **Event-Driven**: State changes broadcast as events
3. **Eventual Consistency**: Clients sync via events
4. **Fail-Safe**: Errors don't break game state
5. **Stateless Clients**: Server holds truth
6. **Idempotent Operations**: Safe retries

## Trade-offs

### In-Memory vs Persistent State
- **Chosen**: In-memory
- **Reason**: Fast, simple, rooms are temporary anyway
- **Trade-off**: State lost on server restart

### Authoritative Server vs P2P
- **Chosen**: Authoritative server
- **Reason**: Prevents cheating, consistent state
- **Trade-off**: Requires server (not offline)

### SignalR vs Raw WebSockets
- **Chosen**: SignalR
- **Reason**: Auto-reconnect, fallbacks, strong typing
- **Trade-off**: Slightly larger payloads

---

**This architecture supports fast-paced multiplayer AR gameplay with minimal latency and maximum reliability.**
