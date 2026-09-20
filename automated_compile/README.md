# Ten Challenges website

This directory contains the static React website deployed to GitHub Pages.
Submission forms open GitHub issues in `utkuokur/ten-challenges-submissions`;
the leaderboard is fetched from that repository's `site-data/leaderboard.json`.
Submission evaluation and archiving run in that repository, not in this website.

## Development

Use Node.js 20.19 or later, matching the Vite requirement.

```sh
npm ci
npm run dev
```

Before deploying:

```sh
npm run check
npm run lint
npm run build
npm run preview
```

The build writes `dist/public`. Preview serves the site under `/ten-challenges/`,
matching GitHub Pages. Lean and Mathlib versions are read at build time from the
parent project's `lean-toolchain` and `lake-manifest.json`.

## Challenge descriptions

Edit `content/tex/challenge_*.tex`, then run `npm run build:html` to regenerate
`public/content/html`. This requires LaTeXML and Python 3. The Pages workflow
also regenerates these pages before building the site. The PDFs in
`public/content/pdf` are separately maintained downloadable copies.

Pushing website changes to `main` triggers `.github/workflows/deploy-pages.yml`.
