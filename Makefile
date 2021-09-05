EMACS ?= emacs

init.el: readme.org
	$(EMACS) -Q -q --batch --eval \
		"(progn \
		   (require 'ob-tangle) \
		   (org-babel-tangle-file \"readme.org\" \"init.el\" \"emacs-lisp\"))"
	$(EMACS) -q -l init.el --batch --eval "(byte-compile-file \"init.el\")"
