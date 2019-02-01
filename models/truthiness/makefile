IMAGE := docker.dragonfly.co.nz/dragonverse-18.04
RUN ?= docker run -it --rm --net=host --user=$$(id -u):$$(id -g) -e RUN= -v$$(pwd)/../..:/work -w /work/models/truthiness $(IMAGE)

all: model.rds

model.rds: model.r model.stan data.rds
	$(RUN) bash -c "Rscript model.r"

data.rds: data.r
	$(RUN) bash -c "Rscript data.r"
	

