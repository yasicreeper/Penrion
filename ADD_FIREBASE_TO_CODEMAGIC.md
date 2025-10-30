# 🔥 Add Firebase Service Account to Codemagic

You're almost done! The `codemagic.yaml` is already configured with your Firebase App ID and email. Now you just need to add the Firebase service account credentials.

---

## ⚠️ Current Error

```
Environment variable FIREBASE_SERVICE_ACCOUNT used in "workflows -> ios-unsigned-workflow -> publishing -> firebase -> firebase_service_account" is not accessible
```

**This means:** Codemagic can't find the `FIREBASE_SERVICE_ACCOUNT` variable.

---

## ✅ Solution: Add Service Account to Codemagic

### Step 1: Get Firebase Service Account JSON

1. Go to **Firebase Console**: https://console.firebase.google.com
2. Select your project: **Penrion-OSU-Tablet**
3. Click **⚙️ gear icon** (top left) → **Project settings**
4. Click **"Service accounts"** tab
5. Click **"Generate new private key"** button
6. Confirm by clicking **"Generate key"**
7. A JSON file downloads (e.g., `penrion-osu-tablet-abc123.json`)

---

### Step 2: Add to Codemagic Environment Variables

1. Go to **Codemagic**: https://codemagic.io/apps
2. Click on your **Penrion** app
3. Go to **Settings** → **Environment variables**
4. Click **"Add new variable"**

**Fill in:**
- **Variable name**: `FIREBASE_SERVICE_ACCOUNT`
- **Variable value**: 
  1. Open the JSON file with Notepad
  2. Select ALL text (Ctrl+A)
  3. Copy (Ctrl+C)
  4. Paste into the "Variable value" field
- **Check ☑️ "Secure"** (IMPORTANT!)
- Click **"Add"**

---

### Step 3: Verify Setup

After adding the variable, you should see in Codemagic:

**Environment Variables:**
- ✅ `FIREBASE_SERVICE_ACCOUNT` (Secured) 🔒
- ✅ `FIREBASE_APP_ID` = `1:1061806026619:ios:61b583e58fe3683abb97de` (if you added this too)

---

### Step 4: Trigger New Build

1. In Codemagic, click **"Start new build"**
2. Select workflow: **`ios-workflow`** or **`ios-unsigned-workflow`**
3. Click **"Start new build"**

---

## 📋 What the JSON Should Look Like

When you open the JSON file, it should contain:

```json
{
  "type": "service_account",
  "project_id": "penrion-osu-tablet-xyz",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xyz@penrion-osu-tablet-xyz.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

**⚠️ Copy and paste the ENTIRE content** (from `{` to `}`)

---

## 🎯 What Happens Next

Once the `FIREBASE_SERVICE_ACCOUNT` is added:

1. ✅ Codemagic builds will complete successfully
2. ✅ IPA automatically uploads to Firebase App Distribution
3. ✅ You receive email at: **yasicree9@gmail.com**
4. ✅ Download link in email (valid forever!)
5. ✅ Can also download from Firebase Console

---

## 🆘 Troubleshooting

### "JSON is too large"
- Codemagic accepts up to 20 KB for environment variables
- Firebase service account JSON is typically 2-4 KB
- Make sure you checked the "Secure" checkbox (allows larger values)

### "Still getting environment variable error"
- Make sure variable name is EXACTLY: `FIREBASE_SERVICE_ACCOUNT` (case-sensitive)
- Verify you clicked "Add" button after pasting JSON
- Try refreshing the Codemagic page

### "Can't find the downloaded JSON file"
- Check your **Downloads** folder
- File name: `penrion-osu-tablet-{random}.json` or similar
- If lost, just regenerate a new key (Step 1)

### "Permission denied" errors in build
- Make sure the JSON is valid (proper format)
- Try regenerating the service account key
- Ensure Firebase App Distribution is enabled in Firebase Console

---

## 🔐 Security Reminder

**IMPORTANT:**
- ✅ Always check "Secure" when adding to Codemagic
- ❌ Never commit this JSON to GitHub
- ❌ Never share this JSON publicly
- ✅ Keep the downloaded JSON file in a safe place (or delete it after adding to Codemagic)

---

## ✅ Quick Checklist

- [ ] Downloaded service account JSON from Firebase
- [ ] Opened JSON with Notepad
- [ ] Copied entire JSON content
- [ ] Added to Codemagic as `FIREBASE_SERVICE_ACCOUNT`
- [ ] Checked "Secure" checkbox
- [ ] Clicked "Add" button
- [ ] Triggered new build
- [ ] Build succeeds and uploads to Firebase! 🎉

---

## 📱 After Successful Build

**You'll receive an email at yasicree9@gmail.com with:**
- Build status notification
- Direct download link to IPA
- Instructions to install

**Or download from Firebase Console:**
1. Go to: https://console.firebase.google.com
2. Select your project
3. Go to: Build → App Distribution
4. See all your builds with download buttons
5. Click download → Install with AltStore/Sideloadly

---

## 🎉 That's It!

Once you add the `FIREBASE_SERVICE_ACCOUNT` variable to Codemagic, everything is configured and ready to go!

**Your configuration is already perfect:**
- ✅ `codemagic.yaml` has Firebase publishing enabled
- ✅ App ID: `1:1061806026619:ios:61b583e58fe3683abb97de`
- ✅ Email: `yasicree9@gmail.com`
- ⏳ Just need to add service account JSON

**Go ahead and add it now! Then trigger a new build and you're done!** 🚀
