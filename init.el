;;; init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/Kyure_A>
;; Maintainer: Kyure_A <twitter.com/Kyure_A>

;;; Commentary:

;; Coding rule:

;; なるべく setq/setf は custom でドット対のリストに書き換える
;; global-map にセットするキーバインドは *global-set-key ブロックに書く
;; 各マイナーモードの active-map にセットするキーバインドは各マイナーモードのブロックに書く
;; 各マイナーモードを有効化するときは global-minor-mode 節に書く

;; todo:
;; [] magit-status を centaur-tabs で使えるようにする
;; [] emacs>= を追加する（C++ までした）

;;; Code:

(leaf *global-set-key
  :bind
  ;; C-c
  ("C-c e b" . my/reload-init-el)
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
  ("<f5>" . my/quickrun-sc)
  ("RET" . smart-newline)
  ("C-<return>" . newline)
  ("C-<space>" . nil)
  ("<backspace>" . smart-hungry-delete-backward-char)
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

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
    (kill-line (- 1 arg)))
  
  )



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

  (leaf lisp-interaction
    :bind
    (:lisp-interaction-mode-map ("C-j" . eval-print-last-sexp)))
  
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
    :ensure t
    :config
    (leaf pos-tip
      :doc "Show tooltip at point"
      :tag "tooltip"
      :ensure t))
  
  (leaf recentf
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
      :ensure t))

  (leaf save-place-mode :global-minor-mode t)
  
  )



