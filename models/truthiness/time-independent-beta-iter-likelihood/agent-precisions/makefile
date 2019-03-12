all: frames/out.mp4

frames/out.mp4: frames/.frames 
	cd frames &&  ffmpeg -framerate 25 -r 4 -i frame_%04d.png  -c:v libx264 -pix_fmt yuv420p out.mp4

frames/.frames: ../generated/truthiness-precision-all-models.rds \
		anim.r
	Rscript anim.r  &&  touch frames/.frames

