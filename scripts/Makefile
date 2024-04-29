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
	10_topsites.ipynb \
	12_concentration.ipynb \
	13_consume_porn_yes_no.ipynb \
	20_duration_on_adultsites.ipynb \
	21_visits_to_adultsites.ipynb \
	22_duration_on_adultsites_independents.ipynb \
	23_tabulated_characteristics_split_by_party.ipynb \
	25_traffic_top10_categories.ipynb \
	30_quantile_reg.ipynb \
	31_quantile_reg_covariates.ipynb \
	40_timeuse.ipynb \
	41_time_of_day.ipynb \
	42_time_of_day_estimates.ipynb \
	--sequence --output


########################################################################
# Alternative classifications
########################################################################
.PHONY: alternative
alternative: ## Make all results via alternative categories
	@echo "==> $@"
	runpynb \
	01_piedomains_get_individual_browsing_data.ipynb \
	02_vt_get_individual_browsing_data.ipynb \
	11_topsites-alternative-classifications.ipynb \
	24_piedomains_duration_on_adultsites.ipynb \
	34_piedomains_quantile_reg.ipynb \
	35_piedomains_quantile_reg_covariates.ipynb \
	36_vt_quantile_reg.ipynb \
	37_vt_quantile_reg_covariates.ipynb \
	--sequence --output




########################################################################
# Other utilities
########################################################################
FIGS_PATH := ../figs/*.p*
TABS_PATH := ../tabs/*.tex
.PHONY: purge
purge:
	@echo "==> $@"
	@echo "Purging created exhibits..."
	rm -f $(FIGS_PATH)
	rm -f $(TABS_PATH)

.PHONY: help
help: ## Show this help message and exit
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'