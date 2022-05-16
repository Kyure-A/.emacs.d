;;; early-init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/Kyure_A>
;; Maintainer: Kyure_A <twitter.com/Kyure_A>

;;; Commentary: Nya

;;; Code:

(eval-and-compile
  (defconst my-saved-file-name-handler-alist file-name-handler-alist)
  (setq file-name-handler-alist nil)
  (setq gc-cons-threshold most-positive-fixnum)
  (add-hook 'emacs-startup-hook
	    (lambda () (setq gc-cons-threshold 268435456))) ;; 256MB
  )



(require 'package)

(eval-and-compile
  (customize-set-variable 'package-archives
			  '(("melpa" . "https://melpa.org/packages/")
			    ("org"   . "https://orgmode.org/elpa/")
			    ("gnu"   . "https://elpa.gnu.org/packages/")))
  (setq package-user-dir "~/.emacs.packages/elpa")
  (add-to-list 'load-path "./elpa")
  (package-initialize)
  (setq package-enable-at-startup nil)
  ;; install
  (when (not (package-installed-p 'leaf))
    (package-refresh-contents)
    (package-install 'leaf)))

(eval-and-compile (require 'cl-lib))

(add-to-list 'load-path "./elisp")

(leaf *leaf
  :preface
  (leaf leaf-keywords :ensure t :init (leaf-keywords-init))
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree :ensure t :custom (imenu-list-size . 30) (imenu-list-position . 'left))
  (leaf blackout :ensure t)
  (leaf el-get :ensure t :require t :custom (el-get-package-directory . "~/.emacs.packages/el-get") :config (add-to-list 'load-path "./el-get"))
  (leaf package-utils :ensure t)
  (leaf use-package :ensure t)
  )



(leaf *visual
  :doc "なんとなく起動時の見た目と起動後の見た目が大きく異なるのが気になるので early-init.el で呼び出したい見た目関連のものをまとめた"
  :preface
  (leaf doom-modeline :ensure t :global-minor-mode t :custom (doom-modeline-icon . t))
  (scroll-bar-mode -1)
  (setq frame-inhibit-implied-resize t)
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
  )

(leaf *theme
  :doc "テーマ類をまとめた"
  :preface
  (leaf monokai-theme :ensure t :config (load-theme 'monokai t))
  ;;(leaf atom-one-dark-theme :ensure t :config (load-theme 'atom-one-dark t))
  ;;(leaf vscode-dark-plus-theme :ensure t :config (load-theme 'vscode-dark-plus t))
  )


(provide 'early-init)

;;; early-init.el ends here
