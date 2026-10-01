---
title: Colophon
description: How this site is made
---

This site is a single page that tries hard to look like Emacs - there's a
mode line, an echo area, Org-style headings, `M-x` and even an "other window".
It felt like the right look for an Emacs package. Here's what went into it.

## Type and colors

The text is set in [Iosevka Etoile](https://typeof.net/Iosevka/) and the code
in [Iosevka](https://typeof.net/Iosevka/), both by Renzhi Li and released
under the SIL Open Font License. The colors come from
[Protesilaos Stavrou's](https://protesilaos.com) Modus themes - modus-operandi
for the light theme and modus-vivendi for the dark one - with CIDER's yellow
thrown in for good measure.

## The screencasts

Every screencast and screenshot shows the real thing: Emacs and CIDER talking
to a real REPL. They were recorded with a small Emacs Lisp script, so they're
easy to redo whenever CIDER changes.

## How it's built

The site is built with [Hugo](https://gohugo.io), using
[hugo-project-landing](https://github.com/bbatsov/hugo-project-landing) - the
same theme is behind [projectile.mx](https://projectile.mx). The latest
release, the GitHub stars and the news are fetched when the site is built, and
it's hosted on GitHub Pages. The source is
[on GitHub](https://github.com/clojure-emacs/cider.mx).

## Privacy

There's no analytics, no cookies and nothing is loaded from third-party
servers. The only thing the site remembers is whether you picked the light or
the dark theme, and that stays in your browser.
