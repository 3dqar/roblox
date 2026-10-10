# 🌋 TROLL OBBY v4.0

Roblox Studio / Rojo project (30 colorful jumping stages).

## v4 additions
- Rotating red laser hazards and blinking traps alongside previous moving/falling platforms.
- Coins earned from advancing stages (+10) and reaching the finish (+250).
- Daily login reward: +75 Coins per UTC day.
- Character cosmetics replace pets: Rain (free), orbiting Spark (120 Coins), Aura (10 R$), Crown (20 R$), and special Bomz effect (40 R$). Premium effects are Game Passes with IDs initially 0 (disabled).
- Personal best run time and global TOP-10 speed ranking via OrderedDataStore.
- Victory dialog and confetti; extra responsive UI for daily rewards, effects, stats, leaderboards.
- Existing cinematic intro, tutorial, missions, skip-stage, VIP, support donation buttons still included.

### What isn't finished yet
- Supporter Pack pass (not implemented).
- Coins/effects/daily reward saving requires published experience and functioning DataStore; Studio unpublished mode uses session-only data.
- Sounds, fully persistent daily mission payouts, premium pet purchases and TOP-100 scrolling board are not implemented.
- This version **has not been run inside Roblox Studio**. Test with Play and Output before publishing publicly.

## Update macOS
In Roblox Studio Stop; in Terminal press Control+C, then:
```bash
cd ~/Downloads/troll-obby
git pull
~/Downloads/rojo serve
```
Reconnect the Rojo plugin if necessary. In Studio press Play and look for `TROLL OBBY v4: generated 30 stages` in Output.

## Monetization
For purchases, create products and passes in Roblox Creator Dashboard and add actual IDs to `src/ReplicatedStorage/Config.lua`. Skip product, donation products and VIP are disabled by default (ID=0). Purchases should only be enabled after private testing.

## Premium cosmetic effects
Create Game Passes for Aura (10), Crown (20), Bomz (40) in Creator Dashboard. Paste their IDs in `EffectPasses` in `Config.lua`. The suggested VIP price is now 39 Robux and donation tiers 5/15/30, but **Roblox Creator Dashboard prices must be set separately**. The amount shown in code does not set Roblox's actual purchase price. Test ownership and visual effects before publishing.

## WOW Lobby (new)
Players spawn in a floating neon lobby with glowing crystals, lit walkways, a portal leading into the 30-stage parkour, and two in-world boards: TOP RUNNERS (fastest recorded runs) and TOP SUPPORTERS (Robux spent on configured donation products). The boards refresh approximately every 90 seconds and need published DataStores for persistent global values. Supporter totals only include purchases **made through our configured donation products** after this update; purchases of game passes aren't included. Board entries remain empty until real scores/purchases exist. A game pass does not automatically appear on the support leaderboard.

Game Pass / Donation Product IDs remain set to 0 by default. No actual Robux payments can occur until configured and published. The lobby generator is in `src/ServerScriptService/Lobby.server.lua`; portal leads from `WOW_LOBBY` to `GeneratedObby`.

**Testing needed:** This was committed from GitHub but not run inside your Roblox Studio. Check collision/physics of lobby plaza, portal activation, correct checkpoint respawn, DataStore permissions, TOP boards, mobile performance and lighting before making the place public.

## Polish pass: lobby + more balanced platforming
- Crystal gate landmarks every five stages, slightly easier lateral gaps (still require jumping), more recognizable routes.
- Architectural arches and center sculpture in lobby; dimmer, more compact navigation.
- In default Studio mode, DataStore is intentionally **not accessed** to avoid error spam. To test persistent storage with a published *test* place and API permissions enabled, change `StudioDataStores` to `true` in `Config.lua`. Live published servers still use DataStore.
- TOP SUPPORTERS now counts `CurrencySpent` on successful configured donation-product receipts; it does not count game passes, nor older purchases before the tracking logic existed.
- Project code has been verified on GitHub, **not yet playtested in Roblox Studio**; check portal and checkpoint respawn, jump reachability, and mobile UI.

