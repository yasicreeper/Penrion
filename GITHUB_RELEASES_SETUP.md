# 🚀 GitHub Releases Setup - Get Your IPA File!

✅ **I've added GitHub Releases support to your workflow!**

Now every build will automatically upload the IPA to your GitHub repository where you can easily download it.

---

## 📝 Quick Setup (2 Minutes)

### Step 1: Create GitHub Personal Access Token

1. **Go to GitHub Token Settings:**
   - Visit: https://github.com/settings/tokens
   - Or: GitHub → Click your profile → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **Generate New Token:**
   - Click **"Generate new token"** (dropdown)
   - Select **"Generate new token (classic)"**

3. **Configure Token:**
   - **Note:** `Codemagic Releases`
   - **Expiration:** No expiration (or 1 year)
   - **Select scopes:** Check ONLY this box:
     - ✅ **`repo`** (Full control of private repositories)
       - This will auto-select all repo sub-scopes

4. **Generate:**
   - Scroll to bottom
   - Click **"Generate token"**
   - **IMPORTANT:** Copy the token NOW (starts with `ghp_...`)
   - You won't be able to see it again!

**Example token:** `ghp_1234567890abcdefghijklmnopqrstuvwxyz123`

---

### Step 2: Add Token to Codemagic

1. **Go to Codemagic:**
   - Visit: https://codemagic.io/apps
   - Click on **Penrion** app

2. **Add Environment Variable:**
   - Go to **Settings** → **Environment variables**
   - Click **"Add new variable"**

3. **Fill in:**
   - **Variable name:** `GITHUB_TOKEN`
   - **Variable value:** (paste the token you just copied)
   - **Check:** ☑️ **"Secure"** (IMPORTANT!)
   - Click **"Add"**

---

### Step 3: Trigger New Build

1. In Codemagic dashboard, click **"Start new build"**
2. Select workflow: **`ios-workflow`**
3. Click **"Start new build"**
4. Wait 10-15 minutes for build to complete

---

## 🎉 After Build Completes

### Download Your IPA:

1. **Go to GitHub Releases:**
   - Visit: https://github.com/yasicreeper/Penrion/releases
   - Or: Your repo → Click **"Releases"** (right side)

2. **Find Latest Release:**
   - You'll see: **v1.0.1**, **v1.0.2**, etc.
   - Click on the latest release

3. **Download IPA:**
   - Under **"Assets"** section
   - Click **"Penrion-OsuTablet-Unsigned.ipa"**
   - File downloads to your Downloads folder!

**Direct link after first build:**
```
https://github.com/yasicreeper/Penrion/releases/latest
```

---

## 📋 What Gets Created

Each successful build creates a GitHub Release with:
- ✅ **Tag:** `v1.0.1`, `v1.0.2`, etc. (auto-increments)
- ✅ **IPA file:** `Penrion-OsuTablet-Unsigned.ipa`
- ✅ **Release notes:** Installation instructions included
- ✅ **Build info:** Date, build number, what's included

---

## 🎯 Benefits of GitHub Releases

- ✅ **Easy downloads** - One click from releases page
- ✅ **Permanent storage** - No 30-day expiration
- ✅ **Version history** - Keep all your builds
- ✅ **Public access** - Share links with others
- ✅ **No login required** - Anyone can download
- ✅ **Automatic** - Uploads after every successful build

---

## 📱 Install the IPA

Once downloaded, install using:

### Option A: Sideloadly (Recommended)
1. Download: https://sideloadly.io
2. Connect iPad to PC via USB
3. Drag IPA into Sideloadly
4. Enter Apple ID → Click Start
5. Done in 2 minutes!

### Option B: AltStore
1. Download: https://altstore.io
2. Install AltStore on PC and iPad
3. Open AltStore on iPad → Tap "+"
4. Select IPA file → Install
5. Re-sign every 7 days

---

## ✅ Quick Checklist

- [ ] Created GitHub Personal Access Token (with `repo` scope)
- [ ] Added `GITHUB_TOKEN` to Codemagic (marked as Secure)
- [ ] Started a new build in Codemagic
- [ ] Build completed successfully
- [ ] Went to https://github.com/yasicreeper/Penrion/releases
- [ ] Downloaded `Penrion-OsuTablet-Unsigned.ipa`
- [ ] Installed on iPad with Sideloadly/AltStore
- [ ] Connected iPad and PC to same WiFi
- [ ] Launched Windows app as Administrator
- [ ] Opened iOS app and connected!
- [ ] Started playing OSU! 🎮

---

## 🆘 Troubleshooting

### "Can't find Personal Access Tokens"
- Go to: https://github.com/settings/tokens
- Make sure you're creating "Tokens (classic)", not "Fine-grained tokens"

### "Token creation requires additional verification"
- GitHub may ask you to enter your password again
- Or enable 2FA if you have it

### "Publishing to GitHub failed" in build logs
- Make sure you checked "Secure" when adding token
- Verify token has `repo` scope
- Try regenerating the token

### "No releases found"
- Wait for build to complete (green checkmark)
- Refresh the releases page
- Check build logs for "Publishing to GitHub"

### "Download link not working"
- Make sure repo is public (or you're logged into GitHub)
- Try: https://github.com/yasicreeper/Penrion/releases/latest

---

## 🔐 Security Note

**The GitHub token gives access to your repository!**
- ✅ Always mark it as "Secure" in Codemagic
- ✅ Never share your token
- ✅ Can revoke anytime at: https://github.com/settings/tokens
- ✅ Expires automatically if you set expiration

---

## 💡 What Happens Now

**Every time you push code to GitHub:**
1. Codemagic automatically builds the app
2. Creates a new IPA file
3. Uploads to GitHub Releases with auto-incrementing version
4. You get email notification
5. Download from: https://github.com/yasicreeper/Penrion/releases

**No more "where is my IPA file?" problems!** 🎉

---

## 🎬 Next Steps

1. **Create the GitHub token** (Step 1 above)
2. **Add it to Codemagic** (Step 2 above)
3. **Start a new build** (Step 3 above)
4. **Check releases page** after build completes

**Your IPA will be at:**
```
https://github.com/yasicreeper/Penrion/releases
```

---

**Let me know when you've added the token and I'll help you trigger the build!** 🚀
