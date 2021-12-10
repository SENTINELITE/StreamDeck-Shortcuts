![GH_Banner](https://user-images.githubusercontent.com/44782976/144744255-caae0988-d019-40dd-8264-3b544b97d733.png)

### About StreamDeck Shortcuts
Welcome in! This Repo is for all things Shortcuts/StreamDeck!

We’re all about making sure the software is Fast, Reliable, & Performant, all while offering excellent accessibility support!

The StreamDeck's been unleashed. Infinite possibilities at the speed of light. All within touch.

If you want to learn more about how & why this was made, take a look at [this Twitter thread!](https://twitter.com/sentinelite)

---

### Backstory
I wanted to run my Shortcuts on my StreamDeck, but the go-to solution bricked on me, on the first day. Whatever I did, I couldn’t get it working again. That was the start of this project…

Of course, I wasn’t going to make a simple thing. No, I had to do it the justice it so rightly deserved. 😝

### Repo Structure
- The backend (this one)
- & the [Property Inspector’s](https://github.com/SENTINELITE/StreamDeck-Shortcuts-PropertyInspector)

---

### Lost, But Not Forgotten Features:
- Set Discord/GitHub image/logo beside their description text?
- isPrivateAnalytics Bool. Allow user’s to toggle Analytics.
- Move settings into a popup window? See Elgato PI Demo.
- Don’t send a payload, if settings haven’t changed. Only send what *has* changed. Show if settings changed by showing an “X” on the save box, instead of the green box.
- We shouldn’t send all the shortcuts, only a limited few. The payload is probably too big, for bigger libraries.
- Allow user to switch Accessibility speed. Only some voices support this…
- Allow for accessibility toggle. Ie, some people may not/want to hold down for x amount of time. Create an option to tap, starting the timer, then another tap confirm or cancel, when the timer finishes.
- 🚀 Create Shortcut from Button Press?
- 🚀 Open/Edit Shortcut in the Shortcuts.app

---

### ⚠️ Known Issues & Bugs
- 🐞Potential: App becomes unresponsive after computer wakes up from sleep???
- 🐞Rare: Sometimes the app fails to startup correctly. Need to dig into this.
- We’re only fetching/getting the first discovered StreamDeck. We need to get all the user’s connected StreamDeck Devices
	- We’re getting the connected count, but we still need to fetch the unique IDs.
- If the shortcut name is long, the search field gets small. We fixed the former, but now we’re Popping out of PI’s regular dimensions…

---

### 🐞 New Issue or 💬 Comments?
- [Open an Issue](https://github.com/SENTINELITE/StreamDeck-Shortcuts/issues/new)
- [Tweet Me](http://sentinelite.com/twitter)
- [Join the Discord Community](https://sentinelite.com/discord)
