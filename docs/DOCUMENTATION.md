# My Hub – Documentation

> A professional Roblox executor utility hub with a clean GUI, six built-in tools, toast notifications, and a full activity log.

---

## Quick Start

Paste **one line** into any Roblox script executor and execute it:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ebubekirdemirci2013-netizen/my-hub/main/hub.lua"))()
```

The hub window will appear in the centre of your screen immediately.

---

## Interface Overview

| Area | Description |
|---|---|
| **Title bar** | Drag to reposition. Yellow **─** minimises, red **✕** closes. |
| **Sidebar** | Six tab buttons – click any to switch panels. |
| **Content area** | Scrollable panel for the selected tool. |
| **Toast notifications** | Slide in from the bottom-right; auto-dismiss after 3 s. |

---

## Tabs

### 🏠 Home
Displays your player name, display name, user ID, current game name & place ID.  
Also shows a quick summary of all available tools.

---

### 🔢 Calculator

**Expression box** – type any mathematical expression and press **Enter** or click **= Evaluate**.

Supported syntax:

| Syntax | Example |
|---|---|
| Arithmetic | `2 + 3 * 4 / 2 - 1` |
| Integer division | `17 // 5` → `3` |
| Modulo | `17 % 5` → `2` |
| Power | `2^10` → `1024` |
| Parentheses | `(3 + 4) * 2` |

Built-in functions:

`abs` `sqrt` `floor` `ceil` `round` `sin` `cos` `tan` `asin` `acos` `atan`
`log` `log10` `exp` `max` `min` `factorial` `gcd`

Constants: `pi`  `e`  `inf`

**Memory slots** – store any result in a named variable:

```
r = 5
area = pi * r^2
```

Then reference it in the expression box: `area + 1`.  
The last result is always available as `ans`.

**History** – the last 50 expressions are shown below the memory section.

---

### 📝 Text Tools

1. Type or paste text in the **Input** box.
2. Click a transform button – the result replaces the text in-place.

| Button | Action |
|---|---|
| UPPER CASE | Convert all letters to upper case |
| lower case | Convert all letters to lower case |
| Title Case | Capitalise the first letter of every word |
| Reverse | Reverse the entire string character by character |
| Trim Spaces | Remove leading/trailing whitespace from every line |
| ROT-13 | Apply ROT-13 substitution cipher (apply twice to decode) |

**Statistics** – click **Count Words & Characters** to see:
characters, characters without spaces, word count, line count.

**Base64** – click **Encode →** or **← Decode** to convert the current text.

---

### { } JSON Viewer

1. Paste valid JSON into the **Input** box.
2. **Parse & View** – decodes and pretty-prints the JSON (2-space indent, keys sorted).
3. **Pretty-Print** – re-formats any already-parsed document.
4. **Minify** – produces a compact single-line representation.
5. **Search** – enter a keyword to find matching keys or string values. Results are shown as `$.path = value` pairs.

Supports: objects, arrays, strings, numbers, booleans, and `null`.

---

### ⚙ Settings

| Setting | Description |
|---|---|
| Notifications | Toggle toast pop-ups on/off |
| Window Transparency | Drag the slider (0 = opaque, ~75 % = mostly transparent) |
| Reset Window Position | Snap the hub back to screen centre |
| Clear Calculator Memory | Wipe all named memory slots |

---

### 📋 Logs

Every action taken in the hub is recorded with a timestamp.

- **Clear Log** – wipes the in-memory log list.
- **Copy to Clipboard** – copies all log lines (requires executor `setclipboard` support).

Log format: `[HH:MM:SS] <icon> <message>`

---

## Keyboard Shortcuts

| Key | Context | Action |
|---|---|---|
| **Enter** (in Calculator input) | Calculator tab | Evaluate expression |

---

## File Structure

```
my-hub/
├── hub.lua          # Complete self-contained Roblox GUI hub
├── load.lua         # One-liner loader (copy this into your executor)
├── lib/
│   └── json.lua     # Standalone pure-Lua JSON library (non-Roblox use)
└── docs/
    └── DOCUMENTATION.md
```

---

## Compatibility

| Environment | Status |
|---|---|
| Synapse X | ✔ |
| KRNL | ✔ |
| Script-Ware | ✔ |
| Fluxus | ✔ |
| Any executor supporting `loadstring` + `game:HttpGet` | ✔ |

> **Note:** `Copy to Clipboard` in the Logs tab requires the executor to expose the `setclipboard` global.

---

## License

MIT – free to use, modify, and distribute.
