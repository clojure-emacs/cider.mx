;;; gif-prelude.el --- scripted Emacs screencasts  -*- lexical-binding: t; -*-

;; Copy this next to your capture scripts and load it from them.  See the
;; emacs-screenshots skill for the workflow around it.
;;
;; The commands worth demoing usually block in the minibuffer, so a plain
;; keyboard macro can't drive them: the macro's keys are consumed before the
;; prompt exists and the read gets empty input.  Instead we run a chain of
;; timers.  Each tick either pushes keys onto `unread-command-events' (the
;; minibuffer's own command loop then processes them exactly as if they were
;; typed) or captures a frame of whatever is on screen.  Each tick schedules
;; the next one, because a capture takes longer than the interval.
;;
;; Environment: GIF_DIR (working directory, with a frames/ subdirectory) and
;; GIF_NAME (base name of this gif).  Frames are written as
;; <name>-<seq>-d<centiseconds>.png, so the assembler can read the per-frame
;; delay straight off the file name.

(require 'cl-lib)

(defvar gif-dir (getenv "GIF_DIR"))
(defvar gif-name (getenv "GIF_NAME"))
(defvar gif-seq 0)
(defvar gif-queue nil)
(defvar gif-tick 0.14
  "Seconds between steps.  Below ~0.1 the captures start to pile up.")

(defvar gif-packages
  '("vertico-*" "orderless-*" "marginalia-*" "markdown-mode-*" "compat-*"
    "keycast-*" "cond-let-*")
  "Globs under ~/.emacs.d/elpa to put on `load-path'.
Without orderless the default `basic' completion style only matches
prefixes, so a substring filter silently yields \"[Match required]\".
keycast needs both compat and cond-let, and pulls them in itself.")

(defvar gif-show-keys t
  "Whether `gif-setup' puts the keys being pressed on the frame, via keycast.
What makes a screencast worth anything is usually which keys produced the
result, and the reader can't see the keyboard.  Set to nil for theme
shots and anything else where the keys aren't the story.")

