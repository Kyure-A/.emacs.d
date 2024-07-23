E := emacs

.PHONY: elc
elc:
	$(E) -Q --batch --eval "(progn (require 'ob-tangle) (org-babel-tangle-file (concat user-emacs-directory \"early-init.org\") (concat user-emacs-directory \"early-init.el\") \"emacs-lisp\"))"
	$(E) -Q --batch --eval "(progn (require 'ob-tangle) (org-babel-tangle-file (concat user-emacs-directory \"README.org\") (concat user-emacs-directory \"init.el\") \"emacs-lisp\"))"
	$(E) -Q --batch --eval "(progn (require 'cl-lib) (byte-compile-file (concat user-emacs-directory \"early-init.el\")))"
	$(E) -Q --batch --eval "(progn (require 'cl-lib) (byte-compile-file (concat user-emacs-directory \"init.el\")))"
