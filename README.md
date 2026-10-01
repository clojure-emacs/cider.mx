# cider.mx

The source of [cider.mx](https://cider.mx), CIDER's landing page. The manual
lives at [docs.cider.mx](https://docs.cider.mx) and is built from the
[cider](https://github.com/clojure-emacs/cider) repo instead.

The site is built with [Hugo](https://gohugo.io) and deployed to GitHub Pages
on every push to `main`, and weekly on a schedule.

## Editing

The page's design comes from the
[hugo-project-landing](https://github.com/bbatsov/hugo-project-landing) theme;
this repository holds the content, which is almost all plain YAML or
markdown:

- `content/_index.md` - the tagline, intro, install command and getting-started
  steps (in the front matter), and the project's history (the body)
- `data/showcase.yaml` - the feature sections, each with its keys and a
  screencast or screenshot from `static/media/`
- `data/features.yaml` - the "and the rest" links
- `data/news.yaml` - the news archive. Posts tagged CIDER on Meta Redux show
  up on their own when the site is built (`newsFeed` and `newsTag` in
  `hugo.toml`); add a post here to keep it listed after it drops out of the feed
- `data/milestones.yaml` - the history log shown next to the history section
- `data/release.yaml` - the release series linked from the opening
- `data/faq.yaml` - the questions
- `data/community.yaml` - help channels and funding options

`layouts/_partials/panes/` has the Emacs buffers shown in the second window
next to the sections without a screencast, and `assets/css/palette.css` the
colors.

## On a CIDER release

- **Patch releases** (2.0.1, 2.0.2, ...): nothing to do. The latest version and
  the star count are fetched from the GitHub API at build time. The weekly
  build picks up a new release, and a `repository_dispatch` event of type
  `cider-release` rebuilds the site right away.
- **Feature releases**: point `series` and `announcement` in
  `data/release.yaml` at the new release and its announcement, and bump
  `fallbackVersion` in `hugo.toml`, which is only used when GitHub can't be
  reached during the build.

## Running it locally

```sh
brew install hugo   # or see https://gohugo.io/installation/
hugo server
```

Then open <http://localhost:1313>. CI builds with the Hugo version pinned in
`.github/workflows/deploy.yml` and fails on any warning, so check that
`hugo --panicOnWarning` is clean before pushing.
