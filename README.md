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
