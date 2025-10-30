# 🔥 Firebase App Distribution Setup Guide

Firebase CLI is now installed on your system! Follow these steps to complete the setup:

---

## Step 1: Get Firebase Token

### Open a new PowerShell terminal and run:

```powershell
firebase login:ci
```

This will:
1. Open your web browser automatically
2. Ask you to sign in to your Google account
3. Grant permissions to Firebase CLI
4. Display a token in the terminal

**Copy the token** - it will look like this:
```
1//0abcdefgh1234567890-LONG-TOKEN-STRING
```

---

## Step 2: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add project"** or **"Create a project"**
3. Project name: `Penrion-OSU-Tablet`
4. Click **Continue**
5. Disable Google Analytics (optional, not needed for this project)
6. Click **Create project**
7. Wait for setup to complete

---

## Step 3: Enable App Distribution

1. In Firebase Console, go to **Build** → **App Distribution**
2. Click **"Get started"**
3. You're now ready to add your iOS app

---

## Step 4: Register iOS App

1. In Firebase Console → **Project Overview** (gear icon) → **Project settings**
2. Scroll to **"Your apps"** section
3. Click the **iOS icon** to add an iOS app
4. Fill in:
   - **iOS bundle ID**: `com.penrion.osutablet`
   - **App nickname**: `Penrion OSU Tablet` (optional)
   - Leave other fields empty
5. Click **"Register app"**
6. Skip the "Download config file" step (click Continue)
7. Skip the "Add SDK" step (click Continue)
8. Click **"Continue to console"**

---

## Step 5: Get Firebase App ID

1. In **Project settings** → **Your apps** section
2. Find your iOS app (`com.penrion.osutablet`)
3. Look for **App ID** - it looks like: `1:123456789012:ios:abcdef1234567890`
4. **Copy this App ID**

---

## Step 6: Add Credentials to Codemagic

### Add Firebase Token:
1. Go to https://codemagic.io/apps
2. Click on your **Penrion** app
3. Go to **Settings** → **Environment variables**
4. Click **"Add new variable"**
   - **Variable name**: `FIREBASE_TOKEN`
   - **Variable value**: (paste the token from Step 1)
   - Check ☑️ **"Secure"**
   - Click **Add**

### Add Firebase App ID:
1. Still in **Environment variables**
2. Click **"Add new variable"** again
   - **Variable name**: `FIREBASE_APP_ID`
   - **Variable value**: (paste the App ID from Step 5)
   - Check ☑️ **"Secure"**
   - Click **Add**

---

## Step 7: Update codemagic.yaml

The Firebase publishing configuration needs to be enabled in your `codemagic.yaml` file. 

I'll update this for you automatically - check the next message!

---

## Step 8: Add Testers (Optional)

1. In Firebase Console → **App Distribution**
2. Click **"Testers & Groups"** tab
3. Click **"Add testers"**
4. Enter email addresses (yours and anyone you want to test)
5. Click **"Add testers"**

---

## ✅ What Happens After Setup

Once configured:
1. Every Codemagic build will automatically upload the IPA to Firebase
2. You (and testers) will receive an email with download link
3. Download IPA from Firebase Console or Firebase App Tester app on iOS
4. IPAs are available indefinitely (no 30-day expiration)

---

## 📱 Installing from Firebase

### Option A: Direct Download
1. Open email from Firebase App Distribution
2. Click "Download"
3. Use AltStore/Sideloadly to install

### Option B: Firebase App (Recommended)
1. Install "Firebase App Tester" from App Store (free, no jailbreak needed)
2. Open app and sign in with your Google account
3. You'll see all available builds
4. Tap "Download" → "Install"
5. Works like TestFlight but without Apple's restrictions!

---

## 🔍 Verification

After you add the environment variables to Codemagic, trigger a new build:

1. Go to Codemagic → Your app
2. Click **"Start new build"**
3. Select workflow: `ios-workflow`
4. Click **"Start new build"**

If everything is configured correctly, you'll see:
- Build completes successfully
- "Publishing to Firebase App Distribution" step appears
- Build is available in Firebase Console

---

## 🆘 Troubleshooting

### "firebase: command not found"
- Close and reopen PowerShell terminal
- Firebase CLI is already installed, just needs terminal restart

### "Login failed"
- Make sure you're using your Google account
- Try: `firebase logout` then `firebase login:ci` again

### "Permission denied for App Distribution"
- In Firebase Console → Project Settings → Service Accounts
- Make sure App Distribution is enabled

### "Invalid App ID"
- Double-check the App ID format: `1:123456789012:ios:abcdef1234567890`
- Must match exactly, including colons

---

## 📋 Summary

**You've completed:**
- ✅ Firebase CLI installed (`firebase-tools` v14.22.0)

**Next steps:**
1. Open new PowerShell terminal
2. Run: `firebase login:ci`
3. Copy the token
4. Create Firebase project
5. Register iOS app
6. Add credentials to Codemagic
7. I'll update the YAML file for you

**Let me know when you have the Firebase token and App ID!**
