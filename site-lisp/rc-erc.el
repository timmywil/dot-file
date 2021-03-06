(require 'erc)
(define-key erc-mode-map "\C-c\C-x" (make-sparse-keymap))

(defun erc-fix-colors ()
  (interactive)
  (set-face-foreground 'erc-current-nick-face "Turquoise4")
  (set-face-foreground 'erc-notice-face "grey70")
  (set-face-foreground 'erc-timestamp-face "green4")
  (set-face-foreground 'erc-pal-face "green4")
  (set-face-attribute  'erc-pal-face nil :weight 'bold)
  (set-face-foreground 'erc-prompt-face nil)
  (set-face-background 'erc-prompt-face nil)
  ;; (set-face-foreground 'erc-my-nick-face nil)
  (set-face-foreground 'erc-my-nick-face "brown")
  (set-face-foreground 'erc-input-face nil))

(defun erc-hide-notices () "hide all notices in a very busy channel"
  (interactive)
  (make-local-variable 'erc-echo-notice-always-hook)
  (setq erc-echo-notice-always-hook nil))

(defun irc ()
  (interactive)
  (save-default-directory
      "~"
    (call-interactively 'erc)
    (erc-fix-colors)))

(custom-set-variables
 '(erc-autoaway-idle-method (quote user))
 '(erc-autoaway-message "I'm idle, but may be working outside of emacs. Decent odds I'll respond if you say my name.")
 '(erc-autoaway-mode t)
 '(erc-fool-highlight-type (quote all))
 '(erc-generate-log-file-name-function (quote erc-generate-log-file-name-short))
 '(erc-join-buffer (quote bury))
 '(erc-log-channels-directory "~/Documents/IRC/erc/")
 '(erc-match-mode 1)
 '(erc-modules (quote (autoaway autojoin button completion fill irccontrols list log match menu move-to-prompt netsplit networks noncommands readonly ring stamp track)))
 '(erc-scrolltobottom-mode t)
 '(erc-server-auto-reconnect t)
 '(erc-server-reconnect-attempts 3)
 '(erc-server-reconnect-timeout 20)

 ;; '(erc-track-exclude (quote ("#clojure" "#emacs" "#org-mode" "#scheme")))
 '(erc-track-exclude-server-buffer t)
 '(erc-track-exclude-types (quote ("JOIN" "NICK" "PART" "QUIT")))
 '(erc-track-faces-priority-list (quote ((erc-nick-default-face erc-current-nick-face) erc-current-nick-face (erc-nick-default-face erc-pal-face) erc-pal-face erc-nick-msg-face erc-direct-msg-face)))
 '(erc-track-priority-faces-only (quote all))
 '(erc-track-position-in-mode-line t)

 ;; http://www.bestinclass.dk/index.php/2010/03/approaching-productivity/
 '(erc-button-url-regexp
   "\\([-a-zA-Z0-9_=!?#$@~`%&*+\\/:;,]+\\.\\)+[-a-zA-Z0-9_=!?#$@~`%&*+\\/:;,]*[-a-zA-Z0-9\\/]"))

(add-hook 'erc-disconnected-hook
          (lambda (nick ip reason)
            (erc-log-save-all-buffers)))

(defun notification-center (title message)
  (start-process "terminal-notifier"
                 "*terminal-notifier*"
                 "/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier"
                 "-title" title
                 "-message" message
                 "-activate" "org.gnu.Emacs"
                 "-sender" "org.gnu.Emacs"))

(defun erc-growl-hook (match-type nick message)
  "Shows a growl notification, when user's nick was mentioned. If the buffer is currently not visible, makes it sticky."
  (when (eq match-type 'current-nick)
    (unless (posix-string-match "^\\** *Users on #" message)
      (notification-center
       (concat "ERC " (buffer-name (current-buffer)))
       message))))

(add-hook 'erc-text-matched-hook 'erc-growl-hook)

(defun rc-erc-mode-line-less-decoration ()
  (defun erc-modified-channels-object (strings)
    "MONKEY PATCHED, the original is in erc-track. Generate a new `erc-modified-channels-object' based on STRINGS. If STRINGS is nil, we initialize `erc-modified-channels-object' to
an appropriate initial value for this flavor of Emacs."
    (if strings
        (if (featurep 'xemacs)
            (let ((e-m-c-s '("[")))
              (push (cons (extent-at 0 (car strings)) (car strings))
                    e-m-c-s)
              (dolist (string (cdr strings))
                (push "," e-m-c-s)
                (push (cons (extent-at 0 string) string)
                      e-m-c-s))
              (push "] " e-m-c-s)
              (reverse e-m-c-s))
          (concat " "
                  (mapconcat 'identity (nreverse strings) " ")
                  " "))
      (if (featurep 'xemacs) '() ""))))

(defface erc-header-line-disconnected
  '((t (:background "red4" :foreground "white")))
  "Face to use when ERC has been disconnected.")

(defun erc-update-header-line-show-disconnected ()
  "Use a different face in the header-line when disconnected."
  (erc-with-server-buffer
    (cond ((erc-server-process-alive) 'erc-header-line)
          (t 'erc-header-line-disconnected))))

(setq erc-header-line-face-method 'erc-update-header-line-show-disconnected)

(provide 'rc-erc)
