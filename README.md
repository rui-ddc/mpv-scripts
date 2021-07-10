# skip-intro.lua

This script skips to the next moment of silence in the video. The intended use for this is to skip until the end of an opening sequence, at which point there's often a short period of silence.

## Setup
Download **skip-intro.lua** and save it to `mpv/scripts/`.

The default keybind to *start/stop* skipping is `Tab`.<br />
You can change this by adding to `mpv/input.conf` the following line:
```
NEW_KEY script-binding skip-key
```

To tweak the script's parameters you can copy the following code to `mpv/script-opts/skip-intro.conf`:
```
# Maximum noise (dB) to trigger
quietness = -30

# Minimum silence duration (s) to trigger
duration = 0.5
```
