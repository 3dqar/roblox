# 🌈 TROLL OBBY

Roblox Studio / Rojo project, with a procedural neon obby and a responsive HUD.

## Current features
- 10 colorful stages with jumping platforms, troll traps, lava, and floating stage signs
- Respawn at checkpoint, stage leaderboard, finish stage
- DataStore progress saving (when published and API access is enabled)
- Shop UI: Skip Stage Developer Product and VIP Game Pass (IDs are **0**, so disabled by default)
- Receipt deduplication with DataStore and server-controlled fulfillment
- Studio-only test fallback when DataStore API access is not enabled

## Update your local project (IMPORTANT)
Rojo synchronizes **local files**, not files on GitHub. After GitHub edits, download a fresh ZIP with `Code → Download ZIP`, unzip it and use the **new** `roblox-main` folder, or run `git pull` if you cloned the repository using Git.

**To avoid repeated downloading:** install Git and use these terminal commands in your project folder:
```sh
cd ~/Downloads/roblox-main
# Only if cloned using Git:
git pull
~/Downloads/rojo serve
```
If you originally downloaded ZIP, it is **not** a Git repository: `git pull` will not work. For subsequent updates, clone it once:
```sh
cd ~/Downloads
git clone https://github.com/3dqar/roblox.git troll-obby
cd troll-obby
~/Downloads/rojo serve
```
From that point on, stop the Rojo server, run `git pull`, then restart `~/Downloads/rojo serve`. No re-downloading ZIPs.

## Play
1. Use [Rojo](https://rojo.space/) CLI and Roblox Studio plugin (same version ideally).
2. In terminal inside this folder run `rojo serve` (or `~/Downloads/rojo serve`).
3. Open **Baseplate** in Roblox Studio and connect the Rojo plugin to `localhost:34872`.
4. Press **Play**. The `GeneratedObby` folder is runtime-generated, meaning it **only appears while Play is running**.
5. If no map: open **Output** with the **Server** filter. Check whether `TROLL OBBY: generated 10 stages` appears or errors are shown. The HUD alone doesn't prove the server script is running.
6. In Explorer, verify `ServerScriptService > Main` and `ReplicatedStorage > Config`.

## Monetization
1. Publish the experience, create **Developer Product** for Skip Stage and **Game Pass** for VIP in Creator Dashboard.
2. Enter IDs in `src/ReplicatedStorage/Config.lua`. Until then, purchase buttons show a helpful message.
3. Test fulfillment in a private published experience, not with real players first.

**Notice:** This code has been edited through GitHub, not executed inside your Roblox Studio. Game functionality, receipts, UI responsiveness, and final balancing still need in-Studio testing.
