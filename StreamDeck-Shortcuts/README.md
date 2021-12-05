#  ReadME File

###Welcome to the StreamDeck Shortcuts Repository!


I wanted to run my shortcuts on my StreamDeck,  was using another plugin, but ended up bricking said plugin, on the first day. After multiple uninstalls & & computer restarts, it just wouldn’t work. That was the start…

Of course I wasn’t going to make a simple thing. No, I had to do it the justice it so rightly deserved.

What started as a simple: “Let’s run Shortcuts on the StreamDeck”, turned into a fun learning process!

###Lost, but not forgotten features:
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
Copy & pasting or moving keys, doesn’t retain their state.
🐞Potential: App becomes unresponsive after computer wakes up from sleep???
🐞Rare: Sometimes the app fails to startup correctly. Need to dig into this.
- [x] When selecting a new voice after opening the PI, the button’s text goes blank. Each subsequent selection does this.
- [x] ForcedTitle OnAppear not working right, upon startup. Temp Fix: Move out of view & back.
- We’re using sleep( ) in the `accessKeyProcess` function. This isn't a good idea. Fully Switch to Async/Await & Task.sleep( )
If the shortcut name is long, the search field get’s small. We fixed the former, but now we’re Popping out of PI’s regular dimensions…
- [x] The first signal is currently being suppressed. For some reason the payload it empty. Not sure as to why.
We’re only fetching/getting the first discovered StreamDeck. We need to get all of them.
    We’re getting the connected count, but we still need to fetch the unique IDs!


![StreamDeck-Shortcuts_Banner](https://user-images.githubusercontent.com/44782976/144732233-c5c1f594-1d22-47e5-b23f-97f22c4982f0.png)