(defvar gif-theme 'tokyo-night-storm)
(defvar gif-theme-dir "~/.emacs.d/elpa/tokyo-night")
(defvar gif-frame-size '(104 . 18))
(defvar gif-font-height 140)

(defun gif-log (fmt &rest args)
  (write-region (concat (apply #'format fmt args) "\n")
                nil (expand-file-name "capture.log" gif-dir) 'append 'silent))

(defun gif-capture (&optional delay)
  "Capture the frame.  DELAY is how long it shows in the gif, in centiseconds."
  ;; Opening a connection or a REPL window knocks `tab-bar-lines' back to 0
  ;; on a live frame, which silently hides the keycast strip, so re-assert it
  ;; for every frame rather than trusting the one set in `gif-setup'.
  (when (bound-and-true-p keycast-tab-bar-mode)
    (set-frame-parameter nil 'tab-bar-lines 1))
  (redisplay t)
  (let* ((e (frame-edges nil 'outer-edges))
         (file (expand-file-name
                (format "frames/%s-%03d-d%d.png" gif-name (cl-incf gif-seq) (or delay 12))
                gif-dir)))
    (call-process-shell-command
     (format "screencapture -x -R '%d,%d,%d,%d' %s"
             (nth 0 e) (nth 1 e) (- (nth 2 e) (nth 0 e)) (- (nth 3 e) (nth 1 e))
             (shell-quote-argument file)))
    (unless (file-exists-p file)
      (gif-log "MISSING %s edges=%S frames=%S" file e (length (frame-list))))))

(defun gif-keys (keys)
  "Feed KEYS (in `kbd' syntax) to the command loop, as if typed.
Appends, so keys queued while an earlier step is still being consumed
stay in the order they were scripted."
  (setq unread-command-events
        (append unread-command-events (listify-key-sequence (kbd keys)))))

(defun gif-keys-literal (string)
  "Feed STRING to the command loop verbatim, no `kbd' parsing."
  (setq unread-command-events
        (append unread-command-events (listify-key-sequence string))))

(defun gif-run ()
  "Run the next queued step, then schedule the one after it."
  (cond
   (unread-command-events
    ;; The command loop hasn't picked up the previous step's keys yet.  Wait
    ;; rather than running ahead of the command they are about to trigger:
    ;; otherwise a capture lands before the command fires and the step is
    ;; silently missing from the gif.
    (run-with-timer gif-tick nil #'gif-run))
   (gif-queue
    (condition-case err
        (funcall (pop gif-queue))
      (error (gif-log "STEP ERROR: %S" err)))
    (run-with-timer gif-tick nil #'gif-run))
   (t
    (gif-log "OK %s (%d frames)" gif-name gif-seq)
    (run-with-timer 0.3 nil (lambda () (kill-emacs))))))

(defun gif-script (&rest steps)
  "Queue STEPS and start running them.
A step is a string (keys to type), a number (capture a frame that shows
for that many centiseconds), or a function (anything else)."
  (setq gif-queue
        (mapcar (lambda (step)
                  (cond ((stringp step) (lambda () (gif-keys step)))
                        ((numberp step) (lambda () (gif-capture step)))
                        (t step)))
                steps))
  ;; The frame can lose focus between setup and the first capture - a slow
  ;; connect, another app grabbing it - and macOS renders an unfocused title
  ;; bar in grey.  Within one gif that's a flicker; across a set of them it's
  ;; two different looks in the same docs page.
  (ignore-errors
    (ns-hide-emacs 'activate)
    (select-frame-set-input-focus (selected-frame)))
  ;; Drop whatever keycast recorded while the demo was being set up (a stray
  ;; click, the connect) so the establishing frames open on an empty strip
  ;; instead of naming a command the reader never saw invoked.
  (when (bound-and-true-p keycast-tab-bar-mode)
    (setq keycast--this-command-keys nil
          keycast--this-command-desc nil
          keycast--command-repetitions 0))
  (run-with-timer 0.8 nil #'gif-run))

(defun gif-typing (string &optional chunk delay)
  "Steps that type STRING CHUNK characters at a time, a frame after each.
Splice the result into a `gif-script' call with `append'."
  (let ((chunk (or chunk 3)) (steps '()) (i 0))
    (while (< i (length string))
      (let ((piece (substring string i (min (length string) (+ i chunk)))))
        (push (lambda () (gif-keys-literal piece)) steps)
        (push (or delay 11) steps)
        (setq i (+ i chunk))))
    (nreverse steps)))

(defun gif--tab-bar-spacer ()
  "A constant element so the keycast strip has height before the first key.
With only `keycast-tab-bar' in `tab-bar-format' the bar renders empty
until a command has been recorded, and the frame's text area jumps down
a line the moment it appears."
  " ")

(defun gif-setup ()
  "Make `emacs -Q' look like a real, tidy configuration."
  (setq inhibit-startup-screen t
        ring-bell-function 'ignore
        use-short-answers t
        make-backup-files nil
        create-lockfiles nil
        auto-save-default nil
        enable-recursive-minibuffers t)
  (menu-bar-mode -1) (tool-bar-mode -1) (scroll-bar-mode -1)
  (blink-cursor-mode -1)
  (setq-default cursor-type 'bar)
  (if (find-font (font-spec :name "Cascadia Code"))
      (set-face-attribute 'default nil :family "Cascadia Code" :height gif-font-height)
    (set-face-attribute 'default nil :family "Menlo" :height gif-font-height))
  (dolist (glob gif-packages)
    (dolist (dir (file-expand-wildcards (concat "~/.emacs.d/elpa/" glob)))
      (add-to-list 'load-path dir)))
  (when (require 'markdown-mode nil t)
    (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))
  ;; without this the title bar reads *Minibuf-1* whenever a prompt is up
  (setq frame-title-format
        '((:eval (let ((buf (window-buffer (or (minibuffer-selected-window)
                                               (selected-window)))))
                   (or (and (buffer-file-name buf)
                            (file-name-nondirectory (buffer-file-name buf)))
                       (buffer-name buf))))))
  (when (require 'orderless nil t)
    (setq completion-styles '(orderless basic)
          completion-category-defaults nil))
  (when (require 'vertico nil t)
    (setq vertico-count 8
          vertico-resize t)             ; no dead space under short candidate lists
    (vertico-mode 1))
  ;; Put the keys on the frame.  keycast records from `post-command-hook',
  ;; and the steps feed `unread-command-events' through the real command
  ;; loop, so scripted keys are picked up exactly like typed ones.  The tab
  ;; bar is the right home for this: it belongs to the frame, so it survives
  ;; the window splits a source+REPL demo needs, and `replace' drops the tab
  ;; buttons so the strip carries nothing but the keys.  Must run before
  ;; `set-frame-size', since the bar takes a line off the text area.
  (when (and gif-show-keys (require 'keycast nil t))
    (setq keycast-tab-bar-location 'replace)
    (keycast-tab-bar-mode 1)
    (setq tab-bar-format (list 'gif--tab-bar-spacer 'keycast-tab-bar)))
  (let ((dir (expand-file-name gif-theme-dir)))
    (add-to-list 'load-path dir)
    (add-to-list 'custom-theme-load-path dir))
  (load-theme gif-theme t)
  (set-frame-parameter nil 'ns-appearance 'dark)   ; 'light for light themes
  (set-frame-parameter nil 'ns-transparent-titlebar t)
  (set-frame-parameter nil 'z-group 'above)
  (ns-hide-emacs 'activate)
  ;; Park the pointer off the frame: left over the title bar it puts the
  ;; window buttons in their hover state for some frames and not others,
  ;; which reads as a flicker once the gif loops.
  (ignore-errors
    (set-mouse-absolute-pixel-position (1- (display-pixel-width))
                                       (1- (display-pixel-height))))
  (set-frame-size (selected-frame) (car gif-frame-size) (cdr gif-frame-size))
  ;; Turning on `tab-bar-mode' doesn't reliably land `tab-bar-lines' on an
  ;; already-live frame, and at 0 the bar is simply never drawn - keycast is
  ;; running and producing text, you just can't see any of it.  Force it,
  ;; after the resize so the bar isn't sized away again.
  (when (bound-and-true-p keycast-tab-bar-mode)
    (set-frame-parameter nil 'tab-bar-lines 1)))

(provide 'gif-prelude)

;;; gif-prelude.el ends here
