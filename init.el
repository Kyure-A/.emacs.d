;;; init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/Kyure_A>
;; Maintainer: Kyure_A <twitter.com/Kyure_A>

;;; Commentary:

;; Coding rule:

;; なるべく setq/setf は custom でドット対のリストに書き換える
;; global-map にセットするキーバインドは *global-set-key ブロックに書く
;; 各マイナーモードの active-map にセットするキーバインドは各マイナーモードのブロックに書く
;; 各マイナーモードを有効化するときは global-minor-mode 節に書く

;;; Code:

(when (< emacs-major-version 27)
  (load "~/.emacs.d/early-init.el"))

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *global-set-key
  :bind
  ;; C-c
  ("C-c e b" . my/reload-init-el)
  ("C-c e e" . my/open-scratch)
  ("C-c e m" . menu-bar-mode)
  ("C-c l c" . leaf-convert-region-replace)
  ("C-c l t" . leaf-tree-mode)
  ("C-c m" . macrostep-mode)
  ("C-c o" . org-capture)
  ("C-c s" . my/sly-start)
  ("C-c t" . centaur-tabs-counsel-switch-group)
  ;; C-x
  ("C-x g" . magit-status)
  ("C-x M-g" . magit-dispatch-popup)
  ("C-x i" . nil)
  ("C-x i i" . ivy-yasnippet)
  ("C-x i n" . ivy-yasnippet-new-snippet)
  ("C-x u" . undo-tree-visualize)
  ;; C-l
  ("C-l" . nil)
  ("C-l C-l" . lsp)
  ("C-l h" . lsp-describe-session)
  ("C-l t" . lsp-goto-type-definition)
  ("C-l r" . lsp-rename)
  ("C-l <f5>" . lsp-restart-workspace)
  ("C-l l" . lsp-lens-mode)
  ("C-l s" . lsp-ui-sideline-mode)
  ("C-l C-d" . lsp-ui-peek-find-definitions)
  ("C-l C-r" . lsp-ui-peek-find-references)
  ;; C-<any>
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line)
  ("C-u" . undo-tree-undo)
  ("C-r" . undo-tree-redo)
  ("C-s" . swiper)
  ("C-/" . other-window)
  ("C-c C-f" . leaf-convert-insert-template)
  ;; M-<any>
  ("M-k" . backward-kill-line)
  ("M-x" . counsel-M-x)
  ("M-%" . vr/query-replace)
  ;; Modifier key
  ("<f2>" . vterm-toggle)
  ("<f3>". dashboard-open)
  ("<f5>" . my/quickrun-sc)
  ("RET" . smart-newline)
  ("C-<return>" . newline)
  ("C-<space>" . nil)
  ("<backspace>" . smart-hungry-delete-backward-char)
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  ("<mouse-8>" . centaur-tabs-backward)
  ("<double-mouse-8>" . centaur-tabs-backward)
  ("<triple-mouse-8>" . centaur-tabs-backward)
  ("<drag-mouse-8>" . centaur-tabs-backward)
  ("<mouse-9>" . centaur-tabs-forward)
  ("<double-mouse-9>" . centaur-tabs-forward)
  ("<triple-mouse-9>" . centaur-tabs-forward)
  ("<drag-mouse-9>" . centaur-tabs-forward)
  :config
  (defalias 'yes-or-no-p 'y-or-n-p))

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *common-defun
  :preface
  ;; 適当
  (defun my/reload-init-el ()
    "C-c e b"
    (interactive)
    (eval-buffer)
    (my/remove-warnings-buffer)
    (my/remove-messages-buffer))
  (defun my/toggle-centaur-tabs-local-mode()
    (interactive)
    (call-interactively 'centaur-tabs-local-mode)
    (call-interactively 'centaur-tabs-local-mode))
  (defun backward-kill-line (arg)
    "Kill ARG lines backward."
    (interactive "p")
    (kill-line (- 1 arg))))

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *core-packages
  :doc "基幹部分の設定"
  :config

  (leaf auto-save
    :custom
    (auto-save-file-name-transforms . '((".*" "~/.tmp/" t)))
    (auto-save-list-file-prefix . nil)
    (auto-save-default . nil))

  (leaf bytecomp
    :custom
    (byte-compile-warnings . '(not cl-functions obsolete))
    (debug-on-error . nil))
  
  (leaf color :require t)
  
  (leaf cus-edit
    :doc "custom が自動で設定を追記するのを無効にする"
    :url "https://emacs-jp.github.io/tips/emacs-in-2020"
    :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

  (leaf files
    :custom
    (backup-directory-alist . '((".*" . "~/.tmp")))
    (create-lockfiles . nil)
    :config
    (let ((default-directory (locate-user-emacs-file "./elisp")))
      (add-to-list 'load-path default-directory)
      (normal-top-level-add-subdirs-to-load-path)))

  (leaf frame :config (set-frame-parameter nil 'unsplittable t))
  
  (leaf mule-cmds
    :config
    (set-language-environment "Japanese")
    (prefer-coding-system 'utf-8)
    (set-default 'buffer-file-coding-system 'utf-8))

  (leaf mwheel
    :custom
    (mouse-wheel-progressive-speed . nil)
    (scroll-preserve-screen-position . 'always))

  (leaf posframe
    :doc "Pop a posframe (just a frame) at point"
    :req "emacs-26.1"
    :tag "tooltip" "convenience" "emacs>=26.1"
    :url "https://github.com/tumashu/posframe"
    :emacs>= 26.1
    :ensure t :require t
    :require t
    :config
    (leaf pos-tip
      :doc "Show tooltip at point"
      :tag "tooltip"
      :ensure t :require t))
  
  (leaf recentf
    :tag "builtin"
    :global-minor-mode t
    :custom
    (recentf-max-saved-items . 150)
    (recentf-auto-cleanup . 'never)
    (recentf-exclude
     '("/dotfiles" "/recentf" "COMMIT_EDITMSG" "/.?TAGS" "^/sudo:" "/\\.emacs\\.d/games/*-scores" "/\\.emacs\\.d/\\.tmp/"))
    :config
    (leaf recentf-ext
      :doc "Recentf extensions"
      :tag "files" "convenience"
      :url "http://www.emacswiki.org/cgi-bin/wiki/download/recentf-ext.el"
      :ensure t :require t))

  (leaf save-place-mode :tag "builtin" :global-minor-mode t)
  
  )

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *library
  :doc "Emacs Lisp library"
  :config
  
  (leaf dash
    :doc "A modern list library for Emacs"
    :req "emacs-24"
    :tag "lisp" "extensions" "emacs>=24"
    :url "https://github.com/magnars/dash.el"
    :emacs>= 24
    :ensure t :require t)

  (leaf dotenv
    :quelpa
    (dotenv :repo "pkulev/dotenv.el"
	    :fetcher github
	    :upgrade t))

  (leaf f
    :doc "Modern API for working with files and directories"
    :req "emacs-24.1" "s-1.7.0" "dash-2.2.0"
    :tag "directories" "files" "emacs>=24.1"
    :url "http://github.com/rejeep/f.el"
    :added "2023-05-26"
    :emacs>= 24.1
    :ensure t)
  
  (leaf promise
    :doc "Promises/A+"
    :req "emacs-25.1"
    :tag "convenience" "promise" "async" "emacs>=25.1"
    :url "https://github.com/chuntaro/emacs-promise"
    :emacs>= 25.1
    :ensure t :require t)

  (leaf queue
    :doc "Queue data structure"
    :tag "queue" "data structures" "extensions"
    :url "http://www.dr-qubit.org/emacs.php"
    :ensure t :require t)

  (leaf request
    :doc "Compatible layer for URL request"
    :req "emacs-24.4"
    :tag "emacs>=24.4"
    :url "https://github.com/tkf/emacs-request"
    :emacs>= 24.4
    :ensure t :require t)
  
  (leaf s
    :doc "The long lost Emacs string manipulation library."
    :tag "strings"
    :ensure t :require t)
  )

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *inbox
  :doc "分類が面倒なパッケージを入れる"
  :config

  (leaf fast-scroll
    :doc "Some utilities for faster scrolling over large buffers."
    :req "emacs-25.1" "cl-lib-0.6.1"
    :tag "scrolling" "scroll" "fast" "convenience" "ahungry" "emacs>=25.1"
    :url "https://github.com/ahungry/fast-scroll"
    :emacs>= 25.1
    :ensure t :require t
    :hook
    (after-init-hook . fast-scroll-mode)
    (fast-scroll-start-hook . (lambda () (flycheck-mode -1)))
    (fast-scroll-end-hook . (lambda () (flycheck-mode 1)))
    :custom
    (fast-but-imprecise-scrolling . t)
    (jit-lock-defer-time . 0)
    :config
    (fast-scroll-config))

  (leaf gcmh
    :doc "the Garbage Collector Magic Hack"
    :req "emacs-24"
    :tag "internal" "emacs>=24"
    :url "https://gitlab.com/koral/gcmh"
    :emacs>= 24
    :ensure t :require t
    :hook (after-init-hook . gcmh-mode)
    :custom (gcmh-verbose . t))

  (leaf good-scroll
    :doc "Good pixel line scrolling"
    :req "emacs-27.1"
    :tag "emacs>=27.1"
    :url "https://github.com/io12/good-scroll.el"
    :added "2022-09-09"
    :emacs>= 27.1
    :ensure t
    :require t)
  
  (leaf goto-address :tag "builtin" :global-minor-mode t :hook (prog-mode-hook . goto-address-prog-mode))

  (leaf smooth-scrolling
    :doc "Make emacs scroll smoothly"
    :tag "convenience"
    :url "http://github.com/aspiers/smooth-scrolling/"
    :added "2022-09-09"
    :ensure t)

  (leaf sublimity
    :doc "smooth-scrolling, minimap and distraction-free mode"
    :req "emacs-26.1"
    :tag "emacs>=26.1"
    :url "https://github.com/zk-phi/sublimity"
    :emacs>= 26.1
    :ensure t :require t
    :global-minor-mode t
    :config
    (leaf sublimity-attractive :require t
      :custom (sublimity-attractive-centering-width . 200))
    (leaf sublimity-scroll :require t
      :custom (sublimity-scroll-weight . 5) (sublimity-scroll-drift-length . 10)))

  (leaf tetris
    :bind
    (:tetris-mode-map
     ("w" . tetris-rotate-prev)
     ("a" . tetris-move-left)
     ("s" . tetris-move-down)
     ("d" . tetris-move-right)
     ("RET" . tetris-move-bottom)))
  
  ;; (leaf zone :doc "screen-saver" :tag "builtin" :require t :config (zone-when-idle 1200))

  ;; (leaf onlyonce
  ;;   :quelpa (onlyonce :repo "Kyure-A/onlyonce.el"
  ;; 		      :fetcher github
  ;; 		      :upgrade t)
  ;;   :config
  ;;   (onlyonce-add '(fira-code-mode-install-fonts))
  ;;   (onlyonce-add '(all-the-icons-install-fonts))
  ;;   (onlyonce-startup))
  )

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *edit
  :doc "補完や構文のチェック, 入力に関するプラグイン"
  :config
  
  (leaf aggressive-indent
    :doc "Minor mode to aggressively keep your code always indented"
    :req "emacs-24.3"
    :tag "tools" "maint" "lisp" "indent" "emacs>=24.3"
    :url "https://github.com/Malabarba/aggressive-indent-mode"
    :emacs>= 24.3
    :ensure t
    :require t
    :global-minor-mode global-aggressive-indent-mode)

  (leaf autorevert
    :doc "revert buffers when files on disk change"
    :tag "builtin"
    :global-minor-mode global-auto-revert-mode
    :custom (auto-revert-interval . 1))
  
  (leaf company
    :doc "Modular text completion framework"
    :req "emacs-25.1"
    :tag "matching" "convenience" "abbrev" "emacs>=25.1"
    :url "http://company-mode.github.io/"
    :emacs>= 25.1
    :ensure t :require t
    :global-minor-mode global-company-mode
    :bind (:company-active-map ( "<tab>" . company-complete-common-or-cycle))
    :custom
    (company-idle-delay . 0)
    (company-minimum-prefix-length . 2)
    (company-selection-wrap-around . t)
    (company-tooltip-align-annotations . t)
    (company-require-match . 'never)
    (company-transformers . '(company-sort-by-statistics company-sort-by-backend-importance))
    :config
    
    (leaf company-box
      :doc "Company front-end with icons"
      :req "emacs-26.0.91" "dash-2.19.0" "company-0.9.6" "frame-local-0.0.1"
      :tag "convenience" "front-end" "completion" "company" "emacs>=26.0.91"
      :url "https://github.com/sebastiencs/company-box"
      :emacs>= 26.0
      :ensure t :require t
      :require t
      :after company frame-local
      :hook ((company-mode-hook . company-box-mode))
      :custom
      (company-box-icons-alist . 'company-box-icons-all-the-icons)
      (company-box-doc-enable . nil))
    
    (leaf company-statistics
      :doc "Sort candidates using completion history"
      :req "emacs-24.3" "company-0.8.5"
      :tag "matching" "convenience" "abbrev" "emacs>=24.3"
      :url "https://github.com/company-mode/company-statistics"
      :emacs>= 24.3
      :ensure t :require t
      :require t
      :after company
      :global-minor-mode t
      :hook (after-init-hook))
    
    (leaf company-posframe
      :doc "Use a posframe as company candidate menu"
      :req "emacs-26.0" "company-0.9.0" "posframe-0.9.0"
      :tag "matching" "convenience" "abbrev" "emacs>=26.0"
      :url "https://github.com/tumashu/company-posframe"
      :emacs>= 26.0
      :ensure t :require t
      :require t
      :after company posframe
      :global-minor-mode t)
    
    (leaf company-quickhelp
      :doc "Popup documentation for completion candidates"
      :req "emacs-24.3" "company-0.8.9" "pos-tip-0.4.6"
      :tag "quickhelp" "documentation" "popup" "company" "emacs>=24.3"
      :url "https://www.github.com/expez/company-quickhelp"
      :emacs>= 24.3
      :ensure t :require t
      :require t
      :after company pos-tip
      :custom (company-quickhelp-delay . 0.1))

    (leaf company-shell
      :doc "Company mode backend for shell functions"
      :req "emacs-24.4" "company-0.8.12" "dash-2.12.0" "cl-lib-0.5"
      :tag "auto-completion" "shell" "company" "emacs>=24.4"
      :url "https://github.com/Alexander-Miller/company-shell"
      :added "2023-04-20"
      :emacs>= 24.4
      :ensure t
      :after company
      :config (add-to-list 'company-backends 'company-shell))
    )

  (leaf delete-selection :doc "delete から overwrite に改名したほうがいい" :tag "builtin" :global-minor-mode delete-selection-mode)

  (leaf dired
    :tag "builtin"
    :bind
    (:dired-mode-map
     ("RET" . dired-open-in-accordance-with-situation)
     ("<right>" . dired-open-in-accordance-with-situation)
     ("<left>" . dired-up-directory)
     ("a" . dired-find-file)
     ("e" . wdired-change-to-wdired-mode))
    :config
    
    (leaf dired-toggle
      :doc "Show dired as sidebar and will not create new buffers when changing dir"
      :tag "sidebar" "dired"
      :url "https://github.com/fasheng/dired-toggle"
      :ensure t :require t)
    
    (leaf dired-k
      :doc "Highlight dired by size, date, git status"
      :req "emacs-24.3"
      :tag "emacs>=24.3"
      :url "https://github.com/emacsorphanage/dired-k"
      :emacs>= 24.3
      :ensure t :require t
      :hook (dired-initial-position-hook . dired-k))
    
    (leaf wdired
      :doc "Rename files editing their names in dired buffers"
      :tag "builtin"
      :require t)
    
    (put 'dired-find-alternate-file 'disabled nil)
    
    :preface

    (leaf dired-open-in-accordance-with-situation
      :url "https://nishikawasasaki.hatenablog.com/entry/20120222/1329932699"
      :preface
      (defun dired-open-in-accordance-with-situation ()
	(interactive)
	(let ((file (dired-get-filename)))
	  (if (file-directory-p file)
	      (dired-find-alternate-file)
	    (dired-find-file)))))

    (leaf dired-zip-files
      :url "https://stackoverflow.com/questions/1431351/how-do-i-uncompress-unzip-within-emacs"
      :preface
      (defun dired-zip-files (zip-file)
	"Create an archive containing the marked files."
	(interactive "sEnter name of zip file: ")
	;; create the zip file
	(let ((zip-file (if (string-match ".zip$" zip-file) zip-file (concat zip-file ".zip"))))
	  (shell-command
	   (concat "zip "
		   zip-file
		   " "
		   (my/concat-string-list
		    (mapcar
		     '(lambda (filename)
			(file-name-nondirectory filename))
		     (dired-get-marked-files))))))
	(revert-buffer))
      
      (defun my/concat-string-list (list)
	"Return a string which is a concatenation of all elements of the list separated by spaces"
	(mapconcat '(lambda (obj) (format "%s" obj)) list " "))))

  (leaf exec-path-from-shell
    :doc "Get environment variables such as $PATH from the shell"
    :req "emacs-24.1" "cl-lib-0.6"
    :tag "environment" "unix" "emacs>=24.1"
    :url "https://github.com/purcell/exec-path-from-shell"
    :emacs>= 24.1
    :ensure t
    :defun (exec-path-from-shell-initialize)
    :custom
    (exec-path-from-shell-check-startup-files . nil)
    (exec-path-from-shell-arguments . nil)
    (exec-path-from-shell-variables . '("ASDF_CONFIG_FILE" "ASDF_DATA_DIR" "ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" "ASDF_DIR"
					"GPG_AGENT_INFO" "GPG_KEY_ID" "PATH" "SHELL" "TEXMFHOME" "WSL_DISTRO_NAME" "http_proxy"))
    :config (exec-path-from-shell-initialize))
  
  (leaf flycheck
    :doc "On-the-fly syntax checking"
    :req "dash-2.12.1" "pkg-info-0.4" "let-alist-1.0.4" "seq-1.11" "emacs-24.3"
    :tag "tools" "languages" "convenience" "emacs>=24.3"
    :url "http://www.flycheck.org"
    :emacs>= 24.3
    :ensure t :require t
    :global-minor-mode global-flycheck-mode
    :bind (:flycheck-mode-map
	   ("M-n" . flycheck-next-error)
	   ("M-p" . flycheck-previous-error))
    :custom (flycheck-idle-change-delay . 0))
  
  (leaf hydra
    :doc "Make bindings that stick around."
    :req "cl-lib-0.5" "lv-0"
    :tag "bindings"
    :url "https://github.com/abo-abo/hydra"
    :ensure t :require t
    :after lv)

  (leaf *ivy
    :config

    (leaf counsel
      :doc "Various completion functions using Ivy"
      :req "emacs-24.5" "ivy-0.13.4" "swiper-0.13.4"
      :tag "tools" "matching" "convenience" "emacs>=24.5"
      :url "https://github.com/abo-abo/swiper"
      :emacs>= 24.5
      :ensure t :require t
      :after ivy swiper
      :global-minor-mode t
      :require t
      :bind
      (:counsel-mode-map ([remap find-file] . nil))
      :custom
      (counsel-find-file-ignore-regexp . (regexp-opt '("./" "../")))
      (read-file-name-function . #'disable-counsel-find-file)
      :preface
      (leaf disable-counsel-find-file
	:url "https://qiita.com/takaxp/items/2fde2c119e419713342b#counsel-find-file-%E3%82%92%E4%BD%BF%E3%82%8F%E3%81%AA%E3%81%84"
	:preface
	(defun disable-counsel-find-file (&rest args)
	  "Disable `counsel-find-file' and use the original `find-file' with ARGS."
	  (let ((completing-read-function #'completing-read-default)
		(completion-in-region-function #'completion--in-region))
	    (apply #'read-file-name-default args))))
      :config
      
      (leaf counsel-projectile
	:doc "Ivy integration for Projectile"
	:req "counsel-0.13.4" "projectile-2.5.0"
	:tag "convenience" "project"
	:url "https://github.com/ericdanan/counsel-projectile"
	:added "2022-09-01"
	:ensure t
	:after counsel projectile
	:global-minor-mode counsel-projectile-mode))
    
    (leaf ivy
      :doc "Incremental Vertical completYon"
      :req "emacs-24.5"
      :tag "matching" "emacs>=24.5"
      :url "https://github.com/abo-abo/swiper"
      :emacs>= 24.5
      :ensure t :require t
      :global-minor-mode t
      :custom
      (ivy-use-virtual-buffers . t)
      (ivy-wrap . t)
      (ivy-extra-directories . t)
      (enable-recursive-minibuffers . t)
      :config
      
      (leaf ivy-rich
	:doc "More friendly display transformer for ivy"
	:req "emacs-25.1" "ivy-0.13.0"
	:tag "ivy" "convenience" "emacs>=25.1"
	:url "https://github.com/Yevgnen/ivy-rich"
	:emacs>= 25.1
	:ensure t :require t
	:after ivy
	:global-minor-mode t)
      
      (leaf ivy-posframe
	:doc "Using posframe to show Ivy"
	:req "emacs-26.0" "posframe-1.0.0" "ivy-0.13.0"
	:tag "ivy" "matching" "convenience" "abbrev" "emacs>=26.0"
	:url "https://github.com/tumashu/ivy-posframe"
	:emacs>= 26.0
	:ensure t :require t
	:after posframe ivy
	:custom (ivy-posframe-display-functions-alist . '((t . ivy-posframe-display-at-frame-center))))
      )

    (leaf swiper
      :doc "Isearch with an overview. Oh, man!"
      :req "emacs-24.5" "ivy-0.13.4"
      :tag "matching" "emacs>=24.5"
      :url "https://github.com/abo-abo/swiper"
      :emacs>= 24.5
      :ensure t :require t
      :after ivy))

  (leaf mwim
    :doc "Switch between the beginning/end of line or code (enhanced C-a, C-e)"
    :tag "convenience"
    :url "https://github.com/alezost/mwim.el"
    :ensure t :require t)
  
  (leaf paren
    :doc "highlight matching paren"
    :tag "builtin"
    :global-minor-mode show-paren-mode
    :custom
    (show-paren-delay . 0)
    (show-paren-style . 'expression))

  (leaf popwin
    :doc "Popup Window Manager"
    :req "emacs-24.3"
    :tag "convenience" "emacs>=24.3"
    :url "https://github.com/emacsorphanage/popwin"
    :emacs>= 24.3
    :ensure t
    :require t
    :custom
    (display-buffer-function . 'popwin:display-buffer)
    (popwin:special-display-config  . t)
    (popwin:popup-window-position . 'bottom))

  (leaf skewer-mode
    :doc "live browser JavaScript, CSS, and HTML interaction"
    :req "simple-httpd-1.4.0" "js2-mode-20090723" "emacs-24"
    :tag "emacs>=24"
    :url "https://github.com/skeeto/skewer-mode"
    :emacs>= 24
    :ensure t :require t
    :after js2-mode)
  
  (leaf smart-hungry-delete
    :doc "smart hungry deletion of whitespace"
    :req "emacs-24.3"
    :tag "convenience" "emacs>=24.3"
    :url "https://github.com/hrehfeld/emacs-smart-hungry-delete"
    :emacs>= 24.3
    :ensure t :require t
    :config (smart-hungry-delete-add-default-hooks))

  (leaf smart-newline
    :doc "Provide smart newline for one keybind."
    :url "https://ainame.hateblo.jp/entry/2013/12/08/162032"
    :ensure t :require t
    :require t)

  (leaf smartparens
    :doc "Automatic insertion, wrapping and paredit-like navigation with user defined pairs."
    :req "dash-2.13.0" "cl-lib-0.3"
    :tag "editing" "convenience" "abbrev"
    :url "https://github.com/Fuco1/smartparens"
    :ensure t :require t
    :require t
    :global-minor-mode smartparens-global-mode show-smartparens-global-mode
    :config
    (leaf smartparens-config :require t :after smartparens :hook (web-mode-hook . (lambda () (sp-pair "<#" "#>")))))

  (leaf undohist
    :doc "Persistent undo history for GNU Emacs"
    :req "cl-lib-1.0"
    :tag "convenience"
    :ensure t :require t
    :require t
    :custom
    (undohist-directory . "~/.emacs.d/.tmp/")
    (undohist-ignored-files . '("/.tmp/" "COMMIT_EDITMSG" "/elpa"))
    :config
    (undohist-initialize))

  (leaf undo-tree
    :doc "Treat undo history as a tree"
    :req "queue-0.2" "emacs-24.3"
    :tag "tree" "history" "redo" "undo" "files" "convenience" "emacs>=24.3"
    :url "https://www.dr-qubit.org/undo-tree.html"
    :emacs>= 24.3
    :ensure t :require t
    :require t
    :after queue
    :global-minor-mode global-undo-tree-mode
    :custom
    (undo-tree-auto-save-history . t)
    (undo-tree-history-directory-alist . '(("." . "~/.emacs.d/.tmp"))))
  
  (leaf visual-regexp
    :doc "A regexp/replace command for Emacs with interactive visual feedback"
    :req "cl-lib-0.2"
    :tag "feedback" "visual" "replace" "regexp"
    :url "https://github.com/benma/visual-regexp.el/"
    :ensure t :require t)

  (leaf which-function-mode :tag "builtin" :custom (which-function-mode . t))

  (leaf which-key
    :doc "Display available keybindings in popup"
    :req "emacs-24.4"
    :tag "emacs>=24.4"
    :url "https://github.com/justbur/emacs-which-key"
    :emacs>= 24.4
    :ensure t :require t
    :global-minor-mode t
    :config (which-key-setup-side-window-bottom))
  
  (leaf yafolding
    :doc "Folding code blocks based on indentation"
    :tag "folding"
    :ensure t :require t
    :hook (prog-mode-hook . yafolding-mode))

  (leaf yasnippet
    :doc "Yet another snippet extension for Emacs"
    :req "cl-lib-0.5"
    :tag "emulation" "convenience"
    :url "http://github.com/joaotavora/yasnippet"
    :ensure t :require t
    :global-minor-mode yas-global-mode yas-minor-mode
    :custom
    (yas-snippet-dirs . '("~/.emacs.d/snippets"))
    :config
    
    (leaf ivy-yasnippet
      :doc "yas-insert-snippet よりスニペットの挿入が可視化されるため見やすい"
      :doc "Preview yasnippets with ivy"
      :req "emacs-24.1" "cl-lib-0.6" "ivy-0.10.0" "yasnippet-0.12.2" "dash-2.14.1"
      :tag "convenience" "emacs>=24.1"
      :url "https://github.com/mkcms/ivy-yasnippet"
      :emacs>= 24.1
      :ensure t :require t
      :after ivy yasnippet)
    
    (leaf yatemplate
      :doc "File templates with yasnippet"
      :req "yasnippet-0.8.1" "emacs-24.3"
      :tag "convenience" "files" "emacs>=24.3"
      :url "https://github.com/mineo/yatemplate"
      :emacs>= 24.3
      :ensure t :require t
      :after yasnippet
      :config (leaf auto-insert-mode :tag "builtin" :global-minor-mode t) (yatemplate-fill-alist)))
  
  )

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *general
  :config
  
  ;; GitHub Education License was expired
  
  (leaf copilot
    :doc "An unofficial Copilot plugin for Emacs"
    :req "emacs-27.2" "s-1.12.0" "dash-2.19.1" "editorconfig-0.8.2" "jsonrpc-1.0.14"
    :tag "out-of-MELPA" "emacs>=27.2"
    :emacs>= 27.2
    :quelpa (copilot :repo "zerolfx/copilot.el"
		     :fetcher github
		     :upgrade t)
    :after editorconfig jsonrpc
    :require t
    :hook (prog-mode . copilot-mode)
    ;;:custom (copilot-node-executable . "~/.asdf/installs/nodejs/17.9.1/bin/node")
    :config
    
    (delq 'company-preview-if-just-one-frontend company-frontends)
    
    (leaf company-copilot-tab
      :url "https://github.com/zerolfx/copilot.el/blob/9b13478720581580a045ac76ad68be075466a963/readme.md?plain=1#L152"
      :after company
      :bind ;; (:company-active-map ( "<tab>" . company-copilot-tab))
      :preface
      (defun company-copilot-tab ()
	(interactive)
	(or (copilot-accept-completion)
	    (company-indent-or-complete-common nil)))))
  
  (leaf editorconfig
    :doc "EditorConfig Emacs Plugin"
    :req "cl-lib-0.5" "nadvice-0.3" "emacs-24"
    :tag "emacs>=24"
    :url "https://github.com/editorconfig/editorconfig-emacs#readme"
    :emacs>= 24
    :ensure t :require t
    :after nadvice
    :global-minor-mode t)

  (leaf lsp-mode
    :doc "LSP mode"
    :req "emacs-26.1" "dash-2.18.0" "f-0.20.0" "ht-2.3" "spinner-1.7.3" "markdown-mode-2.3" "lv-0"
    :tag "languages" "emacs>=26.1" "lsp"
    :url "https://github.com/emacs-lsp/lsp-mode"
    :url "https://blog.medalotte.net/archives/473"
    :emacs>= 26.1
    :ensure t :require t
    :after spinner markdown-mode lv
    :commands lsp
    :custom
    (lsp-enable-snippet . t)
    (lsp-enable-indentation . nil)
    (lsp-prefer-flymake . nil)
    (lsp-document-sync-method . 2)
    (lsp-inhibit-message . t)
    (lsp-message-project-root-warning . t)
    (create-lockfiles . nil)
    (lsp-prefer-capf . t)
    (lsp-headerline-breadcrumb-mode . t))

  (leaf magit
    :doc "A Git porcelain inside Emacs."
    :req "emacs-25.1" "compat-28.1.1.2" "dash-20210826" "git-commit-20220222" "magit-section-20220325" "transient-20220325" "with-editor-20220318"
    :tag "vc" "tools" "git" "emacs>=25.1"
    :url "https://github.com/magit/magit"
    :emacs>= 25.1
    :ensure t :require t
    :after compat git-commit magit-section with-editor
    :hook (magit-status-mode . my/toggle-centaur-tabs-local-mode))
  
  (leaf oj
    :doc "Competitive programming tools client for AtCoder, Codeforces"
    :req "emacs-26.1" "quickrun-2.2"
    :tag "convenience" "emacs>=26.1"
    :url "https://github.com/conao3/oj.el"
    :emacs>= 26.1
    :ensure t :require t
    :custom
    (oj-shell-program . "zsh")
    (oj-open-home-dir . "~/oj-files/")
    (oj-default-online-judge . 'atcoder)
    (oj-compiler-c . "gcc")
    (oj-compiler-python . "cpython"))

  (leaf projectile
    :doc "Manage and navigate projects in Emacs easily"
    :req "emacs-25.1"
    :tag "convenience" "project" "emacs>=25.1"
    :url "https://github.com/bbatsov/projectile"
    :emacs>= 25.1
    :ensure t :require t
    :global-minor-mode t)

  (leaf vterm
    :doc "Fully-featured terminal emulator"
    :req "emacs-25.1"
    :tag "terminals" "emacs>=25.1"
    :url "https://github.com/akermu/emacs-libvterm"
    :emacs>= 25.1
    :ensure t :require t
    :custom
    (vterm-buffer-name-string . t)
    (vterm-clear-scrollback-when-clearing . t)
    (vterm-keymap-exceptions
     . '("<f1>" "<f2>" "<f10>" "C-<return>" "C-<prior>" "C-<next>" "C-c" "C-g" "C-l" "C-s" "C-u" "C-v" "C-w" "C-x" "C-y" "M-v" "M-w" "M-x" "M-y"))
    (vterm-max-scrollback . 5000)
    ;; (vterm-toggle--vterm-buffer-p-function . 'my/term-mode-p)
    :config
    (leaf vterm-toggle :ensure t :require t)
    (add-to-list 'vterm-eval-cmds '("update-pwd" (lambda (path) (setq default-directory path))))
    :preface
    ;; (defun my/term-mode-p(&optional args)
    ;;   (derived-mode-p 'eshell-mode 'term-mode 'shell-mode 'vterm-mode 'multi-term-mode))
    ;; (push (list "find-file-below"
    ;; 		(lambda (path)
    ;; 		  (if-let* ((buf (find-file-noselect path))
    ;;                         (window (display-buffer-below-selected buf nil)))
    ;; 		      (select-window window)
    ;;                 (message "Failed to open file: %s" path))))
    ;; 	  vterm-eval-cmds)
    )
  
  (leaf quickrun
    :doc "Run commands quickly"
    :req "emacs-24.3"
    :tag "emacs>=24.3"
    :url "https://github.com/syohex/emacs-quickrun"
    :emacs>= 24.3
    :ensure t :require t
    :config
    (push '("*quickrun*") popwin:special-display-config)
    :preface
    (defun my/quickrun-sc (start end)
      (interactive "r")
      (if mark-active
	  (quickrun :start start :end end)
	(quickrun))))
  )

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *languages
  :config

  (leaf *c++
    :config
    
    (leaf cc-mode
      :doc "user customization variables for CC Mode"
      :tag "builtin"
      :hook
      (c-mode . (lambda () (setq c-basic-offset 8) (indent-tabs-mode . nil)))
      (c++-mode . (lambda () (setq c-basic-offset 8) (indent-tabs-mode . nil)))
      :custom
      (c-tab-always-indent . t))
    
    (leaf google-c-style
      :doc "Google's C/C++ style for c-mode"
      :tag "tools" "c"
      :ensure t :require t
      :hook ((c-mode c++-mode) . (lambda () (google-set-c-style)))))

  (leaf *dart
    :config

    (leaf dart-mode
      :doc "Major mode for editing Dart files"
      :req "emacs-24.3"
      :tag "languages" "emacs>=24.3"
      :url "https://github.com/bradyt/dart-mode"
      :emacs>= 24.3
      :ensure t :require t
      :hook (dart-mode-hook . flycheck-mode)
      :custom
      (dart-enable-analysis-server . t))
    
    (leaf lsp-dart
      :doc "Dart support lsp-mode"
      :req "emacs-26.3" "lsp-treemacs-0.3" "lsp-mode-7.0.1" "dap-mode-0.6" "f-0.20.0" "dash-2.14.1" "dart-mode-1.0.5"
      :tag "extensions" "languages" "emacs>=26.3" "lsp"
      :url "https://emacs-lsp.github.io/lsp-dart"
      :emacs>= 26.3
      :ensure t :require t
      :after lsp-treemacs lsp-mode dap-mode dart-mode
      :commands lsp
      :hook ((dart-mode-hook . lsp))
      :config
      (dap-register-debug-template "Flutter :: Custom debug"
				   (list :flutterPlatform "x86_64" :program "lib/main_debug.dart" :args
					 '("--flavor" "customer_a"))))
    
    )

  (leaf *lisp
    :doc "Emacs Lisp, Common Lisp"
    :config

    (leaf elisp-mode
      :mode "\\Keg\\'")
    
    (leaf lisp-interaction
      :bind
      (:lisp-interaction-mode-map ("C-j" . eval-print-last-sexp)))

    (leaf sly
      :doc "Sylvester the Cat's Common Lisp IDE"
      :req "emacs-24.3"
      :tag "sly" "lisp" "languages" "emacs>=24.3"
      :url "https://github.com/joaotavora/sly"
      :emacs>= 24.3
      :ensure t :require t
      :custom (inferior-lisp-program . "/usr/bin/sbcl")
      :config
      ;; (load "~/.roswell/helper.el")
      (defun my/sly-start ()
	"sly の挙動を slime に似せる"
	(interactive)
	(split-window-right)
	(sly))))

  (leaf *mark-up
    :config

    (leaf csv-mode
      :doc "Major mode for editing comma/char separated values"
      :req "emacs-27.1" "cl-lib-0.5"
      :tag "convenience" "emacs>=27.1"
      :url "https://elpa.gnu.org/packages/csv-mode.html"
      :emacs>= 27.1
      :ensure t :require t
      :mode "\\.csv\\'")

    (leaf html+-mode :require nil)
    
    (leaf markdown-mode
      :doc "Major mode for Markdown-formatted text"
      :req "emacs-26.1"
      :tag "itex" "github flavored markdown" "markdown" "emacs>=26.1"
      :url "https://jblevins.org/projects/markdown-mode/"
      :emacs>= 26.1
      :ensure t :require t
      :commands markdown-mode
      :mode (("\\.md\\'" . gfm-mode)
	     ("\\.markdown\\'" . gfm-mode))
      :custom
      (markdown-command . "github-markup")
      (markdown-command-needs-filename . t))
    
    (leaf org-mode
      :tag "builtin"
      :custom
      (org-directory . "~/document/org")
      (org-startup-truncated . nil)
      (org-enforce-todo-dependencies . t)
      :config
      
      (leaf org-modern
	:doc "Modern looks for Org"
	:req "emacs-27.1"
	:tag "emacs>=27.1"
	:url "https://github.com/minad/org-modern"
	:emacs>= 27.1
	:ensure t :require t
	:hook
	(org-mode-hook . org-modern-mode)
	(org-agenda-finalize-hook . org-modern-agenda)))

    (leaf web-mode
      :doc "major mode for editing web templates"
      :req "emacs-23.1"
      :tag "languages" "emacs>=23.1"
      :url "https://web-mode.org"
      :emacs>= 23.1
      :ensure t :require t
      :mode
      "\\.[agj]sp\\'"
      "\\.as[cp]x\\'"
      "\\.djhtml\\'"
      "\\.ejs\\'"
      "\\.erb\\'"
      "\\.html\\'"
      "\\.js\\'"
      "\\.jsx\\'"
      "\\.mustache\\'"
      "\\.php\\'"
      "\\.phtml\\'"
      "\\.tpl\\'"
      "\\.vue\\'"
      :custom
      (web-mode-markup-indent-offset . 2)
      (web-mode-enable-auto-pairing . t)
      (web-mode-enable-auto-closing . t)
      (web-mode-tag-auto-close-style . 2)
      (web-mode-enable-auto-quoting . nil)
      (web-mode-enable-current-column-highlight . t)
      (web-mode-enable-current-element-highlight . t)
      :config
      (with-eval-after-load 'web-mode (sp-local-pair '(web-mode) "<" ">" :actions :rem))
      (put 'web-mode-markup-indent-offset 'safe-local-variable 'integerp))
    
    (leaf yaml-mode
      :doc "Major mode for editing YAML files"
      :req "emacs-24.1"
      :tag "yaml" "data" "emacs>=24.1"
      :url "https://github.com/yoshiki/yaml-mode"
      :emacs>= 24.1
      :ensure t
      :mode
      "\\.yml$"
      "\\.yaml$")
    
    (leaf yatex
      :doc "Yet Another tex-mode for emacs //野鳥//"
      :doc "jis=2, UTF-8=4"
      :ensure t :require t
      :mode "\\.tex$"
      :custom
      (YaTeX-nervous . nil)
      (latex-message-kanji-code . 4)
      (YaTeX-kanji-code . 4)
      (YaTeX-coding-system . 4))
    )

  (leaf *pwsh
    :config
    
    (leaf powershell
      :doc "Mode for editing PowerShell scripts"
      :req "emacs-24"
      :tag "languages" "powershell" "emacs>=24"
      :url "http://github.com/jschaf/powershell.el"
      :added "2023-06-02"
      :emacs>= 24
      :ensure t)
    
    (leaf lsp-pwsh
      :doc "client for PowerShellEditorServices"
      :tag "out-of-MELPA" "lsp"
      :added "2023-06-02"
      :require t)
    )
  
  (leaf *rust
    :config
    
    (leaf rust-mode
      :doc "A major-mode for editing Rust source code"
      :req "emacs-25.1"
      :tag "languages" "emacs>=25.1"
      :url "https://github.com/rust-lang/rust-mode"
      :added "2023-04-19"
      :emacs>= 25.1
      :ensure t
      :hook (rust-mode . lsp)
      )

    (leaf cargo
      :doc "Emacs Minor Mode for Cargo, Rust's Package Manager."
      :req "emacs-24.3" "markdown-mode-2.4"
      :tag "tools" "emacs>=24.3"
      :added "2023-06-01"
      :emacs>= 24.3
      :ensure t
      :after markdown-mode
      :hook (rust-mode . cargo-minor-mode)
      :config (add-to-list 'exec-path (expand-file-name "~/.cargo/bin")))

    (leaf *lsp-rust
      :hook (rust-mode . lsp)
      :custom (lsp-rust-server . 'rust-analyzer))
    )
  
  (leaf *shellscript
    :config
    (leaf sh-mode :require nil)

    (leaf modern-sh
      :doc "Minor mode for editing shell script"
      :req "emacs-25.1" "hydra-0.15.0" "eval-in-repl-0.9.7"
      :tag "programming" "languages" "emacs>=25.1"
      :url "https://github.com/damon-kwok/modern-sh"
      :added "2023-04-20"
      :emacs>= 25.1
      :ensure t
      :require t
      :after hydra eval-in-repl
      :mode
      "\\.sh\\'"
      "\\.zsh\\'"
      :hook (sh-mode-hook . modern-sh-mode))
    
    (leaf flymake-shellcheck
      :doc "A bash/sh Flymake backend powered by ShellCheck"
      :req "emacs-26"
      :tag "emacs>=26"
      :url "https://github.com/federicotdn/flymake-shellcheck"
      :added "2023-02-13"
      :emacs>= 26
      :ensure t)
    )

  (leaf *typescript
    :config

    (leaf nodejs-repl
      :doc "Run Node.js REPL"
      :ensure t
      :require t)
    
    (leaf typescript-mode
      :doc "Major mode for editing typescript"
      :req "emacs-24.3"
      :tag "languages" "typescript" "emacs>=24.3"
      :url "http://github.com/ananthakumaran/typescript.el"
      :emacs>= 24.3
      :ensure t :require t
      :mode "\\.ts\\'" "\\.tsx\\'" "\\.mts\\'")
    
    (leaf tide
      :doc "Typescript Interactive Development Environment"
      :req "emacs-25.1" "dash-2.10.0" "s-1.11.0" "flycheck-27" "typescript-mode-0.1" "cl-lib-0.5"
      :tag "typescript" "emacs>=25.1"
      :url "http://github.com/ananthakumaran/tide"
      :emacs>= 25.1
      :ensure t :require t
      :after flycheck typescript-mode
      :hook
      (typescript-mode-hook . my/tide-start)
      (before-save-hook . tide-format-before-save)
      :custom
      (tide-node-executable . "~/.asdf/installs/nodejs/19.0.0/bin/node")
      :config
      (defun my/tide-start ()
	(interactive)
	(tide-setup)
	(flycheck-mode t)
	(setq flycheck-check-syntax-automatically '(save mode-enabled))
	(eldoc-mode t)
	(tide-hl-identifier-mode t)
	(company-mode t)))

    (leaf vue-mode
      :doc "Major mode for vue component based on mmm-mode"
      :req "mmm-mode-0.5.5" "vue-html-mode-0.2" "ssass-mode-0.2" "edit-indirect-0.1.4"
      :tag "languages"
      :added "2023-02-26"
      :ensure t
      :after mmm-mode vue-html-mode ssass-mode edit-indirect))

  (leaf vhdl-mode
    :doc "major mode for editing VHDL code"
    :tag "builtin" "nand2tetris"
    :added "2022-08-28"
    :require t
    :mode "\\.hdl$")

  )

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *visual
  :config

  (leaf all-the-icons
    :doc "A library for inserting Developer icons"
    :req "emacs-24.3"
    :tag "lisp" "convenient" "emacs>=24.3"
    :url "https://github.com/domtronn/all-the-icons.el"
    :emacs>= 24.3
    :ensure t :require t
    :require t
    :config
    
    (leaf all-the-icons-dired
      :doc "Shows icons for each file in dired mode"
      :req "emacs-24.4" "all-the-icons-2.2.0"
      :tag "dired" "icons" "files" "emacs>=24.4"
      :url "https://github.com/wyuenho/all-the-icons-dired"
      :emacs>= 24.4
      :ensure t :require t
      :after all-the-icons
      :hook (dired-mode . all-the-icons-dired-mode))
    
    (leaf all-the-icons-ivy
      :doc "Shows icons while using ivy and counsel"
      :req "emacs-24.4" "all-the-icons-2.4.0" "ivy-0.8.0"
      :tag "faces" "emacs>=24.4"
      :emacs>= 24.4
      :ensure t :require t
      :after all-the-icons ivy)
    
    (leaf all-the-icons-ivy-rich
      :doc "Better experience with icons for ivy"
      :req "emacs-25.1" "ivy-rich-0.1.0" "all-the-icons-2.2.0"
      :tag "ivy" "icons" "convenience" "emacs>=25.1"
      :url "https://github.com/seagle0128/all-the-icons-ivy-rich"
      :emacs>= 25.1
      :ensure t :require t
      :after ivy-rich all-the-icons
      :global-minor-mode t)
    )

  (leaf beacon
    :doc "Highlight the cursor whenever the window scrolls"
    :req "seq-2.14"
    :tag "convenience"
    :url "https://github.com/Malabarba/beacon"
    :ensure t :require t
    :global-minor-mode t
    :custom (beacon-color . "red"))

  (leaf centaur-tabs
    :doc "Aesthetic, modern looking customizable tabs plugin"
    :req "emacs-24.4" "powerline-2.4" "cl-lib-0.5"
    :tag "emacs>=24.4"
    :url "https://github.com/ema2159/centaur-tabs"
    :emacs>= 24.4
    :ensure t
    :require t
    :global-minor-mode t
    :custom
    (centaur-tabs-height . 30)
    (centaur-tabs-hide-tabs-hooks . nil)
    (centaur-tabs-set-icons . t)
    (centaur-tabs-set-bar . 'under)
    (x-underline-at-descent-line . t)
    (centaur-tabs-style . "bar")
    (centaur-tabs-set-modified-marker . t)
    (centaur-tabs-show-navigation-buttons . t)
    (centaur-tabs-adjust-buffer-order . t)
    (centaur-tabs-cycle-scope . 'groups)
    (centaur-tabs-buffer-groups-function . 'my/centaur-tabs-buffer-groups)
    :config
    (centaur-tabs-headline-match)
    (centaur-tabs-enable-buffer-reordering)
    (centaur-tabs-change-fonts "arial" 90)
    :preface
    (defun my/centaur-tabs-buffer-groups ()
      (list
       (cond
	((derived-mode-p 'eshell-mode 'term-mode 'shell-mode 'vterm-mode 'multi-term-mode 'dired-mode 'magit-mode)
	 "Terminal")
	((derived-mode-p 'emacs-lisp-mode)
	 "Emacs")
	((string-match-p (rx (or
			      "\*dashboard\*"
                              "\*tramp"
                              "\*Completions\*"
                              "\*sdcv\*"
                              "\*Messages\*"
                              "\*Ido Completions\*"
			      "\*scratch\*"
			      "\*Flycheck errors\*"
                              ))
			 (buffer-name))
	 "Emacs")
	((string-match-p (rx (or
			      "\*copilot events\*"
			      "\*copilot stderr\*"
                              ))
			 (buffer-name))
	 "Copilot")
	((string-match-p (rx (or
			      "\*clang-error\*"
			      "\*clang-output\*"
                              ))
			 (buffer-name))
	 "Clang")
	(t "Common")))))

  (leaf dashboard
    :doc "A startup screen extracted from Spacemacs"
    :req "emacs-26.1"
    :tag "dashboard" "tools" "screen" "startup" "emacs>=26.1"
    :url "https://github.com/emacs-dashboard/emacs-dashboard"
    :emacs>= 26.1
    :ensure t :require t
    :hook (after-init-hook . dashboard-setup-startup-hook)
    :bind
    (("<f3>" . open-dashboard)
     (:dashboard-mode-map ("<f3>" . quit-dashboard)))
    :custom
    (dashboard-items . '((bookmarks . 10)
			 (recents  . 10)))
    (initial-buffer-choice . (lambda () (get-buffer "*dashboard*")))
    (dashboard-center-content . t)
    (dashboard-set-heading-icons . t)
    (dashboard-set-file-icons . t)
    (dashboard-startup-banner . "~/.emacs.d/banner.png")
    (dashboard-banner-logo-title . "Kyure_A's Emacs")
    :config

    (setq dashboard-footer-messages-list (list '("「今日も一日がんばるぞい！」 - 涼風青葉")
					       '("「なんだかホントに入社した気分です！」 - 涼風青葉")
					       '("example")))
    
    (setq dashboard-footer-messages (nth (random (length dashboard-footer-messages-list)) dashboard-footer-messages-list))
    
    :preface

    (leaf open-dashboard
      :url "https://github.com/seagle0128/.emacs.d/blob/8cbec0c132cd6de06a8c293598a720d377f3f5b9/lisp/init-dashboard.el#L198"
      :preface
      (defun open-dashboard ()
	"Open the *dashboard* buffer and jump to the first widget."
	(interactive)
	;; Check if need to recover layout
	(if (length> (window-list-1)
                     ;; exclude `treemacs' window
                     (if (and (fboundp 'treemacs-current-visibility)
                              (eq (treemacs-current-visibility) 'visible))
			 2
                       1))
            (setq dashboard-recover-layout-p t))
	;; Display dashboard in maximized window
	(delete-other-windows)
	;; Refresh dashboard buffer
	(dashboard-refresh-buffer)
	;; Jump to the first section
	(dashboard-goto-recent-files)))

    (leaf quit-dashboard
      :url "https://github.com/seagle0128/.emacs.d/blob/8cbec0c132cd6de06a8c293598a720d377f3f5b9/lisp/init-dashboard.el#L219"
      :preface
      (defun quit-dashboard ()
	"Quit dashboard window."
	(interactive)
	(quit-window t)
	(and dashboard-recover-layout-p
             (and (bound-and-true-p winner-mode) (winner-undo))
             (setq dashboard-recover-layout-p nil))))
    )

  (leaf display-line-numbers
    :doc "interface for display-line-numbers"
    :tag "builtin"
    :config (custom-set-variables '(display-line-numbers-width-start t)))

  (leaf display-time
    :tag "builtin"
    :global-minor-mode t
    :custom
    (display-time-interval . 1)
    (display-time-string-forms . '((format "%s:%s:%s" 24-hours minutes seconds)))
    (display-time-day-and-date . t))

  (leaf emojify
    :doc "Display emojis in Emacs"
    :req "seq-1.11" "ht-2.0" "emacs-24.3"
    :tag "convenience" "multimedia" "emacs>=24.3"
    :url "https://github.com/iqbalansari/emacs-emojify"
    :emacs>= 24.3
    :ensure t :require t
    :hook (after-init . global-emojify-mode))

  (leaf fira-code-mode
    :doc "Minor mode for Fira Code ligatures using prettify-symbols"
    :req "emacs-24.4"
    :tag "programming-ligatures" "fonts" "ligatures" "faces" "emacs>=24.4"
    :url "https://github.com/jming422/fira-code-mode"
    :emacs>= 24.4
    :ensure t :require t
    :hook ;; (prog-mode-hook . fira-code-mode) ;; wsl2 だとバグる
    :custom (fira-code-mode-disabled-ligatures '("<>" "[]" "#{" "#(" "#_" "#_(" "x")))

  (leaf highlight-indent-guides
    :doc "Minor mode to highlight indentation"
    :req "emacs-24.1"
    :tag "emacs>=24.1"
    :url "https://github.com/DarthFennec/highlight-indent-guides"
    :emacs>= 24.1
    :ensure t :require t
    :hook
    (prog-mode-hook yaml-mode-hook)
    :custom
    (highlight-indent-guides-auto-enabled . t)
    (highlight-indent-guides-responsive . t)
    (highlight-indent-guides-method . 'character))

  (leaf highlight-symbol
    :doc "automatic and manual symbol highlighting"
    :tag "matching" "faces"
    :url "http://nschum.de/src/emacs/highlight-symbol/"
    :ensure t :require t
    :require t
    :hook (prog-mode-hook . highlight-symbol-mode)
    :custom (highlight-symbol-idle-delay . 0.1))

  (leaf neotree
    :doc "A tree plugin like NerdTree for Vim"
    :req "cl-lib-0.5"
    :url "https://github.com/jaypei/emacs-neotree"
    :ensure t :require t
    :custom
    (neo-smart-open . t)
    (neo-create-file-auto-open . t)
    (neo-theme . (if (display-graphic-p) 'icons 'arrow)))

  (leaf page-break-lines
    :doc "Display ^L page breaks as tidy horizontal lines"
    :req "emacs-24.4"
    :tag "faces" "convenience" "emacs>=24.4"
    :url "https://github.com/purcell/page-break-lines"
    :emacs>= 24.4
    :ensure t :require t
    :global-minor-mode global-page-break-lines-mode
    :require t
    :config
    (leaf-handler-package page-break-lines page-break-lines nil)
    (with-eval-after-load 'page-break-lines
      (blackout 'page-break-lines-mode ""))
    (set-fontset-font "fontset-default"
		      (cons page-break-lines-char page-break-lines-char)
		      (face-attribute 'default :family)))

  (leaf rainbow-delimiters
    :doc "Highlight brackets according to their depth"
    :tag "tools" "lisp" "convenience" "faces"
    :url "https://github.com/Fanael/rainbow-delimiters"
    :ensure t :require t
    :hook (prog-mode-hook))

  (leaf rainbow-mode
    :doc "Colorize color names in buffers"
    :tag "faces"
    :url "https://elpa.gnu.org/packages/rainbow-mode.html"
    :ensure t :require t
    :hook (web-mode-hook))

  (leaf solaire-mode
    :doc "make certain buffers grossly incandescent"
    :req "emacs-25.1" "cl-lib-0.5"
    :tag "faces" "buffer" "window" "bright" "dim" "emacs>=25.1"
    :url "https://github.com/hlissner/emacs-solaire-mode"
    :emacs>= 25.1
    :ensure t :require t
    :global-minor-mode solaire-global-mode)

  (leaf yascroll
    :doc "Yet Another Scroll Bar Mode"
    :req "emacs-26.1"
    :tag "convenience" "emacs>=26.1"
    :url "https://github.com/emacsorphanage/yascroll"
    :emacs>= 26.1
    :ensure t :require t
    :global-minor-mode global-yascroll-bar-mode)

  )

;; ---------------------------------------------------------------------------------------------- ;;

(unless (file-exists-p "~/.emacs.d/.tmp/first-startup-over")
  (make-empty-file "~/.emacs.d/.tmp/first-startup-over")
  (fira-code-mode-install-fonts t)
  (all-the-icons-install-fonts t))

(provide 'init)

;; End:
;;; init.el ends here
