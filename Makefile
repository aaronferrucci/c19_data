
DEFAULT := main.R us_totals.R state_totals.R readme
.PHONY: $(DEFAULT)
default: $(DEFAULT)

$(DEFAULT):
	Rscript -e 'source("$@");'

.PHONY: readme
readme:
	[ -f README.md.stub ]
	[ -f per_state_links.md ]
	cat README.md.stub per_state_links.md > README.md
