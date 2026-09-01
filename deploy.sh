#!/bin/zsh
# Publishes this folder to GitHub Pages as <you>.github.io/packverse/
# Same flow as MarketVerse: waits for the GitHub login, then commits, pushes and turns on Pages.
cd "$(dirname "$0")" || exit 1
export PATH="$HOME/marketverse/gh_2.97.0_macOS_arm64/bin:$PWD/gh_2.97.0_macOS_arm64/bin:$PATH"
LOG="$PWD/deploy.log"
: > "$LOG"
say() { echo "$(date +%H:%M:%S)  $*" >> "$LOG"; echo "$*"; }

command -v gh >/dev/null 2>&1 || { say "gh CLI not found — keep the marketverse folder next to this one, or brew install gh"; exit 1; }

say "waiting for authorisation..."
for i in $(seq 1 180); do            # up to 15 minutes
  if gh auth status >/dev/null 2>&1; then break; fi
  sleep 5
done
if ! gh auth status >/dev/null 2>&1; then say "TIMED OUT — code never approved"; exit 1; fi

USER=$(gh api user -q .login 2>/dev/null)
say "authorised as $USER"

git config --global user.name  "$USER" >/dev/null 2>&1
git config --global user.email "$USER@users.noreply.github.com" >/dev/null 2>&1

rm -rf .git
git init -q -b main
git add -A
git commit -q -m "PackVerse — packs, battles, deals and casino with play money"
say "committed $(du -h index.html | cut -f1) app"

if gh repo view "$USER/packverse" >/dev/null 2>&1; then
  say "repo already exists, pushing to it"
  git remote add origin "https://github.com/$USER/packverse.git" 2>/dev/null
  git push -q --force -u origin main && say "pushed" || { say "PUSH FAILED"; exit 1; }
else
  gh repo create packverse --public --source=. --remote=origin --push \
    --description "Pack opening, battles, deals and casino originals with play money, in one HTML file." \
    >> "$LOG" 2>&1 && say "repo created and pushed" || { say "REPO CREATE FAILED"; exit 1; }
fi

# Pages, from the main branch root
gh api -X POST "repos/$USER/packverse/pages" -f "source[branch]=main" -f "source[path]=/" >> "$LOG" 2>&1 \
  && say "pages enabled" \
  || { gh api -X PUT "repos/$USER/packverse/pages" -f "source[branch]=main" -f "source[path]=/" >> "$LOG" 2>&1 \
       && say "pages already on, source set"; }

URL="https://$USER.github.io/packverse/"
say "waiting for $URL to go live..."
for i in $(seq 1 60); do             # first build can take a couple of minutes
  CODE=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "$URL")
  if [ "$CODE" = "200" ]; then
    say "LIVE  $URL"
    echo "$URL" > "$PWD/LIVE_URL.txt"
    exit 0
  fi
  sleep 10
done
say "pushed, but the site has not served a 200 yet — it is usually a minute or two behind"
say "URL will be $URL"
