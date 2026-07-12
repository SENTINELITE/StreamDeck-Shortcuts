# Adding the Companion App Target to Xcode

## Important: Multiple @main Entry Points

✅ **Yes, you can have `@main` in multiple targets!**
- Your plugin has: `@main class StreamDeckShortcuts: Plugin` in `entry.swift`
- Companion app has: `@main struct StreamDeckShortcutsCompanionApp: App` in `CompanionApp.swift`

These don't conflict because each target compiles its own source files separately.
Just ensure **file target membership** is set correctly (see step 4).

## Step-by-Step Instructions

### 1. Add New Target
1. Open `StreamDeck-Shortcuts.xcodeproj` in Xcode
2. Select the project in the Project Navigator (top item)
3. At the bottom of the targets list, click the **"+"** button
4. Choose **"App"** under **macOS** → **Application**
5. Click **Next**

### 2. Configure Target Settings
- **Product Name**: `StreamDeck-Shortcuts-Companion`
- **Team**: Your development team
- **Organization Identifier**: `com.sentinelite` (or your existing identifier)
- **Bundle Identifier**: `com.sentinelite.streamdeck-shortcuts-companion`
- **Language**: Swift
- **User Interface**: SwiftUI
- **Include Tests**: Unchecked (you can add later)
- Click **Finish**

