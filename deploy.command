#!/bin/zsh
# Double-click this to publish PackVerse to GitHub Pages. It signs you into GitHub
# in your browser if needed, runs the deploy, and leaves the window open.
cd "$(dirname "$0")" || exit 1
export PATH="$HOME/marketverse/gh_2.97.0_macOS_arm64/bin:$PWD/gh_2.97.0_macOS_arm64/bin:$PATH"

if ! command -v gh >/dev/null 2>&1; then
  echo "The GitHub CLI (gh) was not found. Keep this folder next to your marketverse folder,"
  echo "or install it with: brew install gh"
  echo "Press Return to close."; read; exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Signing in to GitHub — a browser window is about to open."
  echo "Click 'Authorize' there, then come back to this window."
  echo ""
  gh auth login -h github.com -p https -w
  echo ""
fi

echo "Deploying..."
zsh deploy.sh
echo ""
echo "Done — see above for the live URL (or check deploy.log)."
echo "Press Return to close this window."
read
