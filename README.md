# skip-intro.lua #

This script skips to the next silence in the file. The intended use for this is to skip until the end of an opening sequence, at which point there's often a short period of silence.

## Setup ##
Download *skip-intro.lua* and save it to `/mpv/scripts/`

The default keybind to start/stop the skip is `Tab`. You can change this by creating a new file called `mpv/input.conf` with the following line:
```
NEW_KEY script-binding keypress
```

In order to tweak the script parameters, you can place the text below in a new file at `mpv/script-opts/skip-intro.conf` in mpv's user folder. The parameters will be automatically loaded on start.

```
# Maximum noise (dB) to trigger
quietness = -30

# Minimum silence duration (s) to trigger
duration = 0.1
```
