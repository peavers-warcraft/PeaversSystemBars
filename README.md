# PeaversSystemBars

[![Ultra Performance](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/peavers-warcraft/PeaversSystemBars/master/.github/badges/perf.json)](https://github.com/peavers-warcraft/PeaversSystemBars/actions/workflows/perf.yml)
[![AddonSentry](https://addonsentry.io/api/public/repos/peavers-warcraft/PeaversSystemBars/badge.svg)](https://addonsentry.io/dashboard/peavers-warcraft/PeaversSystemBars)

A World of Warcraft addon that displays FPS and latency as minimal, movable status bars.

Part of the **Peavers Ultra Performance** family: addons that hold themselves to a published budget, measured on every push.

## Measured performance

An addon that watches your framerate has no business costing you any. This one
does **no per-frame work at all** — there is not a single `OnUpdate` handler
anywhere in `src/`. The bars refresh on a timer instead, and the table below is
what one refresh actually costs, regenerated on every push by the
[Ultra Performance harness](https://github.com/peavers-code/peavers-warcraft-workflows/tree/master/perf-harness)
driving the real `BarManager:UpdateAllBars` loop. If any number goes outside
`perf/budget.json`, the build fails.

<!-- perf:begin -->

> Measured on every push by the Ultra Performance harness. The build fails if any number here exceeds the budget in `perf/budget.json`.

| Check | Measured | Budget | |
|---|---:|---:|:--:|
| Packaged size | 46.2 KB | 80 KB | pass |
| Bundled libraries | 0 | 0 | pass |
| Widget calls per frame | 0 | 0 | pass |
| Widget calls per second while idle | 0 | 0 | pass |
| Widget calls per second | 32 | 40 | pass |

Scenarios driven against the real addon source, outside the game:

| Scenario | Calls/frame | Calls/sec | Notes |
|---|---:|---:|---|
| 5 bars refreshed, every 0.5s | 0.00 | 32.0 | 16 calls per tick, 200 ticks driven |
| idle, between ticks | 0.00 | - | no OnUpdate handler exists anywhere in src/ |

<sub>1,318 lines of Lua · 46.2 KB packaged · no bundled libraries</sub>

<!-- perf:end -->

The per-second figure is the honest unit here: five bars cost three calls each
per refresh, plus one colour change for durability, twice a second. Raising
**Update interval** in the settings lowers it proportionally.

## Features

<!-- peavers:features -->
- **FPS Bar** (green) - Shows current frames per second
- **Home Latency Bar** (blue) - Shows datacenter/home ping in milliseconds
- **World Latency Bar** (orange) - Shows world server ping in milliseconds
- Dynamic bar scaling based on rolling 30-second max values
- Movable and lockable frame positioning
- Customizable appearance with title bar toggle
- Updates every 0.5 seconds
<!-- /peavers:features -->

## Usage

<!-- peavers:usage -->
- `/psb` - Toggle the system bars display
- `/psb config` - Open the configuration panel
- Left-click and drag the frame to reposition
<!-- /peavers:usage -->

## Configuration

<!-- peavers:configuration -->
Access settings through the game's addon options or `/psb config` to customize:

- Frame position and size
- Title bar visibility
- Frame lock/unlock
<!-- /peavers:configuration -->


## Installation

### Recommended: PeaversUpdater

Download and install [PeaversUpdater](https://github.com/peavers-warcraft/PeaversUpdater/releases/latest), the desktop updater for the whole Peavers collection. It installs PeaversSystemBars together with its required dependencies and delivers updates before they reach CurseForge.

### Alternative: CurseForge

1. Download from [CurseForge](https://www.curseforge.com/wow/addons/peaverssystembars)
2. Ensure [PeaversCommons](https://www.curseforge.com/wow/addons/peaverscommons) is also installed
3. Ensure [PeaversConfig](https://www.curseforge.com/wow/addons/peaversconfig) is also installed
4. Enable the addon on the character selection screen

---

*Part of the [Peavers](https://peavers.io) addon collection · [Report an issue](https://github.com/peavers-warcraft/PeaversSystemBars/issues) · [Support development on Patreon](https://www.patreon.com/Peavers)*
