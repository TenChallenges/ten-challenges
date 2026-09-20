#!/usr/bin/env bash
# Convert each content/tex/challenge_*.tex to a standalone HTML page in
# public/content/html/, the same way arXiv renders LaTeX to HTML (via LaTeXML).
#
# The .tex sources are the source of truth and are left untouched. The generated
# HTML is committed (like the PDFs), so local Vite builds need no LaTeX
# toolchain. The GitHub Pages workflow regenerates it before building the site.
#
# Requirements: LaTeXML (e.g. `sudo apt-get install latexml`).
# Usage:        scripts/build-html.sh        # from anywhere
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"          # automated_compile/
TEX="$ROOT/content/tex"
OUT="$ROOT/public/content/html"
SHIM="$HERE/latexml"                    # biblatex/aliascnt LaTeXML shims

if ! command -v latexmlc >/dev/null 2>&1; then
  echo "error: latexmlc not found. Install LaTeXML (e.g. 'sudo apt-get install latexml')." >&2
  exit 1
fi

mkdir -p "$OUT"
cd "$TEX"

shopt -s nullglob
status=0
for f in challenge_*.tex; do
  name="${f%.tex}"
  printf 'Converting %-18s -> public/content/html/%s.html ... ' "$f" "$name"
  log="$TEX/$name.latexml.log"   # *.log is gitignored
  if latexmlc --path="$SHIM" --format=html5 \
       --dest="$OUT/$name.html" --log="$log" "$f" >/dev/null 2>&1; then
    # Surface real conversion problems even on a zero exit code.
    if grep -qE '^(Error|Fatal):' "$log"; then
      echo "FAIL (see $name.latexml.log)"; status=1
    else
      echo "ok"
    fi
  else
    echo "FAIL (see $name.latexml.log)"; status=1
  fi
done

# Tidy intermediate logs (also gitignored, but keep the tree clean).
rm -f "$TEX"/*.latexml.log

# Restyle bibliographies to the biblatex/PDF look (clickable DOI/arXiv ids,
# no "Cited by:" back-references) and strip LaTeXML's timestamped page footer.
if [ "$status" -eq 0 ]; then
  python3 "$HERE/postprocess-html.py" || status=1
fi

if [ "$status" -eq 0 ]; then
  echo "Done. HTML + LaTeXML CSS written to public/content/html/"
else
  echo "Completed with errors -- inspect the logs above." >&2
fi
exit "$status"
