;;; early-init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/@kyureq>
;; Maintainer: Kyure_A <twitter.com/@kyureq>

;;; Commentary:

;;; Code:

;; Setup-tracker

(defvar setup-tracker--level 0)
(defvar setup-tracker--parents nil)
(defvar setup-tracker--times nil)

(when load-file-name
  (push load-file-name setup-tracker--parents)
  (push (current-time) setup-tracker--times)
  (setq setup-tracker--level (1+ setup-tracker--level)))

(add-variable-watcher
 'load-file-name
 (lambda (_ v &rest __)
   (cond ((equal v (car setup-tracker--parents))
          nil)
         ((equal v (cadr setup-tracker--parents))
          (setq setup-tracker--level (1- setup-tracker--level))
          (let* ((now (current-time))
                 (start (pop setup-tracker--times))
                 (elapsed (+ (* (- (nth 1 now) (nth 1 start)) 1000)
                             (/ (- (nth 2 now) (nth 2 start)) 1000))))
            (with-current-buffer (get-buffer-create "*setup-tracker*")
              (save-excursion
                (goto-char (point-min))
                (dotimes (_ setup-tracker--level) (insert "> "))
                (insert
                 (file-name-nondirectory (pop setup-tracker--parents))
                 " (" (number-to-string elapsed) " msec)\n")))))
         (t
          (push v setup-tracker--parents)
          (push (current-time) setup-tracker--times)
          (setq setup-tracker--level (1+ setup-tracker--level))))))

;; ---------------------------------------------------------------------------------------------- ;;

;; Garbage Collector

(eval-and-compile
  (defconst init/saved-file-name-handler-alist file-name-handler-alist)
  (setq file-name-handler-alist nil) ;; Magic File Name を無効にする (起動が1秒は早くなる)
  (setq gc-cons-threshold most-positive-fixnum) ;; 起動時の GC を止める
  (add-hook 'emacs-startup-hook
	    (lambda ()
	      (setq gc-cons-threshold 536870912) ;; 512MB
	      (setq file-name-handler-alist init/saved-file-name-handler-alist))))

;; ---------------------------------------------------------------------------------------------- ;;

(require 'package)

(setq package-enable-at-startup nil) ;; (package-initialize) を抑制
(setq package-user-dir "~/.elpkg/elpa")
(add-to-list 'load-path "./elpa")
(add-to-list 'load-path "./elisp")

(eval-and-compile
  (customize-set-variable 'package-archives
			  '(("melpa" . "https://melpa.org/packages/")
			    ("org"   . "https://orgmode.org/elpa/")
			    ("gnu"   . "https://elpa.gnu.org/packages/")
			    ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
  (package-initialize)
  ;; leaf が入っていないときに leaf を入れる
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
  (leaf use-package :ensure t)
  (leaf quelpa
    :ensure t
    :require t
    :after leaf
    :custom
    (quelpa-checkout-melpa-p . nil)
    :config
    (add-to-list 'quelpa-melpa-recipe-stores "~/.elpkg")
    (quelpa
     '(quelpa-leaf
       :fetcher git
       :url "https://github.com/quelpa/quelpa-leaf.git"))
    (leaf quelpa-leaf :after leaf quelpa :require t :init (quelpa-leaf-init))))

;; ---------------------------------------------------------------------------------------------- ;;

(leaf startup
  :hook
  (window-setup-hook . delete-other-windows)
  ;; (after-change-major-mode-hook . my/remove-messages-buffer)
  ;; (after-change-major-mode-hook . my/remove-warnings-buffer)
  ;; (minibuffer-exit-hook . my/remove-completions-buffer)
  :custom
  (inhibit-startup-screen . t)
  (initial-scratch-message . nil)
  (inhibit-startup-buffer-menu . t)
  (message-log-max . nil)
  (ring-bell-function . 'ignore)
  :preface
  (defun my/remove-scratch-buffer ()
    (if (get-buffer "*scratch*")
	(kill-buffer "*scratch*")))
  (defun my/remove-completions-buffer ()
    (if (get-buffer "*Completions*")
        (kill-buffer "*Completions*")))
  (defun my/remove-messages-buffer ()
    (if (get-buffer "*Messages*")
        (kill-buffer "*Messages*")))
  (defun my/remove-warnings-buffer ()
    (if (get-buffer "*Warnings*")
        (kill-buffer "*Warnings*"))))

(leaf *visual
  :doc "起動時の見た目と起動後の見た目が大きく異なるのが気になるので early-init.el で呼び出したい見た目関連のものをまとめた"
  :config
  (leaf monokai-theme
    :quelpa (monokai-theme :repo "Kyure-A/monokai-emacs"
			   :fetcher github
			   :upgrade t)
    :config (load-theme 'monokai t))
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
		 '(menu-bar-lines . 0)))))

;; ---------------------------------------------------------------------------------------------- ;;

(provide 'early-init)

;; End:
;;; early-init.el ends here
