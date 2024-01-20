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

(defvar my/delayed-priority-high-configurations '())
(defvar my/delayed-priority-high-configuration-timer nil)

(defvar my/delayed-priority-low-configurations '())
(defvar my/delayed-priority-low-configuration-timer nil)

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
               (cancel-timer my/delayed-priority-low-configuration-timer))))))

(defmacro with-delayed-execution-priority-high (&rest body)
  (declare (indent 0))
  `(setq my/delayed-priority-high-configurations
         (append my/delayed-priority-high-configurations ',body)))

(defmacro with-delayed-execution (&rest body)
  (declare (indent 0))
  `(setq my/delayed-priority-low-configurations
         (append my/delayed-priority-low-configurations ',body)))

;;;###autoload
(cl-defun autoload-if-found (functions file &optional docstring (interactive nil) (type t))
  "set autoload iff. FILE has found."
  (when (locate-library file)
    (dolist (f functions)
      (autoload f file docstring interactive type))
    t))

(eval-and-compile
  (setq byte-compile-warnings '(cl-functions))
  (require 'cl-lib nil t))

(with-delayed-execution-priority-high
  (require 'cl-lib))

(eval-when-compile
  (unless (file-directory-p "~/.elpkg/elpa/el-clone")
    (package-vc-install "https://github.com/Kyure-A/el-clone.git")))

(eval-and-compile
  (add-to-list 'load-path "~/.elpkg/elpa/el-clone")
  (require 'el-clone))

(global-set-key (kbd "<f2>") 'vterm-toggle)
(global-set-key (kbd "<f3>") 'dashboard-open)
(global-set-key (kbd "RET") 'smart-newline)
(global-set-key (kbd "C-RET") 'newline)
(global-set-key (kbd "<backspace>") 'smart-hungry-delete-backward-char)
(global-set-key (kbd "C-<backspace>") 'backward-delete-word)
(global-set-key (kbd "C-<left>") 'centaur-tabs-forward)
(global-set-key (kbd "C-<right>") 'centaur-tabs-backward)
(global-set-key (kbd "C-<return>") 'newline)
(global-set-key (kbd "C-SPC") 'toggle-input-method)

(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)
(global-set-key (kbd "C-x i") 'nil)
(global-set-key (kbd "C-x i i") 'ivy-yasnippet)
(global-set-key (kbd "C-x i n") 'yas-new-snippet)
(global-set-key (kbd "C-x u") 'undo-tree-visualize)
(global-set-key (kbd "C-x C-z") 'nil)
(global-set-key (kbd "C-x C-c") 'nil)

(global-set-key (kbd "C-c C-f") 'leaf-convert-insert-template)
(global-set-key (kbd "C-c e b") 'eval-buffer)
(global-set-key (kbd "C-c e m") 'menu-bar-mode)
(global-set-key (kbd "C-c l c") 'leaf-convert-region-replace)
(global-set-key (kbd "C-c l t") 'leaf-tree-mode)
(global-set-key (kbd "C-c o") 'Kyure_A/open)
(global-set-key (kbd "C-c p") 'smartparens-global-mode)
(global-set-key (kbd "C-c s") 'Kyure_A/start-repl)
(global-set-key (kbd "C-c t") 'centaur-tabs-counsel-switch-group)
(global-set-key (kbd "C-c r") 'vr/replace)

(global-set-key (kbd "C-l") 'nil)
(global-set-key (kbd "C-l C-l") 'lsp)

(global-set-key (kbd "C-a") 'mwim-beginning-of-code-or-line)
(global-set-key (kbd "C-d") 'smart-hungry-delete-backward-char)
(global-set-key (kbd "C-e") 'mwim-end-of-code-or-line)
(global-set-key (kbd "C-h") 'smart-hungry-delete-backward-char)
(global-set-key (kbd "C-m") 'smart-newline)
(global-set-key (kbd "C-o") 'nil)
(global-set-key (kbd "C-u") 'undo-tree-undo)
(global-set-key (kbd "C-r") 'undo-tree-redo)
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "C-/") 'other-window)
(global-set-key (kbd "C-;") 'smart-hungry-delete-forward-char)

(global-set-key (kbd "M-k") 'backward-kill-line)
(global-set-key (kbd "M-x") 'counsel-M-x)

(with-delayed-execution
  (fset 'yes-or-no-p 'y-or-n-p))

(eval-when-compile
  (el-clone :repo "alezost/mwim.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/mwim"))
  (autoload-if-found '(mwim-beginning-of-code-or-line
                       mwim-end-of-code-or-line)
                     "mwim"))

(eval-when-compile
  (el-clone :repo "hrehfeld/emacs-smart-hungry-delete"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-smart-hungry-delete"))
  (with-eval-after-load 'smart-hungry-delete
    (smart-hungry-delete-add-default-hooks))
  (autoload-if-found '(smart-hungry-delete-forward-char
                       smart-hungry-delete-backward-char)
                     "smart-hungry-delete"))

(eval-when-compile
  (el-clone :repo "ainame/smart-newline.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/smart-newline"))
  (autoload-if-found '(smart-newline) "smart-newline"))

(setq mouse-wheel-progressive-speed nil)
(setq scroll-preserve-screen-position 'always)

(eval-when-compile
  (el-clone :repo "ahungry/fast-scroll"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "ahungry/fast-scroll"))
  (autoload-if-found '(fast-scroll-mode) "fast-scroll")
  (fast-scroll-mode)
  (with-eval-after-load 'fast-scroll
    (add-hook 'fast-scroll-start-hook (lambda () (flycheck-mode -1)))
    (add-hook 'fast-scroll-end-hook (lambda () (flycheck-mode 1)))
    (fast-scroll-config)
    (setq jit-lock-defer-time 0)))

(eval-when-compile
  (el-clone :repo "zk-phi/sublimity"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/sublimity"))
  (autoload-if-found '(sublimity-mode) "sublimity")
  (sublimity-mode t)
  (with-eval-after-load 'sublimity
    (setq sublimity-attractive-centering-width 200)
    (setq sublimity-scroll-weight 5)
    (setq sublimity-scroll-drift-length 10)))

(setq-default indent-tabs-mode nil)

(with-delayed-execution
  (save-place-mode t))

(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default 'buffer-file-coding-system 'utf-8)

(with-delayed-execution
  (delete-selection-mode t))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'after-save-hook (lambda ()
                                         (org-babel-tangle-file "~/.emacs.d/early-init.org" "~/.emacs.d/early-init.el" "emacs-lisp")
                                         (org-babel-tangle-file "~/.emacs.d/init.org" "~/.emacs.d/init.el" "emacs-lisp")
                                         (byte-compile-file "~/.emacs.d/early-init.el")
                                         (byte-compile-file "~/.emacs.d/init.el")
                                         ))))

(with-delayed-execution
  (display-time-mode t)
  (setq display-time-interval 1)
  (setq display-time-string-forms '((format "%s:%s:%s" 24-hours minutes seconds)))
  (setq display-time-day-and-date t))

(with-delayed-execution
  (global-auto-revert-mode t)
  (setq auto-revert-interval 1))

(with-delayed-execution
  (which-function-mode t))

(with-delayed-execution
  (recentf-mode t)
  (setq recentf-max-saved-items 150)
  (setq recentf-auto-cleanup 'never)
  (setq recentf-exclude '("/recentf" "COMMIT_EDITMSG" "/.?TAGS" "^/sudo:" "/\\.emacs\\.d/games/*-scores" "/\\.emacs\\.d/\\.tmp/")))

(leaf recentf-ext
  :doc "Recentf extensions"
  :tag "files" "convenience"
  :url "http://www.emacswiki.org/cgi-bin/wiki/download/recentf-ext.el"
  :ensure t :require t)

(set-frame-parameter nil 'unsplittable t)

(setq custom-file (locate-user-emacs-file "custom.el"))

(setq debug-on-error t)

(setq create-lockfiles nil)

(setq backup-directory-alist '((".*" . "~/.tmp")))

(setq auto-save-file-name-transforms '((".*" "~/.tmp/" t)))
(setq auto-save-list-file-prefix nil)
(setq auto-save-default nil)

(eval-when-compile
  (el-clone :repo "jwiegley/emacs-async"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-async")))

(eval-when-compile
  (el-clone :repo "chuntaro/emacs-async-await"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-async-await")))

(eval-when-compile
  (el-clone :repo "magnars/dash.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dash")))

(eval-when-compile
  (el-clone :repo "pkulev/dotenv.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dotenv")))

(eval-when-compile
  (el-clone :repo "Kyure-A/el-project"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/el-project")))

(eval-when-compile
  (el-clone :repo "emacs-elsa/Elsa"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/Elsa"))
  (autoload-if-found '(elsa-run) "elsa")
  (with-eval-after-load 'elsa
    (elsa-lsp-register)))

(eval-when-compile
  (el-clone :repo "emacs-elsa/flycheck-elsa"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/flycheck-elsa"))

  (autoload-if-found '(flycheck-elsa-setup) "flycheck-elsa")

  (with-eval-after-load 'elisp-mode
    (setq flycheck-elsa-backend 'eask)
    (add-hook 'emacs-lisp-mode-hook #'flycheck-elsa-setup)))

(eval-when-compile
  (el-clone :repo "AdamNiederer/elquery"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/elquery")))

(eval-when-compile
  (el-clone :repo "rejeep/f.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/f")))

(eval-when-compile
  (el-clone :repo "Wilfred/ht.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/ht")))

(eval-when-compile
  (el-clone :repo "conao3/keg.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/keg")))

(eval-when-compile
  (el-clone :repo "purcell/package-lint"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/package-lint"))
  (autoload-if-found '(package-lint-current-buffer) "package-lint"))

(eval-when-compile
  (el-clone :repo "chuntaro/emacs-promise"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-promise")))

(eval-when-compile
  (el-clone :repo "magnars/s.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/s")))

(eval-when-compile
  (el-clone :repo "zbelial/shrink-path.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/shrink-path")))

(eval-when-compile
  (el-clone :repo "emacsmirror/queue"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/queue")))

(eval-when-compile
  (el-clone :repo "ROCKTAKEY/recur"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/recur")))

(eval-when-compile
  (el-clone :repo "tkf/emacs-request"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-request")))

(leaf lisp-interaction :bind (:lisp-interaction-mode-map ("C-j" . eval-print-last-sexp)))

(leaf package-build
  :doc "Tools for assembling a package archive"
  :req "emacs-26.1"
  :tag "tools" "maint" "emacs>=26.1"
  :url "https://github.com/melpa/package-build"
  :added "2023-11-15"
  :emacs>= 26.1
  :ensure t)

(leaf undercover
  :doc "Test coverage library for Emacs Lisp"
  :req "emacs-24" "dash-2.0.0" "shut-up-0.3.2"
  :tag "tools" "coverage" "tests" "lisp" "emacs>=24"
  :url "https://github.com/sviridov/undercover.el"
  :added "2023-06-16"
  :emacs>= 24
  :ensure t
  :require t
  :after shut-up)

(eval-when-compile
  (el-clone :url "https://repo.or.cz/arduino-mode.git"
            :repo "arduino-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/arduino-mode"))
  (autoload-if-found '(arduino-mode) "arduino-mode")
  (add-to-list 'auto-mode-alist '("\\.ino$" . arduino-mode)))

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

(eval-when-compile
  (el-clone :repo "spotify/dockerfile-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dockerfile-mode"))
  (autoload-if-found '(dockerfile-mode) "dockerfile-mode")
  (add-to-list 'auto-mode-alist '("\\Dockerfile$" . dockerfile-mode))
  (with-eval-after-load 'dockerfile-mode
    (add-hook 'dockerfile-mode-hook #'flycheck-mode)))

(eval-when-compile
  (el-clone :repo "fsharp/emacs-fsharp-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-fsharp-mode"))
  (autoload-if-found '(fsharp-mode) "fsharp-mode")
  (add-to-list 'auto-mode-alist '("\\.fs[iylx]?$" . fsharp-mode)))

(eval-when-compile
  (el-clone :repo "hylang/hy-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/hy-mode"))
  (autoload-if-found '(hy-mode) "hy")
  (add-hook 'hy-mode (lambda () (setq hy-shell-interpreter-args
                            (concat "--repl-output-fn=hy.contrib.hy-repr.hy-repr "
                                    hy-shell-interpreter-args)))))

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

(eval-when-compile
  (el-clone :repo "rust-lang/rust-mode")
  (el-clone :repo "kwrooijen/cargo.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/rust-mode"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/cargo"))
  (autoload-if-found '(rust-mode) "rust-mode")
  (add-to-list 'auto-mode-alist '("\\.rs$" . rust-mode))
  (with-eval-after-load 'rust-mode
    (setq rust-format-on-save t)
    (add-hook 'rust-mode-hook #'lsp)
    (add-hook 'rust-mode-hook 'cargo-minor-mode)
    (add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))
    (setq lsp-rust-server 'rust-analyzer)))

(eval-when-compile
  (el-clone :repo "leafOfTree/svelte-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/svelte-mode"))
  (autoload-if-found '(svelte-mode) "svelte-mode")
  (add-to-list 'auto-mode-alist '("\\.svelte$" . svelte-mode)))

(eval-when-compile
  (el-clone :repo "ananthakumaran/typescript.el")
  (el-clone :repo "ananthakumaran/tide"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/typescript"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/tide"))
  (autoload-if-found '(typescript-mode) "typescript-mode")
  (autoload-if-found '(tide-setup) "tide")
  (add-to-list 'auto-mode-alist '("\\.ts$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.mts$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.cts$" . typescript-mode))
  (add-hook 'typescript-mode-hook #'tide-setup)
  (setq tide-node-executable "~/.nix-profile/bin/node"))

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
  :mode "\\.csv$")

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

(with-eval-after-load 'org
  (setq org-directory "~/document/org")
  (setq org-latex-pdf-process '("lualatex --draftmode %f"
                              "lualatex %f"))
  (setq org-startup-truncated nil)
  (setq org-enforce-todo-dependencies t)
  (setq org-support-shift-select t))

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

(eval-when-compile
  (el-clone :repo "minad/org-modern"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-modern"))
  (autoload-if-found '(org-modern-mode) "org-modern")
  (add-hook 'org-mode-hook #'org-modern-mode)
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda))

(eval-when-compile
  (el-clone :repo "org-roam/org-roam"
            :load-paths `(,(locate-user-emacs-file "el-clone/org-roam/extensions")))
  (el-clone :repo "org-roam/org-roam-ui"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam/extensions"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam-ui"))
  (autoload-if-found '(org-roam-ui-mode) "org-roam-ui")
  (with-eval-after-load 'org-roam-mode
    (add-hook 'org-roam-mode-hook #'org-roam-ui-mode)))

(leaf org-tempo :require t)

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

(eval-when-compile
  (el-clone :repo "yoshiki/yaml-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/yaml-mode"))
  (autoload-if-found '(yaml-mode) "yaml-mode")
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
  (with-eval-after-load 'yaml-mode
    (add-hook 'yaml-mode-hook #'flycheck-mode)))

(eval-when-compile
  (el-clone :repo "damon-kwok/modern-sh")
  (el-clone :repo "federicotdn/flymake-shellcheck"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/modern-sh"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/flymake-shellcheck"))
  (autoload-if-found '(sh-mode) "sh-mode")
  (add-to-list 'auto-mode-alist '("\\.sh$" . sh-mode))
  (add-to-list 'auto-mode-alist '("\\.zsh$" . sh-mode))
  (autoload-if-found '(flymake-shell-check-load) "flymake-shell-check")
  (with-eval-after-load 'sh-mode
    (add-hook 'sh-mode-hook 'flymake-shellcheck-load)
    (add-hook 'sh-mode-hook #'modern-sh-mode)))

(eval-when-compile
  (el-clone :url "https://codeberg.org/akib/emacs-eat.git"
            :repo "emacs-eat"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-eat"))
  (autoload-if-found '(eat) "eat"))

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

(eval-when-compile
  (el-clone :repo "ema2159/centaur-tabs"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/centaur-tabs"))
  (autoload-if-found '(centaur-tabs-mode) "centaur-tabs")
  (centaur-tabs-mode t)
  (with-eval-after-load 'centaur-tabs
    (centaur-tabs-group-by-projectile-project)
    (centaur-tabs-headline-match)
    (centaur-tabs-enable-buffer-reordering)
    (centaur-tabs-change-fonts "arial" 90)
    (setq centaur-tabs-height 30)
    (setq centaur-tabs-hide-tabs-hooks nil)
    (setq centaur-tabs-set-icons t)
    (setq centaur-tabs-set-bar 'under)
    (setq x-underline-at-descent-line t)
    (setq centaur-tabs-style "bar")
    (setq centaur-tabs-set-modified-marker t)
    (setq centaur-tabs-show-navigation-buttons t)
    (setq centaur-tabs-adjust-buffer-order t)
    (setq centaur-tabs-cycle-scope 'groups)))

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

(eval-when-compile
  (el-clone :repo "emacs-dashboard/emacs-dashboard"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-dashboard"))
  (autoload-if-found '(dashboard-setup-startup-hook) "dashboard")
  (dashboard-setup-startup-hook)
  (with-eval-after-load 'dashboard
    (define-key dashboard-mode-map (kbd "<f3>") #'quit-dashboard)
    (setq dashboard-items '((bookmarks . 5)
                            (recents  . 5)
                            (projects . 5)))
    (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
    (setq dashboard-center-content t)
    (setq dashboard-set-heading-icons t)
    (setq dashboard-set-file-icons t)
    (setq dashboard-banner-logo-title "Kyure_A's Emacs")
    (setq dashboard-footer-messages '("「今日も一日がんばるぞい！」 - 涼風青葉"
                                          "「なんだかホントに入社した気分です！」 - 涼風青葉"
                                          "「そしてそのバグの程度で実力も知れるわけです」- 阿波根うみこ"
                                          "「えーー！なるっちの担当箇所がバグだらけ！？」 - 桜ねね"
                                          "「C++ を完全に理解してしまったかもしれない」 - 桜ねね"
                                          "「これでもデバッグはプロ級だし 今はプログラムの知識だってあるんだからまかせてよね！」 - 桜ねね"))
    (setq dashboard-startup-banner (if (or (eq window-system 'x) (eq window-system 'ns) (eq window-system 'w32)) "~/.emacs.d/static/banner.png" "~/.emacs.d/static/banner.txt"))))

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
  (dashboard-goto-recent-files))

(defun quit-dashboard ()
  "Quit dashboard window."
  (interactive)
  (quit-window t)
  (and dashboard-recover-layout-p
       (and (bound-and-true-p winner-mode) (winner-undo))
       (setq dashboard-recover-layout-p nil)))

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

(eval-when-compile
  (el-clone :repo "flycheck/flycheck"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/flycheck"))
  (autoload-if-found '(flycheck-mode flycheck-define-checker) "flycheck")
  (with-eval-after-load 'flycheck
    (setq flycheck-idle-change-delay 0)))

(leaf gcmh
  :doc "the Garbage Collector Magic Hack"
  :req "emacs-24"
  :tag "internal" "emacs>=24"
  :url "https://gitlab.com/koral/gcmh"
  :emacs>= 24
  :ensure t :require t
  :hook (after-init-hook . gcmh-mode)
  :custom (gcmh-verbose . t))

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

(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-mode"
            :load-paths `(,(locate-user-emacs-file "el-clone/lsp-mode/clients"))))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-mode"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-mode/clients"))
  (autoload-if-found '(lsp lsp-deferred) "lsp-mode")
  (with-eval-after-load 'lsp
    (setq lsp-enable-snippet t)
    (setq lsp-enable-indentation nil)
    (setq lsp-prefer-flymake nil)
    (setq lsp-document-sync-method 2)
    (setq lsp-inhibit-message t)
    (setq lsp-message-project-root-warning t)
    (setq create-lockfiles nil)
    (setq lsp-prefer-capf t)
    (setq lsp-headerline-breadcrumb-mode t)))

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

(eval-when-compile
  (el-clone :repo "ayanyan/nihongo-util"))

(with-delayed-execution
  (require 'nu-fun)
  (setq nu-my-toten "，")
  (setq nu-my-kuten "．"))

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

(leaf projectile
  :doc "Manage and navigate projects in Emacs easily"
  :req "emacs-25.1"
  :tag "convenience" "project" "emacs>=25.1"
  :url "https://github.com/bbatsov/projectile"
  :emacs>= 25.1
  :ensure t :require t
  :after dashboard)

(leaf restart-emacs
  :doc "Restart emacs from within emacs"
  :tag "convenience"
  :url "https://github.com/iqbalansari/restart-emacs"
  :added "2023-06-14"
  :ensure t)

(leaf skewer-mode
  :doc "live browser JavaScript, CSS, and HTML interaction"
  :req "simple-httpd-1.4.0" "js2-mode-20090723" "emacs-24"
  :tag "emacs>=24"
  :url "https://github.com/skeeto/skewer-mode"
  :emacs>= 24
  :ensure t :require t
  :after js2-mode)

(eval-when-compile
  (el-clone :repo "Fuco1/smartparens"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/smartparens"))
  (autoload-if-found '(smartparens-global-mode) "smartparens")
  (smartparens-global-mode)
  (show-smartparens-global-mode t))

(eval-when-compile
  (el-clone :repo "apchamberlain/undo-tree.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/undo-tree"))
  (autoload-if-found '(undo-tree-undo undo-tree-redo) "undo-tree")
  (with-eval-after-load 'undo-tree
    (global-undo-tree-mode)
    (setq undo-tree-auto-save-history t)
    (setq undo-tree-history-directory-alist  '(("." . "~/.emacs.d/.tmp")))))

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

(leaf visual-regexp
  :doc "A regexp/replace command for Emacs with interactive visual feedback"
  :req "cl-lib-0.2"
  :tag "feedback" "visual" "replace" "regexp"
  :url "https://github.com/benma/visual-regexp.el/"
  :ensure t :require t)

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

(eval-when-compile
  (el-clone :repo "joaotavora/yasnippet")
  (el-clone :repo "mkcms/ivy-yasnippet"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/yasnippet"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/ivy-yasnippet"))
  (autoload-if-found '(yas-global-mode yas-minor-mode) "yasnippet")
  (autoload-if-found '(ivy-yasnippet) "ivy-yasnippet")
  (yas-global-mode t)
  (with-eval-after-load 'yasnippet
    (setq yas-snippet-dirs '("~/.emacs.d/snippets"))))

(eval-when-compile
  (el-clone :repo "mineo/yatemplate"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/yatemplate"))
  (autoload-if-found '(yatemplate-fill-alist) "yatemplate")
  (auto-insert-mode t)
  (yatemplate-fill-alist))

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

(eval-when-compile
  (el-clone :repo "Kyure-A/jobcan.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/jobcan"))
  (autoload-if-found '(jobcan-status) "jobcan"))

(eval-when-compile
  (el-clone :repo "magit/magit"
            :load-paths `(,(locate-user-emacs-file "el-clone/magit/lisp"))))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/magit/lisp"))
  (autoload-if-found '(global-git-commit-mode) "git-commit")
  (autoload-if-found '(magit-status magit-blame) "magit")
  (global-git-commit-mode)
  (with-eval-after-load 'magit
    (setq magit-repository-directories '(("~/ghq/" . 3)))
    (add-hook 'magit-status-mode-hook #'toggle-centaur-tabs-local-mode)))

(leaf mozc
  :doc "minor mode to input Japanese with Mozc"
  :tag "input method" "multilingual" "mule"
  :added "2023-07-20"
  :ensure t
  :require t
  :config (setq mozc-candidate-style 'echo-area))

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

(eval-when-compile
  (el-clone :repo "seagle0128/doom-modeline"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/doom-modeline"))
  (autoload-if-found '(doom-modeline-mode) "doom-modeline")
  (doom-modeline-mode t)
  (with-eval-after-load 'doom-modeline
    (setq doom-modeline-icon t)))

(eval-when-compile
  (el-clone :repo "iqbalansari/emacs-emojify"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emojify"))
  (autoload-if-found '(global-emojify-mode) "emojify")
  (add-hook 'after-init-hook #'global-emojify-mode))

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

(with-delayed-execution
  (show-paren-mode t)
  (with-eval-after-load 'show-paren-mode
    (set-face-underline-p 'show-paren-match-face "#ffffff")
    (setq show-paren-delay 0)
    (setq show-paren-style 'expression)))

(eval-when-compile
  (el-clone :repo "milkypostman/powerline"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/powerline")))

(leaf rainbow-mode
  :doc "Colorize color names in buffers"
  :tag "faces"
  :url "https://elpa.gnu.org/packages/rainbow-mode.html"
  :ensure t :require t
  :hook (web-mode-hook))

(eval-when-compile
  (el-clone :repo "Fanael/rainbow-delimiters"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/rainbow-delimiters"))
  (autoload-if-found '(rainbow-delimiters-mode) "rainbow-delimiters")
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(leaf solaire-mode
  :doc "make certain buffers grossly incandescent"
  :req "emacs-25.1" "cl-lib-0.5"
  :tag "faces" "buffer" "window" "bright" "dim" "emacs>=25.1"
  :url "https://github.com/hlissner/emacs-solaire-mode"
  :emacs>= 25.1
  :ensure t :require t
  :global-minor-mode solaire-global-mode)

(eval-when-compile
  (el-clone :repo "Malabarba/spinner.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/spinner")))

(eval-when-compile
  (el-clone :repo "emacsorphanage/yascroll"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/yascroll"))
  (autoload-if-found '(global-yascroll-bar-mode) "yascroll")
  (global-yascroll-bar-mode t))

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
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
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

(provide 'init)

;; End:
;;; init.el ends here
