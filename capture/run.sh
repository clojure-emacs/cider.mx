#!/bin/bash
# Re-record the screencasts and screenshots in static/media.
#
# Needs a CIDER checkout (for the load path, via Eldev), the Clojure CLI, a
# GUI Emacs and ImageMagick. A small Emacs frame takes over the screen for a
# couple of minutes - don't type while it's up.
#
#   CIDER_DIR=~/projects/cider ./capture/run.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
media="${MEDIA:-$here/../static/media}"
cider_dir="${CIDER_DIR:-$HOME/projects/cider}"
emacs="${EMACS:-/Applications/Emacs.app/Contents/MacOS/Emacs}"

cd "$here"
rm -rf frames shots capture.log
mkdir -p frames shots

# CIDER's own load path, so the scripts load the checkout under test.
(cd "$cider_dir" && eldev exec "(princ (mapconcat #'identity load-path \"\n\"))") \
  | grep "$cider_dir" | grep -v "test/utils" > cider-load-path.txt

# A REPL for the demos, with the cider-nrepl version CIDER asks for.
middleware=$(grep -o 'cider-required-middleware-version "[^"]*"' "$cider_dir/lisp/cider-jack-in.el" | cut -d'"' -f2)
(cd project && rm -f .nrepl-port && \
  clojure -Sdeps "{:deps {nrepl/nrepl {:mvn/version \"1.7.0\"} cider/cider-nrepl {:mvn/version \"$middleware\"}}}" \
          -M -m nrepl.cmdline --middleware '[cider.nrepl/cider-middleware]' > nrepl.log 2>&1) &
server=$!
trap 'pkill -P $server 2>/dev/null; kill $server 2>/dev/null' EXIT
until [ -s project/.nrepl-port ]; do sleep 2; done

for script in eval stills showcase; do
  name=$script; [ "$script" = eval ] && name=cider-eval
  GIF_DIR="$here" GIF_NAME="$name" "$emacs" -Q --eval "(load \"$here/$script.el\")"
done
cat capture.log

gif() {
  local name="$1" out="$2" args=()
  for f in frames/"$name"-*.png; do
    d="${f##*-d}"; args+=(-delay "${d%.png}" "$f")
  done
  magick "${args[@]}" -resize 960x -layers optimize -loop 0 "$media/$out.gif"
}
gif cider-eval cider-eval
gif inspector inspector
gif debugger debugger
gif tests tests

for shot in rich-results macrostep references-menu who-calls; do
  magick "shots/$shot.png" -resize 1000x -quality 84 "$media/$shot.webp"
done
ls -l "$media"
