;;; init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/Kyure_A>
;; Maintainer: Kyure_A <twitter.com/Kyure_A>

;;; Commentary:

;; Coding rule:

;; As much as possible, replace setq/setf as a list of dot pairs using ":custom".
;; Keybindings to be set in the global-map are written in the "(leaf *global-set-key)" section.
;; and keybindings to be set only in the active-map of each minor-mode are written in the "(leaf *minor-mode*)" section.
;; The configuration of a package to make it more extensible should be written (on one line as much as possible) in "(leaf *package*) using :config".
;; To use the package in .emacs.d/elisp, need to ":require t".
;; Use ":global-minor-mode" to make it clear when enabling minor modes.
;; I gave up writing init.el in English.
;; これから日本語で書きます

;; Todo:
;; [] Add whitespace-mode
;; [] centaur-tab will available in *help buffer

;;; Code:

(leaf *global-set-key
  :bind
  ;; C-c
  ("C-c e b" . reload)
  ("C-c e m" . menu-bar-mode)
  ("C-c l c" . leaf-convert-region-replace)
  ("C-c l t" . leaf-tree-mode)
  ("C-c m" . macrostep-mode)
  ("C-c o" . org-capture)
  ("C-c s" . sly-start)
  ("C-c t" . centaur-tabs-counsel-switch-group)
  ;; C-x
  ("C-x g" . magit-status)
  ("C-x M-g" . magit-dispatch-popup)
  ("C-x i" . nil)
  ("C-x i i" . ivy-yasnippet)
  ("C-x i n" . ivy-yasnippet-new-snippet)
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
  ("C-u" . undo)
  ("C-r" . redo)
  ("C-s" . swiper)
  ("C-<shift>-s" . second-sight)
  ("C-t" . multi-term)
  ("C-/" . other-window)
  ;; M-<any>
  ("M-x" . counsel-M-x)
  ;; Modifier key
  ("RET" . smart-newline)
  ("C-<return>" . newline)
  ("C-<space>" . nil)
  ("<backspace>" . smart-hungry-delete-backward-char)
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  :preface
  (defun reload ()
    "C-c e b"
    (interactive)
    (eval-buffer)
    (remove-warnings-buffer)
    (remove-messages-buffer))
  (defun sly-start ()
    "sly の挙動を slime に似せる"
    (interactive)
    (split-window-right)
    (sly))
  (defun remove-scratch-buffer ()
    (if (get-buffer "*scratch*")
	(kill-buffer "*scratch*")))
  (defun remove-completions-buffer ()
    (if (get-buffer "*Completions*")
        (kill-buffer "*Completions*")))
  (defun remove-messages-buffer ()
    (if (get-buffer "*Messages*")
        (kill-buffer "*Messages*")))
  (defun remove-warnings-buffer ()
    (if (get-buffer "*Warnings*")
        (kill-buffer "*Warnings*")))
  )



