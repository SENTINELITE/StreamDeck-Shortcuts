# StreamDeck-Shortcuts Project Plan

## 🎯 **Project Goal**

Create a seamless integration between Apple's Shortcuts app and Elgato StreamDeck, allowing users to:
1. **Trigger StreamDeck actions from Shortcuts app** (using App Intents)
2. **Control StreamDeck keys remotely** (update text, trigger actions, get status)
3. **Bridge iOS/macOS Shortcuts ecosystem with StreamDeck hardware**

## 📊 **Current State Analysis**

### ✅ **What's Working**
1. **StreamDeck Plugin** (`StreamDeck-Shortcuts` target)
   - Core plugin functionality with `ShortcutAction` class
   - Can run Apple Shortcuts when StreamDeck keys are pressed
   - Has settings for shortcuts, accessibility, hold time, etc.
   - Main entry point: `entry.swift` with `StreamDeckShortcuts` class

2. **Companion App** (`StreamDeck-Shortcuts-Companion` target) 
   - Menu bar app with working App Intents
   - Successfully registers 4 intents in Shortcuts.app:
     - `UpdateStreamDeckKey` - Update key display text
     - `RunShortcutOnStreamDeck` - Trigger shortcuts on specific keys  
     - `GetStreamDeckStatus` - Get plugin connection status
     - `ConvertUnixTimeToDate` - Legacy utility intent

3. **App Intents Integration**
   - Intents are discoverable in Shortcuts.app
   - Metadata properly generated and registered
   - UI parameters and descriptions working

### ❌ **What's Missing (The Gap)**

**The core issue: App Intents have no way to communicate with the StreamDeck plugin.**

Current App Intents just return placeholder responses:
```swift
// TODO: Send via XPC to the StreamDeck plugin
// await XPCClient.shared.updateKey(text: text, context: context)
return .result(value: "Successfully updated StreamDeck key")
```

## 🔄 **The Communication Challenge**

### **Current Architecture (Broken)**
```
Shortcuts.app → Companion App (App Intents) → ❌ NO CONNECTION ❌ → StreamDeck Plugin
```

### **Target Architecture (What We Need)**
```
Shortcuts.app → Companion App → XPC Service → StreamDeck Plugin
```

## 🏗️ **Implementation Strategy**

### **Option 1: XPC Service (Complex but Robust)**
```
Project Structure:
├── StreamDeck-Shortcuts (Plugin - runs in StreamDeck Software)
├── StreamDeck-Shortcuts-Companion (Menu Bar App - hosts App Intents)  
├── StreamDeck-Shortcuts-Shared (Framework - shared protocols)
├── StreamDeck-Shortcuts-XPC (XPC Service - communication bridge)
└── StreamDeck-Shortcuts-AppIntents (Extension - legacy, might remove)
```

**Challenges with XPC:**
- Complex multi-process communication
- Sandboxing and entitlements complexity  
- XPC service lifecycle management
- Multiple linking relationships between targets

### **Option 2: Direct Communication (Simpler)**

**App Groups + File/Database Communication:**
```swift
// Companion App writes commands
UserDefaults(suiteName: "group.com.sentinelite.streamdeck-shortcuts")
// Plugin reads commands periodically
```

**Socket/Port Communication:**
```swift
// Companion opens socket, Plugin connects
// Direct TCP/UDP communication on localhost
```

**Distributed Objects/NSXPCConnection:**
```swift
// Direct XPC connection without separate service
// Companion and Plugin communicate directly
```

## 🎯 **Recommended Approach: App Groups + Notifications**

### **Why This is Simpler:**

1. **Shared UserDefaults/Database**
   - Both targets use same App Group
   - Companion writes commands to shared storage
   - Plugin polls or gets notified of changes

2. **DistributedNotificationCenter**
   - Cross-process notifications without XPC complexity
   - Companion sends notification when command ready
   - Plugin receives notification and processes command

3. **File-based Communication**
   - JSON command files in shared App Group container
   - Simple, debuggable, no process lifecycle issues

### **Implementation Steps:**

#### **Phase 1: Shared Communication (1-2 hours)**
1. Add App Group to both targets: `group.com.sentinelite.streamdeck-shortcuts`
2. Create shared command protocol (simple structs)
3. Implement command queue system using UserDefaults

#### **Phase 2: Companion → Plugin Communication (2-3 hours)**  
1. Update App Intents to write commands to shared storage
2. Add notification system to wake up plugin
3. Update plugin to read and execute commands

#### **Phase 3: Plugin → Companion Communication (1-2 hours)**
1. Plugin writes status/results back to shared storage
2. Companion reads results and returns to App Intents

#### **Phase 4: Testing & Polish (2-3 hours)**
1. End-to-end testing: Shortcuts.app → Companion → Plugin
2. Error handling and edge cases
3. Logging and debugging

## 📋 **Immediate Next Steps**

### **Step 1: Simplify Current Structure**
- Remove `StreamDeck-Shortcuts-XPC` and `StreamDeck-Shortcuts-Shared` targets (they're complicating things)
- Focus on direct Companion ↔ Plugin communication

### **Step 2: Add App Group**
1. Add App Group capability to both Companion and Plugin targets
2. Use identifier: `group.com.sentinelite.streamdeck-shortcuts`

### **Step 3: Create Simple Command System**
1. Create `StreamDeckCommand.swift` in both targets (copy/paste is fine)
2. Define command structure:
   ```swift
   struct StreamDeckCommand: Codable {
       let id: UUID
       let type: CommandType
       let parameters: [String: String]
       let timestamp: Date
   }
   ```

### **Step 4: Test Communication**
1. Companion writes test command to App Group UserDefaults
2. Plugin reads and logs the command
3. Verify bidirectional communication works

## 🎯 **Success Criteria**

When complete, this should work end-to-end:
1. Open Shortcuts.app
2. Create shortcut with "Update StreamDeck Key" action
3. Set text to "Hello World" and context ID
4. Run shortcut
5. StreamDeck key updates with "Hello World" text

**Estimated Total Time: 6-10 hours of focused development**

## 🚨 **Risk Mitigation**

- **Keep it simple**: Avoid over-engineering with XPC services initially
- **Incremental development**: Get basic communication working first
- **Fallback plan**: If App Groups don't work, we can always return to XPC
- **Testing strategy**: Test each communication layer independently

---

*This plan prioritizes getting a working end-to-end integration quickly, then optimizing later.*