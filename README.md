# FlowDesk (testing-xcode)

A native iOS todo app built with SwiftUI and Xcode.

This is **not** an Expo or React Native project — there is no EAS build. Everything runs through Xcode and Apple’s toolchain.

## Requirements

- macOS
- [Xcode](https://developer.apple.com/xcode/) (with iOS Simulator)
- Apple Developer account (for TestFlight and App Store distribution)

## Run the app

1. Open `testing-xcode.xcodeproj` in Xcode.
2. Choose a simulator or a connected iPhone in the toolbar.
3. Press **Run** (`Cmd+R`).

Cursor can edit the Swift files, but you need Xcode to build and run the app.

---

## Xcode Canvas (SwiftUI Preview)

The Canvas shows a live preview of your UI while you edit Swift files.

### Refresh the Canvas

- **Option + Cmd + P** — refresh preview after code changes
- **Editor → Canvas → Refresh Canvas**

### If the preview dies (“Debug session ended… killed”)

1. Click **Resume** (▶) in the bottom-left of the Canvas area.
2. Press **Option + Cmd + P**.
3. If it still fails: **Product → Clean Build Folder** (`Shift + Cmd + K`), then refresh again.
4. Last resort: toggle Canvas off/on with **Option + Cmd + Enter**.

### Canvas tips

- **Pause** (⏸) stops live preview; **Resume** (▶) starts it again.
- Refreshing the Canvas **does not** reset saved app data — it only re-renders the UI.
- The Canvas uses the same `UserDefaults` storage as the simulator, so tasks you complete in preview can persist between refreshes.

### Reset data in the Canvas

Clear saved tasks and onboarding:

```bash
defaults delete testing.testing-xcode flowdesk.todos
defaults delete testing.testing-xcode flowdesk.onboarding
```

Then refresh the Canvas (**Option + Cmd + P**).

To wipe all app defaults at once:

```bash
defaults delete testing.testing-xcode
```

---

## iOS Simulator

### Reset the app (fresh start)

**Easiest:** delete the app from the simulator home screen (click and hold → Remove App), then run again from Xcode (`Cmd+R`).

**Reset the whole simulator:**

- **Device → Erase All Content and Settings…** (in the Simulator menu bar)

Or in Xcode:

- **Window → Devices and Simulators → Simulators** → right-click a simulator → **Erase All Content and Settings**

### In-app reset (partial)

On the **You** tab, **Show onboarding again** resets onboarding only — it does **not** delete tasks.

---

## Development tips

| Tip | Detail |
|---|---|
| Haptics | Success haptic fires when completing a task. Best felt on a **physical iPhone**; simulator haptics are weaker. |
| Clean build | **Shift + Cmd + K** clears build artifacts; it does **not** clear app data. |
| Git vs TestFlight | Pushing to GitHub saves your code. TestFlight requires a separate **Archive → Upload** flow in Xcode. |

---

## First version: zero to App Store

Use this once when setting up a brand-new app. After that, skip to [Upload a new build](#upload-a-new-build) for TestFlight updates or [Release on the App Store](#release-on-the-app-store) for public launches.

### 1. Apple Developer account

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
2. Wait for approval (can take a day or two the first time).

### 2. Register the Bundle ID

The bundle ID must match Xcode exactly: **`testing.testing-xcode`**

1. Go to [Apple Developer → Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list).
2. Click **+** → **App IDs** → **App**.
3. Enter a description (e.g. `FlowDesk`) and the bundle ID **`testing.testing-xcode`**.
4. Leave capabilities as default for this app (no special entitlements needed).
5. Click **Register**.

> If you create the app in App Store Connect first (step 3), Apple may register the bundle ID for you automatically.

### 3. Create the app in App Store Connect

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **+** → **New App**.
2. Fill in:
   - **Platforms**: iOS
   - **Name**: FlowDesk (or your public App Store name)
   - **Primary language**: English (or your choice)
   - **Bundle ID**: select **`testing.testing-xcode`**
   - **SKU**: any unique string you’ll never change (e.g. `flowdesk-ios-001`)
   - **User Access**: Full Access (unless you use a limited role)
3. Click **Create**.

You now have an empty app record. You still need a build before TestFlight or the App Store can do anything useful.

### 4. Configure Xcode (before first upload)

Open `testing-xcode.xcodeproj` and select the **testing-xcode** target.

**Signing & Capabilities**

- **Team**: your Apple Developer team
- **Bundle Identifier**: `testing.testing-xcode`
- **Automatically manage signing**: enabled

Xcode will create provisioning profiles for you on the first archive.

**General → Identity**

- **Display Name**: what appears under the icon on the home screen (e.g. `FlowDesk`)
- **Version**: `1.0` (user-facing; change for major releases)
- **Build**: start at `1`, increment on **every** upload (`1`, `2`, `3`…)

**App Icon**

- Add icons in `testing-xcode/Assets.xcassets/AppIcon.appiconset/`
- App Store Connect rejects uploads missing a **1024×1024** App Store icon
- This project already includes a full icon set

**Export compliance (encryption)**

App Store Connect asks whether your app uses encryption. This project sets:

```
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO
```

That means “uses only standard HTTPS / no custom encryption” and skips repeated compliance prompts in TestFlight. For a simple local todo app, **No** is correct.

### 5. First archive and upload

1. Set run destination to **Any iOS Device (arm64)** — not a simulator.
2. **Product → Archive**.
3. In the Organizer: select the archive → **Distribute App**.
4. **App Store Connect** → **Upload** → keep defaults → **Upload**.
5. Wait for email / App Store Connect status: **Processing** → **Ready to Test** (usually 5–30 minutes).

If upload fails, common fixes:

- Bundle ID mismatch between Xcode and App Store Connect
- Missing signing team or expired agreement in App Store Connect
- Build number already used — bump **Build** and archive again
- Missing 1024 App Store icon

### 6. First TestFlight (recommended before public release)

Test the build with yourself or friends before submitting to the App Store.

1. App Store Connect → your app → **TestFlight**.
2. If prompted, answer **Export Compliance** — for this app, encryption is already declared in the project, so compliance is usually automatic.
3. **Internal Testing** → create a group → add your Apple ID as a tester.
4. Install **TestFlight** on your iPhone → accept the invite → install the build.

External testers (people outside your team) require a one-time **Beta App Review** the first time you enable an external group.

### 7. Release on the App Store

When you’re ready for the **first public version**:

1. App Store Connect → your app → **App Store** tab (not TestFlight).
2. Create a new version (e.g. **1.0**) if one doesn’t exist.
3. Fill in required metadata:
   - **Screenshots** (iPhone 6.7" required; add others if you support iPad)
   - **Description**, **Keywords**, **Support URL**, **Marketing URL** (optional)
   - **App Privacy** questionnaire (this app stores data only on-device via UserDefaults — typically “Data Not Collected” or no tracking)
   - **Age Rating** questionnaire
   - **Pricing**: Free or paid
4. Under **Build**, click **+** and select the processed build from step 5.
5. Click **Add for Review** → **Submit to App Review**.

First review often takes **24–48 hours** (sometimes longer). You’ll get email when it’s approved, rejected, or needs more info.

### First version checklist

```
[ ] Apple Developer Program enrolled
[ ] Bundle ID registered: testing.testing-xcode
[ ] App created in App Store Connect
[ ] Xcode signing configured (team + automatic signing)
[ ] Version 1.0, Build 1 set
[ ] App Icon set includes 1024×1024
[ ] Encryption compliance set (ITSAppUsesNonExemptEncryption = NO)
[ ] Product → Archive → Upload
[ ] TestFlight internal test on a real device
[ ] App Store listing filled in (screenshots, description, privacy, age rating)
[ ] Submit for App Review
```

---

## Distribute with TestFlight

Git push and TestFlight are **separate**. You do not need to push to GitHub to upload a TestFlight build (though committing first is good practice).

### One-time setup

If you already completed [First version: zero to App Store](#first-version-zero-to-app-store), you can skip this.

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/).
2. In [App Store Connect](https://appstoreconnect.apple.com), create an app with bundle ID **`testing.testing-xcode`** (must match Xcode).
3. In Xcode: select the project → **testing-xcode** target → **Signing & Capabilities** → confirm your team is selected and **Automatically manage signing** is enabled.

### Upload a new build

1. **Commit your changes** (recommended).

2. **Bump the build number** in Xcode:
   - Target → **General** → **Identity**
   - **Version** (`MARKETING_VERSION`): user-facing version, e.g. `1.0`
   - **Build** (`CURRENT_PROJECT_VERSION`): must increase on **every** upload, e.g. `4` → `5`

3. **Archive**
   - Set the run destination to **Any iOS Device (arm64)** — not a simulator
   - **Product → Archive**
   - Wait for the Organizer window to open

4. **Upload**
   - Select the archive → **Distribute App**
   - Choose **App Store Connect** → **Upload**
   - Accept defaults (automatic signing, etc.) → **Upload**

5. **Wait for processing**
   - App Store Connect → your app → **TestFlight**
   - The build shows “Processing” for roughly 5–30 minutes, then becomes **Ready to Test**

6. **Add testers**
   - **Internal testing**: members of your App Store Connect team (available quickly)
   - **External testing**: requires Beta App Review the first time

### TestFlight checklist

```
[ ] Bump Build number
[ ] Destination: Any iOS Device (arm64)
[ ] Product → Archive
[ ] Distribute → App Store Connect → Upload
[ ] Wait for processing in App Store Connect
[ ] Enable testers in TestFlight
```

### What you do not need

- **EAS / Expo** — for React Native only
- **Simulator** — archives require a real device destination
- **Git push** — optional; not required for TestFlight upload
- **Full App Store review** — only needed for public App Store release, not TestFlight

### Subsequent App Store releases

After the first version is live:

1. Bump **Version** for user-visible releases (e.g. `1.0` → `1.1`) and always bump **Build**.
2. Archive and upload a new build (same as TestFlight).
3. App Store Connect → **App Store** tab → **+ Version** or edit the current version.
4. Select the new build → **Submit for Review**.

You do not need to recreate the app or bundle ID — only upload a new build and submit again.

---

## Project info

| Setting | Value |
|---|---|
| App name | FlowDesk |
| Bundle ID | `testing.testing-xcode` |
| Version | 1.0 (Build 4) |
| Storage | `UserDefaults` (`flowdesk.todos`, `flowdesk.onboarding`) |

---

## Project structure

```
testing-xcode/
├── Models/          # TodoItem
├── Store/           # TodoStore (persistence, task logic)
├── Theme/           # AppTheme
├── Views/           # SwiftUI screens and components
└── testing_xcodeApp.swift
```
