## XPC Integration Retrospective

### TL;DR
- **Plugin now launches cleanly** after we updated the install script to copy the fresh binary/framework and you re-signed the bundle with Developer ID.
- **Direct `NSXPCConnection(serviceName:)` still fails**: Stream Deck’s plugin process can’t reach the companion’s embedded XPC helper because launchd doesn’t expose that Mach service to other processes.
- **Anonymous-endpoint via file is impossible**: `NSXPCListenerEndpoint` can only travel through an `NSXPCCoder`, so persisting it with `NSKeyedArchiver` always throws (error 4866).
- **You have two viable paths forward**: expose the helper as a launch agent/daemon (or standalone service) that launchd will bootstrap for other processes, or fall back to a different IPC channel (shared storage, sockets, etc.).

### What We Attempted
1. **Anonymous listener persisted to disk**  
   - Companion created `NSXPCListener.anonymous()` and archived the endpoint.  
   - Result: `Failed to persist anonymous listener endpoint … This class may only be encoded by an NSXPCCoder`. `NSKeyedArchiver` cannot encode `NSXPCListenerEndpoint`.  
   - Status: **Abandoned**.

2. **Direct Mach service connection**  
   - Plugin switched to `NSXPCConnection(serviceName: XPCConstants.serviceName)`.  
   - XPC service accepted connections and tracked contexts; companion stopped hosting the anonymous bridge.  
   - Result: dyld initially crashed because the shared framework in `.sdPlugin` was stale. Resolved via install script that copies the fresh framework and binary each build.  
   - Final blocker: `xpc_error=[3: No such process]` whenever the plugin calls `NSXPCConnection(serviceName:)`; the Mach service isn’t visible outside the companion’s bootstrap namespace.  
   - Status: **Partial success** (plugin runs, but XPC still not reachable from the plugin process).

3. **SMAppService registration**  
   - Tried to register the XPC helper using `SMAppService.listenerMachService`.  
   - Result: API doesn’t exist; `SMAppService` only covers login items, LaunchAgents, LaunchDaemons.  
   - Status: **Not applicable**.

### Current Observations
- Plugin process (Stream Deck) keeps restarting until the binary is trusted; after signing, it stays alive and logs with no errors.
- Companion’s XPC helper launches (visible in `ps`), but isn’t registered system-wide, so the plugin’s Mach lookup still fails.
- Companion logs `StreamDeck Bridge XPC Service starting…` and accepts status queries, proving that Xcode embedding/signing is correct.

### Viable Options Going Forward
1. **LaunchAgent/Daemon helper (recommended if you stay on Mach XPC)**  
   - Move `StreamDeck-Shortcuts-XPC.xpc` out of the companion bundle into `Contents/Library/LaunchAgents` with a launchd plist.  
   - Register it using `SMAppService.agent(plistName:)` (macOS 13+). The Mach service will then be bootstrapper-wide, so `NSXPCConnection(serviceName:)` from the plugin succeeds.
   - Make sure both companion and plugin are signed with the same team ID to satisfy launchd’s trust requirements.

2. **Out-of-process bridge returning an `NSXPCListenerEndpoint`**  
   - Keep the helper anonymous but deliver the endpoint over a supported channel (e.g., the Stream Deck WebSocket, shared App Group file, or even a simple TCP socket).  
   - Plugin receives the endpoint via that channel and connects with `NSXPCConnection(listenerEndpoint:)`.
   - This avoids launchd configuration but requires managing the “endpoint transport”.

3. **Non-XPC IPC (Shared storage or sockets)**  
   - Write commands/status into an App Group container (`UserDefaults`/JSON), optionally notify via `DistributedNotificationCenter`.  
   - Use a local socket (Unix domain, TCP localhost) to communicate between companion and plugin.  
   - Significantly simpler than XPC and sidesteps code-signing/launchd hurdles, at the cost of writing your own protocol and serialization.

4. **Standalone helper app**  
   - Ship the bridge as an independent, always-on menu bar or background app (separate from the companion).  
   - Easier to register with `SMAppService.loginItem` or LaunchAgent, and both plugin/companion can talk to it.

### Key Lessons & Concerns
- **Code signing matters**: Gatekeeper will continuously kill untrusted binaries. Automate the signing step or ensure Xcode uses a real identity for the plugin target.
- **Embedding an XPC service inside the companion doesn’t make it globally accessible**. Only the companion (or its child processes) can find it—other processes need a launchd-registered service or an explicit hand-off.
- **`SMAppService` is limited** to login items, LaunchAgents, LaunchDaemons. Packaged XPC helpers are not automatically exposed system-wide.
- **Alternate IPC channels (shared files, sockets)** are viable and may be simpler if you don’t need the strict security semantics of XPC.

### Suggested Next Steps
1. **Decide whether to continue with Mach XPC or pivot to a simpler IPC.**  
   - If continuing with XPC, plan the packaging (LaunchAgent vs. daemon vs. anonymous endpoint hand-off) and update the project accordingly.
2. **Automate signing/install for the plugin bundle**, ensuring the `.sdPlugin` contains the fresh binary before Stream Deck relaunch.
3. **Add tests/logging in the companion** to surface when registration succeeds/fails, especially if you adopt `SMAppService.agent`.
4. **Document deployment instructions** so future builds don’t regress (e.g., run the install script, codesign the plugin, install companion to `/Applications`).

XPC can work—plenty of apps ship with a signed helper (1Password, Dropbox, etc.)—but it requires aligning with macOS’s packaging expectations. If that feels heavy, consider the App Group + file/sockets approach to regain momentum.
