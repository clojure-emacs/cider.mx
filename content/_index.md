---
tagline: The Clojure Interactive Development Environment that Rocks
intro: >-
  In a nutshell - CIDER connects Emacs to your running Clojure program. You
  write a function, evaluate it, check out the result and keep going. No
  restarts, no copy-pasting into a REPL window, no waiting for a build. It's
  been doing this since 2012.
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
    basic workflow, and pretty much everything else builds on top of it.

restIntro: >-
  Code completion, documentation lookup, navigation and so on are powered by
  the running program as well. Here are a few more things that didn't fit
  above:
stepsNote: >-
  Connecting to a REPL that's already running, in a container or on another
  machine? [Up and Running](https://docs.cider.mx/cider/basics/up_and_running.html)
  covers it.
outro: Keep hacking!
---

Phil Hagelberg hacked together the first nREPL client for Emacs on a flight to
San Francisco in April 2012. Tim King picked it up, and by August `nrepl.el`
had pushed SLIME aside as the way to write Clojure in Emacs. I took it over in
2013, renamed it to CIDER a few months later (mostly so people would stop
confusing it with the nREPL server), and I've been its primary author and
maintainer ever since.

Fourteen years later CIDER is on its second major version, and it's still
evolving at a steady pace.
[Hundreds of people](https://github.com/clojure-emacs/cider/graphs/contributors)
have contributed to it over the years, and its development is funded by its
users.
