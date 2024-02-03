;;; early-init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/@kyureq>
;; Maintainer: Kyure_A <twitter.com/@kyureq>

;;; Commentary:

;;; Code:

(setq package-enable-at-startup nil)

(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold 536870912)))

(defun display-startup-echo-area-message ())
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq inhibit-startup-buffer-menu t)
(setq message-log-max nil)
(setq ring-bell-function 'ignore)
(setq default-directory "~/")
(setq command-line-default-directory "~/")

(set-face-background 'default "#272822")
(set-face-foreground 'default "#F8F8F0")
(set-face-foreground 'font-lock-keyword-face "#F92672")

(push '(min-height . 1) default-frame-alist)
(push '(min-width . 1) default-frame-alist)
(push '(height . 45) default-frame-alist)
(push '(width . 81) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(internal-border-width . 24) default-frame-alist)
(push '(left-fringe . 1) default-frame-alist)
(push '(right-fringe . 1) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)

(setq frame-inhibit-implied-resize t)

(provide 'early-init)

;; End:
;;; early-init.el ends here
