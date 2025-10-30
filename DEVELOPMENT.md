# Penrion OSU! Tablet Driver - Development Guide

## Project Architecture

### iOS App (Swift/SwiftUI)
```
ios-app/OsuTablet/
├── OsuTabletApp.swift          # App entry point
├── Views/
│   ├── ContentView.swift       # Main container
│   ├── ConnectionView.swift    # Connection screen
│   ├── OsuModeView.swift       # OSU! gaming mode
│   ├── ScreenMirrorView.swift  # Screen mirroring mode
│   └── SettingsView.swift      # Settings panel
├── Managers/
│   ├── ConnectionManager.swift # Network communication
│   ├── TouchManager.swift      # Touch input handling
│   └── SettingsManager.swift   # App settings
└── Info.plist                  # App configuration
```

### Windows App (C#/WPF)
```
windows-app/OsuTabletDriver/
├── App.xaml/cs                 # Application entry
├── MainWindow.xaml/cs          # Main UI
├── Services/
│   ├── VirtualTabletDriver.cs  # HID tablet simulation
│   ├── ConnectionServer.cs     # Network server
│   └── ScreenCaptureService.cs # Screen streaming
└── app.manifest                # Admin privileges config
```

## Technical Details

### Touch Input Processing

#### iOS Side
1. `UITouch` events captured in `OsuModeView`
2. Normalized coordinates (0-1 range)
3. Apple Pencil pressure support (0-1 range)
4. Sent via WebSocket as JSON

#### Windows Side
1. Receives touch data via TCP
2. Maps to absolute screen coordinates
3. Uses `mouse_event` Win32 API
4. Simulates tablet input at driver level

### Network Protocol

#### Message Format
All messages are length-prefixed JSON:
```
[4 bytes length][JSON payload]
```

#### Touch Data
```json
{
  "type": "touch",
  "id": "unique-id",
  "x": 0.5,
  "y": 0.5,
  "pressure": 0.8,
  "phase": "moved",
  "timestamp": 1698765432.123
}
```

#### Screen Frame
```json
{
  "type": "screen_frame",
  "image": "base64-encoded-jpeg",
  "timestamp": 1698765432123
}
```

### Latency Optimization

1. **Network Layer**
   - Direct TCP connection (no HTTP overhead)
   - Binary protocol with minimal parsing
   - Connection pooling and reuse

2. **Touch Processing**
   - Immediate processing on separate thread
   - No buffering or queuing
   - Direct Win32 API calls

3. **Screen Capture**
   - Hardware-accelerated capture
   - JPEG compression with quality tuning
   - Adaptive frame rate based on network

### Tablet Driver Implementation

The virtual tablet driver uses Windows User32 API:

```csharp
// Absolute positioning (0-65535 range)
mouse_event(
    MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE,
    normalizedX,
    normalizedY,
    0,
    UIntPtr.Zero
);
```

This provides:
- Absolute positioning (like a real tablet)
- Sub-pixel precision
- Instant updates
- Compatible with OSU! tablet mode

### Pressure Sensitivity

#### iOS Implementation
- Apple Pencil: `UITouch.force / maximumPossibleForce`
- Finger touch: Defaults to 1.0
- Configurable pressure curves

#### Windows Implementation
- Windows doesn't expose pressure via mouse_event
- Pressure mapped to click state (threshold-based)
- Future: Could use WinTab API for true pressure

### Screen Mirroring

#### Capture Process
1. `Graphics.CopyFromScreen()` - Desktop capture
2. Resize to target resolution (1920x1080)
3. JPEG compression (quality: 75)
4. Base64 encoding
5. Send via WebSocket

#### Performance
- Target: 60 FPS
- Actual: 30-60 FPS depending on network
- Latency: 50-100ms typical
- Bandwidth: 5-15 Mbps

## Building the Project

### iOS App (Requires macOS + Xcode)
```bash
cd ios-app/OsuTablet
open OsuTablet.xcodeproj
# Build in Xcode: Product > Build (Cmd+B)
# Run on device: Product > Run (Cmd+R)
```

**Requirements:**
- Xcode 15+
- iOS 17+ SDK
- Apple Developer account (for device testing)
- Provisioning profile configured

### Windows App
```powershell
cd windows-app/OsuTabletDriver
dotnet restore
dotnet build --configuration Release
dotnet publish -c Release -r win-x64 --self-contained true
```

**Or use the build script:**
```powershell
.\build-windows.ps1
```

**Requirements:**
- .NET 8.0 SDK
- Windows 10 SDK
- Visual Studio 2022 (optional, for debugging)

## Testing

### Local Testing Setup
1. Connect both devices to same WiFi network
2. Note your PC's local IP address
3. Launch Windows app first (as Administrator)
4. Launch iOS app on iPad
5. Connect via auto-discovery or manual IP

### Performance Testing
Monitor these metrics:
- **Touch Latency**: <10ms ideal
- **Network Latency**: <20ms ideal
- **Touch Rate**: 120+ Hz
- **Screen FPS**: 60 FPS target

### OSU! Integration Testing
1. Launch OSU! on Windows
2. Open Options > Input
3. Tablet should be detected automatically
4. Test in practice mode
5. Monitor latency indicator

## Troubleshooting

### Connection Issues
- Firewall blocking port 9876
- Different subnets
- VPN interference
- WiFi isolation mode enabled

### Performance Issues
- Network congestion (use 5GHz WiFi)
- CPU bottleneck (lower screen quality)
- Background apps consuming resources

### Driver Issues
- Not running as Administrator
- Antivirus blocking driver
- Windows security policies

## Future Enhancements

### High Priority
- [ ] WinTab API integration for true pressure
- [ ] USB-C direct connection option
- [ ] Advanced calibration wizard
- [ ] Pressure curve customization UI

### Medium Priority
- [ ] Multiple monitor support
- [ ] Android tablet support
- [ ] macOS support
- [ ] Gesture shortcuts

### Low Priority
- [ ] Cloud settings sync
- [ ] Telemetry and analytics
- [ ] Theme customization
- [ ] Plugin system

## Performance Considerations

### iOS Battery Life
- Screen always-on drains battery
- Network usage is moderate
- Recommend: iPad plugged in during use

### Windows Resource Usage
- CPU: 5-15% (screen capture)
- RAM: ~100 MB
- Network: 5-15 Mbps upload
- Minimal disk I/O

## Security Considerations

- Local network only (no internet exposure)
- No authentication (trust-based on local network)
- Admin privileges required (for driver access)
- No data collection or telemetry

## License & Attribution

This project uses:
- Newtonsoft.Json (MIT License)
- System.Drawing.Common (MIT License)
- Windows User32 API (Microsoft)

## Support & Community

For issues, questions, or contributions:
- GitHub Issues
- Documentation Wiki
- Community Discord (planned)

---

**Note:** This is an educational project demonstrating tablet driver development and cross-platform communication. Performance may vary based on hardware and network conditions.
