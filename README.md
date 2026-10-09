# TROLL OBBY v3 🌋

Roblox/Luau game source synchronized to Studio via **Rojo**.

## New in v3
- 30 stages, jumping gaps, lasers, falling and tweened moving platforms
- Lava ocean, floating islands, glowing crystals and sunset-style lighting
- Stage checkpoint guard (no more accidentally completing every stage immediately)
- Tutorial window, progress HUD, missions/milestones, shop, donation panel, settings
- Developer Product purchase handling and deduplication; configurable VIP game pass

**Testing status:** committed to GitHub; still must be played and verified in Roblox Studio. Mission milestones are display-only (no currency rewards yet). Donation purchase IDs default to zero (disabled). Audio, saved settings, 3D animations and thumbnails are not yet included.

## Update on macOS
Stop Play in Studio and Rojo in Terminal (Control+C), then:
```bash
cd ~/Downloads/troll-obby
git pull
~/Downloads/rojo serve
```
Rojo plugin should connect to localhost:34872. If connected to a different local project, disconnect/reconnect.
Press Play. The map folder **GeneratedObby** appears in Workspace *only during Play*. Look for `TROLL OBBY v3: generated 30 stages` in Output.

If your copy came from a ZIP rather than `git clone`, clone it once and work from the clone:
```bash
cd ~/Downloads
git clone https://github.com/3dqar/roblox.git troll-obby
cd troll-obby
~/Downloads/rojo serve
```

## Publishing / saves
Save progress requires publishing the experience and enabling Studio API access only for a safe test place. In unpublished Studio mode, the game works without persistent saves. Server logs may still warn if DataStore API access is disabled.

## Monetization
Create Developer Products and Game Pass in Roblox Creator Dashboard; put IDs in `src/ReplicatedStorage/Config.lua`. Skip Stage and 3 donation buttons use Developer Product IDs, VIP uses Game Pass ID. Until configured, purchase buttons show a notice instead of opening payment. Test all receipts privately before public launch.

**Known limitations:** moving anchored platforms might not carry characters smoothly depending on physics; stage balance must be playtested on PC and mobile; donation thank-you effects currently show a notification, not permanent rewards.
