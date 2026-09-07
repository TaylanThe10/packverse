# PackVerse

Pack opening, pack battles, item deals and ten casino originals, merged with a live
collectibles-and-crypto market — portfolio, friends, chat and payments — behind one
username/password login with one shared wallet. Everything you pull lands in your
portfolio, where you can hold it or sell it at the market price.

Play money only. Nothing here is real.

**Live:** https://taylanthe10.github.io/packverse/

## What is in it

**Packs** — capsules of real market items, pack battles against bots, deals aimed at a
specific grail, a shop that restocks daily, and a vault of everything you own.

**Casino** — ten originals on a 1% house edge: Cosmic Dice, Asteroid Field, Warp Drive,
Orbit Wheel, Meteor Drop, Star Map, Signal, Ascent, Rocket and Chicken Cross. Every
payout table is verified by a deterministic test suite (`test-deter.js`), which pins the
wheel to an exact 0.9900 RTP on all three risk levels and an eight-level Ascent climb to
exactly 25.37×.

**Market** — simulated prices for collectibles and crypto with order flow, a watchlist,
briefings, auctions and a season pass.

## What the server does

Auth, friends, direct messages, money transfers between players, a live leaderboard and
a real drops feed run on Supabase. Everything else — pack pulls, casino outcomes, market
prices — is worked out on the device, which is why the app stays fast and keeps working
with no signal at all.

That also means pack and casino results are decided client-side, so pack battles are
against bots rather than other players, and the leaderboard is a leaderboard rather than
an audit: each device reports its own account value.

Signed out, or with the server unreachable, the app falls back to a device-only account
and a marked demo feed. Nothing dead-ends.

## Layout

One build, four bands: phone, tablet (the shell widens past 600px), short-and-wide
(landscape phones and short laptop windows get a side rail with the board beside its
controls), and desktop past 900px. Audited from 375×667 to 1920×1080.

## Building and running it

The app ships as a single HTML file with every image inlined — no build step to run it,
no server to host it.

- **Any browser:** open `index.html`. Progress saves in that browser.
- **Publish:** `./deploy.sh` (or double-click `deploy.command`) pushes to GitHub Pages.
  The site works offline after the first visit and installs to an iPhone home screen as
  a full-screen app.
- **Capacitor:** copy `index.html` into the app's `www` folder.

`index.html` is generated. `build.py` merges the two source apps by patching exact
strings and asserting the match count for each, so it fails loudly if a source moves
under it, and it stamps `sw.js` with a fresh version on every build so a deploy always
rotates the cache.

---

Made by Taylan Gurcan
