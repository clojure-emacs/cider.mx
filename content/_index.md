---
tagline: The Clojure Interactive Development Environment that Rocks
heroMedia: media/cider-eval.gif
heroAlt: Evaluating Clojure forms one by one with C-c C-e, each result appearing inline next to its form
lead: CIDER turns Emacs into a live window into your running Clojure program. Evaluate code as you write it, poke at the results, debug, and run your tests, all without restarting anything.
---

## Why CIDER?

Clojure is at its best when you program *interactively*: you build the
program up piece by piece while it runs, re-evaluating definitions and trying
things out as you go. You never stop and restart the application, you just
keep changing it.

CIDER is built for exactly that. It talks to your program over
[nREPL](https://nrepl.org), so the editor always knows what's actually loaded:
completion, documentation, navigation and the debugger all come from the live
program, not from guesses about the source. If you've used SLIME or SLY with
Common Lisp, Geiser with Scheme or Emacs Lisp itself, it'll feel like home.
It works with both `clojure-mode` and `clojure-ts-mode`, and
[alongside clojure-lsp](https://docs.cider.mx/cider/config/lsp.html) if you use
that too.

## Get started

1. **Install it.** CIDER is on NonGNU ELPA, which Emacs enables out of the
   box, so it's just <kbd>M-x package-install RET cider RET</kbd>.
2. **Start a REPL.** Open any file in a Clojure project and press
   <kbd>C-c C-x</kbd> to bring up the start menu, then <kbd>j j</kbd> to
   jack in. CIDER starts your project's REPL and connects to it.
3. **Evaluate something.** Put the cursor after a form and press
   <kbd>C-c C-e</kbd>. The result shows up right next to the code.

Already running a REPL, or working in a container or on a remote machine?
[Up and Running](https://docs.cider.mx/cider/basics/up_and_running.html) covers
connecting to an existing server.
