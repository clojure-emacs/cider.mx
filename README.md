# cider.mx

The source of [cider.mx](https://cider.mx), CIDER's landing page. The manual
lives at [docs.cider.mx](https://docs.cider.mx) and is built from the
[cider](https://github.com/clojure-emacs/cider) repo instead.

The site is built with [Hugo](https://gohugo.io) and deployed to GitHub Pages
on every push to `main`, and weekly on a schedule.

## Editing

Almost everything is plain YAML or markdown:

- `content/_index.md` - the tagline, the three pillars under the hero and the
  getting-started steps (all in the front matter)
- `data/showcase.yaml` - the flagship features, one row each with a GIF
- `data/features.yaml` - the "and a lot more" links
- `data/release.yaml` - the feature release the page spotlights
- `data/faq.yaml` - the FAQ
- `data/community.yaml` - help channels, related projects and funding links

Screenshots and GIFs live in `static/media/`. The layout is
`layouts/home.html` and the styles are in `assets/css/main.css`.

## On a CIDER release

- **Patch releases** (2.0.1, 2.0.2, ...): nothing to do. The latest version and
  the star count are fetched from the GitHub API at build time. The weekly
  build picks up a new release, and a `repository_dispatch` event of type
  `cider-release` rebuilds the site right away.
- **Feature releases** (2.1, 3.0, ...): update `data/release.yaml` with the new
  series, the announcement and three or four highlights, each with a screenshot.
  Bump `fallbackVersion` in `hugo.toml` while you're at it. It's only used when
  GitHub can't be reached during the build.

## Running it locally

```sh
brew install hugo   # or see https://gohugo.io/installation/
hugo server
```

Then open <http://localhost:1313>. CI builds with the Hugo version pinned in
`.github/workflows/deploy.yml` and fails on any warning, so check that
`hugo --panicOnWarning` is clean before pushing.
