;;; init.el ---  -*- lexical-binding: t -*-

;; Author: Kyure_A <twitter.com/@kyureq>
;; Maintainer: Kyure_A <twitter.com/@kyureq>

;;; Commentary:

;;              .mmmmmmmmmmmmmm.                   .cccccccc!                .(.
;;  .+eeeee.   .??:   +m<   <mm.    .aaaaaaaa.    ccC!           .+sssss{    (!!
;; .ee:        .mm:   +mm   .mm_   .aa>   (aaA    cCC           .ss>         1!:
;; .ee_        .mm:   +mm   .mm_   .aa{    aaA    ccC           .sss.        !!
;; .ee_ <ee    .mm:   +mm   .mm_   .aa{ .(AaaA    cCC`           .<sssss    .!:
;; .ee_        .mm:   +mm   .mm_   .aa{ .??aaA    cCCc......         .ss:   ..
;; .eee....    .<<!   ?<<   .<<`   .aa{    aaA     ?CCCCCCC!    ....(s=: .!!-
;;  .?eeeee`                       .AA!    AAA                  .ssss<s!   .!!

;;; Code:

(setq user-full-name "Kyure_A")
(setq user-mail-address "k@kyre.moe")

(defvar my/delayed-priority-high-configurations '())
(defvar my/delayed-priority-high-configuration-timer nil)

(defvar my/delayed-priority-low-configurations '())
(defvar my/delayed-priority-low-configuration-timer nil)

(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq my/delayed-priority-high-configuration-timer
		  (run-with-timer
		   0.1 0.001
		   (lambda ()
		     (if my/delayed-priority-high-configurations
			 (let ((inhibit-message t))
			   (eval (pop my/delayed-priority-high-configurations)))
		       (progn
			 (cancel-timer my/delayed-priority-high-configuration-timer))))))
	    (setq my/delayed-priority-low-configuration-timer
		  (run-with-timer
		   0.3 0.001
		   (lambda ()
		     (if my/delayed-priority-low-configurations
			 (let ((inhibit-message t))
			   (eval (pop my/delayed-priority-low-configurations)))
		       (progn
			 (cancel-timer my/delayed-priority-low-configuration-timer))))))))

(defmacro with-delayed-execution-priority-high (&rest body)
  (declare (indent 0))
  `(setq my/delayed-priority-high-configurations
	 (append my/delayed-priority-high-configurations ',body)))

(defmacro with-delayed-execution (&rest body)
  (declare (indent 0))
  `(setq my/delayed-priority-low-configurations
	 (append my/delayed-priority-low-configurations ',body)))

(leaf *global-set-key
  :bind

  ;; Modifier key
  ("<f2>" . vterm-toggle)
  ("<f3>". dashboard-open)
  ;; ("<f5>" . my/quickrun-sc)
  ("RET" . smart-newline)
  ("<backspace>" . smart-hungry-delete-backward-char)

  ;; C-<Modifer key>
  ("C-<backspace>" . backward-delete-word)
  ("C-<left>" . centaur-tabs-forward)
  ("C-<right>" . centaur-tabs-backward)
  ("C-<return>" . newline)
  ("C-SPC" . toggle-input-method)

  ;; C-x
  ("C-x g" . magit-status)
  ("C-x M-g" . magit-dispatch-popup)
  ("C-x i" . nil)
  ("C-x i i" . ivy-yasnippet)
  ("C-x i n" . yas-new-snippet)
  ("C-x u" . undo-tree-visualize)
  ("C-x C-z" . nil)
  ("C-x C-c" . nil)
  ;; C-c
  ("C-c C-f" . leaf-convert-insert-template)
  ("C-c e b" . eval-buffer)
  ("C-c e m" . menu-bar-mode)
  ("C-c l c" . leaf-convert-region-replace)
  ("C-c l t" . leaf-tree-mode)
  ("C-c o" . Kyure_A/open)
  ("C-c p" . smartparens-global-mode)
  ("C-c s" . Kyure_A/start-repl)
  ("C-c t" . centaur-tabs-counsel-switch-group)
  ("C-c r" . vr/replace)
  ;; C-l
  ("C-l" . nil)
  ("C-l C-l" . lsp)
  ;; C-<any>
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-d" . smart-hungry-delete-backward-char)
  ("C-e" . mwim-end-of-code-or-line)
  ("C-h" . smart-hungry-delete-backward-char)
  ;; ("C-j" . nil)
  ("C-m" . smart-newline)
  ("C-o" . nil)
  ("C-u" . undo-tree-undo)
  ("C-r" . undo-tree-redo)
  ("C-s" . swiper)
  ("C-z" . undo-tree-undo) ;; よく間違ってとまってかす
  ("C-/" . other-window)
  ("C-;" . smart-hungry-delete-forward-char)
  ;; M-<any>
  ("M-k" . backward-kill-line)
  ("M-x" . counsel-M-x)

  :config
  (fset 'yes-or-no-p 'y-or-n-p)
  (defalias 'yes-or-no-p 'y-or-n-p))

(leaf mwim
  :doc "Switch between the beginning/end of line or code (enhanced C-a, C-e)"
  :tag "convenience"
  :url "https://github.com/alezost/mwim.el"
  :ensure t :require t)

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
  :ensure t :require t)

(setq mouse-wheel-progressive-speed nil)
(setq scroll-preserve-screen-position 'always)

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

(leaf good-scroll
  :doc "Good pixel line scrolling"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/io12/good-scroll.el"
  :added "2022-09-09"
  :emacs>= 27.1
  :ensure t
  :require
  :global-minor-mode t)

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

(setq-default indent-tabs-mode nil)

(with-delayed-execution
  (save-place-mode t))

(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default 'buffer-file-coding-system 'utf-8)

(leaf delete-selection :doc "delete から overwrite に改名したほうがいい" :tag "builtin" :global-minor-mode delete-selection-mode)

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'after-save-hook '(lambda () (org-babel-tangle-file "~/.emacs.d/init.org" "~/.emacs.d/init.el" "emacs-lisp")))))

(leaf display-time
  :tag "builtin"
  :global-minor-mode t
  :custom
  (display-time-interval . 1)
  (display-time-string-forms . '((format "%s:%s:%s" 24-hours minutes seconds)))
  (display-time-day-and-date . t))

(leaf *emacs-lisp
  :doc "Emacs Lisp"
  :config

  (leaf async
    :doc "Asynchronous processing in Emacs"
    :req "emacs-24.4"
    :tag "async" "emacs>=24.4"
    :url "https://github.com/jwiegley/emacs-async"
    :added "2023-09-22"
    :emacs>= 24.4
    :ensure t
    :require t)

  (leaf async-await
    :doc "Async/Await"
    :req "emacs-25.1" "promise-1.1" "iter2-0.9.10"
    :tag "convenience" "await" "async" "emacs>=25.1"
    :url "https://github.com/chuntaro/emacs-async-await"
    :added "2023-06-30"
    :emacs>= 25.1
    :ensure t
    :after iter2)

  (leaf dash
    :doc "A modern list library for Emacs"
    :req "emacs-24"
    :tag "lisp" "extensions" "emacs>=24"
    :url "https://github.com/magnars/dash.el"
    :emacs>= 24
    :ensure t :require t)

  (leaf dotenv
    :el-get "pkulev/dotenv.el"
    :require t)

  (leaf el-project
    :doc "Generate project skelton for Emacs Lisp"
    :req "emacs-24.1"
    :tag "tools" "emacs>=24.1"
    :url "https://github.com/Kyure-A/el-project"
    :added "2023-12-31"
    :emacs>= 24.1
    :ensure t
    :require t)

  (leaf elsa
    :doc "Emacs Lisp Static Analyser"
    :req "emacs-26.1" "trinary-0" "f-0" "dash-2.14" "cl-lib-0.3" "lsp-mode-0" "ansi-0" "async-1.9.7" "lgr-0.1.0"
    :tag "lisp" "languages" "emacs>=26.1"
    :url "https://github.com/emacs-elsa/Elsa"
    :added "2023-06-29"
    :emacs>= 26.1
    :ensure t
    :require t
    :after trinary lsp-mode ansi lgr
    :config

    (elsa-lsp-register)

    (leaf flycheck-elsa
      :doc "Flycheck for Elsa"
      :req "emacs-25" "flycheck-0.14" "seq-2.0"
      :tag "convenience" "emacs>=25"
      :url "https://github.com/emacs-elsa/flycheck-elsa"
      :added "2023-12-23"
      :emacs>= 25
      :ensure t
      :after flycheck
      :config
      (add-hook 'emacs-lisp-mode-hook #'flycheck-elsa-setup)
      (setq flycheck-elsa-backend 'eask)))

  (leaf elquery
    :doc "The HTML library for elisp"
    :req "emacs-25.1" "dash-2.13.0"
    :tag "webscale" "tools" "hypermedia" "html" "emacs>=25.1"
    :url "https://github.com/AdamNiederer/elquery"
    :added "2023-12-23"
    :emacs>= 25.1
    :ensure t
    :require t)

  (leaf f
    :doc "Modern API for working with files and directories"
    :req "emacs-24.1" "s-1.7.0" "dash-2.2.0"
    :tag "directories" "files" "emacs>=24.1"
    :url "http://github.com/rejeep/f.el"
    :added "2023-05-26"
    :emacs>= 24.1
    :require t
    :ensure t)

  (leaf ht
    :doc "The missing hash table library for Emacs"
    :req "dash-2.12.0"
    :tag "hash" "hash map" "hash table"
    :added "2023-08-02"
    :ensure t
    :require t)

  (leaf keg
    :doc "Modern Elisp package development system"
    :req "emacs-24.1"
    :tag "convenience" "emacs>=24.1"
    :url "https://github.com/conao3/keg.el"
    :added "2023-06-16"
    :emacs>= 24.1
    :ensure t
    :require t
    :config

    (leaf keg-mode
      :doc "Major mode for editing Keg files"
      :req "emacs-24.4"
      :tag "convenience" "emacs>=24.4"
      :url "https://github.com/conao3/keg.el"
      :added "2023-06-16"
      :emacs>= 24.4
      :ensure t :require t)

    (leaf flycheck-keg
      :doc "Flycheck for Keg projects"
      :req "emacs-24.3" "keg-0.1" "flycheck-0.1"
      :tag "convenience" "emacs>=24.3"
      :url "https://github.com/conao3/keg.el"
      :added "2023-06-16"
      :emacs>= 24.3
      :ensure t
      :require t
      :after keg flycheck))

  (leaf lisp-interaction :bind (:lisp-interaction-mode-map ("C-j" . eval-print-last-sexp)))

  (leaf package-build
    :doc "Tools for assembling a package archive"
    :req "emacs-26.1"
    :tag "tools" "maint" "emacs>=26.1"
    :url "https://github.com/melpa/package-build"
    :added "2023-11-15"
    :emacs>= 26.1
    :ensure t)

  (leaf package-lint
    :doc "A linting library for elisp package authors"
    :req "cl-lib-0.5" "emacs-24.4" "let-alist-1.0.6" "compat-29.1"
    :tag "lisp" "emacs>=24.4"
    :url "https://github.com/purcell/package-lint"
    :added "2023-11-15"
    :emacs>= 24.4
    :ensure t
    :after compat)

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

  (leaf recur
    :doc "Tail call optimization"
    :req "emacs-24.3"
    :tag "lisp" "emacs>=24.3"
    :url "https://github.com/ROCKTAKEY/recur"
    :added "2023-08-02"
    :emacs>= 24.3
    :ensure t)

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

  (leaf undercover
    :doc "Test coverage library for Emacs Lisp"
    :req "emacs-24" "dash-2.0.0" "shut-up-0.3.2"
    :tag "tools" "coverage" "tests" "lisp" "emacs>=24"
    :url "https://github.com/sviridov/undercover.el"
    :added "2023-06-16"
    :emacs>= 24
    :ensure t
    :require t
    :after shut-up))

(leaf arduino-mode
  :doc "Major mode for editing Arduino code"
  :req "emacs-25.1" "spinner-1.7.3"
  :tag "arduino" "languages" "emacs>=25.1"
  :url "https://repo.or.cz/arduino-mode.git"
  :added "2023-11-25"
  :emacs>= 25.1
  :ensure t
  :after spinner)

(leaf lisp-mode :require t :mode "\\.cl\\'")

(leaf sly
  :doc "Sylvester the Cat's Common Lisp IDE"
  :req "emacs-24.3"
  :tag "sly" "lisp" "languages" "emacs>=24.3"
  :url "https://github.com/joaotavora/sly"
  :emacs>= 24.3
  :after prog
  :ensure t :require t
  :custom (inferior-lisp-program . "/usr/bin/sbcl")
  :config
  ;; (load "~/.roswell/helper.el")
  (defun start-sly ()
    "sly の挙動を slime に似せる"
    (interactive)
    (split-window-right)
    (sly)))

(leaf cc-mode
  :doc "user customization variables for CC Mode"
  :tag "builtin"
  :after prog
  :hook
  (c-mode . (lambda () (setq c-basic-offset 8) (indent-tabs-mode . nil)))
  (c++-mode . (lambda () (setq c-basic-offset 8) (indent-tabs-mode . nil)))
  :custom
  (c-tab-always-indent . t))

(leaf google-c-style
  :doc "Google's C/C++ style for c-mode"
  :tag "tools" "c"
  :after prog
  :ensure t :require t
  :hook ((c-mode c++-mode) . (lambda () (google-set-c-style))))

(leaf dart-mode
  :doc "Major mode for editing Dart files"
  :req "emacs-24.3"
  :tag "languages" "emacs>=24.3"
  :url "https://github.com/bradyt/dart-mode"
  :emacs>= 24.3
  :after prog
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

(leaf flutter
  :doc "Tools for working with Flutter SDK"
  :req "emacs-25.1"
  :tag "languages" "emacs>=25.1"
  :url "https://github.com/amake/flutter.el"
  :added "2023-08-22"
  :emacs>= 25.1
  :after dart-mode
  :ensure t
  :hook (dart-mode . (lambda ()
                       (add-hook 'after-save-hook #'flutter-run-or-hot-reload nil t))))

(leaf dockerfile-mode
  :doc "Major mode for editing Docker's Dockerfiles"
  :req "emacs-24"
  :tag "tools" "processes" "languages" "docker" "emacs>=24"
  :url "https://github.com/spotify/dockerfile-mode"
  :added "2024-01-08"
  :emacs>= 24
  :ensure t)

(leaf fsharp-mode
  :doc "Support for the F# programming language"
  :req "emacs-25"
  :tag "languages" "emacs>=25"
  :added "2023-10-21"
  :emacs>= 25
  :ensure t
  :custom (inferior-fsharp-program . ""))

(leaf hy-mode
  :doc "Major mode for Hylang"
  :req "dash-2.18.0" "s-1.11.0" "emacs-24"
  :tag "python" "lisp" "languages" "emacs>=24"
  :url "http://github.com/hylang/hy-mode"
  :added "2023-08-03"
  :emacs>= 24
  :ensure t
  :require t
  :hook
  (hy-mode . (lambda ()
               (setf hy-shell-interpreter-args
                     (concat "--repl-output-fn=hy.contrib.hy-repr.hy-repr "
                             hy-shell-interpreter-args))))
  :preface
  (defun hy-repl ()
    "Start hylang repl as if we were using slime."
    (interactive)
    (split-window-right)
    (multi-vterm)
    (vterm-send-string "source .venv/bin/activate")
    (vterm-send-return)
    (vterm-send-string "hy")
    (vterm-send-return)
    (sit-for 3)
    (let* ((vterm-buffer (buffer-name (current-buffer)))
           (result (with-current-buffer vterm-buffer
                     (buffer-string))))
      (message vterm-buffer)
      (when (or (s-contains-p "zsh: correct \'hy\'" result) (s-contains-p "command not found" result))
        (message "[hy-repl] hy could not be found. venv environment may not be activated or hy may not be installed.")
        (with-current-buffer vterm-buffer
          (let (kill-buffer-hook kill-buffer-query-functions)
            (kill-buffer)))
        (delete-window))))
  )

(leaf powershell
  :doc "Mode for editing PowerShell scripts"
  :req "emacs-24"
  :tag "languages" "powershell" "emacs>=24"
  :url "http://github.com/jschaf/powershell.el"
  :added "2023-06-02"
  :emacs>= 24
  :after prog
  :ensure t)

(leaf lsp-pwsh
  :doc "client for PowerShellEditorServices"
  :tag "out-of-MELPA" "lsp"
  :added "2023-06-02"
  :require t
  :after lsp powershell)

(leaf rust-mode
  :doc "A major-mode for editing Rust source code"
  :req "emacs-25.1"
  :tag "languages" "emacs>=25.1"
  :url "https://github.com/rust-lang/rust-mode"
  :added "2023-04-19"
  :emacs>= 25.1
  :after prog
  :ensure t
  :hook (rust-mode . lsp))

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

(leaf lsp-rust
  :after lsp
  :hook (rust-mode . lsp)
  :custom (lsp-rust-server . 'rust-analyzer))

(leaf svelte-mode
  :doc "Emacs major mode for Svelte"
  :req "emacs-26.1"
  :tag "languages" "wp" "emacs>=26.1"
  :url "https://github.com/leafOfTree/svelte-mode"
  :added "2023-07-24"
  :emacs>= 26.1
  :ensure t)

(leaf lsp-svelte
  :doc "LSP Svelte integration"
  :tag "out-of-MELPA" "svelte" "lsp"
  :added "2023-07-26"
  :after svelte-mode
  :require t)

(leaf typescript-mode
  :doc "Major mode for editing typescript"
  :req "emacs-24.3"
  :tag "languages" "typescript" "emacs>=24.3"
  :url "http://github.com/ananthakumaran/typescript.el"
  :emacs>= 24.3
  :after prog
  :ensure t :require t
  :mode "\\.ts\\'" "\\.tsx\\'" "\\.mts\\'" "\\.cts\\'")

(leaf tide
  :doc "Typescript Interactive Development Environment"
  :req "emacs-25.1" "dash-2.10.0" "s-1.11.0" "flycheck-27" "typescript-mode-0.1" "cl-lib-0.5"
  :tag "typescript" "emacs>=25.1"
  :url "http://github.com/ananthakumaran/tide"
  :emacs>= 25.1
  :ensure t :require t
  :after flycheck typescript-mode
  :hook
  (typescript-mode-hook . tide-start)
  :custom
  (tide-node-executable . "~/.asdf/installs/nodejs/19.0.0/bin/node")
  :config
  (defun tide-start ()
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
  :after prog
  :ensure t
  :after mmm-mode vue-html-mode ssass-mode edit-indirect)

(leaf csv-mode
  :doc "Major mode for editing comma/char separated values"
  :req "emacs-27.1" "cl-lib-0.5"
  :tag "convenience" "emacs>=27.1"
  :url "https://elpa.gnu.org/packages/csv-mode.html"
  :emacs>= 27.1
  :after prog
  :ensure t :require t
  :mode "\\.csv\\'")

(leaf markdown-mode
  :doc "Major mode for Markdown-formatted text"
  :req "emacs-26.1"
  :tag "itex" "github flavored markdown" "markdown" "emacs>=26.1"
  :url "https://jblevins.org/projects/markdown-mode/"
  :emacs>= 26.1
  :after prog
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
  (org-latex-pdf-process .  '("lualatex --draftmode %f"
                              "lualatex %f"))
  (org-startup-truncated . nil)
  (org-enforce-todo-dependencies . t)
  (org-support-shift-select . t)
  :config

  (leaf org-roam
    :doc "A database abstraction layer for Org-mode"
    :req "emacs-26.1" "dash-2.13" "org-9.4" "emacsql-20230228" "magit-section-3.0.0"
    :tag "convenience" "roam" "org-mode" "emacs>=26.1"
    :url "https://github.com/org-roam/org-roam"
    :added "2023-12-02"
    :emacs>= 26.1
    :ensure t
    :after org emacsql magit-section)

  (leaf org-roam-ui
    :doc "User Interface for Org-roam"
    :req "emacs-27.1" "org-roam-2.0.0" "simple-httpd-20191103.1446" "websocket-1.13"
    :tag "outlines" "files" "emacs>=27.1"
    :url "https://github.com/org-roam/org-roam-ui"
    :added "2023-12-02"
    :emacs>= 27.1
    :ensure t
    :after org-roam websocket)

  (leaf org-modern
    :doc "Modern looks for Org"
    :req "emacs-27.1"
    :tag "emacs>=27.1"
    :url "https://github.com/minad/org-modern"
    :emacs>= 27.1
    :ensure t :require t
    :after org
    :hook
    (org-mode-hook . org-modern-mode)
    (org-agenda-finalize-hook . org-modern-agenda))

  (leaf org-tempo :require t)

  (leaf ox-beamer
    :require t
    :after org
    :custom
    (org-latex-pdf-process . '("lualatex --draftmode %f"
                               "lualatex %f"))

    (org-latex-default-class . "ltjsarticle")
    :config
    (add-to-list 'org-latex-classes
                 '("beamer"
                   "\\documentclass[presentation]{beamer}
[NO-DEFAULT-PACKAGES]
\\usepackage{luatexja}
\\usepackage{textcomp}
\\usepackage{graphicx}
% \\usepackage{booktabs}
\\usepackage{longtable}
\\usepackage{wrapfig}
\\usepackage{ulem}
\\usepackage{hyperref}
\\hypersetup{pdfencoding=auto, linkbordercolor={0 1 0}}
%% Fonts
% mathematical font
\\usepackage{fontspec}
\\usepackage{amsmath, amssymb}
% Japanese
\\usepackage{luacode}
\\usepackage{luatexja-otf}
\\usepackage[ipaex]{luatexja-preset}
\\renewcommand{\\kanjifamilydefault}{\\gtdefault}
%%
\\setbeamercovered{transparent}
\\setbeamertemplate{navigation symbols}{}"
                     ("\\section{%s}" . "\\section*{%s}")
                     ("\\subsection{%s}" . "\\subsection*{%s}")
                     ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                     ("\\paragraph{%s}" . "\\paragraph*{%s}")
                     ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

  )

(leaf vhdl-mode
  :doc "major mode for editing VHDL code"
  :tag "builtin" "nand2tetris"
  :added "2022-08-28"
  :require t
  :after prog
  :mode "\\.hdl$")

(leaf web-mode
  :doc "major mode for editing web templates"
  :req "emacs-23.1"
  :tag "languages" "emacs>=23.1"
  :url "https://web-mode.org"
  :emacs>= 23.1
  :after prog
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
  (leaf html+-mode :require nil)
  (with-eval-after-load 'web-mode (sp-local-pair '(web-mode) "<" ">" :actions :rem))
  (put 'web-mode-markup-indent-offset 'safe-local-variable 'integerp))

(leaf yaml-mode
   :doc "Major mode for editing YAML files"
   :req "emacs-24.1"
   :tag "yaml" "data" "emacs>=24.1"
   :url "https://github.com/yoshiki/yaml-mode"
   :emacs>= 24.1
   :after prog
   :ensure t
   :mode
   "\\.yml$"
   "\\.yaml$")

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
    :hook (sh-mode . modern-sh-mode))

  (leaf flymake-shellcheck
    :doc "A bash/sh Flymake backend powered by ShellCheck"
    :req "emacs-26"
    :tag "emacs>=26"
    :url "https://github.com/federicotdn/flymake-shellcheck"
    :added "2023-02-13"
    :emacs>= 26
    :ensure t))

(leaf eat
  :doc "Emulate A Terminal, in a region, in a buffer and in Eshell"
  :req "emacs-26.1" "compat-29.1"
  :tag "processes" "terminals" "emacs>=26.1"
  :url "https://codeberg.org/akib/emacs-eat"
  :added "2023-12-31"
  :emacs>= 26.1
  :ensure t
  :after compat)

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
  (centaur-tabs-buffer-groups-function . 'centaur-tabs-buffer-groups) ;; centaur-tabs-group-by-projcetile-project しているため、my/centaur-tabs-buffer-groups は意味ない
  :config
  (centaur-tabs-group-by-projectile-project)
  (centaur-tabs-headline-match)
  (centaur-tabs-enable-buffer-reordering)
  (centaur-tabs-change-fonts "arial" 90)
  :preface
  (defun centaur-tabs-buffer-groups ()
    (list
     (cond
      ((derived-mode-p 'eshell-mode 'term-mode 'shell-mode 'vterm-mode 'multi-term-mode 'dired-mode 'magit-mode) "Terminal")
      ((derived-mode-p 'emacs-lisp-mode) "Emacs")
      ((string-match-p (rx (or
                            "\*dashboard\*"
                            "\*scratch\*"
                            "\*sdcv\*"
                            "\*setup-tracker\*"
                            "\*tramp"
                            "\*Completions\*"
                            "\*Flycheck errors\*"
                            "\*Ido Completions\*"
                            "\*Messages\*"
                            "\*Warnings\*"
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
                            "\*rust-analyzer::stderr\*"
                            "\*rust-analyzer\*"
                            ))
                       (buffer-name))
       "rust-analyzer")
      ((string-(message "message" format-args)atch-p (rx (or
                                "\*clang-error\*"
                                "\*clang-output\*"
                                ))
               (buffer-name))
       "C++")
      ((derived-mode-p 'c++-mode) "C++")
      (t "Common")))))

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

  (leaf company-clang :doc "company-mode completion backend for Clang" :after company)

  (leaf company-etags :doc "company-mode completion backend for etags" :after company)

  (leaf company-gtags :doc "company-mode completion backend for GNU Global" :after company)

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
    :after company posframe
    :global-minor-mode t)

  (leaf company-quickhelp
    :doc "Popup documentation for completion candidates"
    :req "emacs-24.3" "company-0.8.9" "pos-tip-0.4.6"
    :tag "quickhelp" "documentation" "popup" "company" "emacs>=24.3"
    :url "https://www.github.com/expez/company-quickhelp"
    :emacs>= 24.3
    :ensure t :require t
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
  (dashboard-items . '((bookmarks . 5)
                       (recents  . 5)
                       (projects . 5)))
  (initial-buffer-choice . (lambda () (get-buffer "*dashboard*")))
  (dashboard-center-content . t)
  (dashboard-set-heading-icons . t)
  (dashboard-set-file-icons . t)
  (dashboard-banner-logo-title . "Kyure_A's Emacs")
  :config
  (setq dashboard-footer-messages '("「今日も一日がんばるぞい！」 - 涼風青葉"
                                    "「なんだかホントに入社した気分です！」 - 涼風青葉"
                                    "「そしてそのバグの程度で実力も知れるわけです」- 阿波根うみこ"
                                    "「えーー！なるっちの担当箇所がバグだらけ！？」 - 桜ねね"
                                    "「C++ を完全に理解してしまったかもしれない」 - 桜ねね"
                                    "「これでもデバッグはプロ級だし 今はプログラムの知識だってあるんだからまかせてよね！」 - 桜ねね"))
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
  :config
  (setf dashboard-startup-banner (if (or (eq window-system 'x) (eq window-system 'ns) (eq window-system 'w32)) "~/.emacs.d/static/banner.png" "~/.emacs.d/static/banner.txt")))

(leaf dirvish
  :doc "A modern file manager based on dired mode"
  :req "emacs-27.1" "transient-0.3.7"
  :tag "convenience" "files" "emacs>=27.1"
  :url "https://github.com/alexluigit/dirvish"
  :added "2023-06-07"
  :emacs>= 27.1
  :after dired
  :ensure t
  :init (dirvish-override-dired-mode)
  :custom
  (dirvish-attributes . '(vc-state subtree-state all-the-icons collapse git-msg file-time file-size))
  (dirvish-preview-dispatchers . (cl-substitute 'pdf-preface 'pdf dirvish-preview-dispatchers))    
  :config

  (leaf dired
    :tag "builtin"
    :bind
    (:dired-mode-map
     ("RET" . dired-open-in-accordance-with-situation)
     ("<right>" . dired-open-in-accordance-with-situation)
     ("<left>" . dired-up-directory)
     ("a" . dired-find-file)
     ("e" . wdired-change-to-wdired-mode))
    :custom
    (dired-recursive-copies . 'always)
    :config
    ;; (ffap-bindings) ;; find-file を便利にするが、ちょっと挙動が嫌なので OFF にした

    (leaf dired-async
      :doc "Asynchronous dired actions"
      :tag "out-of-MELPA" "network" "async" "dired"
      :url "https://github.com/jwiegley/emacs-async"
      :added "2023-09-22"
      :after dired async
      :require t)

    (leaf dired-toggle
      :doc "Show dired as sidebar and will not create new buffers when changing dir"
      :tag "sidebar" "dired"
      :url "https://github.com/fasheng/dired-toggle"
      :after dired
      :ensure t :require t)

    (leaf dired-k
      :doc "Highlight dired by size, date, git status"
      :req "emacs-24.3"
      :tag "emacs>=24.3"
      :url "https://github.com/emacsorphanage/dired-k"
      :emacs>= 24.3
      :ensure t :require t
      :after dired
      :hook (dired-initial-position-hook . dired-k))

    (leaf wdired
      :doc "Rename files editing their names in dired buffers"
      :tag "builtin"
      :after dired
      :require t)

    (leaf dired-toggle-sudo
      :doc "Browse directory with sudo privileges."
      :tag "dired" "emacs"
      :added "2023-07-21"
      :after dired
      :ensure t)

    (leaf dired-preview
      :doc "Automatically preview file at point in Dired"
      :req "emacs-27.1"
      :tag "convenience" "files" "emacs>=27.1"
      :url "https://git.sr.ht/~protesilaos/dired-preview"
      :added "2023-07-30"
      :after dired
      :emacs>= 27.1
      :ensure t)

    (put 'dired-find-alternate-file 'disabled nil))

  :preface

  (leaf dired-open-in-accordance-with-situation
    :url "https://nishikawasasaki.hatenablog.com/entry/20120222/1329932699"
    :preface
    (defun dired-open-in-accordance-with-situation ()
      (interactive)
      (let ((file (dired-get-filename)))
        (if (file-directory-p file)
            (dired-find-alternate-file)
          (dired-find-file))))))

(leaf editorconfig
  :doc "EditorConfig Emacs Plugin"
  :req "cl-lib-0.5" "nadvice-0.3" "emacs-24"
  :tag "emacs>=24"
  :url "https://github.com/editorconfig/editorconfig-emacs#readme"
  :emacs>= 24
  :ensure t :require t
  :after nadvice
  :global-minor-mode t)

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

(leaf counsel
  :doc "Various completion functions using Ivy"
  :req "emacs-24.5" "ivy-0.13.4" "swiper-0.13.4"
  :tag "tools" "matching" "convenience" "emacs>=24.5"
  :url "https://github.com/abo-abo/swiper"
  :emacs>= 24.5
  :ensure t :require t
  :after ivy swiper
  :global-minor-mode t
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
  :after ivy)

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

(leaf minimap
  :doc "Sidebar showing a \"mini-map\" of a buffer"
  :url "http://elpa.gnu.org/packages/minimap.html"
  :added "2023-09-05"
  :ensure t)

(leaf multiple-cursors
  :doc "Multiple cursors for Emacs."
  :req "cl-lib-0.5"
  :tag "cursors" "editing"
  :url "https://github.com/magnars/multiple-cursors.el"
  :added "2023-12-04"
  :ensure t)

(leaf neotree
  :doc "A tree plugin like NerdTree for Vim"
  :req "cl-lib-0.5"
  :url "https://github.com/jaypei/emacs-neotree"
  :ensure t :require t
  :custom
  (neo-smart-open . t)
  (neo-create-file-auto-open . t)
  (neo-theme . (if (display-graphic-p) 'icons 'arrow)))

(leaf pdf-tools
  :doc "Support library for PDF documents"
  :req "emacs-26.3" "tablist-1.0" "let-alist-1.0.4"
  :tag "multimedia" "files" "emacs>=26.3"
  :url "http://github.com/vedang/pdf-tools/"
  :added "2023-07-23"
  :emacs>= 26.3
  :ensure t
  :require t
  :after tablist
  :config (pdf-tools-install)
  (pdf-loader-install))

(leaf projectile
  :doc "Manage and navigate projects in Emacs easily"
  :req "emacs-25.1"
  :tag "convenience" "project" "emacs>=25.1"
  :url "https://github.com/bbatsov/projectile"
  :emacs>= 25.1
  :ensure t :require t
  :after dashboard)

(leaf skewer-mode
  :doc "live browser JavaScript, CSS, and HTML interaction"
  :req "simple-httpd-1.4.0" "js2-mode-20090723" "emacs-24"
  :tag "emacs>=24"
  :url "https://github.com/skeeto/skewer-mode"
  :emacs>= 24
  :ensure t :require t
  :after js2-mode)

(leaf undo-tree
  :doc "Treat undo history as a tree"
  :req "queue-0.2" "emacs-24.3"
  :tag "tree" "history" "redo" "undo" "files" "convenience" "emacs>=24.3"
  :url "https://www.dr-qubit.org/undo-tree.html"
  :emacs>= 24.3
  :ensure t :require t
  :global-minor-mode global-undo-tree-mode
  :custom
  (undo-tree-auto-save-history . t)
  (undo-tree-history-directory-alist . '(("." . "~/.emacs.d/.tmp"))))

(leaf undohist
  :doc "Persistent undo history for GNU Emacs"
  :req "cl-lib-1.0"
  :tag "convenience"
  :ensure t :require t
  :custom
  (undohist-directory . "~/.emacs.d/.tmp/")
  (undohist-ignored-files . '("/.tmp/" "COMMIT_EDITMSG" "/elpa"))
  :config
  (undohist-initialize))

(leaf which-key
  :doc "Display available keybindings in popup"
  :req "emacs-24.4"
  :tag "emacs>=24.4"
  :url "https://github.com/justbur/emacs-which-key"
  :emacs>= 24.4
  :ensure t :require t
  :global-minor-mode t
  :config (which-key-setup-side-window-bottom))

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

(leaf docker
  :doc "Interface to Docker"
  :req "aio-1.0" "dash-2.19.1" "emacs-26.1" "s-1.13.0" "tablist-1.1" "transient-0.4.3"
  :tag "convenience" "filename" "emacs>=26.1"
  :url "https://github.com/Silex/docker.el"
  :added "2024-01-08"
  :emacs>= 26.1
  :ensure t
  :after aio tablist)

(leaf elcord
  :doc "Allows you to integrate Rich Presence from Discord"
  :req "emacs-25.1"
  :tag "games" "emacs>=25.1"
  :url "https://github.com/Mstrodl/elcord"
  :added "2023-08-13"
  :emacs>= 25.1
  :ensure t
  :require t)

(leaf jobcan
  :doc "Managing jobcan in Emacs"
  :req "emacs-25.1" "elquery-1.1.0" "ht-2.4" "request-0.3.3" "s-1.13.1"
  :tag "tools" "emacs>=25.1"
  :url "https://github.com/Kyure-A/jobcan.el"
  :added "2023-12-31"
  :emacs>= 25.1
  :ensure t
  :after elquery
  :require t)

(leaf magit
  :doc "A Git porcelain inside Emacs."
  :req "emacs-25.1" "compat-28.1.1.2" "dash-20210826" "git-commit-20220222" "magit-section-20220325" "transient-20220325" "with-editor-20220318"
  :tag "vc" "tools" "git" "emacs>=25.1"
  :url "https://github.com/magit/magit"
  :emacs>= 25.1
  :ensure t :require t
  :after compat git-commit magit-section with-editor
  :hook (magit-status-mode . my/toggle-centaur-tabs-local-mode)
  :config
  (setq magit-repository-directories '(("~/ghq/" . 3)))
  (when (string< "28.1" "29")
    ;; https://github.com/emacs-mirror/emacs/blob/281be72422f42fcc84d43f50723a3e91b7d03cbc/lisp/emacs-lisp/seq.el#L709
    (defun seq-keep (function sequence)
      "Apply FUNCTION to SEQUENCE and return the list of all the non-nil results."
      (delq nil (seq-map function sequence)))))

(leaf nodejs-repl
  :doc "Run Node.js REPL"
  :ensure t
  :require t
  :after prog)

(leaf oj
  :doc "Competitive programming tools client for AtCoder, Codeforces"
  :req "emacs-26.1" "quickrun-2.2"
  :tag "convenience" "emacs>=26.1"
  :url "https://github.com/conao3/oj.el"
  :emacs>= 26.1
  :after prog
  :ensure t :require t
  :custom
  (oj-shell-program . "zsh")
  (oj-open-home-dir . "~/oj-files/")
  (oj-default-online-judge . 'atcoder)
  (oj-compiler-c . "gcc")
  (oj-compiler-python . "cpython"))

(leaf prettier
  :doc "Code formatting with Prettier"
  :req "emacs-26.1" "iter2-0.9" "nvm-0.2" "editorconfig-0.8"
  :tag "files" "languages" "convenience" "emacs>=26.1"
  :url "https://github.com/jscheid/prettier.el"
  :added "2023-10-20"
  :emacs>= 26.1
  :ensure t
  :after iter2 nvm editorconfig
  :hook (after-init-hook . global-prettier-mode))

(leaf quickrun
  :doc "Run commands quickly"
  :req "emacs-24.3"
  :tag "emacs>=24.3"
  :url "https://github.com/syohex/emacs-quickrun"
  :emacs>= 24.3
  :ensure t :require t
  :after prog
  :config
  (push '("*quickrun*") popwin:special-display-config)
  :preface
  (defun quickrun-sc (start end)
    (interactive "r")
    (if mark-active
        (quickrun :start start :end end)
      (quickrun))))

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

(leaf display-line-numbers
    :doc "interface for display-line-numbers"
    :tag "builtin"
    :config (custom-set-variables '(display-line-numbers-width-start t)))

(leaf emojify
  :doc "Display emojis in Emacs"
  :req "seq-1.11" "ht-2.0" "emacs-24.3"
  :tag "convenience" "multimedia" "emacs>=24.3"
  :url "https://github.com/iqbalansari/emacs-emojify"
  :emacs>= 24.3
  :ensure t :require t
  :after after-init
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

(leaf hide-mode-line
  :doc "minor mode that hides/masks your modeline"
  :req "emacs-24.4"
  :tag "mode-line" "frames" "emacs>=24.4"
  :url "https://github.com/hlissner/emacs-hide-mode-line"
  :added "2023-09-05"
  :emacs>= 24.4
  :ensure t
  :require t
  :hook
  (vterm-mode . hide-mode-line-mode)
  (dashboard-mode . hide-mode-line-mode))

(leaf highlight-symbol
  :doc "automatic and manual symbol highlighting"
  :tag "matching" "faces"
  :url "http://nschum.de/src/emacs/highlight-symbol/"
  :ensure t :require t
  :require t
  :hook (prog-mode-hook . highlight-symbol-mode)
  :custom (highlight-symbol-idle-delay . 0.1))

(leaf page-break-lines
  :doc "Display ^L page breaks as tidy horizontal lines"
  :req "emacs-24.4"
  :tag "faces" "convenience" "emacs>=24.4"
  :url "https://github.com/purcell/page-break-lines"
  :emacs>= 24.4
  :ensure t :require t
  :global-minor-mode global-page-break-lines-mode)

(leaf paren
  :doc "highlight matching paren"
  :tag "builtin"
  :global-minor-mode show-paren-mode
  :custom
  (show-paren-delay . 0)
  (show-paren-style . 'expression))

(leaf rainbow-mode
  :doc "Colorize color names in buffers"
  :tag "faces"
  :url "https://elpa.gnu.org/packages/rainbow-mode.html"
  :ensure t :require t
  :hook (web-mode-hook))

(leaf rainbow-delimiters
  :doc "Highlight brackets according to their depth"
  :tag "tools" "lisp" "convenience" "faces"
  :url "https://github.com/Fanael/rainbow-delimiters"
  :ensure t :require t
  :hook (prog-mode-hook))

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

(leaf *defun
    :preface
    ;; 適当
    (defun toggle-centaur-tabs-local-mode()
      (interactive)
      (call-interactively 'centaur-tabs-local-mode)
      (call-interactively 'centaur-tabs-local-mode))

    (defun backward-kill-line (arg)
      "Kill ARG lines backward."
      (interactive "p")
      (kill-line (- 1 arg)))

    (defun delete-word (arg)
      "Delete characters forward until encountering the end of a word.
  With argument ARG, do this that many times.
  https://qiita.com/ballforest/items/5a76f284af254724144a"
      (interactive "p")
      (delete-region (point) (progn (forward-word arg) (point))))

    (defun backward-delete-word (arg)
      "Delete characters backward until encountering the beginning of a word.
  With argument ARG, do this that many times.
  https://qiita.com/ballforest/items/5a76f284af254724144a"
      (interactive "p")
      (delete-word (- arg)))

    (defun Kyure_A/echo-choices (list message-str)
      "Displays choices in the echo area and evaluates the choice"
      (setq chosen (completing-read "Choose an option: " list))
      (cl-loop for i
               below (length list)
               do (when (equal (car (nth i list)) chosen)
                    (eval (eval (cdr (nth i list)))) ;; quote を外すのが雑
                    (cl-return))
               finally (message message-str)))

    (defun Kyure_A/open-recentf ()
      "Outputs a list of 10 most recently opened files to the echo area"
      (interactive)
      (let* ((recent-opened-files '()))
        (cl-loop for i below 10
                 do (push (cons (nth i recentf-list) `(find-file ,(nth i recentf-list))) recent-opened-files))
        (setq recent-opened-files (reverse recent-opened-files))
        (Kyure_A/echo-choices recent-opened-files "not found")))

    (defun Kyure_A/open ()
      (interactive)
      (let* ((choices '(("dashboard" . (open-dashboard))
                        ("documents" . (if (file-exists-p "~/documents")
                                           (find-file "~/documents")
                                         (find-file "~/Documents")))
                        ("dotfiles" . (find-file "~/dotfiles"))
                        (".emacs.d" . (find-file "~/.emacs.d"))
                        ("elpa" . (find-file package-user-dir))
                        ("recent" . (open-recentf))
                        ("wsl" . (find-file "/mnt/c/Users/kyre/")))))
        (Kyure_A/echo-choices choices "invalid options")))

    (defun Kyure_A/start-repl ()
      (interactive)
      (let* ((mode-repl-pair '(("lisp-mode" . (start-sly))
                               ("hy-mode" . (hy-repl)))))
        (cl-loop for i
                 below (length mode-repl-pair)
                 do (when (equal (car (nth i mode-repl-pair)) (format "%s" major-mode))
                      (eval (eval (cdr (nth i mode-repl-pair))))
                      (cl-return))
                 finally (message (format "[start-repl] couldn't found repl for %s" major-mode)))))
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
    (when (file-exists-p "./elisp")
      (let ((default-directory (locate-user-emacs-file "./elisp")))
        (add-to-list 'load-path default-directory)
        (normal-top-level-add-subdirs-to-load-path)))
    )

  (leaf frame :config (set-frame-parameter nil 'unsplittable t))

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
  )

(leaf *inbox
  :doc "分類が面倒なパッケージを入れる"
  :config

  (leaf gcmh
    :doc "the Garbage Collector Magic Hack"
    :req "emacs-24"
    :tag "internal" "emacs>=24"
    :url "https://gitlab.com/koral/gcmh"
    :emacs>= 24
    :ensure t :require t
    :hook (after-init-hook . gcmh-mode)
    :custom (gcmh-verbose . t))

  (leaf mozc
    :doc "minor mode to input Japanese with Mozc"
    :tag "input method" "multilingual" "mule"
    :added "2023-07-20"
    :ensure t
    :require t
    :config (setq mozc-candidate-style 'echo-area))

  (leaf nu-fun
    :el-get "ayanyan/nihongo-util"
    :require t
    :custom
    (nu-my-toten . "，")
    (nu-my-kuten . "．"))

  (leaf restart-emacs
    :doc "Restart emacs from within emacs"
    :tag "convenience"
    :url "https://github.com/iqbalansari/restart-emacs"
    :added "2023-06-14"
    :ensure t)

  (leaf tetris
    :bind
    (:tetris-mode-map
     ("w" . tetris-rotate-prev)
     ("a" . tetris-move-left)
     ("s" . tetris-move-down)
     ("d" . tetris-move-right)
     ("RET" . tetris-move-bottom)))
  )

;; ---------------------------------------------------------------------------------------------- ;;

(leaf *edit
  :doc "補完や構文のチェック, 入力に関するプラグイン"
  :config

  (leaf autorevert
    :doc "revert buffers when files on disk change"
    :tag "builtin"
    :global-minor-mode global-auto-revert-mode
    :custom (auto-revert-interval . 1))

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

  (leaf smartparens
    :doc "Automatic insertion, wrapping and paredit-like navigation with user defined pairs."
    :req "dash-2.13.0" "cl-lib-0.3"
    :tag "editing" "convenience" "abbrev"
    :url "https://github.com/Fuco1/smartparens"
    :ensure t :require t
    :global-minor-mode smartparens-global-mode show-smartparens-global-mode
    :config
    (leaf smartparens-config :require t :after smartparens :hook (web-mode-hook . (lambda () (sp-pair "<#" "#>")))))

  (leaf visual-regexp
    :doc "A regexp/replace command for Emacs with interactive visual feedback"
    :req "cl-lib-0.2"
    :tag "feedback" "visual" "replace" "regexp"
    :url "https://github.com/benma/visual-regexp.el/"
    :ensure t :require t)

  (leaf which-function-mode :tag "builtin" :custom (which-function-mode . t))

  (leaf yafolding
    :doc "Folding code blocks based on indentation"
    :tag "folding"
    :ensure t :require t
    :hook (prog-mode-hook . yafolding-mode))

  )

(provide 'init)

;; End:
;;; init.el ends here
