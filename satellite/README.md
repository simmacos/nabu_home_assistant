# Screensaver + Satellite Assistant — Documentation

---

## Screensaver

### How it works

At KDE startup the autostart entry is loaded and launches the main script.
After **120 seconds of inactivity** (detected by `swayidle`) Kitty opens fullscreen with 3 panels.

![Screensaver running on the Surface Go satellite](screensaver.jpg)

### Files

| File | Original path |
|------|---------------|
| `autostart-screensaver.sh.desktop` | `~/.config/autostart/` |
| `autostart-screensaver.sh` | `~/.config/` |
| `avvia_screensaver.sh` | `~/` |
| `screensaver.conf` | `~/.config/kitty/` |

### autostart-screensaver.sh.desktop

KDE autostart entry that runs `autostart-screensaver.sh` at session start.

### autostart-screensaver.sh

```bash
#!/usr/bin/env bash
sleep 5
swayidle -w timeout 120 '~/avvia_screensaver.sh start' resume '~/avvia_screensaver.sh stop' 2>/dev/null &
```

- Waits 5 seconds to let Wayland load
- Launches `swayidle`: after 120s of inactivity it starts the screensaver, and stops it on resume

### avvia_screensaver.sh

```bash
# start → opens Kitty fullscreen with the screensaver.conf session
# stop  → kills the process via the PID saved in /tmp/kitty_screensaver.pid
```

### screensaver.conf (Kitty session)

3-panel layout:

| Panel | Command | Description |
|-------|---------|-------------|
| Left | `weathr` | Weather |
| Top right (31%) | `peaclock` | Decorative clock |
| Bottom right (60%) | `cbonsai -S` | Animated bonsai tree |

> `sleep 0.5` before `cbonsai` is needed to let the window dimensions load in Wayland before drawing the tree.

---

## Satellite Assistant (Home Assistant)

### Project

**`~/linux-voice-assistant`** — voice satellite for Home Assistant based on the Wyoming protocol.

### fish aliases (`~/.config/fish/config.fish`)

| Alias | Command | Description |
|-------|---------|-------------|
| `ass` | `~/linux-voice-assistant/./script/run --name "Surface Go" --audio-input-device "Audio interno Stereo analogico" --audio-output-device "pipewire" --debug` | Start the satellite on this PC (Surface Go) |
| `ass-on` | `wol <MAC_SERVER>` | Power on the HA server via Wake-on-LAN |
| `ass-ssh` | `ssh <USER>@<IP_SERVER>` | SSH into the HA server |
| `ass-off` | `ssh <USER>@<IP_SERVER> "sudo poweroff"` | Power off the HA server remotely |

### How it starts (`ass`)

```bash
~/linux-voice-assistant/script/run \
  --name "Surface Go" \
  --audio-input-device "Audio interno Stereo analogico" \
  --audio-output-device "pipewire" \
  --debug
```

The `script/run` script activates the virtualenv (`.venv`) and launches the Python module `linux_voice_assistant`.

### Configuration (`preferences.json`)

```json
{
    "active_wake_words": ["hey_rhasspy"],
    "volume": 1.0,
    "thinking_sound": 1
}
```

- **Active wake word**: `hey_rhasspy`
- **Volume**: 100%
- **Thinking sound**: enabled

### Available wake words

| Wake word | File |
|-----------|------|
| `hey_home_assistant` | `wakewords/hey_home_assistant.tflite` |
| `hey_rhasspy` *(active)* | — |
| `alexa` | `wakewords/alexa.tflite` |
| `hey_jarvis` | `wakewords/hey_jarvis.tflite` |
| `hey_luna` | `wakewords/hey_luna.tflite` |
| `hey_mycroft` | `wakewords/hey_mycroft.tflite` |
| `okay_nabu` | `wakewords/okay_nabu.tflite` |
| `choo_choo_homie` | `wakewords/choo_choo_homie.tflite` |
| `okay_computer` | `wakewords/okay_computer.tflite` |
| `stop` | `wakewords/stop.tflite` |

### Home Assistant server

| Info | Value |
|------|-------|
| IP | `<IP_SERVER>` |
| SSH user | `<USER>` |
| MAC (WoL) | `<MAC_SERVER>` |
