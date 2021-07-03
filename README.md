## skip-intro.lua

This script skips to the next silence in the file. The
intended use for this is to skip until the end of an
opening or ending sequence, at which point there's often a short
period of silence.

The default keybind is `Tab`. You can change this by adding
the following line to your `input.conf`:
```
KEY script-binding skip-intro
```

In order to tweak the script parameters, you can place the
text below in a new file at
`script-opts/skip-intro.conf` in mpv's user folder. The
parameters will be automatically loaded on start.

```
# Maximum amount of noise to trigger, in terms of dB.
# The default is -30 (yes, negative). -60 is very sensitive,
# -10 is more tolerant to noise.
quietness = -30

# Minimum duration of silence to trigger.
duration = 0.1
```
