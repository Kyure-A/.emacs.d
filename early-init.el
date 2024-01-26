;;; early-init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/@kyureq>
;; Maintainer: Kyure_A <twitter.com/@kyureq>

;;; Commentary:

;;; Code:

(setq package-enable-at-startup nil)

(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold 536870912)))

(defconst init/saved-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook (lambda () (setq file-name-handler-alist init/saved-file-name-handler-alist)))

(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq inhibit-startup-buffer-menu t)
(setq message-log-max nil)
(setq ring-bell-function 'ignore)

(set-face-background 'default "#272822")

(setq default-frame-alist
        (append (list
                 '(min-height . 1)
                 '(height     . 45)
                 '(min-width  . 1)
                 '(width      . 81)
                 '(vertical-scroll-bars . nil)
                 '(internal-border-width . 24)
                 '(left-fringe    . 1)
                 '(right-fringe   . 1)
                 '(fullscreen . maximized)
                 '(tool-bar-lines . 0)
                 '(menu-bar-lines . 0))))

(scroll-bar-mode -1)

(setq frame-inhibit-implied-resize t)

(provide 'early-init)

;; End:
;;; early-init.el ends here
