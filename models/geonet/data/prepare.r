library(data.table)
library(sf)
library(Matrix)

#Convert felt points to spatial objects, in NZTM
felt <- st_transform(st_as_sf(fread('felt_reports.csv'),
		coords=c("felt_lon", "felt_lat"), crs=4326), 2193)

bb <- st_transform(
	st_as_sf(data.frame(long=c(174.563, 174.997), lat= c(-41.394, -41.181)), 	coords=c("long", "lat"), 
	crs=4326), 2193)

domain <- st_make_grid(bb, n=c(1, 1))


#Select the felt reports that are in the domain
wellington <- felt[st_within(felt, domain, sparse=FALSE), ]


#Make a hexagonal grid that is around 1 km in size
hex <- st_sf(st_make_grid(
		st_as_sfc(st_bbox(wellington)), 
		cellsize=1000, square=FALSE))
hex$hex_id <- seq(1, nrow(hex))

wellington <- st_join(wellington, hex)

# Now make the neighbourhood matrix and inputs for the CAR model
neighbours <- do.call(rbind, lapply(seq(nrow(hex)), function(i){
	touching <- hex[st_intersects(hex, hex[i, ], sparse=F), ]
	return(cbind(touching$hex_id, i))
	}))

neighbours <- neighbours[neighbours[, 2] != neighbours[, 1], ]

s <- sparseMatrix(neighbours[,1], neighbours[,2])
D_sparse <- colSums(s)
d <- diag(1/sqrt(D_sparse))
lambda <- eigen(d %*% s %*% d, only.values=T)$values

W_sparse <- neighbours[neighbours[, 2] > neighbours[, 1], ]
W_n <- nrow(W_sparse)

save(wellington, hex, D_sparse, lambda, W_sparse, W_n, file='data.rdata')



