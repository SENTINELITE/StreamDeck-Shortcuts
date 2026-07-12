## LaunchAgent Migration Summary

### TL;DR
- We replaced the embedded XPC service with a standalone agent (`StreamDeck-Shortcuts-Agent`) that launchd can bootstrap globally. The agent now runs via a LaunchAgent plist and exposes the Mach service `com.FTRBND.streamdeck-shortcuts.xpc.StreamDeck-Shortcuts-XPC`.
- The companion app still drives everything, but now it registers the LaunchAgent instead of persisting an `NSXPCListenerEndpoint`. The Stream Deck plugin connects to the agent directly via `NSXPCConnection(serviceName:)`.
- Current status: the agent launches and the plugin registers successfully. Shortcuts actions reappear. The “Get StreamDeck Status” intent still spins, so we need to make sure the agent advertises the Mach service consistently (and that its CFBundle info matches the signed binary) before the round‑trip completes.

### What We Changed
1. **Repackaged the helper**  
   - Converted the former XPC bundle into a standalone tool (`StreamDeck-Shortcuts-Agent`) with its own `Info.plist` and bundle identifier `com.FTRBND.streamdeck-shortcuts.agent`.
   - Updated the helper to run off `NSXPCListener(machServiceName:)` and keep running via `dispatchMain()`.

2. **LaunchAgent plumbing**  
   - Added `StreamDeck-Shortcuts-Companion/LaunchAgents/com.FTRBND.streamdeck-shortcuts.agent.plist` with `Program` pointing to the helper inside the bundle. We now copy that plist into the app bundle (and optionally to `~/Library/LaunchAgents/`) and register it with `SMAppService.agent`.
   - The agent exports `com.FTRBND.streamdeck-shortcuts.xpc.StreamDeck-Shortcuts-XPC`, so any process signed with the same team ID (the plugin) can connect via its Mach name.

3. **Companion updates**  
   - Companion’s `AppDelegate` now calls `registerLaunchAgent()` on launch, handling error cases (already registered, not found, etc.). Logs in Console help confirm registration results.

4. **Build system**  
   - Xcode project now copies both the helper binary and the LaunchAgent plist into the companion bundle and sets the helper’s runpaths/bundle ID appropriately.

### What Works
- **Agent launch and logging**: `StreamDeck-Shortcuts-Agent` starts under launchd, logs its startup, and keeps running.
- **Plugin registration**: `StreamDeck-Shortcuts_Alt` now calls `registerPlugin` without crashing; the helper logs the registration and the plugin reports success.
- **Shortcuts actions**: After refreshing Shortcuts’ cache, the companion’s App Intents show up again in Shortcuts.app.

### What’s Still Pending
- **Mach service advertising**: Although the agent runs, the plugin still occasionally logs `xpc_error=[3: No such process]`. We need to ensure the LaunchAgent plist in use contains the absolute `Program` path and that launchd advertises `com.FTRBND.streamdeck-shortcuts.xpc.StreamDeck-Shortcuts-XPC` reliably (verify with `launchctl print gui/$UID/com.FTRBND.streamdeck-shortcuts.agent`).
- **Intent round‑trip**: “Get StreamDeck Status” spins (no response) because the companion never hears back from the plugin. Once the Mach service issue above is resolved, the agent should be able to reply to the intent via the plugin callback.

### MVP Checklist
- [x] Helper is a launchd job with a stable Mach service name  
- [x] Companion registers the LaunchAgent and logs outcomes  
- [x] Plugin connects via `NSXPCConnection(serviceName:)` and doesn’t crash  
- [x] App Intents show in Shortcuts  
- [ ] App Intent pipeline completes (status, update, run shortcut) without timeouts  
- [ ] Automated packaging (build → copy → sign → bootstrap) so manual steps disappear

### Next Steps
1. **Lock the LaunchAgent deploy flow**: ensure the plist is installed to `~/Library/LaunchAgents/` (with absolute `Program`) and the helper binary’s Info.plist stays in sync with the signed build. Bundle the copy/bootstrap logic into the companion or a post‑install script.
2. **Verify the Mach service**: after the above, `launchctl print gui/$UID/com.FTRBND.streamdeck-shortcuts.agent` should show the exported `MachServices` entry. The plugin logs should stop showing `xpc_error=[3: No such process]`.
3. **Intent testing**: re‑run “Get StreamDeck Status”, “Update StreamDeck Key”, and “Run Shortcut on StreamDeck”. Confirm responses return quickly and log the round trip in both the agent and plugin.
4. **Automation & cleanup**: once the loop is stable, script the signing/copy/bootstrap steps so every rebuild automatically ships a working companion + agent bundle. Remove manual LaunchAgent copies, integrate `SMAppService` calls, and document the install flow.

We’re very close to MVP: the architecture is in place, the helper runs, plugin calls succeed, and Shortcuts sees the actions. The last mile is making the Mach service advertisement consistent and verifying the App Intent responses. Once that’s resolved, we can polish and automate the install pipeline.
