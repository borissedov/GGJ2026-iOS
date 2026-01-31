# Oh My Hungry God - Multiplayer Setup Guide

Complete guide for setting up and deploying the multiplayer AR game system.

## System Overview

```
┌─────────────────┐
│  Web Display    │  ← Shows QR code, lobby, orders, results
│  (TypeScript)   │
└────────┬────────┘
         │
         │ SignalR WebSocket
         │
┌────────▼────────┐
│  Backend Server │  ← .NET 9 + SignalR (Authoritative)
│  (Azure)        │
└────────┬────────┘
         │
         │ SignalR WebSocket
         │
┌────────▼────────┐
│  iOS AR Clients │  ← Throw fruits, see orders
│  (ARKit)        │
└─────────────────┘
```

## Prerequisites

- **Backend**: .NET 9 SDK, Azure account
- **Frontend**: Node.js 18+, npm
- **iOS**: Xcode 14+, iOS 15+, ARKit-capable device

---

## Part 1: Backend Deployment to Azure

### Step 1: Create Azure App Service

1. Go to [Azure Portal](https://portal.azure.com)
2. Create new **App Service**
3. Configure:
   - **Name**: `oh-my-hungry-god-backend` (or your choice)
   - **Runtime**: .NET 9
   - **Operating System**: Linux (recommended) or Windows
   - **Region**: Choose closest to your users
   - **Pricing Tier**: B1 or higher (F1 free tier works for testing)

### Step 2: Configure App Service Settings

In Azure Portal → Your App Service → Configuration:

#### General Settings

- **Stack**: .NET
- **Version**: 9
- **Platform**: 64-bit
- **Always On**: **ENABLED** ⚠️ (Critical for WebSockets!)
- **ARR Affinity**: Enabled
- **HTTPS Only**: Recommended

#### Application Settings

Add these environment variables:

```
ASPNETCORE_ENVIRONMENT = Production
WEBSITE_TIME_ZONE = UTC
```

### Step 3: Enable WebSockets

⚠️ **CRITICAL**: WebSockets must be enabled for SignalR to work.

Azure Portal → Your App Service → Configuration → General settings:
- **Web sockets**: **ON**

### Step 4: Deploy Backend

#### Option A: GitHub Integration (Recommended)

1. Push your code to GitHub repository
2. Azure Portal → Deployment Center
3. Select **GitHub**
4. Authenticate and select repository: `OhMyHungryGod.Server`
5. Azure will auto-build and deploy

#### Option B: Manual Deployment

```bash
cd OhMyHungryGod.Server/OhMyHungryGod.Server
dotnet publish -c Release -o ./publish
cd publish
zip -r ../deploy.zip .
```

Then upload `deploy.zip` via:
- Azure Portal → Deployment Center → FTP/Credentials
- Or use Azure CLI: `az webapp deployment source config-zip`

### Step 5: Verify Backend

Test your backend at: `https://your-app.azurewebsites.net/health`

Should return:
```json
{
  "status": "healthy",
  "timestamp": "2026-01-31T...",
  "version": "1.0.0"
}
```

SignalR hub is at: `https://your-app.azurewebsites.net/gamehub`

---

## Part 2: Frontend Deployment

### Option A: Cloudflare Pages (Recommended) ⚡

Fastest and most globally distributed option with free tier.

#### Method 1: GitHub Integration (Easiest)

1. **Push to GitHub**
   ```bash
   cd oh-my-hungry-god-display
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Create Cloudflare Pages Project**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Pages → Create a project
   - Connect to Git → Select your repository
   - Build settings:
     - **Framework preset**: Vite
     - **Build command**: `npm run build`
     - **Build output directory**: `dist`
   - Click **Save and Deploy**

3. **Add Environment Variable**
   - Settings → Environment variables
   - Add variable:
     ```
     VITE_BACKEND_URL = https://your-backend.azurewebsites.net/gamehub
     ```
   - Redeploy to apply changes

#### Method 2: Direct Upload (Quick Test)

1. **Build locally**
   ```bash
   cd oh-my-hungry-god-display
   echo "VITE_BACKEND_URL=https://your-backend.azurewebsites.net/gamehub" > .env
   npm run build
   ```

2. **Deploy via Wrangler (Cloudflare CLI)**
   ```bash
   npm install -g wrangler
   wrangler login
   wrangler pages deploy dist --project-name=oh-my-hungry-god
   ```

3. **Or upload via Dashboard**
   - Cloudflare Dashboard → Pages → Upload assets
   - Drag and drop the `dist/` folder

### Option B: Azure Static Web Apps

1. **Create Static Web App**
   - Azure Portal → Create Static Web App
   - Connect to your GitHub repo
   - Build settings:
     - App location: `/oh-my-hungry-god-display`
     - Output location: `dist`

2. **Configure Environment**
   - Azure Portal → Static Web App → Configuration → Environment variables:
     ```
     VITE_BACKEND_URL = https://your-backend.azurewebsites.net/gamehub
     ```

### Option C: Other Static Hosts (Netlify, Vercel)

1. **Build**
   ```bash
   cd oh-my-hungry-god-display
   echo "VITE_BACKEND_URL=https://your-backend.azurewebsites.net/gamehub" > .env
   npm run build
   ```

2. **Deploy `dist/` folder** to your static host of choice

---

## Part 3: iOS App Configuration

### Step 1: Add SignalR Package

1. Open `HungryGodMask.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. Enter URL: `https://github.com/moozzyk/SignalR-Client-Swift`
4. Add to target: `HungryGodMask`

### Step 2: Update Backend URL

Edit `HungryGodMask/Networking/SignalRClient.swift`:

```swift
init(hubUrl: String = "https://your-backend.azurewebsites.net/gamehub") {
    self.hubUrl = hubUrl
}
```

### Step 3: Uncomment SignalR Code

In `SignalRClient.swift`, uncomment all the SignalR implementation code that's currently commented out with `// TODO:`.

### Step 4: Build and Test

1. Build the app in Xcode
2. Run on a physical iOS device (AR requires real device)
3. Test joining a room

---

## Part 4: Testing the Full System

### Test Flow

1. **Start Backend**
   - Verify it's running: `https://your-backend.azurewebsites.net/health`

2. **Open Display** (on TV/projector)
   - Navigate to your frontend URL
   - Should show QR code and join code

3. **Join from iOS**
   - Open iOS app
   - Select "Multiplayer" mode
   - Enter join code
   - Toggle "Ready"

4. **Start Game**
   - When all players ready, countdown starts
   - Play through 10 orders
   - View results

### Troubleshooting

#### Backend Issues

- **500 errors**: Check Azure logs (Log Stream)
- **SignalR not connecting**: Verify WebSockets are enabled
- **CORS errors**: Check CORS policy in `Program.cs`

#### Frontend Issues

- **Can't connect**: Verify `VITE_BACKEND_URL` is correct
- **No QR code**: Check browser console for errors

#### iOS Issues

- **Build errors**: Ensure SignalR package is added
- **Connection fails**: Check backend URL in `SignalRClient.swift`
- **AR not working**: Must run on physical device, not simulator

---

## Azure App Service Configuration Summary

### Required Settings ✅

| Setting | Value | Location |
|---------|-------|----------|
| Runtime Stack | .NET 9 | Configuration → General |
| Always On | **ENABLED** | Configuration → General |
| WebSockets | **ENABLED** | Configuration → General |
| Platform | 64-bit | Configuration → General |
| ASPNETCORE_ENVIRONMENT | Production | Configuration → App Settings |

### Health Check (Optional but Recommended)

- Path: `/health`
- Configure in: Configuration → Health check

### CORS

Already configured in code (`Program.cs`) to allow all origins.

For production, update to specific domains:
```csharp
policy.WithOrigins(
    "https://your-frontend.azurewebsites.net",
    "https://your-static-web-app.net"
)
```

---

## Performance Tips

### Backend
- Use B1 tier or higher for production
- Enable Application Insights for monitoring
- Set up autoscaling if expecting many concurrent rooms

### Frontend
- Use CDN for static assets
- Enable compression
- Consider Azure Front Door for global distribution

### iOS
- Test on various devices
- Monitor battery usage during long sessions
- Consider background refresh settings

---

## Monitoring

### Backend Monitoring

Azure Portal → Your App Service → Monitoring:

- **Metrics**: CPU, Memory, Response Time
- **Log Stream**: Real-time logs
- **Application Insights**: Detailed telemetry (optional)

### Key Metrics to Watch

- Active SignalR connections
- Room count
- Average game duration
- Error rates

---

## Costs Estimate

### Minimal Setup (Testing)
- Backend: Azure F1 Free tier or B1 Basic (~$13/month)
- Frontend: Cloudflare Pages Free tier (unlimited bandwidth!)
- **Total**: $0-13/month

### Production Setup
- Backend: Azure B2 Basic (~$50/month) or S1 Standard (~$70/month)
- Frontend: Cloudflare Pages Free tier (still free! ⚡)
- **Total**: ~$50-70/month

### Alternative Frontend Hosts
- **Cloudflare Pages**: FREE (unlimited bandwidth, 500 builds/month)
- **Azure Static Web Apps**: Free tier or ~$9/month Standard
- **Netlify**: Free tier (100GB bandwidth)
- **Vercel**: Free tier (100GB bandwidth)

Costs scale with:
- Number of concurrent players
- Data transfer
- Compute resources

---

## Next Steps

1. ✅ Deploy backend to Azure
2. ✅ Deploy frontend
3. ✅ Configure iOS app
4. 🎮 Test with friends
5. 🎯 Optimize based on usage
6. 📊 Set up monitoring
7. 🎨 Create mood videos (neutral, happy, angry, burned)

## Support

For issues:
- Backend logs: Azure Portal → Log Stream
- Frontend: Browser DevTools console
- iOS: Xcode console output

Good luck with your Global Game Jam project! 🎮🍉
