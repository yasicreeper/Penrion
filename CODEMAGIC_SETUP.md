# 🚀 Codemagic CI/CD Setup Guide

## Overview
Codemagic will automatically build your iOS IPA file in the cloud every time you push changes to GitHub. No Mac required after initial setup!

## Benefits
✅ No Mac needed for building  
✅ Automatic builds on every commit  
✅ Cloud-based signing and packaging  
✅ Free tier available (500 build minutes/month)  
✅ Ready-to-install IPA files  

---

## Step 1: Sign Up for Codemagic

1. Go to https://codemagic.io
2. Click "Sign up for free"
3. Sign up with your GitHub account
4. Authorize Codemagic to access your repositories

---

## Step 2: Connect Your Repository

1. In Codemagic dashboard, click **"Add application"**
2. Select **GitHub** as the source
3. Find and select **"yasicreeper/Penrion"**
4. Codemagic will automatically detect the `codemagic.yaml` file

---

## Step 3: Configure Code Signing (For Signed IPA)

### Option A: For Jailbroken/Sideloading (Unsigned - Easiest)
- Select workflow: **"iOS Penrion (Unsigned for Sideloading)"**
- No code signing required!
- Click **"Start your first build"**
- Skip to Step 5

### Option B: For Regular Devices (Signed IPA)
You'll need an Apple Developer account ($99/year or free account):

1. In Codemagic, go to **Teams > Your team > Integrations**
2. Click **"App Store Connect"**
3. Follow the wizard to connect your Apple ID:
   - App Store Connect API key (for paid accounts)
   - OR Apple ID credentials (for free accounts)

4. Configure signing certificate:
   - **Automatic signing** (recommended): Codemagic handles everything
   - **Manual signing**: Upload your .p12 certificate and provisioning profile

---

## Step 4: Push the Configuration File

```powershell
# Add the codemagic.yaml file
git add codemagic.yaml

# Commit the changes
git commit -m 'Add Codemagic CI/CD workflow for iOS builds'

# Push to GitHub
git push origin main
```

---

## Step 5: Start Your First Build

1. In Codemagic dashboard, select your app **"Penrion"**
2. Select the workflow:
   - **"iOS Penrion (Unsigned for Sideloading)"** - for jailbreak/AltStore
   - **"iOS Penrion OSU Tablet"** - for signed IPA
3. Click **"Start new build"**
4. Select branch: **"main"**
5. Click **"Start build"**

Build will take 5-10 minutes.

---

## Step 6: Download Your IPA

Once build completes:

1. Click on the completed build
2. Go to **"Artifacts"** tab
3. Download the IPA file:
   - `Penrion-OsuTablet-Unsigned.ipa` (for unsigned)
   - `OsuTablet.ipa` (for signed)

---

## Automatic Builds

After setup, Codemagic will automatically:
- ✅ Build IPA on every push to `main` branch
- ✅ Email you when build completes
- ✅ Store artifacts for 30 days

---

## Configuration Details

### Workflows Included

#### 1. `ios-workflow` (Signed)
- For App Store, TestFlight, or enterprise distribution
- Requires Apple Developer account
- Auto-increments build number
- Creates signed IPA

#### 2. `ios-unsigned-workflow` (Unsigned)
- For jailbroken devices or sideloading
- No Apple Developer account needed
- Works with AltStore, SideStore, Sideloadly
- Creates unsigned IPA

---

## Customization

### Change Bundle Identifier
Edit `codemagic.yaml`:
```yaml
environment:
  vars:
    BUNDLE_ID: "com.yourname.osutablet"  # Change this
```

### Change Build Settings
```yaml
instance_type: mac_mini_m1  # Options: mac_mini_m1, mac_pro
xcode: 15.0                  # Xcode version
max_build_duration: 60       # Minutes (max 120)
```

### Add Notification Email
```yaml
publishing:
  email:
    recipients:
      - your-email@example.com  # Change this
```

---

## Build Status Badge

Add to your README.md:
```markdown
[![Codemagic build status](https://api.codemagic.io/apps/<app-id>/workflows/<workflow-id>/status_badge.svg)](https://codemagic.io/apps/<app-id>/workflows/<workflow-id>/latest_build)
```

Get your app-id from Codemagic dashboard URL.

---

## Troubleshooting

### Build Fails with Code Signing Error
- For unsigned builds: Use `ios-unsigned-workflow`
- For signed builds: Verify Apple Developer account connection

### "No Podfile found" Warning
- This is normal if you don't use CocoaPods
- The build will continue successfully

### Xcode Version Issues
- Change `xcode: 15.0` in codemagic.yaml to match your needs
- Available versions: 14.0, 14.3, 15.0, 15.1, etc.

### Build Takes Too Long
- Check build logs for bottlenecks
- Consider using a faster instance type (paid plans)

---

## Cost

### Free Tier
- 500 build minutes per month
- ~50 iOS builds per month
- Perfect for personal projects

### Paid Plans (if needed)
- **Hobbyist**: $28/month - 3,000 minutes
- **Professional**: $68/month - 10,000 minutes
- **Enterprise**: Custom pricing

---

## Alternative: GitHub Actions

If you prefer GitHub Actions instead, we can set that up too (requires self-hosted macOS runner or paid minutes).

---

## Next Steps After Build

1. **Download IPA** from Codemagic artifacts
2. **Install on iPad** using one of these methods:
   - AltStore (easiest for non-jailbroken)
   - Sideloadly
   - AppSync Unified (jailbroken)
   - Xcode (if you have a Mac)

See `IPA_BUILD_GUIDE.md` for detailed installation instructions.

---

## Support

- **Codemagic Docs**: https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/
- **Codemagic Support**: support@codemagic.io
- **Project Issues**: https://github.com/yasicreeper/Penrion/issues

---

## Summary

1. ✅ Created `codemagic.yaml` configuration
2. ⏳ Sign up at codemagic.io
3. ⏳ Connect GitHub repository
4. ⏳ Push configuration file
5. ⏳ Start first build
6. ⏳ Download IPA and install on iPad

**Estimated setup time: 10-15 minutes**