## Optional free Creator Store assets
Search in Creator Store for **low-poly floating rocks**, **stylized fantasy trees**, **neon sci-fi portal**, **cartoon clouds**, **obby sound effects**, and **ambient synth music**. Prefer assets without Scripts or LocalScripts and verify creator/license permissions. Put *decorative* models in Workspace outside `GeneratedObby` (which is regenerated at runtime); don't use unreviewed free models with executable scripts. Only use royalty-free audio allowed for Roblox experiences.

## Suggested Creator Store searches (optional)
- Stylized low poly rocks / floating islands
- Fantasy trees (no scripts)
- Crystal clusters (no scripts)
- Animated waterfall (inspect included scripts)
- Sci-fi portal frame (decorative only; do not replace programmed teleport trigger)
- Cartoon clouds and ambience (check visibility/performance)
- Short UI click, checkpoint and victory sound effects (licensed for Roblox use)
Avoid untrusted scripts inside free models. Cosmetic models can be placed into Workspace; generated course geometry under GeneratedObby is rebuilt when Play begins. Test collisions and mobile performance.

## Adventure feature update (checkpoint + double jump + speedrun + wheel + secrets + photos)
New files:
- `src/ServerScriptService/Adventure.server.lua`: 3 secret coin rooms (+35 Coins each, once per account when DataStore enabled), lobby photo zone and speedrun entrance, server-validated wheel/boost requests.
- `src/StarterPlayer/StarterPlayerScripts/Adventure.client.lua`: checkpoint particle bursts + built-in chime, small wheel/boost buttons, jump control, speedrun timer and reward messages.
- `Progression.server.lua` now owns rewards: daily wheel (once per UTC day: 25–150 Coins or a Spark cosmetic), 3-minute Double Jump for 80 Coins, secret rewards. Rewards are granted only by the server, not by the client.
- `Main.server.lua` tracks the separate speedrun route's checkpoints (2 through finish) without modifying unlocked stage progression and records completed times.

### Things to test in Roblox Studio
1. Step on checkpoint 2: green/gold burst and short sound; receive +10 Coins (as before).
2. Earn 80 Coins, press DOUBLE JUMP, jump then jump again while airborne. Boost expires after 3 minutes.
3. Go to lobby SPEEDRUN gate; travel through every stage and finish to record a separate speedrun time. Intentionally skipping a checkpoint must not count.
4. Press DAILY WHEEL twice: only the first attempt each UTC day awards a prize.
5. Find secret rooms near stages 4, 14, 24; +35 Coins once for each.
6. Use the photo area in lobby; it displays the zone and lets you use Roblox screenshot controls.

**Limitations:** No mechanical sound asset purchase is required, but the built-in checkpoint chime availability still needs Studio verification. The wheel currently reveals prizes immediately; a graphical spinning-wheel animation is a possible future enhancement. Secret room jump gaps and double-jump accessibility must be manually playtested. This GitHub update was not executed in Roblox Studio.

### Update on Mac
```bash
cd ~/Downloads/troll-obby
git pull
~/Downloads/rojo serve
```
Stop your previous Rojo server first (Control+C). Avoid copying files manually.

## Color Rush update
- Removed the old +75 Coins Daily Reward from UI and server to prevent overlapping daily bonuses. Daily Lucky Wheel remains.
- Added COLOR RUSH, a free color-memory challenge: watch a sequence of four Red/Black/Green tiles, repeat it, earn 20 Coins on success. 90-second cooldown between completed rounds; no Coins/Robux stakes or losses. This is **not** a roulette or casino and does not grant 2x/5x bet payouts, which are prohibited by Roblox simulated-gambling rules.
- Server validates game sequence, timing and rewards. UI is in `ColorRush.client.lua`, server handler in `ColorRush.server.lua`.
- Not yet tested in Roblox Studio; run Play and inspect Output before publishing.