(leaf *inbox
  :doc "分類が面倒なパッケージを入れる"
  :config
  
  (leaf dash
    :doc "A modern list library for Emacs"
    :req "emacs-24"
    :tag "lisp" "extensions" "emacs>=24"
    :url "https://github.com/magnars/dash.el"
    :emacs>= 24
    :ensure t)

  (leaf fast-scroll
    :doc "Some utilities for faster scrolling over large buffers."
    :req "emacs-25.1" "cl-lib-0.6.1"
    :tag "scrolling" "scroll" "fast" "convenience" "ahungry" "emacs>=25.1"
    :url "https://github.com/ahungry/fast-scroll"
    :emacs>= 25.1
    :ensure t
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
    :ensure t
    :hook (after-init-hook . gcmh-mode)
    :custom (gcmh-verbose . t))

  (leaf goto-address :tag "builtin" :global-minor-mode t :hook (prog-mode-hook . goto-address-prog-mode))

  (leaf promise
    :doc "Promises/A+"
    :req "emacs-25.1"
    :tag "convenience" "promise" "async" "emacs>=25.1"
    :url "https://github.com/chuntaro/emacs-promise"
    :emacs>= 25.1
    :ensure t)
  
  (leaf s
    :doc "The long lost Emacs string manipulation library."
    :tag "strings"
    :ensure t)

  (leaf sublimity
    :doc "smooth-scrolling, minimap and distraction-free mode"
    :req "emacs-26.1"
    :tag "emacs>=26.1"
    :url "https://github.com/zk-phi/sublimity"
    :emacs>= 26.1
    :ensure t
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
  
  (leaf zone :doc "screen-saver" :tag "builtin" :require t :config (zone-when-idle 1200))
  
  )



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
    :ensure t
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
    (leaf company-anywhere :el-get zk-phi/company-anywhere :require t)
    (leaf company-box :ensure t :hook ((company-mode-hook . company-box-mode))
      :custom (company-box-icons-alist . 'company-box-icons-all-the-icons) (company-box-doc-enable . nil))
    (leaf company-statistics :ensure t :global-minor-mode t :hook (after-init-hook))
    (leaf company-posframe :ensure t :global-minor-mode t)
    (leaf company-quickhelp :require t :ensure t :global-minor-mode t :custom (company-quickhelp-delay . 0.1)))

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
      :ensure t)
    
    (leaf dired-k
      :doc "Highlight dired by size, date, git status"
      :req "emacs-24.3"
      :tag "emacs>=24.3"
      :url "https://github.com/emacsorphanage/dired-k"
      :emacs>= 24.3
      :ensure t
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

  (leaf flycheck
    :doc "On-the-fly syntax checking"
    :req "dash-2.12.1" "pkg-info-0.4" "let-alist-1.0.4" "seq-1.11" "emacs-24.3"
    :tag "tools" "languages" "convenience" "emacs>=24.3"
    :url "http://www.flycheck.org"
    :emacs>= 24.3
    :ensure t
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
    :ensure t
    :after lv
    
    :config
    
    (leaf hydra-posframe
      :doc "Display hydra diagnostics at point"
      :req "emacs-26.1" "hydra-0.14.0" "posframe-1.1.4"
      :tag "out-of-MELPA" "tools" "languages" "convenience" "emacs>=26.1"
      :url "https://github.com/Ladicle/hydra-posframe"
      :emacs>= 26.1
      :el-get Ladicle/hydra-posframe
      :after hydra posframe
      :require t))

  (leaf *ivy
    :config

    (leaf counsel
      :doc "Various completion functions using Ivy"
      :req "emacs-24.5" "ivy-0.13.4" "swiper-0.13.4"
      :tag "tools" "matching" "convenience" "emacs>=24.5"
      :url "https://github.com/abo-abo/swiper"
      :emacs>= 24.5
      :ensure t
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
	    (apply #'read-file-name-default args)))))
    
    (leaf ivy
      :doc "Incremental Vertical completYon"
      :req "emacs-24.5"
      :tag "matching" "emacs>=24.5"
      :url "https://github.com/abo-abo/swiper"
      :emacs>= 24.5
      :ensure t
      :global-minor-mode t
      :custom
      (ivy-use-virtual-buffers . t)
      (ivy-wrap . t)
      (ivy-extra-directories . t)
      (enable-recursive-minibuffers . t)
      :config
      (leaf ivy-rich :ensure t :global-minor-mode t)
      (leaf all-the-icons-ivy-rich :ensure t :global-minor-mode t)
      (leaf ivy-posframe :ensure t :global-minor-mode t
	:custom (ivy-posframe-display-functions-alist . '((t . ivy-posframe-display-at-frame-center)))))

    (leaf swiper
      :doc "Isearch with an overview. Oh, man!"
      :req "emacs-24.5" "ivy-0.13.4"
      :tag "matching" "emacs>=24.5"
      :url "https://github.com/abo-abo/swiper"
      :emacs>= 24.5
      :ensure t
      :after ivy))

  (leaf mwim
    :doc "Switch between the beginning/end of line or code (enhanced C-a, C-e)"
    :tag "convenience"
    :url "https://github.com/alezost/mwim.el"
    :ensure t)
  
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
    :custom
    (display-buffer-function . 'popwin:display-buffer)
    (popwin:special-display-config  . t)
    (popwin:popup-window-position . 'bottom))
  
  (leaf smart-hungry-delete
    :doc "smart hungry deletion of whitespace"
    :req "emacs-24.3"
    :tag "convenience" "emacs>=24.3"
    :url "https://github.com/hrehfeld/emacs-smart-hungry-delete"
    :emacs>= 24.3
    :ensure t
    :config (smart-hungry-delete-add-default-hooks))

  (leaf smart-newline
    :doc "Provide smart newline for one keybind."
    :url "https://ainame.hateblo.jp/entry/2013/12/08/162032"
    :ensure t
    :require t)

  (leaf smartparens
    :doc "Automatic insertion, wrapping and paredit-like navigation with user defined pairs."
    :req "dash-2.13.0" "cl-lib-0.3"
    :tag "editing" "convenience" "abbrev"
    :url "https://github.com/Fuco1/smartparens"
    :ensure t
    :require t
    :global-minor-mode smartparens-global-mode show-smartparens-global-mode
    :config
    (leaf smartparens-config :require t :after smartparens :hook (web-mode-hook . (lambda () (sp-pair "<#" "#>")))))

  (leaf undohist
    :doc "Persistent undo history for GNU Emacs"
    :req "cl-lib-1.0"
    :tag "convenience"
    :ensure t
    :require t
    :custom
    (undohist-directory . "~/.emacs.d/.tmp/undo-history")
    (undohist-ignored-files . '("/.tmp/" "COMMIT_EDITMSG" "/elpa"))
    :config
    (undohist-initialize))

  (leaf undo-tree
    :doc "Treat undo history as a tree"
    :req "queue-0.2" "emacs-24.3"
    :tag "tree" "history" "redo" "undo" "files" "convenience" "emacs>=24.3"
    :url "https://www.dr-qubit.org/undo-tree.html"
    :emacs>= 24.3
    :ensure t
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
    :ensure t
    :config
    (leaf visual-regexp-steroids
      :doc "Extends visual-regexp to support other regexp engines"
      :req "visual-regexp-1.1"
      :tag "feedback" "visual" "python" "replace" "regexp" "foreign" "external"
      :url "https://github.com/benma/visual-regexp-steroids.el/"
      :ensure t
      :after visual-regexp))

  (leaf which-function-mode :tag "builtin" :custom (which-function-mode . t))

  (leaf which-key
    :doc "Display available keybindings in popup"
    :req "emacs-24.4"
    :tag "emacs>=24.4"
    :url "https://github.com/justbur/emacs-which-key"
    :emacs>= 24.4
    :ensure t
    :global-minor-mode t
    :config (which-key-setup-side-window-bottom))
  
  (leaf yafolding
    :doc "Folding code blocks based on indentation"
    :tag "folding"
    :ensure t
    :hook (prog-mode-hook . yafolding-mode))

  (leaf yasnippet
    :doc "Yet another snippet extension for Emacs"
    :req "cl-lib-0.5"
    :tag "emulation" "convenience"
    :url "http://github.com/joaotavora/yasnippet"
    :ensure t
    :global-minor-mode yas-global-mode yas-minor-mode
    :custom
    (yas-snippet-dirs . '("~/.emacs.d/snippets"))
    :confi
    (leaf ivy-yasnippet
      :doc "yas-insert-snippet よりスニペットの挿入が可視化されるため見やすい"
      :doc "Preview yasnippets with ivy"
      :req "emacs-24.1" "cl-lib-0.6" "ivy-0.10.0" "yasnippet-0.12.2" "dash-2.14.1"
      :tag "convenience" "emacs>=24.1"
      :url "https://github.com/mkcms/ivy-yasnippet"
      :emacs>= 24.1
      :ensure t
      :after ivy yasnippet)
    (leaf yatemplate
      :doc "File templates with yasnippet"
      :req "yasnippet-0.8.1" "emacs-24.3"
      :tag "convenience" "files" "emacs>=24.3"
      :url "https://github.com/mineo/yatemplate"
      :emacs>= 24.3
      :ensure t
      :after yasnippet
      :config (leaf auto-insert-mode :tag "builtin" :global-minor-mode t) (yatemplate-fill-alist)))
  
  )



(leaf *programming
  :config

  (leaf copilot
    :doc "An unofficial Copilot plugin for Emacs"
    :req "emacs-27.2" "s-1.12.0" "dash-2.19.1" "editorconfig-0.8.2" "jsonrpc-1.0.14"
    :tag "out-of-MELPA" "emacs>=27.2"
    :emacs>= 27.2
    :el-get "zerolfx/copilot.el"
    :after editorconfig jsonrpc
    :require t
    :hook (prog-mode . copilot-mode)
    :custom (copilot-node-executable . "~/.asdf/installs/nodejs/17.9.1/bin/node")
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
    :ensure t
    :after nadvice
    :global-minor-mode t)

  (leaf lsp-mode
    :url "https://blog.medalotte.net/archives/473"
    :tag "lsp"
    :ensure t
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
    :ensure t
    :after compat git-commit magit-section with-editor
    :hook (magit-status-mode . my/toggle-centaur-tabs-local-mode))
  
  (leaf oj
    :doc "Competitive programming tools client for AtCoder, Codeforces"
    :req "emacs-26.1" "quickrun-2.2"
    :tag "convenience" "emacs>=26.1"
    :url "https://github.com/conao3/oj.el"
    :emacs>= 26.1
    :ensure t
    :custom
    (oj-shell-program . "zsh")
    (oj-open-home-dir . "~/oj-files/")
    (oj-default-online-judge . 'atcoder)
    (oj-compiler-c . "gcc")
    (oj-compiler-python . "cpython"))
  
  (leaf quickrun
    :doc "Run commands quickly"
    :req "emacs-24.3"
    :tag "emacs>=24.3"
    :url "https://github.com/syohex/emacs-quickrun"
    :emacs>= 24.3
    :ensure t
    :config
    (push '("*quickrun*") popwin:special-display-config)
    :preface
    (defun my/quickrun-sc (start end)
      (interactive "r")
      (if mark-active
	  (quickrun :start start :end end)
	(quickrun))))

  (leaf vterm
    :doc "Fully-featured terminal emulator"
    :req "emacs-25.1"
    :tag "terminals" "emacs>=25.1"
    :url "https://github.com/akermu/emacs-libvterm"
    :emacs>= 25.1
    :ensure t
    :custom
    (vterm-max-scrollback . 5000)
    (vterm-buffer-name-string . "vterm: %s")
    (vterm-keymap-exceptions
     . '("<f1>" "<f2>" "<f10>" "C-<return>" "C-<prior>" "C-<next>" "C-c" "C-g" "C-l" "C-s" "C-u" "C-v" "C-w" "C-x" "C-y" "M-v" "M-w" "M-x" "M-y"))
    (vterm-toggle--vterm-buffer-p-function . 'my/term-mode-p)
    :config
    (leaf vterm-toggle :ensure t)
    :preface
    (defun my/term-mode-p(&optional args)
      (derived-mode-p 'eshell-mode 'term-mode 'shell-mode 'vterm-mode 'multi-term-mode)))

  (leaf *C++
    :config
    
    (leaf cc-mode
      :doc "user customization variables for CC Mode"
      :tag "builtin"
      :hook
      (c-mode . (lambda () (setq c-basic-offset 8) (indent-tabs-mode . nil)))
      (c++-mode . (lambda () (setq c-basic-offset 8) (indent-tabs-mode . nil)))
      :custom
      (c-tab-always-indent . t))
    
    (leaf ccls
      :ensure t
      :hook ((c-mode c++-mode objc-mode) . (lambda () (require 'ccls) (lsp)))
      :config
      (ccls-executable "/usr/bin/ccls")
      (ccls-sem-highlight-method 'font-lock)
      (ccls-use-default-rainbow-sem-highlight))
    
    (leaf google-c-style
      :doc "Google's C/C++ style for c-mode"
      :tag "tools" "c"
      :ensure t
      :hook ((c-mode c++-mode) . (lambda () (google-set-c-style)))))

  (leaf *dart
    :config
    
    (leaf dart-mode
      :ensure t
      :hook (dart-mode-hook . flycheck-mode)
      :custom
      (dart-enable-analysis-server . t))
    
    (leaf lsp-dart
      :ensure t
      :commands lsp
      :hook ((dart-mode-hook . lsp))
      :config
      (dap-register-debug-template "Flutter :: Custom debug"
				   (list :flutterPlatform "x86_64" :program "lib/main_debug.dart" :args
					 '("--flavor" "customer_a")))))

  (leaf *typescript
    :config
    
    (leaf typescript-mode :ensure t :mode "\\.ts\\'" "\\.tsx\\'")
    
    (leaf tide
      :ensure t
      :hook
      (typescript-mode-hook . my/tide-start)
      (before-save-hook . tide-format-before-save)
      :config
      (defun my/tide-start ()
	(interactive)
	(tide-setup)
	(flycheck-mode t)
	(setq flycheck-check-syntax-automatically '(save mode-enabled))
	(eldoc-mode t)
	(tide-hl-identifier-mode t)
	(company-mode t))))

  (leaf *mark-up
    :config
    
    (leaf csv-mode :ensure t :mode "\\.csv\\'")
    
    (leaf markdown-mode
      :url "https://qiita.com/harumaki6511/items/45265a3113d40828d920"
      :commands markdown-mode
      :mode (("\\.md\\'" . gfm-mode)
	     ("\\.markdown\\'" . gfm-mode))
      :custom
      (markdown-command . "github-markup")
      (markdown-command-needs-filename . t)
      (markdown-content-type . "application/xhtml+xml")
      (markdown-css-paths . '("https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"))
      (markdown-xhtml-header-content . "\n<style>\nbody {\n  box-sizing: border-box;\n  max-width: 740px;\n  width: 100%;\n  margin: 40px auto;\n  padding: 0 10px;\n}\n</style>\n<script>\ndocument.addEventListener('DOMContentLoaded', () => {\n  document.body.classList.add('markdown-body');\n});\n</script>\n"))

    (leaf org-mode
      :custom
      (org-directory . "~/document/org")
      (org-startup-truncated . nil)
      (org-enforce-todo-dependencies . t)
      :config
      (leaf org-beautify-theme :ensure t :config (load-theme 'org-beautify t))
      (leaf org-modern :ensure t :hook (org-mode-hook . org-modern-mode) (org-agenda-finalize-hook . org-modern-agenda)))
    
    (leaf yatex
      :doc "jis=2, UTF-8=4"
      :ensure t
      :mode "\\.tex$"
      :custom
      (YaTeX-nervous . nil)
      (latex-message-kanji-code . 4)
      (YaTeX-kanji-code . 4)
      (YaTeX-coding-system . 4)))

  (leaf *web
    :config
    
    (leaf request :ensure t)
    
    (leaf skewer-mode :ensure t :doc "M-x run-skewer")
    
    (leaf web-mode
      :ensure t
      :mode
      "\\.[agj]sp\\'"
      "\\.as[cp]x\\'"
      "\\.djhtml\\'"
      "\\.ejs\\'"
      "\\.erb\\'"
      "\\.html?$\\'"
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
      (put 'web-mode-markup-indent-offset 'safe-local-variable 'integerp)))

  (leaf elpy
    :tag "Python"
    :ensure t
    :init
    (elpy-enable)
    :config
    (remove-hook 'elpy-modules 'elpy-module-highlight-indentation) ;; インデントハイライトの無効化
    (remove-hook 'elpy-modules 'elpy-module-flymake) ;; flymakeの無効化
    :custom
    (elpy-rpc-python-command . "python3") ;; https://mako-note.com/ja/elpy-rpc-python-version/の問題を回避するための設定
    (flycheck-python-flake8-executable . "flake8")
    :bind (elpy-mode-map
           ("C-c C-r f" . elpy-format-code))
    :hook ((elpy-mode-hook . flycheck-mode)))

  (leaf sly
    :tag "Common Lisp"
    :ensure t
    :custom (inferior-lisp-program . "/usr/bin/sbcl")
    :config
    ;; (load "~/.roswell/helper.el")
    ;; (leaf sly-autoloads :require t)
    (defun my/sly-start ()
      "sly の挙動を slime に似せる"
      (interactive)
      (split-window-right)
      (sly)))

  )



(leaf *visual
  :config

  (leaf all-the-icons
    :ensure t
    :config
    (leaf all-the-icons-dired :ensure t :hook (dired-mode . all-the-icons-dired-mode))
    (leaf all-the-icons-ivy :ensure t))

  (leaf beacon
    :ensure t
    :global-minor-mode t
    :custom (beacon-color . "red"))

  (leaf centaur-tabs
    :ensure t
    :require t
    :global-minor-mode t
    :custom
    (centaur-tabs-height . 30)
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
    :ensure t
    :init (dashboard-setup-startup-hook)
    :bind
    ("<f10>" . open-dashboard)
    (:dashboard-mode-map
     ("<f10>" . quit-dashboard))
    :custom
    (dashboard-items . '((bookmarks . 10)
			 (recents  . 5)))
    (initial-buffer-choice . (lambda () (get-buffer "*dashboard*")))
    (dashboard-center-content . t)
    (dashboard-set-heading-icons . t)
    (dashboard-set-file-icons . t)
    (dashboard-startup-banner . "~/.emacs.d/banner.png")
    (dashboard-banner-logo-title . "Kyure_A's Emacs")
    :config
    (leaf projectile :ensure t)
    :preface
    (leaf dashboard-goto-recent-files
      :url "https://qiita.com/minoruGH/items/b47430af6537ee69c6ef"
      :preface
      (defun dashboard-goto-recent-files ()
	"Go to recent files."
	(interactive)
	(funcall (local-key-binding "r"))))

    (leaf open-dashboard
      :url "https://qiita.com/minoruGH/items/b47430af6537ee69c6ef"
      :preface
      (defun open-dashboard ()
	"Open the *dashboard* buffer and jump to the first widget."
	(interactive)
	(delete-other-windows)
	;; Refresh dashboard buffer
	(if (get-buffer dashboard-buffer-name)
	    (kill-buffer dashboard-buffer-name))
	(dashboard-insert-startupify-lists)
	(switch-to-buffer dashboard-buffer-name)
	;; Jump to the first section
	(goto-char (point-min))
	(dashboard-goto-recent-files)))

    (leaf quit-dashboard
      :url "https://qiita.com/minoruGH/items/b47430af6537ee69c6ef"
      :preface
      (defun quit-dashboard ()
	"Quit dashboard window."
	(interactive)
	(quit-window t)
	(when (and dashboard-recover-layout-p
		   (bound-and-true-p winner-mode))
	  (winner-undo)
	  (setq dashboard-recover-layout-p nil)))))
  
  (leaf display-line-numbers :config (custom-set-variables '(display-line-numbers-width-start t)))

  (leaf display-time
    :global-minor-mode t
    :custom
    (display-time-interval . 1)
    (display-time-string-forms . '((format "%s:%s:%s" 24-hours minutes seconds)))
    (display-time-day-and-date . t))

  (leaf emojify :ensure t :hook (after-init . global-emojify-mode))
  
  (leaf fira-code-mode
    :ensure t
    :hook ;; (prog-mode-hook . fira-code-mode) ;; wsl2 だとバグる
    :custom (fira-code-mode-disabled-ligatures '("<>" "[]" "#{" "#(" "#_" "#_(" "x")))
  
  (leaf highlight-indent-guides
    :ensure t
    :hook
    (prog-mode-hook yaml-mode-hook)
    :custom
    (highlight-indent-guides-auto-enabled . t)
    (highlight-indent-guides-responsive . t)
    (highlight-indent-guides-method . 'character))

  (leaf highlight-symbol
    :ensure t
    :require t
    :hook (prog-mode-hook . highlight-symbol-mode)
    :custom (highlight-symbol-idle-delay . 0.1))

  (leaf neotree
    :ensure t
    :custom
    (neo-smart-open . t)
    (neo-create-file-auto-open . t)
    (neo-theme . (if (display-graphic-p) 'icons 'arrow)))
  
  (leaf page-break-lines
    :ensure t
    :global-minor-mode global-page-break-lines-mode
    :require t
    :config
    (leaf-handler-package page-break-lines page-break-lines nil)
    (with-eval-after-load 'page-break-lines
      (blackout 'page-break-lines-mode ""))
    (set-fontset-font "fontset-default"
		      (cons page-break-lines-char page-break-lines-char)
		      (face-attribute 'default :family)))
  
  (leaf rainbow-delimiters :ensure t :hook (prog-mode-hook))

  (leaf rainbow-mode :ensure t :hook (web-mode-hook))

  (leaf solaire-mode
    :doc "使っていないバッファの色を少し暗くする"
    :ensure t
    :global-minor-mode solaire-global-mode)
  
  (leaf yascroll :ensure t :global-minor-mode global-yascroll-bar-mode)

  )



(unless (file-exists-p "~/.emacs.d/.tmp/first-startup-over")
  (make-empty-file "~/.emacs.d/.tmp/first-startup-over")
  (fira-code-mode-install-fonts t)
  (all-the-icons-install-fonts t))

(provide 'init)

;; End:
;;; init.el ends here
