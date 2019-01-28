all: model.rds

index.html: index.Rmd model.rds
	R -e "rmarkdown::render('index.Rmd')"

model.rds: model.r model.stan data.rds
	Rscript model.r

data.rds: data.r
	Rscript data.r
	

