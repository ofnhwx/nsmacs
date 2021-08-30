EMACS ?= emacs

init.el: init.org
	$(EMACS) -Q -q --batch --eval \
		"(progn \
		   (require 'ob-tangle) \
		   (org-babel-tangle-file \"init.org\" \"init.el\" \"emacs-lisp\"))"
	$(EMACS) -q -l init.el --batch --eval "(byte-compile-file \"init.el\")"