### 3. Delete Auto-Generated Files
Xcode will create some default files we don't need:
1. In the Project Navigator, find the new `StreamDeck-Shortcuts-Companion` folder
2. Delete these files (Move to Trash):
   - `StreamDeck_Shortcuts_CompanionApp.swift` (we have our own)
   - `ContentView.swift` (we don't need a window)
   - `Assets.xcassets` (optional - delete if you want to share assets)

### 4. Add Our Files to the Target
1. In Finder, navigate to: `StreamDeck-Shortcuts/StreamDeck-Shortcuts-Companion/`
2. Drag these files into Xcode's Project Navigator under the target:
   - `CompanionApp.swift`
   - `AppIntents.swift`
   - `Info.plist`
   - `StreamDeck-Shortcuts-Companion.entitlements`
3. When prompted, ensure:
   - ✅ **Copy items if needed** (unchecked - they're already in place)
   - ✅ **Create groups** (selected)
   - ✅ **Add to targets**: `StreamDeck-Shortcuts-Companion` (checked)

### 5. Configure Target Build Settings

#### General Tab
1. Select the `StreamDeck-Shortcuts-Companion` target
2. Go to **General** tab:
   - **Display Name**: `StreamDeck Shortcuts`
   - **Bundle Identifier**: `com.sentinelite.streamdeck-shortcuts-companion`
   - **Version**: `2.0.0`
   - **Build**: `12`
   - **Minimum Deployment**: macOS 12.0


#### Signing & Capabilities
1. Go to **Signing & Capabilities** tab:
   - Enable **Automatically manage signing** (or configure manually)
   - Add capability: **App Sandbox**
     - ✅ Outgoing Connections (Client)
   - Add capability: **App Groups**
     - Add: `group.com.sentinelite.streamdeck-shortcuts` 


---- Stopped here last

#### Build Settings
1. Go to **Build Settings** tab:
   - Search for "Info.plist File"
   - Set to: `StreamDeck-Shortcuts-Companion/Info.plist`
   - Search for "Code Sign Entitlements"
   - Set to: `StreamDeck-Shortcuts-Companion/StreamDeck-Shortcuts-Companion.entitlements`
   - Search for "Product Name"
   - Set to: `StreamDeck Shortcuts Companion`

### 6. Update Info.plist Reference
1. Select the target → **Build Settings**
2. Search for "Info.plist File"
3. Set to: `$(SRCROOT)/StreamDeck-Shortcuts-Companion/Info.plist`

### 7. Build and Test
1. Select the `StreamDeck-Shortcuts-Companion` scheme
2. Build the project (⌘B)
3. Run the app (⌘R)
4. You should see a menu bar icon appear (slider icon)

### 8. Verify App Intents Registration
After building, verify App Intents are registered:
```bash
/usr/libexec/PlistBuddy -c "Print :NSExtension:NSExtensionAttributes:IntentsSupported" \
  ~/Library/Developer/Xcode/DerivedData/StreamDeck-Shortcuts-*/Build/Products/Debug/StreamDeck\ Shortcuts\ Companion.app/Contents/Info.plist
```

Or simply open **Shortcuts.app** and search for "StreamDeck" to see your intents!

## Next Steps
Once this is working:
1. ✅ Create XPC Service target
2. ✅ Create Shared framework for protocols
3. ✅ Wire up XPC communication
4. ✅ Test full integration

### Phase 2: XPC Communication Setup

#### 1. Create Shared Framework Target
1. In Xcode, add new target: **Framework** → **macOS** → **Framework**
2. Configure:
   - **Product Name**: `StreamDeck-Shortcuts-Shared`
   - **Bundle Identifier**: `com.sentinelite.streamdeck-shortcuts.shared`
   - **Language**: Swift
3. Create the XPC protocol files:
   ```
   StreamDeck-Shortcuts-Shared/
   ├── StreamDeckXPCProtocol.swift
   ├── StreamDeckCommands.swift
   └── Info.plist
   ```

#### 2. Create XPC Service Target
1. Add new target: **XPC Service** → **macOS** → **XPC Service**
2. Configure:
   - **Product Name**: `StreamDeck-Shortcuts-XPC`
   - **Bundle Identifier**: `com.sentinelite.streamdeck-shortcuts.xpc`
3. Link the Shared framework to this target
4. Implement XPC service listener

#### 3. Update Companion App
1. Link Shared framework to Companion target
2. Create XPC client class
3. Update AppIntents to use XPC communication:
   - `UpdateStreamDeckKey` → Send via XPC
   - `RunShortcutOnStreamDeck` → Send via XPC
   - `GetStreamDeckStatus` → Query via XPC

#### 4. Update StreamDeck Plugin
1. Link Shared framework to plugin target
2. Add XPC client connection to plugin
3. Listen for XPC messages and execute StreamDeck commands
4. Return status/results via XPC

#### 5. Entitlements & Sandboxing
1. Update companion app entitlements:
   - Add XPC service entitlement
2. Update plugin entitlements if needed
3. Configure App Groups for shared data (if needed)

#### 6. Testing Strategy
1. **Unit Test**: XPC communication in isolation
2. **Integration Test**: Companion → XPC → Plugin
3. **End-to-End Test**: Shortcuts.app → Companion → XPC → Plugin
4. **Error Handling**: Test failure scenarios

### Implementation Files Needed:

**Shared Framework:**
- `StreamDeckXPCProtocol.swift` - XPC service protocol definitions
- `StreamDeckCommands.swift` - Command data structures

**XPC Service:**
- `XPCServiceMain.swift` - XPC service entry point
- `StreamDeckXPCService.swift` - XPC service implementation

**Companion App:**
- `XPCClient.swift` - XPC client wrapper
- Update `AppIntents.swift` - Use XPC instead of TODO comments

**Plugin:**
- `XPCListener.swift` - Listen for XPC messages
- Update existing command handlers to work with XPC

## Troubleshooting

### "LSUIElement" not recognized?
- Make sure Info.plist is properly linked in Build Settings

### App doesn't appear in menu bar?
- Check `LSUIElement` is set to `true` in Info.plist
- Verify `setupMenuBar()` is being called

### App Intents not showing in Shortcuts.app?
- Clean build folder (⇧⌘K)
- Rebuild and run the app at least once
- Intents register when the app launches
- Check Console.app for any registration errors

### Bundle identifier conflicts?
- Make sure each target has a unique bundle identifier:
  - Plugin: `com.sentinelite.streamdeck-shortcuts`
  - Companion: `com.sentinelite.streamdeck-shortcuts-companion`
  - Extension: `com.sentinelite.streamdeck-shortcuts.appintents` (if keeping)
