#
# Generate a simple box on the image boundaries
#
# Andrew Turpin aturpin@unimelb.edu.au
# Tue 15 Jan 2013 09:59:12 EST
#

BACKGROUND_COLOUR <- 0   # black
DOT_COLOUR        <- 1   # white
DOT_SIZE          <- 1

screen.width    <- 980  # pixels
screen.height   <- 560    # pixels

WIDTH    <- screen.width 
HEIGHT   <- screen.height 

##################################################################
# print matrix as a 8-bit pbm file
##################################################################
printPBM <- function(i) {
    cat("P1", "\n")
    cat("# Box: ", WIDTH, "x" , HEIGHT, "\n")
    cat(paste(WIDTH, HEIGHT), "\n")
    c <- 1
    for(y in 1:HEIGHT) 
        for(x in 1:WIDTH) {
            cat(ifelse(i[y,x] == BACKGROUND_COLOUR, 1, 0)," ")  # 0 is black, I guess?
            if (c == 30) {
                cat("\n")
                c <- 0
            }
            c <- c + 1
        }
}

##############################################################
image <- matrix(BACKGROUND_COLOUR, ncol=WIDTH, nrow=HEIGHT)
for(x in 1:WIDTH) {
    image[1, x]      <- DOT_COLOUR
    image[HEIGHT, x] <- DOT_COLOUR
}
for(y in 1:HEIGHT) {
    image[y, 1]     <- DOT_COLOUR
    image[y, WIDTH] <- DOT_COLOUR
}

printPBM(image)
