# 🌋 TROLL OBBY v4.0

Roblox Studio / Rojo project (30 colorful jumping stages).

## v4 additions
- Rotating red laser hazards and blinking traps alongside previous moving/falling platforms.
- Coins earned from advancing stages (+10) and reaching the finish (+250).
- Daily login reward: +75 Coins per UTC day.
- Four cosmetic companion pets: Spark (free), Cloud (120 coins), Flame (400), Star (900).
- Personal best run time and global TOP-10 speed ranking via OrderedDataStore.
- Victory dialog and confetti; extra responsive UI for daily rewards, pets, stats, leaderboards.
- Existing cinematic intro, tutorial, missions, skip-stage, VIP, support donation buttons still included.

### What isn't finished yet
- Supporter Pack pass (not implemented).
- Coins/pets/daily reward saving requires published experience and functioning DataStore; Studio unpublished mode uses session-only data.
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
