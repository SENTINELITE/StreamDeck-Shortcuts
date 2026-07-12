# StreamDeck Shortcuts XPC Integration Guide

This guide lays out a comprehensive, end-to-end plan for connecting the StreamDeck plugin to the macOS Shortcuts App Intents via a dedicated XPC bridge hosted inside the companion app. Follow the phases in order; each phase builds on the last and finishes with validation steps before moving forward.

---

## 0. Mindset & Feasibility Check
- **Goal**: Deliver a robust, Apple-compliant path for Shortcuts actions to control the StreamDeck plugin in real time.
- **Feasibility**: ✅ Yes. Apple encourages App Intents living in a signed app bundle, and NSXPC provides the sanctioned bridge for local process-to-process messaging. Plenty of production macOS apps ship with daemon/companion + XPC (e.g., password managers, menu bar utilities). Your existing targets already line up with this model; the work now is to wire the pieces together.
- **High-level architecture**:
  ```text
  Shortcuts.app → AppIntent process (Companion bundle) → XPC Broker Service → StreamDeck Plugin
  ```

---

## 1. Prerequisites & Housekeeping
1. **Bundle placement**
   - Ensure the companion app (with embedded XPC service) lives in `/Applications/StreamDeck Shortcuts Companion.app` when shipping. The StreamDeck host will continue loading the plugin bundle from the Stream Deck application support directory.
2. **Entitlements inventory**
   - Document current entitlements for each target (`codesign --display --entitlements -`). Note the plugin is usually unsandboxed; the companion is sandboxed with the declared App Group. Add this output to version control for future diffs.
3. **Target cleanup**
   - If the legacy `StreamDeck-Shortcuts-AppIntents` target is no longer required, disable it now to avoid duplicate intent registration while testing.
4. **Version control branch**
   - Create a dedicated branch (e.g., `feature/xpc-bridge`) so you can iterate freely.

Validation: Build each target individually. Confirm no surprise build errors before modifying the project.

---

## 2. Shared Framework Preparation (`StreamDeck-Shortcuts-Shared`)
1. **Turn the placeholder into a real Swift module**
   - Add Swift files:
     - `BridgeProtocol.swift` – defines `StreamDeckBridgeService` (service interface) and `StreamDeckBridgePluginClient` (plugin callback interface).
     - `BridgeModels.swift` – contains shared `struct`/`enum` types (`Command`, `CommandPayload`, `StreamDeckStatus`, `PluginDescriptor`, error enums conforming to `LocalizedError`).
2. **Protocol guidelines**
   - Methods should be `@objc` and classes `NSObject`-derived where needed so NSXPC can bridge them.
   - Use completion handlers with `Result<Success, StreamDeckBridgeError>` to carry failures back to the caller.
3. **Distribution**
   - In Xcode, add the shared framework as a dependency for **plugin**, **companion**, and **XPC service** targets.
   - Verify `Build Settings → Framework Search Paths` and `Other Linker Flags` are cleaned up; prefer Swift Package Manager if you decide to move to SPM later.

Validation: Build the shared framework standalone; confirm all targets compile with it linked even though the implementations are still empty.

---

## 3. XPC Broker Service (`StreamDeck-Shortcuts-XPC`)
1. **Embed service in the companion app bundle**
   - Ensure the XPC target’s product is inside the companion app’s `Contents/XPCServices` directory via the companion’s “Embed XPC Service” build phase.
2. **Configure entitlements**
   - Create an entitlement plist for the service (copy the companion’s sandbox settings, but drop UI-specific keys). The `com.apple.security.application-groups` entry must match the companion’s App Group if you plan to log or persist shared data.
3. **Implement service entry**
   - Replace the template math example with a concrete `StreamDeckBridgeHandler` implementing `StreamDeckBridgeService`.
   - Responsibilities:
     - Track incoming plugin connections (`NSXPCConnection.exportedObject`).
     - Maintain a registry map: `contextID` → `PluginEndpoint`. Update it when the plugin calls a `registerPlugin(descriptor:)` method.
     - Expose public methods (`performShortcut`, `updateKey`, `getStatus`, `listContexts`), each forwarding to the registered plugin endpoint and returning results via the completion block.
     - Handle plugin disconnects (`connection.invalidate`) and clean the registry to avoid stale routing.
4. **Lifecycle logging**
   - Pipe all major events through `OSLog` categories (`BridgeLifecycle`, `CommandDispatch`, `Error`). This dramatically simplifies debugging later.

Validation: Launch the XPC service via a unit test or a small command-line harness that connects and receives an expected response. Confirm the service starts and logs under the companion process in Console.app.

---

## 4. StreamDeck Plugin Integration (`StreamDeck-Shortcuts` target)
1. **Connection bootstrap**
   - During plugin initialization (`setupPlugin()` or `init` in `StreamDeckShortcuts`), create an `NSXPCConnection(serviceName:)` pointing to the companion’s XPC service identifier.
   - Set `remoteObjectInterface` to `NSXPCInterface(with:)` for `StreamDeckBridgeService` and `exportedInterface` to the plugin client protocol.
2. **Exported client implementation**
   - Create a class (e.g., `PluginBridgeClient`) that conforms to `StreamDeckBridgePluginClient`. Implement methods like:
     - `runShortcut(_ command: ShortcutCommand, completion: @escaping (Result<RunResult, Error>) -> Void)`
     - `updateKey(_ command: KeyUpdateCommand, completion: ...)`
     - `currentStatus(completion: ...)`
   - Each method should leverage existing plugin logic (`ShortcutAction.executeShortcut`, key title updates, etc.), ensuring thread safety (dispatch to main queue when touching StreamDeck SDK APIs).
