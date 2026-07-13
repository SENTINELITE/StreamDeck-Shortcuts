![GH_Banner](https://user-images.githubusercontent.com/44782976/144744255-caae0988-d019-40dd-8264-3b544b97d733.png)

# Stream Deck Shortcuts

Run the Shortcuts you already rely on from your Stream Deck—quickly, clearly, and with accessibility controls that meet you where you are.

The Stream Deck's been unleashed. Infinite possibilities at the speed of light. All within touch.

This is the Version Two codebase, including the Stream Deck plugin and its integrated Property Inspector.

## What it does

- Choose a Shortcuts folder, then select the shortcut you want on a key.
- Search your entire shortcut library from the Property Inspector. Search understands both shortcut names and folder names, so a query such as `utilities copy` finds a Copy shortcut in Utilities.
- Keep shortcut selection fast even when your library is organized across many folders.
- Set display-title, accessibility, and hold-time behavior per key or globally.
- Choose an accessibility voice and adjust speech rate when spoken feedback is enabled.

## Using the Property Inspector

1. Add **Launch Shortcut V2** to a Stream Deck key.
2. Pick a folder and shortcut, or use the magnifying glass beside the shortcut picker to search everything.
3. Search by shortcut title, folder, or both. Select a result to assign it to the key.
4. Optionally configure the display title, accessibility feedback, and hold behavior for that key or across your setup.

## A little backstory

I wanted to run my Shortcuts on my Stream Deck, but the go-to solution bricked on me on the first day. Whatever I did, I couldn’t get it working again. That was the start of this project.

Of course, I wasn’t going to make a simple thing. No—I had to do it the justice it so rightly deserved. 😝

If you want to learn more about how and why this was made, take a look at [this Twitter thread](https://twitter.com/sentinelite/status/1477716577533325312?s=21).

## Sponsor the project

Stream Deck Shortcuts is independently built and maintained. Sponsorship helps fund continued Shortcuts compatibility, accessibility improvements, thoughtful Stream Deck workflows, documentation, and long-term maintenance.

If this plugin is useful to you, [sponsor the project on GitHub](https://github.com/sponsors/SENTINELITE).

## Repository layout

- `StreamDeck-Shortcuts/` — Swift plugin source.
- `PropertyInspectorViews/` — the integrated Stream Deck Property Inspector.
- `PropertyInspectorViews/Preview/` — generic local preview fixtures for Property Inspector development.
- `Scripts/verify-streamdeck-plugin-bundle.sh` — release check that prevents preview-only assets from being included in a plugin bundle.
- `Scripts/sync-local-streamdeck-plugin.sh` — builds and refreshes the locally installed plugin for testing.
- `Scripts/release-streamdeck-plugin.sh` — archives, signs, validates, and packs a clean release artifact.

## Build and release

For day-to-day testing, this builds the plugin, copies the current executable and Property Inspector into the locally installed bundle, validates it, and restarts only this plugin:

```sh
Scripts/sync-local-streamdeck-plugin.sh --restart
```

For a distributable Stream Deck artifact, the release script archives the Release executable, stages a clean `.sdPlugin` (excluding preview fixtures and local settings), signs its executable, validates it with the Stream Deck CLI, and writes the packaged artifact to `dist/`:

```sh
Scripts/release-streamdeck-plugin.sh
```

The default bundle template is the installed plugin. For a repeatable CI setup, pass a clean `.sdPlugin` template with `--template`. To additionally create, notarize, staple, and verify the standalone CLI installer package, use `--notarize-pkg` after the one-time `notarytool` credential setup.

## Support

- [Open an issue](https://github.com/SENTINELITE/StreamDeck-Shortcuts/issues/new)
- [Reach me on Twitter](http://sentinelite.com/twitter)
- [Join the Discord community](https://sentinelite.com/discord)
