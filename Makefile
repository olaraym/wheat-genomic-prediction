.PHONY: env data analysis figures all test clean

ENV_NAME := $(shell awk '/^name:/ {print $$2}' environment.yml)

env:            ## create the conda environment
	conda env create -f environment.yml || conda env update -f environment.yml

data:           ## download raw data into data/raw (edit for each project)
	mkdir -p data/raw
	@echo "TODO: add download commands"

analysis:       ## run the analysis
	@echo "TODO: add analysis commands"

figures:        ## build figures into results/figures
	mkdir -p results/figures
	@echo "TODO: add figure commands"

all: data analysis figures

test:           ## run tests on the toy data (used by CI)
	pytest -q tests

clean:
	rm -rf data/raw results/figures .pytest_cache
