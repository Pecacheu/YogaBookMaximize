Here's a script I put together that works better than Lenovo's official software for maximizing windows across screens, or placing a window on the bottom screen besides the physical/virutal keyboard (WonderBar window). If you have the virtual touchpad open, it will also reposition both the trackpad and your window for you automatically (trackpad to the right for right-handed folks. Can be easily modified so the script does it to the left instead.)

It also works perfectly with Chrome/Edge's **picture-in-picture** video player, while the built-in gestures do not. If you've never heard of that feature, try it out! Right-click any video (you have to right-click twice on YouTube) and select "picture-in-picture." Last but not least, it adds some shortcuts for your **media controls**, too, since by some inexplicable oversight, Lenovo forgot to add any to the official keyboard.

## Shortcuts
- <u>Shift + Win + Up</u> = Maximize Window
- <u>Ctrl + Win + Up</u> = Wonderbar Window
- <u>Win + /</u> = Landscape Mode (Default)
- <u>Win + \\</u> = Inverse Landscape Mode
- <u>Ctrl + F1</u> = Play/Pause
- <u>Ctrl + F2</u> = Prev
- <u>Ctrl + F3</u> = Next

### Menu Only Commands
- Top Only (Disable lower display)
- Bottom Only (Disable upper display)

## Advantages over built-in gesture
- Works more reliably, and with nearly all resizable applications.
- Works in **ALL** screen orientations!
- Still works when an external monitor is connected, and is able to ignore any extra screens no matter where they're placed (above, below, left or right)
- Even works if your top display isn't set as the primary monitor!
- Is able to trick Windows into using the "maximized window" UI across both screens, maximizing your screen real-estate and removing any ugly borders.
- When the virtual touchpad is open and WonderBar window is used, it repositions both automatically so you can have a virtual trackpad AND a window open on the bottom screen! Great for watching YouTube videos while getting work done.

## How to Install
Download the AHK file above. I suggest you copy it to your Startup folder so it runs automatically, but you'll need to run in manually at least once. Press **WIN + R** and type `shell:startup` into the prompt, that will open your Startup folder. You will also need to install [AutoHotKey v2](https://autohotkey.com) if you've never used it before.

**Note:** You may need to change `MonTopID` and `MonBtmID`, I'm not sure how universal these are. To see all the IDs, use `PrintIDs()`