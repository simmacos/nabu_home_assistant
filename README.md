# Nabu — Local Offline Voice Assistant

A **100% local, offline** voice assistant for the home, built on [Home Assistant](https://www.home-assistant.io/) and the [Wyoming protocol](https://github.com/rhasspy/wyoming). No data ever leaves the local network: no cloud, no accounts, no telemetry.

The system runs distributed across **3 machines** connected over LAN.

---

## Architecture

```
┌──────────────────────────────┐
│  SATELLITE  (Surface Go)      │
│  ─ microphone + speaker       │
│  ─ linux-voice-assistant      │
│    (Wyoming satellite)        │
│  ─ local wake word            │
│  ─ KDE/Wayland screensaver    │
└───────────────┬──────────────┘
                │ LAN (Wyoming protocol)
                ▼
┌──────────────────────────────┐
│  HOME ASSISTANT  (server)     │
│  ─ homeassistant   :8123      │
│  ─ openwakeword    :10400     │  detects "okay nabu"
└───────┬───────┬───────┬──────┘
        │       │       │
        ▼       ▼       ▼
┌────────┐ ┌────────┐ ┌──────────┐
│ AI SRV │ │ AI SRV │ │  AI SRV   │
│ faster-│ │ piper- │ │  ollama   │
│ whisper│ │ tts    │ │  :11434   │
│ :10300 │ │ :10200 │ │  LLM      │
│ STT    │ │ TTS    │ │  (Gemma)  │
│ (it,   │ │ (it_IT │ │  intent / │
│ v3-    │ │ riccar-│ │  convers. │
│ turbo) │ │ do)    │ │           │
└────────┘ └────────┘ └──────────┘
```

> **Note:** `home-assistant/` and `ai-server/` can run on the same machine or on separate ones — they are split into distinct compose files for flexibility.

---

## Voice request flow

1. **Wake word** — the satellite (or `openwakeword`) listens continuously and triggers on the keyword.
2. **STT** — audio is sent to `faster-whisper` → transcribed to text (Italian).
3. **Intent / conversation** — Home Assistant handles the text. Built-in intents run the action (lights, scenes…); open questions are forwarded to the **Ollama** LLM (Gemma) for a natural-language answer.
4. **TTS** — the text response goes to `piper-tts` → audio.
5. **Playback** — the audio returns to the satellite and is played back.

Everything happens **on the LAN**, with zero external connections.

---

## Components

### `ai-server/` — STT + TTS

| Service | Port | Role | Config |
|---------|------|------|--------|
| `faster-whisper` | 10300 | Speech→Text | model `large-v3-turbo`, language `it`, `int8`, 12 CPU threads |
| `piper-tts` | 10200 | Text→Speech | voice `it_IT-riccardo-x_low` |

```bash
cd ai-server && docker compose up -d
```

**Ollama** — the LLM provider for conversation/intent — runs **natively on the host** (not in compose), on the same AI server.

| Service | Port | Role | Config |
|---------|------|------|--------|
| `ollama` | 11434 | LLM (intent / conversation) | model `gemma3:4b` (adjust tag to your model) |

```bash
# native install (Arch): pacman -S ollama  (or the official script)
systemctl enable --now ollama
ollama pull gemma3:4b
```

In Home Assistant add the **Ollama** integration pointing to `<ai-server-ip>:11434` and select it as the conversation agent.

### `home-assistant/` — HA core + wake word

| Service | Port | Role | Config |
|---------|------|------|--------|
| `homeassistant` | 8123 | Core (host network) | linuxserver image, TZ `Europe/Rome` |
| `openwakeword` | 10400 | Wake word detection | model `okay_nabu` |

```bash
cd home-assistant && docker compose up -d
```

> ⚠️ Before starting: replace `/path/to/your/ha/config` in `home-assistant/docker-compose.yml` with your real HA config path.

### `satellite/` — voice device + display

A PC with microphone and speaker (e.g. Surface Go) running [`linux-voice-assistant`](https://github.com/OHF-Voice/linux-voice-assistant).

- **Active wake word:** `hey_rhasspy` (configurable in `preferences.json`)
- **Available wake words:** `okay_nabu`, `hey_jarvis`, `alexa`, `hey_mycroft`, `hey_luna`, `hey_home_assistant`, `okay_computer`, `choo_choo_homie`, `stop`
- **Screensaver:** after 120s of inactivity (`swayidle`) it opens Kitty fullscreen with 3 panels — weather, clock, animated bonsai.

![Screensaver running on the Surface Go 2 satellite](satellite/screensaver.jpg)

Full details in [`satellite/README.md`](satellite/README.md).

---

## Quick start

```bash
# 1. AI server (STT + TTS)
cd ai-server && docker compose up -d

# 2. Home Assistant + wake word
cd ../home-assistant
# edit the config path in the compose file, then:
docker compose up -d

# 3. Satellite
# see satellite/README.md
```

In Home Assistant, configure the **Wyoming** integration pointing to the services:
- Whisper → `<ai-server-ip>:10300`
- Piper → `<ai-server-ip>:10200`
- openWakeWord → `<ha-ip>:10400`

Then add the **Ollama** integration → `<ai-server-ip>:11434` and set it as the conversation agent.

---

## Example hardware

| Role | Machine |
|------|---------|
| Satellite | Surface Go (KDE/Wayland) |
| Home Assistant + AI | Mini-PC server (powered on via Wake-on-LAN) |

---

## Privacy

- **No cloud.** STT, TTS, wake word, intent and the LLM (Ollama/Gemma) all run entirely locally.
- No dependency on external services (Alexa, Google, OpenAI…).
- Models (Whisper, Piper, openWakeWord, Ollama) are downloaded once and stored locally.

---

## License

[MIT](LICENSE) © 2026 simmacos
