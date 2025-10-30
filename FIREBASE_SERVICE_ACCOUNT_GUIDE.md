# 🔥 Firebase Setup with Service Account (Recommended Method)

The `firebase login:ci` command is deprecated. Let's use the **recommended service account method** instead - it's actually better for Codemagic CI/CD!

---

## ✅ Why Service Account is Better

- ✅ **More secure** - no personal account tokens
- ✅ **No expiration** - tokens don't expire like user tokens
- ✅ **CI/CD optimized** - designed for automated builds
- ✅ **Recommended by Google** - official best practice

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add project"** or **"Create a project"**
3. Project name: **`Penrion-OSU-Tablet`**
4. Click **Continue**
5. **Disable** Google Analytics (not needed)
6. Click **Create project**
7. Wait for setup (~30 seconds)

---

### Step 2: Enable App Distribution

1. In Firebase Console, click **Build** → **App Distribution**
2. Click **"Get started"**
3. You'll see "No releases yet" - that's fine!

---

### Step 3: Register iOS App

1. Click the **⚙️ gear icon** (top left) → **Project settings**
2. Scroll to **"Your apps"** section
3. Click the **Apple icon** 🍎 (Add iOS app)
4. Fill in:
   - **iOS bundle ID**: `com.penrion.osutablet`
   - **App nickname**: `Penrion OSU Tablet`
   - **App Store ID**: (leave empty)
5. Click **"Register app"**
6. Click **"Continue"** (skip downloading config)
7. Click **"Continue"** (skip adding SDK)
8. Click **"Continue to console"**

---

### Step 4: Get Firebase App ID

1. Still in **Project settings** → **Your apps**
2. Find your iOS app (should show `com.penrion.osutablet`)
3. Look for **App ID** - looks like: `1:123456789012:ios:abc123def456`
4. **📋 Copy this App ID** - save it somewhere

---

### Step 5: Create Service Account & Get JSON Key

1. In Firebase Console, click **⚙️ gear icon** → **Project settings**
2. Click the **"Service accounts"** tab
3. Click **"Generate new private key"**
4. A popup appears: **"Generate new private key?"**
5. Click **"Generate key"**
6. A JSON file downloads automatically (e.g., `penrion-osu-tablet-abc123.json`)
7. **📁 Save this file securely** - we'll need it next

---

### Step 6: Add Credentials to Codemagic

#### Option A: Using Web Interface (Easier)

1. Go to https://codemagic.io/apps
2. Click on your **Penrion** app
3. Go to **Settings** → **Environment variables**

**Add Firebase App ID:**
4. Click **"Add new variable"**
   - **Variable name**: `FIREBASE_APP_ID`
   - **Variable value**: (paste the App ID from Step 4)
   - Check ☑️ **"Secure"**
   - Click **"Add"**

**Add Service Account Key:**
5. Click **"Add new variable"** again
6. Open the JSON file you downloaded in Step 5 with Notepad
7. Copy **the entire JSON content** (from `{` to `}`)
8. In Codemagic:
   - **Variable name**: `FIREBASE_SERVICE_ACCOUNT`
   - **Variable value**: (paste the entire JSON)
   - Check ☑️ **"Secure"**
   - Click **"Add"**

---

### Step 7: Update codemagic.yaml

Now I'll add the Firebase App Distribution configuration to your `codemagic.yaml` file.

**I'll do this automatically for you - check the next message!**

---

## 📝 What the JSON File Contains

The service account JSON looks like this:
```json
{
  "type": "service_account",
  "project_id": "penrion-osu-tablet",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xyz@penrion-osu-tablet.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

**⚠️ Keep this file secret!** It grants full access to your Firebase project.

---

## 🎯 After Setup

Once configured and pushed to GitHub, every Codemagic build will:

1. ✅ Build your iOS app
2. ✅ Create unsigned IPA
3. ✅ **Automatically upload to Firebase App Distribution**
4. ✅ Send email notifications to testers
5. ✅ Make IPA available for download (no expiration!)

---

## 📱 How to Download & Install

### From Firebase Console:
1. Go to Firebase Console → App Distribution
2. Click on your app
3. See all releases with download buttons
4. Download IPA → Install with AltStore/Sideloadly

### From Firebase App Tester (iOS):
1. Install "Firebase App Tester" from App Store (free)
2. Sign in with the Google account you used
3. See all builds automatically
4. Tap install → Works like TestFlight!

---

## 🆘 Troubleshooting

### "Can't find the JSON file"
- Check your Downloads folder
- File name: `penrion-osu-tablet-{random}.json`
- If lost, generate a new key (Step 5)

### "JSON is too large for environment variable"
- This is normal (5-10 KB)
- Codemagic accepts up to 20 KB for secure variables
- Make sure you checked the "Secure" checkbox

### "Service account permissions error"
- Firebase automatically grants correct permissions
- If you see errors, regenerate the key in Step 5

### "App ID not working"
- Must match exact format: `1:123456789012:ios:abc123def456`
- Get it from Project Settings → Your apps
- Bundle ID must match: `com.penrion.osutablet`

---

## 🔐 Security Best Practices

✅ **DO:**
- Store JSON file securely
- Use "Secure" checkbox in Codemagic for both variables
- Keep JSON out of git repository

❌ **DON'T:**
- Commit JSON to GitHub
- Share JSON in public places
- Use personal Google account tokens

---

## ✅ Checklist

- [ ] Firebase project created
- [ ] App Distribution enabled
- [ ] iOS app registered with bundle ID `com.penrion.osutablet`
- [ ] App ID copied
- [ ] Service account JSON downloaded
- [ ] `FIREBASE_APP_ID` added to Codemagic (Secure)
- [ ] `FIREBASE_SERVICE_ACCOUNT` added to Codemagic (Secure)
- [ ] codemagic.yaml updated (I'll do this)
- [ ] Git pushed to trigger build

---

## 📋 Summary

**What you need to provide me:**
1. ✅ Firebase App ID (from Step 4)
2. ✅ Confirmation that both environment variables are added to Codemagic

**What I'll do:**
1. Update `codemagic.yaml` with Firebase publishing configuration
2. Commit and push to GitHub
3. Guide you through triggering a new build

**Let me know when you've completed Steps 1-6!**
