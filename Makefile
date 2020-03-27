
DEFAULT := main.R us_totals.R  state_totals.R  
.PHONY: $(DEFAULT)
default: $(DEFAULT)

$(DEFAULT):
	Rscript -e 'source("$@");'
