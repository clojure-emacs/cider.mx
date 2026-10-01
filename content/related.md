---
title: Related projects
description: The projects around CIDER
---

CIDER is the most visible part of a bigger family of projects. Most of its
smarts actually live in Clojure libraries that other editors use as well, and
a few Emacs packages build on top of it or go along with it. Here are the most
notable ones.

## The foundation

- **[nREPL](https://nrepl.org)** - the network REPL CIDER talks to. It's the
  common ground for pretty much every Clojure editor and tool these days.
- **[cider-nrepl](https://github.com/clojure-emacs/cider-nrepl)** - the nREPL
  middleware behind most of CIDER's features (completion, documentation,
  the debugger, the inspector, the test runner and so on). Other editors use
  it too.
- **[Orchard](https://github.com/clojure-emacs/orchard)** - the editor-agnostic
  library that cider-nrepl is built on. If you're writing Clojure tooling of
  your own, this is a good place to start.
- **[Drawbridge](https://github.com/nrepl/drawbridge)** - an HTTP/HTTPS
  transport for nREPL, for when a raw socket isn't an option. CIDER can
  connect to it through Drawbridge's bridge.
- **[Piggieback](https://github.com/nrepl/piggieback)** - nREPL support for
  ClojureScript REPLs.
- **[clj-suitable](https://github.com/clojure-emacs/clj-suitable)** - completion
  for JavaScript objects, their properties and methods in ClojureScript.

## In Emacs

- **[clojure-mode](https://github.com/clojure-emacs/clojure-mode)** - font-locking,
  indentation and navigation for Clojure. CIDER builds on top of it.
- **[clojure-ts-mode](https://github.com/clojure-emacs/clojure-ts-mode)** - the
  next generation Clojure major mode, powered by Tree-sitter. CIDER works with
  it as well.
- **[clj-refactor](https://github.com/clojure-emacs/clj-refactor.el)** - powerful
  refactoring commands on top of CIDER, backed by
  [refactor-nrepl](https://github.com/clojure-emacs/refactor-nrepl).
- **[inf-clojure](https://github.com/clojure-emacs/inf-clojure)** - basic
  interaction with a Clojure subprocess, for when you don't need (or can't
  use) nREPL.
- **[Sayid](https://github.com/clojure-emacs/sayid)** - an omniscient
  debugger. Instead of stopping at a breakpoint, it records every call to the
  functions you've traced and lets you dig through the recording afterwards.
  It comes with its own Emacs package and plays nicely with CIDER.
- **[sesman](https://github.com/vspinu/sesman)** - the session management that
  CIDER uses to tie REPLs to projects.
- **[parseedn](https://github.com/clojure-emacs/parseedn)** and
  **[parseclj](https://github.com/clojure-emacs/parseclj)** - EDN and Clojure
  parsers written in Emacs Lisp. CIDER uses parseedn to read EDN - say,
  shadow-cljs's config or data returned by your program - and parseedn is built
  on parseclj.

## More

You'll find plenty of other projects under the
[clojure-emacs](https://github.com/clojure-emacs) and
[nREPL](https://github.com/nrepl) organizations on GitHub, and the manual has
a list of [additional packages](https://docs.cider.mx/cider/additional_packages.html)
that work well with CIDER.
