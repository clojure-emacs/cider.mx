---
tagline: The Clojure Interactive Development Environment that Rocks
intro: >-
  CIDER hooks Emacs up to your running Clojure program. You write a function,
  evaluate it, poke at what comes back and keep going. No restarts, no
  copy-pasting into a REPL window, no waiting on a build. It's been doing
  that since 2012.
install: M-x package-install RET cider RET
heroMedia: media/cider-eval.gif
heroAlt: Evaluating Clojure forms one by one with C-c C-e, each result appearing inline next to its form

steps:
  - >-
    Install it. CIDER is on NonGNU ELPA, which Emacs knows about out of the
    box, so <kbd>M-x package-install RET cider RET</kbd> is all it takes.
  - >-
    Open any file in a Clojure project and press <kbd>C-c C-x</kbd>, then
    <kbd>j j</kbd>. CIDER figures out whether it's a Clojure CLI, Leiningen,
    shadow-cljs or Babashka project, starts a REPL and connects to it.
  - >-
    Put the cursor after a form and press <kbd>C-c C-e</kbd>. That's the
    loop. Everything else builds on it.

outro: Keep hacking!
---

Phil Hagelberg hacked together the first nREPL client for Emacs on a flight to
San Francisco in April 2012. Tim King picked it up, and by August `nrepl.el`
had pushed SLIME aside as the way to write Clojure in Emacs. I took it over in
2013, renamed it to CIDER a few months later (mostly so people would stop
confusing it with the nREPL server), and I've been its primary author and
maintainer ever since.

Fourteen years on, CIDER is on its second major version and still changing
more than most tools half its age. It's built by
[hundreds of contributors](https://github.com/clojure-emacs/cider/graphs/contributors)
and funded by the people who use it.
