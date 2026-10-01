;;; showcase.el --- inspector, debugger and test gifs for cider.mx  -*- lexical-binding: t; -*-

(load (expand-file-name "prelude.el" (getenv "GIF_DIR")))

(defvar demo-project (expand-file-name "project" gif-dir))

(defun demo-open (rel)
  (switch-to-buffer (find-file-noselect (expand-file-name rel demo-project)))
  (delete-other-windows)
  (goto-char (point-min))
  (set-window-start nil (point-min)))

(defun demo-after (regexp)
  (goto-char (point-min))
  (re-search-forward regexp)
  (goto-char (match-beginning 0))
  (forward-sexp))

(defun demo-await (&optional secs)
  (lambda ()
    (let ((end (+ (float-time) (or secs 0.8))))
      (while (< (float-time) end)
        (accept-process-output nil 0.1)))))

(defun demo-segment (name)
  "Start writing frames for the gif NAME."
  (lambda ()
    (setq gif-name name gif-seq 0)
    (setq keycast--this-command-keys nil
          keycast--this-command-desc nil)
    (message nil)))

(defun demo-quiet () (lambda () (message nil)))

(defun demo-inspector-point (regexp)
  "Move point in the inspector to the first match of REGEXP."
  (lambda ()
    (select-window (get-buffer-window "*cider-inspect*"))
    (goto-char (point-min))
    (re-search-forward regexp)
    (goto-char (match-beginning 0))))

(defun demo-await-window (name secs)
  (lambda ()
    (let ((end (+ (float-time) secs)))
      (while (and (< (float-time) end) (not (get-buffer-window name)))
        (accept-process-output nil 0.2)))
    (gif-log "window %s: %s" name (and (get-buffer-window name) t))
    (gif-log "MESSAGES: %s" (with-current-buffer "*Messages*"
                             (buffer-substring-no-properties
                              (max (point-min) (- (point-max) 1500)) (point-max))))))

(defun demo-steps ()
  (append
   ;; inspector: drill into a grouped collection and back out
   (list (demo-segment "inspector")
         (lambda () (demo-open "src/demo/users.clj") (demo-after "^(group-by :city users)"))
         120
         "C-c M-i" (demo-await 1.2) (demo-quiet) 170
         (demo-inspector-point "\\[{:id 2") 70
         "RET" (demo-await 1) (demo-quiet) 190
         (demo-inspector-point "{:id 2") 70
         "RET" (demo-await 1) (demo-quiet) 210
         "l" (demo-await 0.8) (demo-quiet) 90
         "l" (demo-await 0.8) (demo-quiet) 260)
   ;; debugger: instrument a function, call it and step through
   (list (demo-segment "debugger")
         (lambda () (delete-other-windows) (demo-open "src/demo/users.clj")
           (demo-after "^(defn total-price"))
         110
         "C-u C-M-x" (demo-await 1) (demo-quiet) 120
         (lambda () (demo-after "^(total-price \\[")) 60
         "C-c C-e" (demo-await 1.5) 180
         "n" (demo-await 1) 160
         "n" (demo-await 1) 160
         "n" (demo-await 1) 330
         ;; end the session quietly, after the last frame is taken
         (lambda ()
           (with-current-buffer (find-file-noselect (expand-file-name "src/demo/users.clj" demo-project))
             (ignore-errors (cider-debug-mode-send-reply ":quit"))))
         (demo-await 1))
   ;; tests: run the namespace's tests and land on the failure
   (list (demo-segment "tests")
         (lambda () (delete-other-windows) (demo-open "test/demo/core_test.clj"))
         120
         "C-c C-k" (demo-await 1.5) (demo-quiet) 90
         "C-c C-t n" (demo-await-window "*cider-test-report*" 20) (demo-await 1) (demo-quiet) 300
         (lambda () (when-let* ((w (get-buffer-window "*cider-test-report*")))
                      (select-window w)
                      (goto-char (point-min))
                      (re-search-forward "Fail in" nil t)
                      (recenter 1)))
         (demo-await 0.5) (demo-quiet) 380)))

(condition-case err
    (progn
      (dolist (dir (split-string (with-temp-buffer
                                   (insert-file-contents
                                    (expand-file-name "cider-load-path.txt" gif-dir))
                                   (buffer-string))
                                 "\n" t))
        (add-to-list 'load-path dir))
      (require 'cider)
      (require 'cider-inspector)
      (require 'cider-debug)
      (require 'cider-test)
      (setq native-comp-async-report-warnings-errors 'silent
            confirm-kill-processes nil
            cider-repl-pop-to-buffer-on-connect nil
            cider-test-show-report-on-success t
            cider-show-eval-spinner nil
            gif-frame-size '(92 . 24))
      (gif-setup)
      (setq keycast-substitute-alist
            '((cider-inspect "C-c M-i" t)
              (cider-eval-last-sexp "C-c C-e" t)
              (cider-eval-defun-at-point "C-u C-M-x" "instrument for debugging")
              (cider-test-run-ns-tests "C-c C-t n" t)
              (cider-load-buffer "C-c C-k" t)
              (cider-test-menu--run-ns "C-c C-t n" "cider-test-run-ns-tests")
              (self-insert-command nil nil)))
      (add-hook 'cider-connected-hook
                (lambda ()
                  (run-with-timer
                   1 nil
                   (lambda ()
                     (condition-case err
                         (progn
                           (demo-open "src/demo/users.clj")
                           (cider-nrepl-sync-request:eval
                            "(require 'demo.core 'demo.users :reload)")
                           ;; load the test middleware now, so its `=' diffing
                           ;; applies when the test ns is loaded in the gif
                           (cider-nrepl-sync-request:eval "(require 'cider.nrepl.middleware.test)")
                           (message nil)
                           (apply #'gif-script (demo-steps)))
                       (error (gif-log "HOOK ERROR: %S" err)))))))
      (let ((default-directory (file-name-as-directory demo-project)))
        (cider-connect-clj
         (list :host "127.0.0.1"
               :port (string-trim (with-temp-buffer
                                    (insert-file-contents
                                     (expand-file-name ".nrepl-port" demo-project))
                                    (buffer-string)))
               :project-dir demo-project)))
      (run-with-timer 180 nil (lambda () (gif-log "TIMEOUT") (kill-emacs))))
  (error (gif-log "ERROR: %S" err) (kill-emacs)))
