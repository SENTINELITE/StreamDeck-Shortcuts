### Welcome to the StreamDeck Shortcuts Repository!
![GH_Banner](https://user-images.githubusercontent.com/44782976/144743854-a7d2d06a-b268-42cc-912a-af7100789008.png)

### About StreamDeck Shortcuts
Welcome in! This Repo is for all things Shortcuts/StreamDeck!

We’re all about making sure the software is Fast, Reliable, & Performant, all while offering excellent accessibility support!

The StreamDeck's been unleashed. Infinite possibilities at the speed of light. All within touch.

If you want to learn more about how & why this was made, take a look at [this Twitter thread!]
—

### Backstory
I wanted to run my shortcuts on my StreamDeck,  was using another plugin, but ended up bricking said plugin, on the first day. After multiple uninstalls & & computer restarts, it just wouldn’t work. That was the start…

Of course I wasn’t going to make a simple thing. No, I had to do it the justice it so rightly deserved.

What started as a simple: “Let’s run Shortcuts on the StreamDeck”, turned into a fun learning process!

### Repo Structure
The Repository is split into two:
- The backend (this one)
- & the [Property Inspector’s](https://github.com/SENTINELITE/StreamDeck-Shortcuts-PropertyInspector)


### Lost, but not forgotten features:
- Set Discord/Github image/logo beside their description text?
- isPrivateAnalytics Bool. Allow user’s to toggle Analytics.
- Move settings into a popup window? See Elgato PI Demo.
- Don’t send a payload, if settings haven’t changed. Only send what *has* changed. Show if settings changed by showing an “X” on the save box, instead of the green box.
- We shouldn’t send all of the shortcuts, only a limited few. The payload is probably too big, for bigger libraries.
- Allow user to switch Accessibility speed. Only some voices support this…
- Allow for accessibility toggle. ie some people may not/want to hold down for x amount of time. Create an option to tap, starting the timer, then another tap confirm or cancel, when the timer finishes.
- 🚀 Create Shortcut from Button Press?
- 🚀 Open/Edit Shortcut in the Shortcuts.app



## ⚠️ Known Issues & Bugs
- 🐞Potential: App becomes unresponsive after computer wakes up from sleep???
- 🐞Rare: Sometimes the app fails to startup correctly. Need to dig into this.
- We’re only fetching/getting the first discovered StreamDeck. We need to get all of them.
    - We’re getting the connected count, but we still need to fetch the unique IDs!
- If the shortcut name is long, the search field get’s small. We fixed the former, but now we’re Popping out of PI’s regular dimensions…

If you experience any bugs, feel free to do any of the following:
- [open an Issue,]
- [Tweet Me]
- [Join the Discord Community]
