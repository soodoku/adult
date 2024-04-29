.DEFAULT_GOAL := help

.PHONY: all
all: ## Make all results (will purge existing results)
all: purge main alternative
	@echo "==> $@"


########################################################################
# Main classification
########################################################################
.PHONY: main
main: ## Make all results via YG categories
	@echo "==> $@"
	runpynb \
	00_get_individual_browsing_data.ipynb \
	20_duration_on_adultsites.ipynb \
	30_quantile_reg.ipynb \
	31_quantile_reg_covariates.ipynb \
	--sequence


########################################################################
# Other utilities
########################################################################
FIGS_PATH := ./figs
TABS_PATH := ./tabs
purge:
	@echo "==> $@"
	@echo "Purging created exhibits..."
	rm -f $(FIGS_PATH)
	rm -f $(TAB_PATH)

.PHONY: help
help: ## Show this help message and exit
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'