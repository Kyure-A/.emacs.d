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

(global-set-key (kbd "<f2>") 'eat)
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

(global-set-key (kbd "C-c e b") 'eval-buffer)
(global-set-key (kbd "C-c e m") 'menu-bar-mode)
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
  (el-clone :repo "abo-abo/avy"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/avy"))
  (with-eval-after-load 'avy
    (setq avy-all-windows nil)
    (setq avy-background t)))

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
  (el-clone :repo "zk-phi/sublimity"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/sublimity"))
  (autoload-if-found '(sublimity-mode) "sublimity")
  (sublimity-mode t)
  (with-eval-after-load 'sublimity
    (setq sublimity-attractive-centering-width 200)
    (setq sublimity-scroll-weight 15)
    (setq sublimity-scroll-drift-length 10)))

(setq-default indent-tabs-mode nil)

(with-delayed-execution
  (save-place-mode t))

(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default 'buffer-file-coding-system 'utf-8)

(with-delayed-execution
  (delete-selection-mode t))

(defun auto-yes (old-fun &rest args)
  (cl-letf (((symbol-function 'y-or-n-p) (lambda (prompt) t))
             ((symbol-function 'yes-or-no-p) (lambda (prompt) t)))
    (apply old-fun args)))

(advice-add #'async-shell-command :around #'auto-yes)

(add-to-list 'display-buffer-alist '("*Async Shell Command*" display-buffer-no-window (nil)))

(defun my/compile-init-org ()
  (shell-command-to-string
   (mapconcat #'shell-quote-argument
              `("emacs" "-Q" "--batch" "--eval" "(progn (require 'ob-tangle) (org-babel-tangle-file \"~/.emacs.d/init.org\" \"~/.emacs.d/init.el\" \"emacs-lisp\"))")
              " ")))

(defun my/compile-early-init-org ()
  (shell-command-to-string
   (mapconcat #'shell-quote-argument
              `("emacs" "-Q" "--batch" "--eval" "(progn (require 'ob-tangle) (org-babel-tangle-file \"~/.emacs.d/early-init.org\" \"~/.emacs.d/early-init.el\" \"emacs-lisp\"))")
              " ")))


(defun my/compile-init-files ()
  (interactive)
  (my/compile-early-init-org)
  (my/compile-init-org)
  (byte-compile-file "~/.emacs.d/early-init.el")
  (byte-compile-file "~/.emacs.d/init.el"))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'my/compile-init-files)))

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

(eval-when-compile
  (el-clone :repo "emacsmirror/recently"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/recently"))
  (autoload-if-found '(recently-mode) "recently")
  (recently-mode t))

(set-frame-parameter nil 'unsplittable t)

(setq custom-file (locate-user-emacs-file "custom.el"))

(setq debug-on-error t)

(setq create-lockfiles nil)

(setq backup-directory-alist '((".*" . "~/.tmp")))

(setq auto-save-file-name-transforms '((".*" "~/.tmp/" t)))
(setq auto-save-list-file-prefix nil)
(setq auto-save-default nil)

(eval-when-compile
  (el-clone :repo "skeeto/emacs-aio"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-aio")))

(eval-when-compile
  (el-clone :repo "rejeep/ansi"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/ansi")))

(eval-when-compile
  (el-clone :repo "jwiegley/emacs-async"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-async")))

(eval-when-compile
  (el-clone :repo "chuntaro/emacs-async-await"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-async-await")))

(eval-when-compile
  (el-clone :repo "alezost/bui.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/bui")))

(eval-when-compile
    (el-clone :repo "Alexander-Miller/cfrs"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/cfrs")))

(eval-when-compile
  (el-clone :repo "phikal/compat.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/compat")))

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
  (el-clone :repo "magit/emacsql"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacsql")))

(eval-when-compile
  (el-clone :repo "cask/epl"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/epl")))

(eval-when-compile
  (el-clone :repo "rejeep/f.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/f")))

(eval-when-compile
  (el-clone :repo "sebastiencs/frame-local"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/frame-local")))

(eval-when-compile
  (el-clone :repo "Wilfred/ht.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/ht")))

(eval-when-compile
  (el-clone :repo "doublep/iter2"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/iter2")))

(eval-when-compile
  (el-clone :repo "conao3/keg.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/keg"))
  (add-to-list 'auto-mode-alist '("Keg" . emacs-lisp-mode)))

(eval-when-compile
  (el-clone :repo "Fuco1/emacs-lgr"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-lgr")))

(with-delayed-execution
  (define-key lisp-interaction-mode-map (kbd "C-j") #'eval-print-last-sexp))

(eval-when-compile
  (el-clone :repo "melpa/package-build"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/package-build"))
  (require 'package-build))

(eval-when-compile
  (el-clone :repo "purcell/package-lint"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/package-lint"))
  (autoload-if-found '(package-lint-current-buffer) "package-lint"))

(eval-when-compile
  (el-clone :repo "tjarvstrand/pos-tip"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/pos-tip")))

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
  (el-clone :repo "skeeto/emacs-web-server"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-web-server")))

(eval-when-compile
  (el-clone :repo "politza/tablist"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/tablist")))

(eval-when-compile
  (el-clone :repo "magit/transient"
            :load-paths `(,(locate-user-emacs-file "el-clone/transient/lisp"))))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/transient/lisp")))

(eval-when-compile
  (el-clone :repo "emacs-elsa/trinary-logic"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/trinary-logic")))

(eval-when-compile
  (el-clone :repo "Alexander-Miller/pfuture"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/pfuture")))

(eval-when-compile
  (el-clone :repo "emacsorphanage/pkg-info"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/pkg-info")))

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

(eval-when-compile
  (el-clone :repo "cask/shut-up"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/shut-up")))

(eval-when-compile
  (el-clone :repo "sviridov/undercover.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/undercover")))

(eval-when-compile
  (el-clone :repo "ahyatt/emacs-websocket"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-websocket")))

(eval-when-compile
  (el-clone :repo "zkry/yaml.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/yaml")))

(eval-when-compile
  (el-clone :url "https://repo.or.cz/arduino-mode.git"
            :repo "arduino-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/arduino-mode"))
  (autoload-if-found '(arduino-mode) "arduino-mode")
  (add-to-list 'auto-mode-alist '("\\.ino$" . arduino-mode)))

(with-delayed-execution
  (autoload-if-found '(lisp-mode) "lisp-mode")
  (add-to-list 'auto-mode-alist '("\\.cl$" . lisp-mode)))

(eval-when-compile
  (el-clone :repo "joaotavora/sly"
            :load-paths `(,(locate-user-emacs-file "el-clone/sly/lib")
                          ,(locate-user-emacs-file "el-clone/sly/contrib")
                          ,(locate-user-emacs-file "el-clone/sly/slynk"))))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/sly"))
  (autoload-if-found '(sly) "sly")
  (setq inferior-lisp-program "/usr/bin/sbcl")
  (defun start-sly ()
    "Make Sly startup behavior similar to Slime"
    (interactive)
    (split-window-right)
    (sly)))

(eval-when-compile
  (el-clone :repo "bradyt/dart-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dart-mode"))
  (autoload-if-found '(dart-mode) "dart-mode")
  (add-to-list 'auto-mode-alist '("\\.dart$" . dart-mode))
  (with-eval-after-load 'dart
    (add-hook 'dart-mode-hook #'flycheck-mode)
    (setq dart-enable-analysis-server t)))

(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-dart"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-dart"))
  (add-hook 'dart-mode-hook #'lsp)
  (with-eval-after-load 'lsp-dart
    (dap-register-debug-template "Flutter :: Custom debug"
                               (list :flutterPlatform "x86_64" :program "lib/main_debug.dart" :args
                                     '("--flavor" "customer_a")))))

(eval-when-compile
  (el-clone :repo "amake/flutter.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/flutter"))
  (autoload-if-found '(flutter-run-or-hot-reload) "flutter")
  (with-eval-after-load 'flutter
    (add-hook 'dart-mode (lambda () (add-hook 'after-save-hook #'flutter-run-or-hot-reload nil t)))))

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

(eval-when-compile
  (el-clone :repo "NixOS/nix-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/nix-mode"))

  (autoload-if-found '(nix-mode) "nix-mode")
  (autoload-if-found '(nix-drv-mode) "nix-drv-mode")
  (autoload-if-found '(company-nix) "nix-company")
  (add-to-list 'auto-mode-alist '("\\.nix$" . nix-mode))

  (with-eval-after-load 'nix-mode
    (add-hook 'nix-mode-hook #'lsp))

  (with-eval-after-load 'company
    (push 'company-nix company-backends)))

(eval-when-compile
  (el-clone :repo "jschaf/powershell.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/powershell"))
  (autoload-if-found '(powershell powershell-mode) "powershell")
  (add-to-list 'auto-mode-alist '("\\.ps1$" . powershell-mode)))

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
  (add-to-list 'auto-mode-alist '("\\.js$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.mjs$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.cjs$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.ts$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.mts$" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.cts$" . typescript-mode))
  (add-hook 'typescript-mode-hook #'tide-setup)
  (add-hook 'typescript-mode-hook #'flycheck-mode)
  (setq tide-node-executable "~/.nix-profile/bin/node"))

(eval-when-compile
  (el-clone :repo "emacsmirror/csv-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/csv-mode"))
  (autoload-if-found '(csv-mode) "csv-mode")
  (add-to-list 'auto-mode-alist '("\\.csv$" . csv-mode)))

(eval-when-compile
  (el-clone :repo "jrblevin/markdown-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/markdown-mode"))
  (autoload-if-found '(markdown-mode gfm-mode) "markdown-mode")
  (add-to-list 'auto-mode-alist '("\\.md$" . gfm-mode))
  (add-to-list 'auto-mode-alist '("\\.markdown$" . gfm-mode))
  (with-eval-after-load 'markdown
    (setq markdown-command "github-markup")
    (setq markdown-command-needs-filename t)))

(with-eval-after-load 'org
  (setq org-directory "~/document/org")
  (setq org-latex-pdf-process '("lualatex --draftmode %f"
                              "lualatex %f"))
  (setq org-startup-truncated nil)
  (setq org-enforce-todo-dependencies t)
  (setq org-support-shift-select t)
  (setq org-latex-pdf-process '("lualatex --draftmode %f"
                             "lualatex %f"))
  (setq org-latex-default-class "ltjsarticle"))

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

(with-delayed-execution
  (with-eval-after-load 'org
    (require 'org-tempo)))

(with-delayed-execution
  (autoload-if-found '(vhdl-mode) "vhdl")
  (add-to-list 'auto-mode-alist '("\\.hdl$" . vhdl-mode)))

(eval-when-compile
  (el-clone :repo "fxbois/web-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/web-mode"))
  (autoload-if-found '(web-mode) "web-mode" nil t)
  (add-to-list 'auto-mode-alist '("\\.[agj]sp$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.gsp$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.liquid$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.svg$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl$" . web-mode))

  (with-eval-after-load 'web-mode
    (setq web-mode-markup-indent-offset 2)
    (setq web-mode-enable-auto-pairing t)
    (setq web-mode-enable-auto-closing t)
    (setq web-mode-tag-auto-close-style 2)
    (setq web-mode-enable-auto-quoting nil)
    (setq web-mode-enable-current-column-highlight t)
    (setq web-mode-enable-current-element-highlight t)
    (setq web-mode-comment-style 2)
    (setq web-mode-enable-auto-indentation nil)))

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

(eval-when-compile
  (el-clone :repo "purcell/exec-path-from-shell"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/exec-path-from-shell"))
  (autoload-if-found '(exec-path-from-shell-initialize) "exec-path-from-shell")
  (exec-path-from-shell-initialize)
  (with-eval-after-load 'exec-path-from-shell
    (setq exec-path-from-shell-check-startup-files nil)
    (setq exec-path-from-shell-arguments nil)
    (setq exec-path-from-shell-variables '("ASDF_CONFIG_FILE" "ASDF_DATA_DIR" "ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" "ASDF_DIR"
                                        "GPG_AGENT_INFO" "GPG_KEY_ID" "PATH" "SHELL" "TEXMFHOME" "WSL_DISTRO_NAME" "http_proxy"))))

(eval-when-compile
  (el-clone :repo "abo-abo/ace-window"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/ace-window")))

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

(eval-when-compile
  (el-clone :repo "company-mode/company-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/company-mode"))
  (autoload-if-found '(global-company-mode) "company")
  (global-company-mode)
  (with-eval-after-load 'company
    (define-key company-active-map (kbd "<tab>") #'company-complete-common-or-cycle)
    (setq company-idle-delay 0)
    (setq company-minimum-prefix-length 2)
    (setq company-selection-wrap-around t)
    (setq company-tooltip-align-annotations t)
    (setq company-require-match 'never)
    (setq company-transformers '(company-sort-by-statistics company-sort-by-backend-importance))))

(eval-when-compile
  (el-clone :repo "sebastiencs/company-box"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/company-box"))
  (autoload-if-found '(company-box-mode) "company-box")
  (with-eval-after-load 'company-mode
    (when window-system
      (add-hook 'company-mode-hook #'company-box-mode)))
  (with-eval-after-load 'company-box
    (setq company-box-icons-alist 'company-box-icons-all-the-icons))
  (with-eval-after-load 'company-box-doc
    (setq company-box-doc-enable nil)))

(eval-when-compile
  (el-clone :repo "tumashu/company-posframe"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/company-posframe"))
  (autoload-if-found '(company-posframe-mode) "company-posframe")
  (company-posframe-mode t))

(eval-when-compile
  (el-clone :repo "expez/company-quickhelp"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/company-quickhelp"))
  (autoload-if-found '(company-quickhelp-mode) "company-quickhelp")
  (company-quickhelp-mode t))

(eval-when-compile
  (el-clone :repo "Alexander-Miller/company-shell"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/company-shell"))
  (autoload-if-found '(company-shell) "company-shell")
  (add-to-list 'company-backends 'company-shell))

(eval-when-compile
  (el-clone :repo "company-mode/company-statistics"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/company-statistics"))
  (autoload-if-found '(company-statistics-mode) "company-statistics")
  (company-statistics-mode t))

(defvar dashboard-recover-layout-p nil
  "Whether recovers the layout.")

(defun dashboard-goto-recent-files ()
  "Go to recent files."
  (interactive)
  (let ((func (local-key-binding "r")))
    (and func (funcall func))))

(defun open-dashboard ()
  "Open the *dashboard* buffer and jump to the first widget."
  (interactive)
  (setq dashboard-recover-layout-p t)
  ;; Display dashboard in maximized window
  (delete-other-windows)
  ;; Refresh dashboard buffer
  (dashboard-open)
  ;; Jump to the first section
  (dashboard-goto-recent-files))

(defun quit-dashboard ()
  "Quit dashboard window."
  (interactive)
  (quit-window t)
  (and dashboard-recover-layout-p
       (and (bound-and-true-p winner-mode) (winner-undo))
       (setq dashboard-recover-layout-p nil)))

(eval-when-compile
  (el-clone :repo "bbatsov/projectile"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/projectile"))
  (require 'projectile))

(eval-when-compile
  (el-clone :repo "emacs-dashboard/emacs-dashboard"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-dashboard"))
  (autoload-if-found '(dashboard-mode dashboard-open) "dashboard")
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
  (setq dashboard-startup-banner (if (or (eq window-system 'x) (eq window-system 'ns) (eq window-system 'w32)) "~/.emacs.d/static/banner.png" "~/.emacs.d/static/banner.txt"))
  (open-dashboard)
  (with-eval-after-load 'dashboard
    (dashboard-setup-startup-hook)
    (define-key dashboard-mode-map (kbd "<f3>") #'quit-dashboard)))

(eval-when-compile
  (el-clone :repo "alexluigit/dirvish"
            :load-paths `(,(locate-user-emacs-file "el-clone/dirvish/extensions"))))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dirvish"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dirvish/extensions"))
  (autoload-if-found '(dirvish-override-dired-mode) "dirvish")
  (dirvish-override-dired-mode)
  (with-eval-after-load 'dirvish
    (setq dirvish-attributes '(vc-state subtree-state all-the-icons collapse git-msg file-time file-size))
    (setq dirvish-preview-dispatchers (cl-substitute 'pdf-preface 'pdf dirvish-preview-dispatchers))))

(with-eval-after-load 'dired
  (setq dired-recursive-copies 'always)
  (put 'dired-find-alternate-file 'disabled nil)
  (define-key dired-mode-map (kbd "RET") #'dired-open-in-accordance-with-situation)
  (define-key dired-mode-map (kbd "<left>") #'dired-up-directory)
  (define-key dired-mode-map (kbd "<right>") #'dired-open-in-accordance-with-situation))

(eval-when-compile
  (el-clone :repo "jwiegley/emacs-async"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-async"))
  (autoload-if-found '(dired-async-mode) "dired-async")
  (dired-async-mode t))

(eval-when-compile
  (el-clone :repo "emacsorphanage/dired-k"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dired-k"))
  (autoload-if-found '(dired-k) "dired-k")
  (add-hook 'dired-initial-position-hook #'dired-k))

(defun dired-open-in-accordance-with-situation ()
  (interactive)
  (let ((file (dired-get-filename)))
    (if (file-directory-p file)
        (dired-find-alternate-file)
      (dired-find-file))))

(eval-when-compile
  (el-clone :repo "protesilaos/dired-preview"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dired-preview"))
  (autoload-if-found '(dired-preview-global-mode) "dired-preview" nil t)
  ;; (dired-preview-global-mode t)
  )

(eval-when-compile
  (el-clone :repo "renard/dired-toggle-sudo"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dired-toggle-sudo"))
  (require 'dired-toggle-sudo))

(eval-when-compile
  (el-clone :repo "editorconfig/editorconfig-emacs"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/editorconfig-emacs"))
  (autoload-if-found '(editorconfig-mode) "editorconfig")
  (editorconfig-mode t))

(eval-when-compile
  (el-clone :repo "kaz-yos/eval-in-repl"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/eval-in-repl")))

(eval-when-compile
  (el-clone :repo "flycheck/flycheck"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/flycheck"))
  (autoload-if-found '(flycheck-mode flycheck-define-checker) "flycheck")
  (with-eval-after-load 'flycheck
    (setq flycheck-idle-change-delay 0)))

(eval-when-compile
  (el-clone :repo "emacsmirror/gcmh"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/gcmh"))
  (autoload-if-found '(gcmh-mode) "gcmh")
  (gcmh-mode)
  (with-eval-after-load 'gcmh
    (setq gcmh-verbose t)))

(eval-when-compile
  (el-clone :repo "abo-abo/hydra"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/hydra")))

(eval-when-compile
  (el-clone :repo "bmag/imenu-list"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/imenu-list")))

;; ivy, counsel and swiper are managed as monorepo.
(eval-when-compile
  (el-clone :repo "abo-abo/swiper"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/swiper")))

(with-delayed-execution-priority-high
  (autoload-if-found '(counsel-mode) "counsel")
  (counsel-mode t)
  (with-eval-after-load 'counsel
    (define-key counsel-mode-map [remap find-file] nil)
    (setq counsel-find-file-ignore-regexp (regexp-opt '("./" "../")))
    (setq read-file-name-function #'disable-counsel-find-file)))

(defun disable-counsel-find-file (&rest args)
  "Disable `counsel-find-file' and use the original `find-file' with ARGS."
  (let ((completing-read-function #'completing-read-default)
        (completion-in-region-function #'completion--in-region))
    (apply #'read-file-name-default args)))

(eval-when-compile
  (el-clone :repo "ericdanan/counsel-projectile"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/counsel-projectile"))
  (autoload-if-found '(counsel-projectile-mode) "counsel-projectile")
  (counsel-projectile-mode t))

(with-delayed-execution-priority-high
  (autoload-if-found '(ivy-mode ivy-read ivy-completion-read) "ivy")
  (with-eval-after-load 'ivy
    (setq ivy-use-virtual-buffers t)
    (setq ivy-wrap t)
    (setq ivy-extra-directories t)
    (setq enable-recursive-minibuffers t)))

(eval-when-compile
  (el-clone :repo "Yevgnen/ivy-rich"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/ivy-rich"))
  (autoload-if-found '(ivy-rich-mode) "ivy-rich")
  (with-eval-after-load 'ivy
    (ivy-rich-mode t)))

(eval-when-compile
  (el-clone :repo "tumashu/ivy-posframe"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/ivy-posframe"))
  (autoload-if-found '(ivy-posframe-mode) "ivy-posframe")
  (with-eval-after-load 'ivy
    (ivy-posframe-mode t)
    (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))))

(with-delayed-execution-priority-high
  (autoload-if-found '(swiper) "swiper"))

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

(eval-when-compile
  (el-clone :repo "emacs-lsp/dap-mode"))

(with-delayed-execution
  (message "Install dap-mode...")
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dap-mode"))
  (autoload-if-found '(dap-debug) "dap-mode"))

(eval-when-compile
  (el-clone :repo "dengste/minimap"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/minimap"))
  (autoload-if-found '(minimap-mode) "minimap")
  (with-eval-after-load 'minimap
    (setq minimap-window-location 'right)
    (setq minimap-update-delay 0.2)
    (setq minimap-minimum-width 20)
    (setq minimap-major-modes '(prog-mode org-mode))))

(eval-when-compile
  (el-clone :repo "magnars/multiple-cursors.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/multiple-cursors"))
  (autoload-if-found '(mc/edit-lines mc/mark-next-like-this mc/mark-previous-like-this mc/mark-all-like-this) "multiple-cursors")
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C->") #'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") #'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") #'mc/mark-all-like-this))

(eval-when-compile
  (el-clone :repo "jaypei/emacs-neotree"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-neotree"))
  (require 'neotree)
  ;; (autoload-if-found '(neotree-hide neotree-dir neotree-make-executor neo-open-file neo-open-dir) "neotree")
  (with-eval-after-load 'neotree
    (setq neo-smart-open t)
    (setq eo-create-file-auto-open t)
    (setq neo-theme (if (display-graphic-p) 'icons 'arrow))))

(eval-when-compile
  (el-clone :repo "ayanyan/nihongo-util"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/nihongo-util"))
  (require 'nu-fun)
  (setq nu-my-toten "，")
  (setq nu-my-kuten "．"))

(eval-when-compile
  (el-clone :repo "emacsmirror/paredit"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/paredit")))

(eval-when-compile
  (el-clone :repo "emacsorphanage/popwin"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/popwin"))
  (autoload-if-found '(popwin-mode) "popwin")
  (popwin-mode t)
  (with-eval-after-load 'popwin
    (setq display-buffer-function 'popwin:display-buffer)
    (setq popwin:special-display-config t)
    (setq popwin:popup-window-position 'bottom)))

(eval-when-compile
  (el-clone :repo "tumashu/posframe"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/posframe")))

(eval-when-compile
  (el-clone :repo "skeeto/skewer-mode")
  (el-clone :repo "mooz/js2-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/skewer"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/js2")))

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

(eval-when-compile
  (el-clone :repo "benma/visual-regexp.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/visual-regexp"))
  (autoload-if-found '(vr/replace) "visual-regexp"))

(eval-when-compile
  (el-clone :repo "justbur/emacs-which-key"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-which-key"))
  (autoload-if-found '(which-key-mode) "which-key")
  (which-key-mode))

(eval-when-compile
  (el-clone :repo "yanghaoxie/which-key-posframe"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/which-key-posframe"))
  (autoload-if-found '(which-key-posframe-mode) "which-key-posframe")
  (with-eval-after-load 'which-key
    (which-key-posframe-mode)))

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

(eval-when-compile
  (el-clone :repo "Silex/docker.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/docker"))
  (require 'docker))

(eval-when-compile
  (el-clone :repo "Mstrodl/elcord"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/elcord")))

(eval-when-compile
  (el-clone :repo "Kyure-A/jobcan.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/jobcan"))
  (require 'jobcan))

(eval-when-compile
  (el-clone :repo "magit/magit"
            :load-paths `(,(locate-user-emacs-file "el-clone/magit/lisp")))
  (el-clone :repo "magit/transient"
            :load-paths `(,(locate-user-emacs-file "el-clone/transient/lisp")))
  (el-clone :repo "magit/with-editor"
            :load-paths `(,(locate-user-emacs-file "el-clone/with-editor/lisp"))))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/magit/lisp"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/transient/lisp"))
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/with-editor/lisp"))
  (autoload-if-found '(global-git-commit-mode) "git-commit")
  (autoload-if-found '(magit-status magit-blame) "magit")
  (global-git-commit-mode)
  (with-eval-after-load 'magit
    (setq magit-repository-directories '(("~/ghq/" . 3)))
    (add-hook 'magit-status-mode-hook #'toggle-centaur-tabs-local-mode)))

(eval-when-compile
  (el-clone :repo "abicky/nodejs-repl.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/nodejs-repl")))

(eval-when-compile
  (el-clone :repo "rejeep/nvm.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/nvm")))

(eval-when-compile
  (el-clone :repo "conao3/oj.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/oj"))
  (with-eval-after-load 'oj
    (setq oj-shell-program "zsh")
    (setq oj-open-home-dir "~/oj-files/")
    (setq oj-default-online-judge 'atcoder)
    (setq oj-compiler-c "gcc")
    (setq oj-compiler-python "cpython")))

(eval-when-compile
  (el-clone :repo "jscheid/prettier.el"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/prettier"))
  (add-hook 'after-init-hook #'global-prettier-mode))

(eval-when-compile
  (el-clone :repo "syohex/emacs-quickrun"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-quickrun"))
  (autoload-if-found '(quickrun) "emacs-quickrun")
  (push '("*quickrun*") popwin:special-display-config)
  (defun quickrun-sc (start end)
    (interactive "r")
    (if mark-active
        (quickrun :start start :end end)
      (quickrun))))

(eval-when-compile
  (el-clone :repo "domtronn/all-the-icons.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/all-the-icons")))

(eval-when-compile
  (el-clone :repo "wyuenho/all-the-icons-dired"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/all-the-icons-dired"))
  (autoload-if-found '(all-the-icons-dired-mode) "all-the-icons-dired")
  (add-hook 'dired-mode #'all-the-icons-dired-mode))

(eval-when-compile
  (el-clone :repo "seagle0128/all-the-icons-ivy-rich"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/all-the-icons-ivy-rich"))
  (autoload-if-found '(all-the-icons-ivy-rich-mode) "all-the-icons-ivy-rich")
  (all-the-icons-ivy-rich-mode t))

(eval-when-compile
  (el-clone :repo "Malabarba/beacon"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/beacon"))
  (autoload-if-found '(beacon-mode) "beacon")
  (beacon-mode t)
  (with-eval-after-load 'beacon
    (setq beacon-color "red")))

(with-delayed-execution
  (custom-set-variables '(display-line-numbers-width-start t)))

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

(eval-when-compile
  (el-clone :repo "rainstormstudio/nerd-icons.el"))

(with-delayed-execution-priority-high
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/nerd-icons")))

(eval-when-compile
  (el-clone :repo "purcell/page-break-lines"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/page-break-lines"))
  (autoload-if-found '(page-break-lines-mode global-page-break-lines-mode) "page-break-lines")
  (global-page-break-lines-mode t))

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

(eval-when-compile
  (el-clone :repo "emacsmirror/rainbow-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/rainbow"))
  (autoload-if-found '(rainbow-mode) "rainbow")
  (add-hook 'web-mode-hook #'rainbow-mode))

(eval-when-compile
  (el-clone :repo "Fanael/rainbow-delimiters"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/rainbow-delimiters"))
  (autoload-if-found '(rainbow-delimiters-mode) "rainbow-delimiters")
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(eval-when-compile
  (el-clone :repo "hlissner/emacs-solaire-mode"))

(with-delayed-execution
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-solaire")))

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
