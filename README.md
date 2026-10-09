# TROLL OBBY — Roblox game

An expandable obstacle course made with Luau and [Rojo](https://rojo.space/).

## What's included
- 10 procedural stages with checkpoints, lava and a finish pad
- DataStore progress saving (highest reached stage)
- Stage leaderstats and respawning at latest unlocked checkpoint
- In-game shop UI: **Skip stage (9 Robux)** and **VIP (99 Robux)** placeholders
- Server-side purchase receipt handling and persistent VIP perks
- Keyboard, mobile-friendly buttons; no external models or assets

## Run with Roblox Studio
1. Install **Roblox Studio** and **Rojo** (CLI + Studio plugin): https://rojo.space/docs/v7/getting-started/installation/
2. Clone or download this repository.
3. In the project directory run `rojo serve`.
4. In Roblox Studio open a **new Baseplate**, then connect through the **Rojo plugin**.
5. Remove the default Baseplate part if desired; press **Play**. The map is generated at runtime.
6. For real DataStore tests: **publish the experience**, then in **Game Settings > Security** enable **Studio Access to API Services** only in a safe test experience.

## Enable paid purchases
1. Publish the experience to Roblox.
2. In Creator Dashboard create a **Developer Product** (Skip Stage, suggested 9 Robux) and **Game Pass** (VIP, suggested 99 Robux).
3. Copy the IDs into `src/ReplicatedStorage/Config.lua` (replace zeros).
4. Publish/test again. The purchase buttons do nothing when IDs are 0, and clearly indicate unconfigured purchases.

**Important:** Roblox handles the purchase dialogs; money is not generated simply because players join. Purchases must be tested in a published experience. Roblox publishing/monetization requirements may change.

## Architecture
- `src/ServerScriptService/Main.server.lua`: world generation, checkpoints, saving, product receipt, VIP benefits.
- `src/StarterPlayer/StarterPlayerScripts/UI.client.lua`: shop and stage HUD.
- `src/ReplicatedStorage/Config.lua`: prices/IDs, stage count.
- `default.project.json`: Rojo mapping.

## Known limits / roadmap
This is an **MVP**, not a live published Roblox experience. Test in Studio first. Planned: moving obstacles, troll traps, sounds, thumbnail, analytics, additional stages, better monetization balance.
