IMAGE := docker.dragonfly.co.nz/dragonverse-18.04
# RUN ?= docker run -it --rm --net=host --user=$$(id -u):$$(id -g) -e RUN= -v$$(pwd)/../../..:/work -w /work/models/truthiness/time-independent-beta $(IMAGE)
RUN=

all: spin.html

generated/.here:
	mkdir -p generated  &&  touch generated/.here

generated/data.rdata: generated/.here  data.r
	$(RUN) bash -c "Rscript data.r"

generated/model.rds: run-model.r  model.stan  generated/data.rdata
	$(RUN) bash -c "Rscript run-model.r"

generated/model-results.rdata: generated/model.rds \
		model-results.r
	Rscript model-results.r

spin.html: generated/data.rdata \
		www/custom.css \
		generated/model.rds \
		generated/model-results.rdata \
		spin.r 
	$(RUN) bash -c "Rscript -e 'rmarkdown::render(\"spin.r\", clean=F)'"

clean:
	rm -fr cache &&  rm -f spin.spin.R spin.spin.Rmd spin.utf8.md spin.knit.md spin.html

cleanall:
	rm -fr generated spin_files
	rm -fr cache &&  rm -f spin.spin.R spin.spin.Rmd spin.utf8.md spin.knit.md spin.html
