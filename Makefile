
RSCRIPTS := counties.R
.PHONY: $(RSCRIPTS)
default: $(RSCRIPTS) 

$(RSCRIPTS):
	Rscript -e 'source("$@");'

NOW=$(shell date "+%m/%d/%Y %T %Z")
GIT_STUFF := git-add git-commit git-push
.PHONY: $(GIT_STUFF)
git-stuff: $(GIT_STUFF)
git-add:
	git add images/*.png README.md
git-commit:
	git commit -m "$(NOW) autoupdate. Beep boop."
git-push:
	git push origin master
