# Target Membership Quick Reference

## Understanding Target Membership

Each `.swift` file in your project can belong to **one or more** targets. For `@main` entry points, they should belong to **exactly one** target.

## How to Check/Set Target Membership in Xcode

### Method 1: File Inspector (Easiest)
1. Select any `.swift` file in Project Navigator
2. Open **File Inspector** (⌘⌥1 or View → Inspectors → File)
3. Look for **Target Membership** section
4. Check/uncheck targets as needed

### Method 2: Build Phases
1. Select project → Select target
2. Go to **Build Phases** tab
3. Expand **Compile Sources**
4. See all files compiled for this target

## Your Project Structure

```
Project: StreamDeck-Shortcuts.xcodeproj

┌─────────────────────────────────────────────────────────┐
│ 🎯 Target: StreamDeck-Shortcuts (Plugin)               │
├─────────────────────────────────────────────────────────┤
│ ✅ StreamDeck-Shortcuts/entry.swift (@main)            │
│ ✅ StreamDeck-Shortcuts/ShortcutAction.swift           │
│ ✅ StreamDeck-Shortcuts/shortcuts.swift                │
│ ✅ StreamDeck-Shortcuts/*.swift (all plugin files)     │
│ ❌ StreamDeck-Shortcuts-Companion/* (none!)            │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 🎯 Target: StreamDeck-Shortcuts-Companion (App)        │
├─────────────────────────────────────────────────────────┤
│ ✅ StreamDeck-Shortcuts-Companion/CompanionApp.swift   │
│    (@main - SwiftUI App)                               │
│ ✅ StreamDeck-Shortcuts-Companion/AppIntents.swift     │
│ ❌ StreamDeck-Shortcuts/* (none!)                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 🎯 Target: StreamDeck-Shortcuts-Shared (Future)        │
├─────────────────────────────────────────────────────────┤
│ ✅ Shared/*.swift (protocols, models, etc.)            │
│ 📦 Linked by both Plugin and Companion                 │
└─────────────────────────────────────────────────────────┘
```

## Common Mistakes to Avoid

### ❌ **DO NOT** add `entry.swift` to Companion target
**Error:** `Multiple @main entry points`

### ❌ **DO NOT** add `CompanionApp.swift` to Plugin target  
**Error:** `@main attribute cannot be applied to struct StreamDeckShortcutsCompanionApp`
(Plugin expects `@main` on a `Plugin` subclass)

### ✅ **DO** share common code via Shared target/framework
Create a third target for shared protocols, models, utilities

## Debugging Target Issues

### Build Error: "Multiple @main entry points"
```
Cause: Same @main file added to multiple targets
Fix: Select the file → File Inspector → Uncheck extra targets
```

### Build Error: "No @main entry point"
```
Cause: Entry point file not in target
Fix: Select the file → File Inspector → Check the target
```

### Runtime: Wrong app launches
```
Cause: Wrong scheme selected
Fix: Xcode toolbar → Select correct scheme before Run
```

## SwiftUI Debugging Tips

Since you prefer SwiftUI debugging flow:

### Live Previews in Companion App
Add to `CompanionApp.swift`:
```swift
#if DEBUG
import SwiftUI

struct CompanionApp_Previews: PreviewProvider {
    static var previews: some View {
        // Preview your menu bar setup
        Text("Menu Bar App Preview")
    }
}
#endif
```

### Debug Both Targets Simultaneously
1. Run Companion app (⌘R)
2. Attach to StreamDeck plugin process:
   - Debug → Attach to Process
   - Find "StreamDeck-Shortcuts" process

### Console Filtering
In Console.app, filter by:
- Companion: `process:StreamDeck Shortcuts Companion`
- Plugin: `process:StreamDeck-Shortcuts`