## Five Arcade Activities Update
- Hourly Treasure Hunt: five treasure islands every UTC hour, +15 Coins per chest per player/hour. Bridges let players reach them.
- Color Floor: a 5-second RED / BLUE / GREEN challenge every 24 seconds, +8 Coins for standing on the correct tile.
- Daily Obby Challenge: green lobby portal, six platforms and a +100 Coins daily reward; exit prompt to return.
- Mystery Chest: free once per UTC day, gives 40 Coins or exclusive Frost cosmetic (no bets).
- Race Against Ghost: sample and play back your previous best speedrun path using a non-collidable translucent ghost (up to 500 half-second samples).

Studio testing and verification still required. All 5 features are source-level implemented but Roblox Studio was not available for playtest. Daily rewards and ghost persistence require a published place and working DataStores; StudioDataStores=false keeps test progress session-only. Test portals, coin payouts, replay and mobile layouts privately before public launch.

## Creator Store free art shortlist (October 2026)
These are specific "Get Model" entries identified in Roblox Creator Store, not automatically installed and not personally tested inside Roblox Studio:
- Low Poly Tree (456 triangles): https://create.roblox.com/store/asset/80500557091895/Low-Poly-Tree
- Low poly tree pack (10 mesh parts): https://create.roblox.com/store/asset/14447476012/Low-poly-tree-pack
- Low-Poly Tree (306 triangles): https://create.roblox.com/store/asset/3287226226/LowPoly-Tree
- Crystal/Gems pack (21 mesh parts): https://create.roblox.com/store/asset/18638490438
- Crystal Pack: https://create.roblox.com/store/asset/686276613/Crystal-Pack
Prefer lighter tree assets for repeated placement; use crystal packs sparingly. Examine asset details, creator/license, child scripts and mesh complexity before using. If the model contains unknown Script/LocalScript/ModuleScript, remove or disable them before Play. Do not add script-loaded free model portals: use the existing configured portal trigger.

### Recommended placement
Place a few decorative models in Studio Workspace under a custom "ManualDecor" folder, not in "GeneratedObby" or "WOW_LOBBY", since those two are programmatically regenerated when Play runs. Position tree packs by lobby perimeters, rock islands at the sides of the 50-stage course, and a handful of crystal clusters around the portal, Mystery Chest and Photo Zone. Set decorative model collisions off where appropriate; test mobile performance.

### Personal ghost quality / scalability
Ghost is created **only in Arcade.client.lua on the local client**; the server sends each player their own saved best samples only. One ghost is shown at a time and the prior one is destroyed. It is not replicated to other players. The stored record now has a bounded 600-sample budget with fixed 0.5-second intervals (roughly 5 minutes of track). Old hourly treasure collection stamps are pruned.

## Five-world / Prestige update
- 50 checkpoints in five ten-stage themes: Lava, Ice, Candy, Space, Cyber. Stage surfaces and perimeter sculptures use biome-specific materials and colors.
- Yellow BOUNCE PAD platforms in every sixth stage impart an upward boost and play local particle FX. The server applies physics; the player sees client-only particles.
- Animated lobby entrance: three cinematic camera views and a prominent PLAY button; pressing PLAY calls the server-side lobby portal action.
- New Prestige option once the original stage 51 finish is unlocked. Prestige preserves stored stage progress and starts a new sequential challenge loop from stage 1; Prestige count is persisted separately.
- Compatible with existing Treasure Hunt, Arcade minigames, and saved records, but Roblox Studio playtesting is still required.

## Quality assurance still required
This repository was updated and checked via GitHub file reads, not executed in Roblox Studio. Verify all five biome transitions, bounce trajectories, PLAY portal, Prestige start/completion/respawn, mobile button overlap and device performance. Prestige is a replay challenge and does **not** currently reset the main saved Stage; that is intentional to avoid data loss. This version does not yet grant special currency for completing a Prestige loop.

