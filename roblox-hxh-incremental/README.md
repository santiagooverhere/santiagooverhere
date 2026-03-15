# Hunter x Hunter Incremental (Roblox)

A full Lua/Luau Roblox game template inspired by **Hunter x Hunter** with a GUI-first gameplay loop similar to incremental RPG experiences.

## Features included

- Fully GUI-driven gameplay (no mandatory world interaction).
- Mobile-friendly responsive UI scaling.
- Training loop with auto stat gains.
- Mission board and mission completion rewards.
- Attributes, XP, level, inventory, and Jenny economy.
- Clan / Race / Nen Power rolling system with rarity weights.
- Turn-based combat simulation with move lists per Nen power.
- Global player marketplace (DataStore-backed listing feed).
- Auto-save profile progression (join, interval, leave, shutdown).

## Lore-inspired systems

The default data model includes HxH-inspired entries for:
- Clans: Freecss, Zoldyck, Kurta, etc.
- Races: Human, Chimera Ant, etc.
- Nen powers: Enhancement, Transmutation, Conjuration, Emission, Manipulation, Specialization.

Each entry contains rarity + buffs and powers include unique move kits.

## Import into Roblox Studio

### Option A (recommended): Rojo workflow
1. Install [Rojo](https://rojo.space/).
2. Open this folder in your editor.
3. Run:
   ```bash
   rojo serve
   ```
4. In Roblox Studio, connect the Rojo plugin to this project.
5. Press Play.

### Option B: Manual copy
1. Create a place in Roblox Studio.
2. Recreate the folder layout from `src/` inside Studio services:
   - `ReplicatedStorage/Config`
   - `ReplicatedStorage/Shared`
   - `ServerScriptService/Services`
   - `ServerScriptService/Bootstrap`
   - `StarterGui/HxHUI`
3. Paste each script's content into matching Script/ModuleScript/LocalScript instances.
4. Publish and test in a server-enabled play session.

## Important production notes

- DataStore APIs require published game + Studio API access enabled.
- Marketplace uses DataStore list keys; for large scale production, migrate to sharded key indices and add anti-fraud validations.
- Add security hardening (server-side checks per action, anti-exploit throttling) before public release.
- Add art/assets/audio separately to avoid IP issues.

## Suggested next steps

- Add a proper mission timer queue instead of instant completion.
- Add PvP queue and async battle requests.
- Add daily quests, season pass, and rebirth/prestige systems.
- Expand Nen move effects into true status systems.
