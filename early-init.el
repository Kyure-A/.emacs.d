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

(setq package-user-dir "~/.elpkg/elpa")
(add-to-list 'load-path "./elpa")
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq inhibit-startup-buffer-menu t)
(setq message-log-max nil)
(setq ring-bell-function 'ignore)

(eval-and-compile
  (customize-set-variable 'package-archives
                          '(("melpa" . "https://melpa.org/packages/")
                            ("org"   . "https://orgmode.org/elpa/")
                            ("gnu"   . "https://elpa.gnu.org/packages/")
                            ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
  (package-initialize))

(eval-and-compile
  (when (not (package-installed-p 'leaf))
    (package-refresh-contents)
    (package-install 'leaf)))

(leaf *leaf
  :config
  (leaf leaf-manager :ensure t :after leaf)
  (leaf leaf-keywords :ensure t :init (leaf-keywords-init) :after leaf)
  (leaf leaf-convert :ensure t :after leaf)
  (leaf leaf-tree :ensure t :custom (imenu-list-size . 30) (imenu-list-position . 'left) :after leaf)
  (leaf package :require t)
  (leaf use-package :ensure t))

(eval-when-compile
  (el-clone :repo "Kyure_A/monokai-emacs"))

(add-to-list 'load-path (locate-user-emacs-file "el-clone/monokai-emacs"))
(require 'monokai-theme)
(load-theme 'monokai t)

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

(add-hook 'window-setup-hook 'delete-other-windows)

(provide 'early-init)

;; End:
;;; early-init.el ends here
