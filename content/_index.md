---
tagline: The Clojure Interactive Development Environment that Rocks
lead: >-
  CIDER turns Emacs into a live window into your running Clojure program.
  Evaluate code as you write it, poke at the results, debug and run your
  tests, all without restarting anything.
install: M-x package-install RET cider RET
heroMedia: media/cider-eval.gif
heroAlt: Evaluating Clojure forms one by one with C-c C-e, each result appearing inline next to its form

pillars:
  - title: Live
    blurb: >-
      You build the program up while it runs, re-evaluating definitions and
      trying things out as you go. You never stop and restart it.
  - title: Knows your program
    blurb: >-
      Completion, docs, navigation and the debugger all ask the running
      program over nREPL, instead of guessing from the source.
  - title: Everywhere Clojure runs
    blurb: >-
      Clojure, ClojureScript, Babashka, nbb, Basilisp and ClojureCLR, on your
      machine, in a container or on a remote server.

steps:
  - title: Install
    body: >-
      CIDER is on NonGNU ELPA, which Emacs enables out of the box:
      <kbd>M-x package-install RET cider RET</kbd>
  - title: Jack in
    body: >-
      Open a file in your Clojure project, press <kbd>C-c C-x</kbd>, then
      <kbd>j j</kbd>. CIDER starts your project's REPL and connects to it.
  - title: Evaluate
    body: >-
      Put the cursor after a form and press <kbd>C-c C-e</kbd>. The result
      shows up right next to the code.
---

If you've used SLIME or SLY with Common Lisp, Geiser with Scheme or Emacs Lisp
itself, CIDER will feel like home.
