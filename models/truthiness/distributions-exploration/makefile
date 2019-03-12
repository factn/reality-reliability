all: explore.html

explore.html: explore.r custom.css
	Rscript -e "rmarkdown::render('explore.r', clean=F)"