## Character polish and audio update
- New `DeathFX.client.lua`: short client-only rainbow particle burst when the local avatar dies, automatically removed after 2 seconds.
- `MovementFX.client.lua`: four selectable running trails, Aurora / Fire / Ice / Rainbow. Lightweight particles only appear while moving on the ground. Choose via the TRAIL button.
- `Adventure.client.lua`: larger, easier-to-touch mobile controls with repositioned buttons; PC positioning remains as before.
- `BiomeMusic.client.lua`: fades music between Lava, Ice, Candy, Space and Cyber themes; simple MUSIC ON/OFF button.
- To activate music, paste **permitted Roblox audio IDs** into `MusicAssetIds` in `Config.lua`. Defaults are all zero, so music will remain silent until configured. Make sure your experience has permission to play each sound.
- All new cosmetic effects use local-only particles to limit network load; no permanent character modifications are performed.

Test mobile HUD safe zones, VFX after respawn, and actual sound playback with authorized IDs in a published private Studio test place before launching.

## Trails expansion — Coins and Robux
Seven cosmetic trails: Aurora (free), Fire (500 Coins), Ice (1,100 Coins), Rainbow (2,500 Coins), Galaxy (15 Robux), Lightning (25 Robux), Royal (40 Robux).
- Coin trails are purchased with server-validated earned currency. Prices intentionally require substantial play.
- Premium trails are **permanent Game Passes**, but their real IDs must be created in Roblox Creator Dashboard and pasted into `TrailPasses` in `Config.lua`. Configure matching 15/25/40 Robux prices in Dashboard. ID=0 means purchasing is disabled, not free.
- Trail inventory, chosen style and unspent Coins persist in the v4 player DataStore in published servers (subject to API availability). Running particles are created only locally to reduce replication and do not change player speed.
- Check that all Game Pass ownership checks succeed after purchasing, including rejoins. No real Robux purchases can be tested until passes are configured.

## Quality and gameplay audit (October 2026)
Latest fixes after cross-script review:
- **Double Jump** now requires a verified permanent Game Pass configured in `Config.AbilityPasses.DoubleJump` (suggested price 19 Robux). It no longer consumes 80 Coins or expires after 3 minutes. Existing players must rejoin after configuring the pass if they already own it.
- **Prestige and Speedrun respawns** now return to their current replay checkpoint rather than the main saved Stage. An active Prestige run cannot be started repeatedly to claim extra ranks.
- **Color Floor** requires movement of at least 4 studs after the color announcement to grant its 8 Coins reward; standing AFK on a tile does not qualify.
- **V4 profile loading** distinguishes safe temporary Studio testing from published DataStore failure. Wheel day, secret unlocks and trail inventory are included in profile saves and state notifications.
- **Extras UI** gains subdued button borders and hover transitions.
- The Rojo project mapping was reviewed: ServerScriptService, ReplicatedStorage and StarterPlayerScripts use folder mappings so newly added .server.lua/.client.lua files are included.

### Publish checklist — actual Studio test still required
1. Load the project with `git pull`, start Rojo, open Roblox Studio Output.
2. Check first-join lobby, PLAY portal, 50 checkpoint jumps and every bounce pad. Test death/respawn midway through normal parkour, Speedrun and Prestige.
3. Try the daily wheel twice; verify daily limit after rejoining a private **published** place with DataStore access.
4. Test Treasure Hunt, Mystery Chest, Daily Challenge, Color Rush, Color Floor, and the owner-only ghost replay.
5. Test paid Game Pass entitlements using IDs you created in Creator Dashboard; IDs set to 0 intentionally disable purchasing.
6. Check UI overlap and touch buttons using Studio Device Emulator for phones and tablets, then test real device performance.
7. Run a multi-client Studio server and inspect Output for runtime errors. Do not advertise this build as error-free before these manual tests.

Note: Online GitHub review can verify source code and committed files, but **cannot execute Luau inside Roblox Studio**. Some gameplay balance or platform behavior may need adjustment after actual testing.
