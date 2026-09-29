# cider.mx

The source of [cider.mx](https://cider.mx), CIDER's landing page. The manual
lives at [docs.cider.mx](https://docs.cider.mx) and is built from the
[cider](https://github.com/clojure-emacs/cider) repo instead.

The site is built with [Hugo](https://gohugo.io) and deployed to GitHub Pages
on every push to `main`.

## Editing

Almost everything is plain markdown or YAML:

- `content/_index.md` - the tagline, the intro and the getting-started steps
- `data/features.yaml` - the feature cards, each with an optional GIF or
  screenshot under `static/media/`
- `data/release.yaml` - the current release and its highlights; update it when
  cutting a release
- `data/community.yaml` - help channels, related projects and funding links

The page layout is in `layouts/home.html` and the styles in
`assets/css/main.css`.

## Running it locally

```sh
brew install hugo   # or see https://gohugo.io/installation/
hugo server
```

Then open <http://localhost:1313>. CI builds with the Hugo version pinned in
`.github/workflows/deploy.yml` and fails on any warning, so check that
`hugo --panicOnWarning` is clean before pushing.