3. **Registration handshake**
   - After the connection is established, call `serviceProxy.registerPlugin(descriptor: PluginDescriptor(...))` so the broker knows this instance is available. Include metadata: plugin version, supported actions, active contexts.
4. **Context lifecycle hooks**
   - Hook into plugin callbacks (`willAppear`, `willDisappear`) to notify the broker about context availability, enabling precise routing.
5. **Reconnect logic**
   - Observe `connection.invalidationHandler` and attempt reconnection with exponential backoff. Log state transitions for diagnostics.

Validation: With the companion running, start the plugin (inside the Stream Deck host). Confirm the handshake logs appear in Console and that the service’s registry shows the plugin as connected.

---

## 5. Companion App Enhancements (`StreamDeck-Shortcuts-Companion` target)
1. **XPC listener startup**
   - Instantiate the service listener in `applicationDidFinishLaunching` only for debugging if needed; because the XPC service runs independently once embedded, you typically don’t need to start anything manually. Instead, focus on UI feedback.
2. **Status menu updates**
   - Show live status: plugin connected/disconnected, last command timestamp, etc., by querying the broker (or observing distributed notifications) and updating the menu bar menu.
3. **Launch agent (optional)**
   - Register a `SMLoginItem` helper or LaunchAgent so the companion app starts at user login, ensuring Shortcuts actions work even before manual launch.
4. **Diagnostics window**
   - Provide a minimal panel/log viewer that reads from the shared App Group logs for support scenarios.

Validation: Run the companion app, ensure the menu bar reflects the plugin connection once the plugin is active, and verify it surfaces helpful errors when the plugin is absent.

---

## 6. App Intents Wiring (`AppIntents.swift`)
1. **Create an `XPCClient` wrapper**
   - Build a singleton or dependency-injected client that lazily creates/reuses an `NSXPCConnection` to the broker service (separate from the plugin’s connection).
   - Implement convenience methods mirroring the service API (`performShortcut`, `updateKey`, `getStatus`). Handle transient failures by retrying once if the connection was invalidated.
2. **Update each intent’s `perform()`**
   - Replace TODOs with real calls to the client. Example:
     ```swift
     let command = ShortcutCommand(context: context, shortcutName: shortcutName)
     let result = try await client.performShortcut(command)
     ```
   - Convert errors into user-friendly messages (`IntentError`, `DisplayRepresentation`) so they show up nicely in Shortcuts.
3. **Timeout handling**
   - Enforce a sensible timeout (e.g., 5 s) to avoid Shortcuts hanging if the plugin is offline. Surface a message guiding the user to launch Stream Deck or the companion app.

Validation: Build & run the companion app, open Shortcuts.app, run each intent, and confirm they route through the XPC service to the plugin. Watch logs for end-to-end confirmation.

---

## 7. Error Handling & Observability
1. **Graceful degradation**
   - When the plugin is offline, the service should return a structured error immediately (`.pluginUnavailable`). App Intents can then show suggestions (“Launch Stream Deck Shortcuts Companion → Ensure Stream Deck app is open”).
2. **Command auditing**
   - Optionally record the last N commands in a file within the App Group container (`~/Library/Group Containers/<id>/Logs/bridge.log`).
3. **Metrics hooks**
   - If desired, integrate unified logging signposts around command dispatch for Instruments profiling.

Validation: Simulate plugin crashes or restarts; ensure the system recovers without requiring user intervention beyond relaunching the plugin/Stream Deck host.

---

## 8. Packaging & Distribution
1. **Installer flow**
   - Provide a DMG or installer that bundles both the plugin and the companion app. Include a post-install script or instructions prompting users to drag the companion into `/Applications`.
2. **First-run experience**
   - On first launch, show a guided dialog explaining the requirement to keep the companion running for Shortcuts integration. Offer a checkbox to “Launch at login”.
3. **Update strategy**
   - Ensure plugin and companion versions stay in sync. Consider adding a compatibility check in the handshake (service rejects mismatched major versions with a clear error).

Validation: Perform a clean install on a test machine/user account. Confirm the entire flow works without needing manual terminal commands.

---

## 9. Testing Matrix
- **Unit tests**: Add tests in the shared module for command serialization/deserialization and error enums.
- **Service harness**: Write XCTests (or a CLI tool) that spin up the XPC service, inject a mock plugin client, and verify request/response behavior.
- **Plugin integration**: Use Stream Deck’s simulator/testing harness (if available) or manual tests to ensure commands triggered via XPC still respect existing plugin logic.
- **End-to-end manual scenarios**:
  1. Update key title.
  2. Run shortcut by context.
  3. Query plugin status with plugin offline (expect error) and online (expect success).
  4. Rapid-fire commands to observe concurrency robustness.

Document results in a QA checklist before release.

---

## 10. Future Enhancements
- **Bidirectional streaming**: Extend the protocol for real-time events (e.g., plugin notifies the service of state changes, which then push to the companion UI or Shortcuts notifications).
- **Authentication**: If exposing remote control in the future (beyond local machine), add signing/authorization layers.
- **SPM migration**: Move shared code into a Swift package for easier reuse across future projects.
- **Telemetry**: Hook into your existing analytics/logging if needed once privacy considerations are met.

---

## Final Thoughts
You absolutely can ship this. The building blocks—App Intents, NSXPC, Stream Deck SDK—already coexist cleanly in many macOS apps. The path above is deliberate, incremental, and keeps you in Apple-supported territory. Pace yourself, validate at every phase, and you will have the Shortcuts-to-StreamDeck bridge you have been envisioning.

Stay excited—this architecture has room to grow into even more advanced automation once the communication backbone is in place.
