all: index.html

index.html: index.Rmd model.rds
	R -e "rmarkdown::render('index.Rmd')"


model.rds: model.r model.stan
	Rscript model.r