(leaf *built-in
  :doc "結構適当"
  :config

  (leaf bytecomp
    :custom
    (byte-compile-warnings . '(not cl-functions obsolete))
    (debug-on-error . nil))

  (leaf cl-lib :require t)
  
  (leaf color :require t)
  
  (leaf cus-edit
    :tag "builtin"
    :url "https://emacs-jp.github.io/tips/emacs-in-2020"
    :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

  (leaf dired
    :bind
    (:dired-mode-map
     ("RET" . dired-open-in-accordance-with-situation)
     ("<right>" . dired-open-in-accordance-with-situation)
     ("<left>" . dired-up-directory)
     ("a" . dired-find-file))
    :config
    (leaf dired-toggle :ensure t)
    (leaf dired-k :hook (dired-initial-position-hook . dired-k) :ensure t)
    (put 'dired-find-alternate-file 'disabled nil)
    :preface
    (defun dired-open-in-accordance-with-situation ()
      "https://nishikawasasaki.hatenablog.com/entry/20120222/1329932699"
      (interactive)
      (let ((file (dired-get-filename)))
	(if (file-directory-p file)
	    (dired-find-alternate-file)
	  (dired-find-file)))))

  (leaf display-line-numbers
    :emacs<= "26.0"
    :global-minor-mode global-display-line-numbers-mode
    :config (custom-set-variables '(display-line-numbers-width-start t)))

  (leaf files
    :custom
    (backup-directory-alist . '((".*" . "~/.backup")))
    (create-lockfiles . nil)
    :config
    (let ((default-directory (locate-user-emacs-file "./elisp")))
      (add-to-list 'load-path default-directory)
      (normal-top-level-add-subdirs-to-load-path)))

  (leaf *frame
    :config
    (set-frame-parameter nil 'unsplittable t) ; なるべくスクリーンを分割しないようにする マウスを使うと新しくウインドウを開くのであんまりいい設定ではない
    )

  (leaf goto-address
    :global-minor-mode t
    :hook (prog-mode-hook . goto-address-prog-mode))

  (leaf hl-line :hook (emacs-startup-hook . global-hl-line-mode)) ; highlight
  
  (leaf mule-cmds
    :tag "builtin"
    :config
    (set-language-environment "Japanese")
    (prefer-coding-system 'utf-8)
    (set-default 'buffer-file-coding-system 'utf-8))

  (leaf mwheel
    :tag "builtin"
    :custom
    (mouse-wheel-progressive-speed . nil)
    (scroll-preserve-screen-position . 'always))

  (leaf recentf
    :tag "builtin"
    :global-minor-mode t
    :custom
    (recentf-max-saved-items . 150)
    (recentf-auto-cleanup . 'never)
    (recentf-exclude '("/recentf" "COMMIT_EDITMSG" "/.?TAGS" "^/sudo:" "/\\.emacs\\.d/games/*-scores" "/\\.emacs\\.d/\\.cask/"))
    :config
    (leaf recentf-ext :ensure t))

  (leaf save-place-mode :global-minor-mode t)

  (leaf startup
    :tag "builtin"
    :hook
    (window-setup-hook . delete-other-windows)
					;(after-change-major-mode-hook . remove-scratch-buffer)
					;(after-change-major-mode-hook . remove-messages-buffer)
					;(after-change-major-mode-hook . remove-warnings-buffer)
    (minibuffer-exit-hook . remove-completions-buffer)
    :custom
    (inhibit-startup-screen . t)
    (initial-scratch-message . nil)
    (inhibit-startup-buffer-menu . t)
    (message-log-max . nil)
    (ring-bell-function . 'ignore)
    )

  (leaf which-function-mode :custom (which-function-mode . t))
  
  )



(leaf *inbox
  :doc "分類が面倒なパッケージを入れる"
  :config
  
  (leaf *deepl-translate
    :commands my:deepl-translate
    :bind (("C-x T" . my:deepl-translate))
    :preface
    (require 'url-util)
    (defun my:deepl-translate (&optional string)
      (interactive)
      (setq string
            (cond ((stringp string) string)
                  ((use-region-p)
                   (buffer-substring (region-beginning) (region-end)))
                  (t
                   (save-excursion
                     (let (s)
                       (forward-char 1)
                       (backward-sentence)
                       (setq s (point))
                       (forward-sentence)
                       (buffer-substring s (point)))))))
      (run-at-time 0.1 nil 'deactivate-mark)
      (browse-url
       (concat
	"https://www.deepl.com/translator#en/ja/"
	(url-hexify-string string)
	)))
    )
  
  (leaf fast-scroll
    :ensure t
    :require t
    :global-minor-mode t
    :hook
    (fast-scroll-start-hook . (lambda () (flycheck-mode -1)))
    (fast-scroll-end-hook . (lambda () (flycheck-mode 1)))
    :custom
    (fast-but-imprecise-scrolling . t)
    (jit-lock-defer-time . 0)
    :config
    (fast-scroll-config))
  
  (leaf gcmh
    :ensure t
    :global-minor-mode t
    :custom (gcmh-verbose . t))

  (leaf leaf
    :require t
    :config
    (leaf leaf-keywords :ensure t :init (leaf-keywords-init))
    (leaf leaf-convert :ensure t)
    (leaf leaf-tree :ensure t :custom (imenu-list-size . 30) (imenu-list-position . 'left)))

  (leaf magit :ensure t)

  (leaf multi-term
    :ensure t
    :bind (:term-raw-map ("C-y" . term-paste))
    :custom
    (multi-term-program . "/bin/zsh")
    (term-buffer-maximum-size . 10000)
    :config (add-to-list 'term-unbind-key-list '"M-x")
    )

  (leaf neotree
    :ensure t
    :custom
    (neo-smart-open . t)
    (neo-create-file-auto-open . t)
    (neo-theme . (if (display-graphic-p) 'icons 'arrow)))

  (leaf promise :ensure t)
  
  (leaf request :ensure t)

  (leaf sublimity
    :doc "smooth-scrolling"
    :el-get zk-phi/sublimity
    :global-minor-mode t
    :require t
    :config
    (leaf sublimity-scroll :require t
      :custom (sublimity-scroll-weight . 5) (sublimity-scroll-drift-length . 10))
    (leaf sublimity-attractive :require t
      :custom (sublimity-attractive-centering-width . 200)))

  (leaf undohist
    :ensure t
    :require t
    :custom
    (undohist-directory . "~/.emacs.d/undo-history")
    (undohist-ignored-files . '("/tmp/" "COMMIT_EDITMSG" "/elpa"))
    :config
    (undohist-initialize))
  
  )



(leaf *edit
  :doc "補完や構文のチェック, 入力に関するプラグイン"
  :config

  (leaf aggressive-indent
    :ensure t
    :global-minor-mode global-aggressive-indent-mode)

  (leaf company
    :tag "company"
    :ensure t
    :global-minor-mode global-company-mode
    :bind
    (:company-active-map ( "<tab>" . company-complete-common-or-cycle))
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
    (leaf company-quickhelp :require t :ensure t :global-minor-mode t :custom (company-quickhelp-delay . 0.1))
    (leaf pos-tip :ensure t))
  
  (leaf counsel
    :ensure t
    :global-minor-mode t
    :require t
    :bind
    (:counsel-mode-map ([remap find-file] . nil))
    :custom
    (counsel-find-file-ignore-regexp . (regexp-opt '("./" "../")))
    (read-file-name-function . #'disable-counsel-find-file)
    :preface
    (defun disable-counsel-find-file (&rest args)
      "Disable `counsel-find-file' and use the original `find-file' with ARGS."
      "https://qiita.com/takaxp/items/2fde2c119e419713342b#counsel-find-file-%E3%82%92%E4%BD%BF%E3%82%8F%E3%81%AA%E3%81%84"
      (let ((completing-read-function #'completing-read-default)
	    (completion-in-region-function #'completion--in-region))
	(apply #'read-file-name-default args)))
    :config
    (leaf counsel-flycheck
      :url "https://github.com/nathankot/dotemacs/blob/master/init.el#L709"
      (defvar counsel-flycheck-history nil
	"History for `counsel-flycheck'")
      (defun counsel-flycheck ()
	(interactive)
	(if (not (bound-and-true-p flycheck-mode))
	    (message "Flycheck mode is not available or enabled")
	  (ivy-read "Error: "
		    (let ((source-buffer (current-buffer)))
		      (with-current-buffer (or (get-buffer flycheck-error-list-buffer)
					       (progn
						 (with-current-buffer
						     (get-buffer-create flycheck-error-list-buffer)
						   (flycheck-error-list-mode)
						   (current-buffer))))
			(flycheck-error-list-set-source source-buffer)
			(flycheck-error-list-reset-filter)
			(revert-buffer t t t)
			(split-string (buffer-string) "\n" t " *")))
		    :action (lambda (s &rest _)
			      (-when-let* ( (error (get-text-property 0 'tabulated-list-id s))
					    (pos (flycheck-error-pos error)) )
				(goto-char (flycheck-error-pos error))))
		    :history 'counsel-flycheck-history))))
    )
  
  (leaf flycheck
    :ensure t
    :global-minor-mode global-flycheck-mode
    :bind (:flycheck-mode-map
	   ("M-n" . flycheck-next-error)
	   ("M-p" . flycheck-previous-error))
    :custom (flycheck-idle-change-delay . 0))

  (leaf hydra
    :ensure t
    :config
    (leaf hydra-posframe :el-get Ladicle/hydra-posframe :require t))

  (leaf ivy
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

  (leaf mwim :ensure t)

  (leaf paren
    :tag "builtin"
    :global-minor-mode show-paren-mode
    :custom
    (show-paren-delay . 0)
    (show-paren-style . 'expression))

  (leaf popwin
    :url "http://dev.ariel-networks.com/wp/archives/462"
    :doc "It's just copied and pasted from the URL."
    :ensure t
    :custom
    (display-buffer-function . 'popwin:display-buffer)
    (popwin:special-display-config  . t)
    (popwin:popup-window-position . 'bottom))

  (leaf redo+ :require t)

  (leaf second-sight :el-get blue0513/second-sight :require t)

  (leaf smart-hungry-delete
    :url "https://github.com/hrehfeld/emacs-smart-hungry-delete/pull/7/commits/f49bb37edfa19bd605b425f8f0fe285a1d00987e"
    :el-get black7375/emacs-smart-hungry-delete
    :require t
    :config (smart-hungry-delete-add-default-hooks))

  (leaf smart-newline
    :url "https://ainame.hateblo.jp/entry/2013/12/08/162032"
    :el-get ainame/smart-newline.el
    :require t)

  (leaf smartparens
    :doc "なんかうまく有効になっていない"
    :ensure t
    :require t
    :global-minor-mode smartparens-global-mode
    :config
    (leaf smartparens-config :require t :after smartparens :config (sp-pair "<" ">")))
  
  (leaf visual-regexp
    :doc "ビジュアライズされた置換"
    :ensure t
    :config (leaf visual-regexp-steroids :ensure t))

  (leaf which-key
    :ensure t
    :global-minor-mode t
    :config (which-key-setup-side-window-bottom))
  
  (leaf yasnippet
    :ensure t
    :global-minor-mode yas-global-mode yas-minor-mode
    :custom
    (yas-snippet-dirs . '("~/.emacs.d/snippets"))
    :config
    (leaf yasnippet-snippets :ensure t :doc "各言語用のテンプレート　多分 clone して自分のディレクトリに落としたほうがいい")
    (leaf ivy-yasnippet :ensure t :require t :doc "yas-insert-snippet よりスニペットの挿入が可視化されるため見やすい")
    (leaf yatemplate :ensure t :config (leaf auto-insert-mode :global-minor-mode t) (yatemplate-fill-alist)))
  
  )



(leaf *languages
  :doc "各言語のモード"
  :config

  (leaf ccls
    :tag "C++"
    :ensure t
    :hook ((c-mode c++-mode objc-mode) .(lambda () (require 'ccls) (lsp)))
    :config
    (ccls-executable "/usr/bin/ccls")
    (ccls-sem-highlight-method 'font-lock)
    (ccls-use-default-rainbow-sem-highlight))

  (leaf csv-mode :ensure t :mode "\\.csv\\'")

  (leaf elpy
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
    :hook ((elpy-mode-hook . flycheck-mode))
    )
  
  (leaf impatient-mode
    :tag "html"
    :ensure t)

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

  (leaf oj
    :doc "Competitive programming tools client for AtCoder, Codeforces"
    :req "emacs-26.1" "quickrun-2.2"
    :tag "convenience" "emacs>=26.1"
    :url "https://github.com/conao3/oj.el"
    :emacs>= 26.1
    :ensure t
    :custom ((oj-compiler-c . "clang")
             (oj-compiler-python . "cpython")
             (oj-default-online-judge . 'atcoder)))

  (leaf org-mode
    :tag "builtin"
    :hook (org-capture-after-finalize-hook . (lambda () (delete-frame)))
    :custom
    (org-directory . "~/document/org")
    (org-startup-truncated . nil)
    (org-enforce-todo-dependencies . t)
    :config
    (leaf org-beautify-theme :ensure t :config (load-theme 'org-beautify t))
    (leaf org-bullets :require t :ensure t :hook (org-mode-hook . (lambda () (org-bullets-mode 1))))
    )

  (leaf sly
    :tag "Common Lisp"
    :ensure t
    :custom (inferior-lisp-program . "/usr/bin/sbcl")
    :config ;(leaf sly-autoloads :require t) ;(leaf slime-autoloads :ensure t) ;(load "~/.roswell/helper.el")
    )

  (leaf web-mode
    :tag "html" "css"
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
    "\\.tsx?\\'"
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

  (leaf yatex
    :tag "TeX"
    :doc "jis=2, UTF-8=4"
    :ensure t
    :mode "\\.tex$"
    :custom
    (YaTeX-nervous . nil)
    (latex-message-kanji-code . 4)
    (YaTeX-kanji-code . 4)
    (YaTeX-coding-system . 4))

  )



(leaf *visual
  :doc "UI デザインを変化させるもの"
  :config

  (leaf all-the-icons
    :ensure t
    :config ;(all-the-icons-install-fonts t)
    (leaf all-the-icons-dired :ensure t :hook (dired-mode . all-the-icons-dired-mode))
    (leaf all-the-icons-ivy :ensure t))

  (leaf centaur-tabs
    :ensure t
    :require t
    :global-minor-mode t
    :hook
    (dashboard-mode . centaur-tabs-local-mode)
    (dired-mode . centaur-tabs-local-mode)
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
    :config
    (centaur-tabs-headline-match)
    (centaur-tabs-enable-buffer-reordering)
    (centaur-tabs-change-fonts "arial" 90))

  (leaf dashboard
    :url "https://qiita.com/minoruGH/items/b47430af6537ee69c6ef"
    :ensure t
    :init (dashboard-setup-startup-hook)
    :bind
    ("<f10>" . open-dashboard)
    (:dashboard-mode-map
     ("<f10>" . quit-dashboard))
    :custom
					;(dashboard-startup-banner . "~/.emacs.d/assets/banner.png")
    (dashboard-items . '((bookmarks . 10)
			 (recents  . 5)))
    (initial-buffer-choice . (lambda () (get-buffer "*dashboard*")))
    (dashboard-center-content . t)
    (dashboard-set-heading-icons . t)
    (dashboard-set-file-icons . t)
    (dashboard-banner-logo-title . "Kyure_A's Emacs")
    :config
    (leaf projectile :ensure t)
    :preface
    (defun dashboard-goto-recent-files ()
      "Go to recent files."
      (interactive)
      (funcall (local-key-binding "r")))
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
      (dashboard-goto-recent-files))
    (defun quit-dashboard ()
      "Quit dashboard window."
      (interactive)
      (quit-window t)
      (when (and dashboard-recover-layout-p
		 (bound-and-true-p winner-mode))
	(winner-undo)
	(setq dashboard-recover-layout-p nil)))
    )

  (leaf emojify
    :ensure t
    :hook (after-init . global-emojify-mode))

  (leaf fira-code-mode
    :doc "M-x fira-code-mode-install-fonts"
    :hook (prog-mode-hook)
    :custom (fira-code-mode-disabled-ligatures '("<>" "[]" "#{" "#(" "#_" "#_(" "x"))
    )
  
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

  (leaf rainbow-delimiters
    :ensure t
    :hook (prog-mode-hook))

  (leaf rainbow-mode
    :ensure t
    :hook (prog-mode-hook))

  (leaf yascroll
    :ensure t
    :doc ":global-minor-mode global-yascroll-bar-mode")

  )

(setq file-name-handler-alist my-saved-file-name-handler-alist)



(provide 'init)

;; End:
;;; init.el ends here
