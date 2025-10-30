# Troubleshooting Guide

## Windows App Issues

### Issue: App closes immediately after running

**Solution:**
The app requires Administrator privileges. You must:
1. Right-click `OsuTabletDriver.exe`
2. Select **"Run as administrator"**
3. Click "Yes" when Windows UAC prompt appears

### Issue: "Access Denied" or "Elevated Rights Required" error

**Cause:** The app is not running with Administrator privileges.

**Solution:**
- **Method 1:** Right-click the exe and select "Run as administrator" every time
- **Method 2:** Set permanent admin rights:
  1. Right-click `OsuTabletDriver.exe`
  2. Select "Properties"
  3. Go to "Compatibility" tab
  4. Check "Run this program as an administrator"
  5. Click "Apply" and "OK"

### Issue: App crashes with error dialog

**Steps to diagnose:**
1. Check the error log file at:
   ```
   C:\Users\[YourUsername]\Documents\OsuTabletDriver_Error.log
   ```
2. Open the log file in Notepad to see detailed error information
3. Common issues:
   - **Port 9876 already in use:** Another program is using the network port
   - **Network error:** Firewall is blocking the connection
   - **Driver initialization failed:** Not running as Administrator

### Issue: Firewall blocking connections

**Solution:**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Click "Change settings"
4. Click "Allow another app..."
5. Browse to `OsuTabletDriver.exe`
6. Check both "Private" and "Public" networks
7. Click "OK"

### Issue: Cannot connect from iPad

**Checklist:**
- [ ] Both devices are on the same WiFi network
- [ ] Windows app is running as Administrator
- [ ] Firewall allows OsuTabletDriver (see above)
- [ ] No VPN is active on either device
- [ ] Port 9876 is not blocked by router

**Test connection:**
1. On Windows, open Command Prompt
2. Type: `ipconfig` and press Enter
3. Find your IPv4 Address (e.g., 192.168.1.100)
4. On iPad, enter this IP address in the app

### Issue: High latency or lag

**Solutions:**
- Use 5GHz WiFi instead of 2.4GHz
- Reduce the distance between devices and router
- Close other network-intensive applications
- Lower the screen streaming quality in settings
- Ensure no one else is using heavy bandwidth on your network

## iOS App Issues

### Issue: Cannot install IPA file

**For Jailbroken Devices:**
1. Install AppSync Unified from Karen's Repo
2. Use Filza to open the IPA file
3. Tap "Install"

**For Non-Jailbroken Devices:**
1. Install AltStore (https://altstore.io)
2. Connect iPad to computer with AltStore
3. Open IPA file with AltStore
4. Note: Apps expire after 7 days (free account)

### Issue: App crashes on launch (iOS)

**Solutions:**
1. Reinstall the app
2. Check iOS version (requires iOS 17.0+)
3. Reset network settings: Settings > General > Reset > Reset Network Settings
4. Restart iPad

### Issue: Touch input not working

**Checklist:**
- [ ] iPad is connected to Windows app (check connection status)
- [ ] Touch input is enabled in OSU! Mode
- [ ] Active area is configured correctly
- [ ] Windows app is running as Administrator

### Issue: No pressure sensitivity

**Requirements:**
- Apple Pencil (1st or 2nd generation)
- iPad model that supports Apple Pencil
- Pressure sensitivity enabled in settings

**If you don't have Apple Pencil:**
- App will work with finger touch
- Pressure will be simulated based on touch

## Network Configuration

### Finding your PC's IP Address

**Windows:**
1. Press `Win + R`
2. Type `cmd` and press Enter
3. Type `ipconfig` and press Enter
4. Look for "IPv4 Address" under your WiFi adapter
5. It will look like: `192.168.1.XXX` or `10.0.0.XXX`

### Port Forwarding (if needed)

If devices are on different networks:
1. Access your router settings (usually http://192.168.1.1)
2. Find "Port Forwarding" or "Virtual Server"
3. Forward port `9876` to your PC's local IP
4. Protocol: TCP
5. Save settings

## Performance Optimization

### For Best Performance:

**Windows PC:**
- Close unnecessary background applications
- Disable Windows Game Mode (can cause conflicts)
- Use wired Ethernet connection if possible
- Update graphics drivers

**iPad:**
- Close all other apps
- Enable Low Power Mode (Settings > Battery)
- Disable Background App Refresh
- Keep iPad plugged in during use

**Network:**
- Use 5GHz WiFi band
- Place router in central location
- Minimum recommended: 50 Mbps
- Keep devices within 30 feet of router

## Still Having Issues?

### Collect Diagnostic Information:

1. **Windows Error Log:**
   - Location: `C:\Users\[YourUsername]\Documents\OsuTabletDriver_Error.log`

2. **System Information:**
   - Windows Version: Press `Win + R`, type `winver`, press Enter
   - .NET Version: Open Command Prompt, type `dotnet --version`
   - iOS Version: Settings > General > About

3. **Network Test:**
   - On Windows Command Prompt: `ping [iPad IP address]`
   - Both devices should be able to ping each other

### Create a GitHub Issue:

Visit: https://github.com/yasicreeper/Penrion/issues

Include:
- Description of the problem
- Error messages (if any)
- Error log file contents
- Windows and iOS versions
- Steps you've already tried

---

## Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| App won't start | Run as Administrator |
| Can't connect | Check firewall and network |
| High latency | Use 5GHz WiFi |
| No pressure | Need Apple Pencil |
| App expires (iOS) | Resign with AltStore (every 7 days) |

---

**Last Updated:** October 30, 2025
