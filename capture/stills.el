;;; stills.el --- still shots for cider.mx  -*- lexical-binding: t; -*-

(load (expand-file-name "prelude.el" (getenv "GIF_DIR")))

(defvar demo-project (expand-file-name "project" gif-dir))
(defvar shots-dir (expand-file-name "shots" gif-dir))

(defun demo-file (rel) (expand-file-name rel demo-project))

(defun demo-open (rel)
  (switch-to-buffer (find-file-noselect (demo-file rel)))
  (delete-other-windows)
  (goto-char (point-min)))

(defun demo-goto (regexp)
  (goto-char (point-min))
  (re-search-forward regexp)
  (goto-char (match-beginning 0)))

(defun demo-wait (secs)
  (let ((end (+ (float-time) secs)))
    (while (< (float-time) end)
      (accept-process-output nil 0.1)
      (redisplay t))))

(defun demo-shot (name)
  (ignore-errors (select-frame-set-input-focus (selected-frame)))
  (when-let* ((w (get-buffer-window "*Warnings*"))) (delete-window w))
  (message nil)
  (demo-wait 0.6)
  (redisplay t)
  (let* ((e (frame-edges nil 'outer-edges))
         (file (expand-file-name (concat name ".png") shots-dir)))
    (call-process-shell-command
     (format "screencapture -x -R '%d,%d,%d,%d' %s"
             (nth 0 e) (nth 1 e) (- (nth 2 e) (nth 0 e)) (- (nth 3 e) (nth 1 e))
             (shell-quote-argument file)))
    (gif-log "shot %s %s" name (file-exists-p file))))

(defmacro demo-step (name &rest body)
  `(condition-case err (progn ,@body)
     (error (gif-log "STEP %s ERROR: %S" ,name err))))

(defun demo-shots ()
  (demo-step "require"
    (demo-open "src/demo/core.clj")
    (cider-nrepl-sync-request:eval
     "(require 'demo.core 'demo.art 'demo.users 'demo.core-test :reload)"))

  (demo-step "rich-results"
    (demo-open "src/demo/art.clj")
    (demo-goto "^(sunburst 120 8)")
    (forward-sexp)
    (cider-eval-last-sexp)
    (demo-wait 2.5)
    (recenter 1)
    (demo-shot "rich-results"))

  (demo-step "macrostep"
    (demo-open "src/demo/users.clj")
    (demo-goto "(->> items")
    (forward-sexp)
    (cider-macrostep-expand)
    (save-excursion (demo-goto "^(defn total-price") (set-window-start nil (line-beginning-position)))
    (demo-wait 2)
    (demo-shot "macrostep")
    (ignore-errors (cider-macrostep-collapse-all)))

  (demo-step "references-menu"
    (demo-open "src/demo/core.clj")
    (demo-goto "(defn greet")
    (forward-word 2)
    (backward-word)
    (set-frame-size nil 88 16)
    (cider-references-menu)
    (demo-wait 1)
    (demo-shot "references-menu")
    (transient-quit-all)
    (set-frame-size nil 72 16))

  (demo-step "who-calls"
    (demo-open "src/demo/core.clj")
    (cider-who-calls "demo.core/greet")
    (demo-wait 3)
    (select-window (get-buffer-window "*cider-who-calls*"))
    (goto-char (point-min))
    (re-search-forward "demo.core/greet")
    (cider-tree-view-toggle)
    (demo-wait 2)
    (demo-shot "who-calls")))

(condition-case err
    (progn
      (dolist (dir (split-string (with-temp-buffer
                                   (insert-file-contents
                                    (expand-file-name "cider-load-path.txt" gif-dir))
                                   (buffer-string))
                                 "\n" t))
        (add-to-list 'load-path dir))
      (require 'cider)
      (require 'cider-macrostep)
      (require 'cider-xref-tree)
      (require 'cider-xref)
      (setq native-comp-async-report-warnings-errors 'silent)
      (setq confirm-kill-processes nil
            cider-repl-pop-to-buffer-on-connect nil
            cider-eval-result-duration 'change
            gif-show-keys nil
            gif-frame-size '(72 . 16))
      (gif-setup)
      (make-directory shots-dir t)
      (add-hook 'cider-connected-hook
                (lambda ()
                  (run-with-timer
                   1 nil
                   (lambda ()
                     (demo-shots)
                     (gif-log "OK stills")
                     (kill-emacs)))))
      (let ((default-directory (file-name-as-directory demo-project)))
        (cider-connect-clj
         (list :host "127.0.0.1"
               :port (string-trim (with-temp-buffer
                                    (insert-file-contents (demo-file ".nrepl-port"))
                                    (buffer-string)))
               :project-dir demo-project)))
      (run-with-timer 120 nil (lambda () (gif-log "TIMEOUT") (kill-emacs))))
  (error (gif-log "ERROR: %S" err) (kill-emacs)))
