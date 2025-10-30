# 📥 How to Download IPA from Codemagic

## Method 1: Direct Download from Build Page (EASIEST) ✅

### Steps:
1. **Go to Codemagic Dashboard**
   - Visit: https://codemagic.io/apps
   - Click on your "Penrion" app

2. **Find Your Build**
   - Click on the latest successful build (green checkmark ✓)
   - This opens the build details page

3. **Download IPA**
   - Scroll down to the **"Build artifacts"** section
   - You should see: `Penrion-OsuTablet-Unsigned.ipa`
   - Click the **download icon** next to it
   - File will download to your computer

**Build URL format:** `https://codemagic.io/app/{app-id}/build/{build-id}`

---

## Method 2: Email with Download Link 📧

### Setup in Codemagic:
1. Go to Codemagic Dashboard
2. Select your app
3. Click **"Settings"** → **"Email notifications"**
4. Add your email address
5. Enable "Attach artifacts" option

### After Build:
- You'll receive an email with:
  - Build status
  - Direct download link to IPA
  - Build logs link

---

## Method 3: Slack Webhook (For Teams) 💬

If you use Slack, add this to `codemagic.yaml`:

```yaml
publishing:
  slack:
    channel: '#ios-builds'
    notify_on_build_start: false
    notify:
      success: true
      failure: true
```

Then in Codemagic:
1. Settings → Integrations → Slack
2. Connect your workspace
3. Select channel for notifications
4. Builds will post download links automatically

---

## Method 4: Firebase App Distribution 🔥

### One-Time Setup:

1. **Create Firebase Project:**
   - Go to https://console.firebase.google.com
   - Click "Add project"
   - Name it "Penrion-OSU-Tablet"
   - Disable Google Analytics (optional)

2. **Enable App Distribution:**
   - In Firebase Console → Build → App Distribution
   - Click "Get started"
   - Add testers (your email addresses)

3. **Get Firebase Token:**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login and get token
   firebase login:ci
   ```
   Copy the token that appears

4. **Add to Codemagic:**
   - Go to Codemagic → Your App → Settings
   - Environment variables → Add variable
   - Name: `FIREBASE_TOKEN`
   - Value: (paste the token from step 3)
   - Check "Secure"

5. **Get Firebase App ID:**
   - Firebase Console → Project Settings → Your apps
   - Click "Add app" → iOS
   - Register app with bundle ID: `com.penrion.osutablet`
   - Copy the **App ID** (format: `1:123456789:ios:abcdef`)

6. **Add App ID to Codemagic:**
   - Codemagic → Environment variables
   - Name: `FIREBASE_APP_ID`
   - Value: (paste App ID)
   - Check "Secure"

### After Setup:
- Builds automatically upload to Firebase
- You and testers get email notifications
- Download IPA from Firebase Console or mobile app
- No 7-day expiration like TestFlight!

---

## Method 5: Google Drive Upload 📁

### One-Time Setup:

1. **Create Google Cloud Service Account:**
   - Go to https://console.cloud.google.com
   - Create new project: "Penrion-Builds"
   - Enable Google Drive API
   - Create Service Account
   - Download JSON key file

2. **Share Google Drive Folder:**
   - Create folder in Drive: "iOS Builds"
   - Share with service account email (from JSON)
   - Give "Editor" permission

3. **Add to Codemagic:**
   - Codemagic → Settings → Environment variables
   - Name: `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`
   - Value: (paste entire JSON file content)
   - Check "Secure"

### After Setup:
- Each build uploads IPA to your Google Drive
- Access from any device
- Never expires
- Shareable links

---

## 🎯 Recommended Approach

### For Personal Use (Just You):
**→ Use Method 1 or 2** (Direct download or Email)
- No setup required
- Works immediately
- Simple and reliable

### For Team/Testing:
**→ Use Method 4** (Firebase App Distribution)
- Professional testing workflow
- Automatic notifications to testers
- Install via Firebase App (no manual sideloading)
- Build distribution tracking

### For Long-term Storage:
**→ Use Method 5** (Google Drive)
- Permanent storage
- Access from anywhere
- Version history

---

## 🆘 Troubleshooting

### "Can't find Build artifacts section"
- Make sure build completed successfully (green ✓)
- Try refreshing the page
- Check that `artifacts:` section is in codemagic.yaml

### "Download link expired"
- Codemagic keeps builds for 30 days by default
- Re-run the build if needed
- Set up Google Drive for permanent storage

### "Email not receiving artifacts"
- Check spam folder
- Verify email in Codemagic settings
- Make sure "Attach artifacts" is enabled

### "Firebase upload failing"
- Check Firebase token is valid: `firebase login:ci`
- Verify App ID matches your bundle identifier
- Ensure Firebase App Distribution is enabled

---

## 📝 Current Configuration

Your `codemagic.yaml` already has:
```yaml
artifacts:
  - release/ios/*.ipa
```

This means Codemagic will:
✅ Save the IPA file after build
✅ Make it available for download on build page
✅ Keep it for 30 days

**Just go to your build page and look for "Build artifacts"!**

---

## 🔗 Useful Links

- **Codemagic Dashboard:** https://codemagic.io/apps
- **Firebase Console:** https://console.firebase.google.com
- **Google Cloud Console:** https://console.cloud.google.com
- **Codemagic Docs - Artifacts:** https://docs.codemagic.io/yaml-publishing/artifacts/
- **Codemagic Docs - Firebase:** https://docs.codemagic.io/yaml-publishing/firebase-app-distribution/

---

## ✅ Quick Checklist

- [ ] Build completed successfully in Codemagic
- [ ] Open build details page
- [ ] Scroll to "Build artifacts" section
- [ ] Click download button
- [ ] IPA file downloads to your computer
- [ ] Install on iPad using AltStore/Sideloadly

**That's it!** The IPA should be directly downloadable from the Codemagic build page.
