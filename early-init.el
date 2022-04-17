;;; early-init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/Kyure_A>
;; Maintainer: Kyure_A <twitter.com/Kyure_A>

;;; Commentary:
;;; scroll-bar-mode は OS によりけりだけれど horizontal-scroll-bar-mode は デフォルトで OFF

;;; Code:

(eval-and-compile
  (defconst my-saved-file-name-handler-alist file-name-handler-alist)
  (setq file-name-handler-alist nil)
  (setq gc-cons-threshold most-positive-fixnum)
  (add-hook 'emacs-startup-hook
	    (lambda () (setq gc-cons-threshold 268435456))) ;; 256MB
  )



(eval-and-compile
  (customize-set-variable 'package-archives
			  '(("melpa" . "https://melpa.org/packages/")
			    ("org"   . "https://orgmode.org/elpa/")
			    ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (setq package-enable-at-startup nil) ;https://www.reddit.com/r/emacs/comments/1rdstn/set_packageenableatstartup_to_nil_for_slightly/
  (when (not (package-installed-p 'leaf))
    (package-refresh-contents)
    (package-install 'leaf)))

(leaf *leaf
  :preface
  (leaf leaf-keywords :ensure t :init (leaf-keywords-init))
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree :ensure t :custom (imenu-list-size . 30) (imenu-list-position . 'left))
  (leaf blackout :ensure t)
  (leaf el-get :ensure t :require t :config (add-to-list 'load-path "~/.emacs.d/el-get"))
  (leaf package-utils :ensure t)
  (leaf use-package :ensure t))



(leaf *theme
  :doc "なんとなく起動時の見た目と起動後の見た目が大きく異なるのが気になるので early-init.el で呼び出したい見た目関連のものをまとめた"
  :preface
  (push '(fullscreen . maximized) default-frame-alist)
  (push '(menu-bar-lines . 0) default-frame-alist)
  (push '(tool-bar-lines . 0) default-frame-alist)
  (setq frame-inhibit-implied-resize t)
  (leaf doom-modeline :ensure t :global-minor-mode t :custom (doom-modeline-icon . t))
  (leaf monokai-theme :ensure t :config (load-theme 'monokai t)))


(provide 'early-init)

;;; early-init.el ends here
