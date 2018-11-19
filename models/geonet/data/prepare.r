library(data.table)
library(sf)
library(Matrix)

QUAKE <- '2018p816466'

#Convert felt points to spatial objects, in NZTM
felt <- st_transform(st_as_sf(fread('felt_reports.csv'),
		coords=c("felt_lon", "felt_lat"), crs=4326), 2193)

quake <- felt[felt$quake_public_id == QUAKE, ]

#Make a hexagonal grid that is around 1 km in size
hex <- st_sf(st_make_grid(
		st_as_sfc(st_bbox(quake)), 
		cellsize=50000, square=FALSE))

hex$hex_id <- seq(1, nrow(hex))

quake <- st_join(quake, hex)
quake <- quake[!(is.na(quake$hex_id)), ]


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

claims <- data.table(quake)[, 
    .(value=felt_mmi, 
        count=felt_count, 
        agent=as.numeric(factor(felt_agent_id)), 
        index=hex_id)]

save(quake, claims, hex, D_sparse, lambda, W_sparse, W_n, file='data.rdata')



