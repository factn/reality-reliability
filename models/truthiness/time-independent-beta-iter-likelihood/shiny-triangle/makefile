HOST ?= 192.168.0.136

all:

.PHONY: data run local

run:
	 Rscript -e "shiny::runApp('.', port=5411, host = '$(HOST)')"

data: data/.data
data/.data: data.r
	Rscript data.r  && \
	touch data/.data

