HOST ?= 192.168.0.136

all:

.PHONY: data run local

run:
	 Rscript -e "shiny::runApp('.', port=3078, host = '$(HOST)')"

local:
	 Rscript -e "shiny::runApp('.', port=3078, host = '127.0.0.1')"

data: data/.data
data/.data: data.r
	Rscript data.r  && \
	touch data/.data


deploy:
	Rscript -e "rsconnect::deployApp('.', appName='qfly-demo')"

ico:
	/usr/bin/convert -resize x32 -gravity center  data/qfly.png -flatten -colors 256 -background transparent www/favicon.ico
	cp www/favicon.ico data/
