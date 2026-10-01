;;; eval.el --- hero gif for cider.mx: inline evaluation  -*- lexical-binding: t; -*-

(load (expand-file-name "prelude.el" (getenv "GIF_DIR")))

(defvar demo-project (expand-file-name "project" gif-dir))
(defvar demo-src (expand-file-name "src/demo/core.clj" demo-project))

(condition-case err
    (progn
      (dolist (dir (split-string (with-temp-buffer
                                   (insert-file-contents
                                    (expand-file-name "cider-load-path.txt" gif-dir))
                                   (buffer-string))
                                 "\n" t))
        (add-to-list 'load-path dir))
      (require 'cider)
      (setq confirm-kill-processes nil
            cider-repl-pop-to-buffer-on-connect nil
            cider-eval-result-duration 'change   ; keep every result on screen
            cider-show-error-buffer nil
            cider-use-overlays t
            gif-frame-size '(88 . 20))
      (gif-setup)
      (setq keycast-substitute-alist
            '((cider-eval-last-sexp "C-c C-e" t)
              (self-insert-command nil nil)))
      (gif-log "setup done")

      (defun demo-buffer ()
        (switch-to-buffer (find-file-noselect demo-src))
        (delete-other-windows))

      (defun demo-goto-end-of (regexp)
        "Put point right after the form starting with REGEXP."
        (lambda ()
          (demo-buffer)
          (goto-char (point-min))
          (re-search-forward (concat "^" regexp))
          (beginning-of-line)
          (forward-sexp)))

      (defun demo-await ()
        (lambda () (accept-process-output nil 0.6)))

      (defun demo-eval (regexp)
        (list (demo-goto-end-of regexp) 45
              "C-c C-e" (demo-await) (lambda () (message nil)) 170))

      (add-hook 'cider-connected-hook
                (lambda ()
                  (gif-log "connected")
                  (run-with-timer
                   1 nil
                   (lambda ()
                    (condition-case err
                     (progn
                     (demo-buffer)
                     (gif-log "requiring from %s (%s)" (buffer-name) major-mode)
                     (cider-nrepl-sync-request:eval "(require 'demo.core)")
                     (gif-log "required")
                     (goto-char (point-min))
                     (message nil)
                     (apply #'gif-script
                            (append
                             (list (lambda () (demo-buffer) (message nil)) 150)
                             (demo-eval "(defn greet")
                             (demo-eval "(greet \"CIDER\")")
                             (demo-eval "(map greet")
                             (demo-eval "(frequencies")
                             (demo-eval "(->> ")
                             (list 380)))
                     (gif-log "scripted"))
                     (error (gif-log "HOOK ERROR: %S" err)))))))

      (let ((default-directory (file-name-as-directory demo-project)))
        (cider-connect-clj
         (list :host "127.0.0.1"
               :port (string-trim (with-temp-buffer
                                    (insert-file-contents
                                     (expand-file-name ".nrepl-port" demo-project))
                                    (buffer-string)))
               :project-dir demo-project)))
      ;; if the connect never completes, don't leave a zombie Emacs behind
      (run-with-timer 90 nil (lambda () (gif-log "TIMEOUT") (kill-emacs))))
  (error (gif-log "ERROR: %S" err) (kill-emacs)))
