IMAGE := docker.dragonfly.co.nz/dragonverse-18.04
# RUN ?= docker run -it --rm --net=host --user=$$(id -u):$$(id -g) -e RUN= -v$$(pwd)/../../..:/work -w /work/models/truthiness/time-independent-beta $(IMAGE)
RUN=

all: spin.html


MODELS_I := $(shell seq -w 0 1 2400) 
MODELS := $(patsubst %,generated/.model%,$(MODELS_I))

test:
	@echo $(MODELS_I)
	@echo $(MODELS)

generated/data.rdata: data.r
	$(RUN) bash -c "Rscript data.r"


generated/.model%: run-model.r \
		generated/data.rdata
	touch .running$*  &&  Rscript $< $*  &&  rm .running$*  &&  touch $@

allmods: generated/.alldone
generated/.alldone: $(MODELS)
	touch generated/.alldone


generated/model-results.rdata: generated/.alldone \
		model-results.r
	Rscript model-results.r

spin.html: generated/data.rdata \
		www/custom.css \
		generated/.alldone \
		generated/model-results.rdata \
		spin.r 
	$(RUN) bash -c "Rscript -e 'rmarkdown::render(\"spin.r\", clean=F)'"

clean:
	rm -fr cache &&  rm -f spin.spin.R spin.spin.Rmd spin.utf8.md spin.knit.md spin.html

cleanall:
	rm -fr generated/* spin_files
	rm -fr cache &&  rm -f spin.spin.R spin.spin.Rmd spin.utf8.md spin.knit.md spin.html .Rhistory *.rds *.png


