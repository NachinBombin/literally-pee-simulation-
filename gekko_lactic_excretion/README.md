# gekko_lactic_excretion

Simplified lactic acid excretion system for the **Gekko NPC** — a bipedal creature that lore-wise excretes lactic acid in the form of a liquid stream.

Extracted and stripped from [literally-pee-simulation-](https://github.com/NachinBombin/literally-pee-simulation-). All SWEP logic, zipper mechanics, piss types, and player-specific code removed. Only the core stream visual, splash particles, mist cloud, and audio remain.

---

## Addon Structure

```
gekko_lactic_excretion/
├── addon.txt
├── README.md
├── lua/
│   ├── autorun/
│   │   └── server/
│   │       └── sv_gekko_pee.lua        ← NPC metatable extensions: StartLacticPee / StopLacticPee
│   ├── effects/
│   │   └── gekko_lactic_cloud.lua      ← Client-side mist cloud on splash
│   └── entities/
│       └── ent_gekko_lactic_drop/
│           ├── shared.lua
│           ├── cl_init.lua
│           └── init.lua                ← Physics drop: trajectory, rope trail, splash
```

---

## Required Assets (copy from literally-pee-simulation-)

These are **not included** — copy them from the source addon:

| Source path | Destination in this addon |
|---|---|
| `sound/postal2/Piss_Start.wav` | `sound/postal2/Piss_Start.wav` |
| `sound/postal2/Piss_Loop.wav` | `sound/postal2/Piss_Loop.wav` |
| `sound/postal2/Piss_End.wav` | `sound/postal2/Piss_End.wav` |
| `materials/piss/trails/pee.vmt` | `materials/piss/trails/pee.vmt` |
| `materials/piss/trails/pee.vtf` | `materials/piss/trails/pee.vtf` |

---

## Usage

In your Gekko NPC Lua file, call:

```lua
-- Begin excreting lactic acid
self:StartLacticPee()

-- Stop excreting
self:StopLacticPee()
```

These methods are added to the NPC metatable by `sv_gekko_pee.lua` automatically on server start.

---

## How it Works

1. `StartLacticPee()` starts a repeating timer (`PEE_RATE = 0.05s`) that spawns `ent_gekko_lactic_drop` entities at the NPC's pelvis bone.
2. Each drop is a tiny invisible physics sphere launched forward with slight downward arc.
3. Each drop is connected to the previous one with a `constraint.Rope()` using the pee stream material — this creates the visible liquid stream.
4. On collision (`PhysicsCollide` / `Touch`), the drop triggers `slime_splash_01_droplets` (built-in GMod particle) and `gekko_lactic_cloud` (greenish-yellow mist).
5. Audio: `Piss_Start` on begin, `Piss_Loop` re-triggered every 1.8s, `Piss_End` on stop.
