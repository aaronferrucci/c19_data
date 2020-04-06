
RSCRIPTS := main.R us_totals.R state_totals.R
.PHONY: $(RSCRIPTS)
default: $(RSCRIPTS) readme git-stuff

$(RSCRIPTS):
	Rscript -e 'source("$@");'

.PHONY: readme
readme:
	[ -f README.md.stub ]
	[ -f per_state_links.md ]
	cat README.md.stub per_state_links.md > README.md

NOW=$(shell date "+%m/%d/%Y %T %Z")
git-stuff:
	git add images/*.png README.md
	git commit -m "$(NOW) autoupdate. Beep boop."
	git push origin master
