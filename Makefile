.DEFAULT_GOAL := help

FIGURES_DIR := ./figs
TABLES_DIR := ./tabs
SCRIPTS_DIR := ./scripts
MS_DIR := ./ms
PY_UTILITIES := $(SCRIPTS_DIR)/utils/utils.py $(SCRIPTS_DIR)/utils/data_utils.py

EXECUTE_JUPYTERNB = cd $(SCRIPTS_DIR) && runpynb $(<F) 

.PHONY: descriptives
descriptives: # Make descriptive results
	@echo "+ $@"
	$(EXECUTE_JUPYTERNB) 1*.ipynb

.PHONY: summary
summary: # Make tables for summary statistics and percentiles
	@echo "+ $@"
	$(EXECUTE_JUPYTERNB) 2*.ipynb 

.PHONY: reg
reg: # Make regression results (tables & figures)	
	@echo "+ $@"
	$(EXECUTE_JUPYTERNB) 3*.ipynb

.PHONY: purge
purge: # Purge all output files in ./figs and ./tabs
	@echo "+ $@"	
	rm -f $(FIGURES_DIR)/*	
	rm -f $(TABLES_DIR)/*	

.PHONY: ms
ms: # Build LaTeX manuscript using latexmk
	@echo "+ $@"
	@echo "Purging existing pdf"
	rm -f $(MS_DIR)/adult.pdf
	cd $(MS_DIR) && latexmk -pdf adult.tex
	cd $(MS_DIR) && latexmk -c

.PHONY: build	
build: # Prepare data and figure folders if they do not exist
build: purge descriptives summary reg

.PHONY: all
all: # Run notebooks to get results and compile manuscript
all: build ms

.PHONY: help		
help: # Show Help
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'