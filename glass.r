#
# Generate a glass pattern as a PNG file
#
# Adapted from MERP javascript, which was adapted from AMM's Matlab code.
#
# Assumes that dots are small enough that if they fall on distance
# RADIUS from the centre, then they will still be in the image.
# (See WIDTH, HEIGHT, RADIUS, and DOT_SIZE globals.)
#
# Andrew Turpin aturpin@unimelb.edu.au
# Tue 18 Dec 2012 07:13:22 EST
# Mon 14 Jan 2013 14:50:23 EST: Modified params under Ally's direction
#

NUM_DOTS          <- 200
STEP_SIZE         <- 10     # gap between dots?
BACKGROUND_COLOUR <- 0     # black
DOT_COLOUR        <- 255   # white

CLOCKWISE      <- 90   # direction of spiral in degrees
ANTI_CLOCKWISE <- 0    # 0 is radial, 90 is concentric, 35 clock, 145 anti

viewingDistance <- 40 # cm
stimDiameterCm  <- atan(10.0*pi/180.0) * viewingDistance   # number of cm across the stim
dotDiameterCm   <- atan(8.6/60*pi/180.0)* viewingDistance # number of cm across a dot
screen.width    <- 980/2 # pixels
screen.height   <- 560    # pixels
screenWidthCm   <- 18.7/2 # cm
screenHeightCm  <- 10.7   # cm
pixelsPerCmWidth  <- screen.width / screenWidthCm
pixelsPerCmHeight <- screen.height / screenHeightCm
pixelsPerCm       <- (pixelsPerCmWidth + pixelsPerCmHeight) / 2

RADIUS   <- round(stimDiameterCm / 2.0 * pixelsPerCm) 
DOT_SIZE <- floor(dotDiameterCm / 2.0  * pixelsPerCm )
WIDTH    <- screen.width # 2*(RADIUS + DOT_SIZE+2)   # +2 for luck
HEIGHT   <- screen.height # 2*(RADIUS + DOT_SIZE+2)   # +2 for luck

##################################################################
# Draw dot of radius DOT_SIZE at (x,y)
#  (x,y)  - relative to (0,0) in centre of image
#  image  - matrix of pixels
##################################################################
drawDot <- function(x,y,image) {
    for(xx in -DOT_SIZE:+DOT_SIZE)
        for(yy in -DOT_SIZE:+DOT_SIZE) {
            if (xx*xx + yy*yy <= DOT_SIZE*DOT_SIZE) {
                xxx <- WIDTH/2 + xx + x
                yyy <- HEIGHT/2 + yy + y
                image[yyy,xxx] <- DOT_COLOUR
            }
        }

    return(image)
}

##################################################################
# Determining the coordinate position of the signal pair dots    
#  numPairs - number of pairs to generate
#  orient - angle of signal dots
#  image  - matrix of pixels
##################################################################
drawSignalPairs <- function(numPairs, orient, image) {
    for(i in 1:numPairs) {
            # find an (x,y) within circle
        dist <- RADIUS*RADIUS + 1
        while (dist > RADIUS*RADIUS) {
            x <- runif(1, min=1, max=2*RADIUS) - RADIUS
            y <- runif(1, min=1, max=2*RADIUS) - RADIUS
            dist <- x*x + y*y
        }

        orientRad <- orient*pi/180
        angle <- atan2(y,x)

        x1 <- x + STEP_SIZE*cos(angle+orientRad)
        y1 <- y + STEP_SIZE*sin(angle+orientRad)

        image <- drawDot(x,y,image)
        image <- drawDot(x1,y1,image)
    }

    return(image)
}

##################################################################
# Determining the coordinate position of the remaing dot pairs    
##################################################################
drawNoiseDots <- function(numNoiseDots,image) {
    for(i in 1:numNoiseDots) {
        dist <- RADIUS*RADIUS+2;
        while(dist > RADIUS*RADIUS) {
            x <- runif(1,min=1, max=2*RADIUS) - RADIUS 
            y <- runif(1,min=1, max=2*RADIUS) - RADIUS
            dist <- x*x + y*y
        }
        image <- drawDot(x,y,image)
    }
    return(image)
}

##################################################################
# Draw the Canvas
##################################################################
drawCanvas <- function(numDotsAsSignal, orient) {
    image <- matrix(BACKGROUND_COLOUR, ncol=WIDTH, nrow=HEIGHT)

    image <- drawSignalPairs(numDotsAsSignal/2, orient, image)
    image <- drawNoiseDots(NUM_DOTS - numDotsAsSignal, image)

    return(image)
}

##################################################################
# print matrix as a 8-bit pbm file
##################################################################
printPBM <- function(i, fractionSignal, orient) {
  # cat("P4", "\n")
  # cat(paste("# Glass: ",fractionSignal, orient), "\n")
  # cat("255", "\n")
  # cat(paste(WIDTH, HEIGHT), "\n")
  # for(x in 1:WIDTH) {
  #     for(y in 1:HEIGHT)
  #         cat(rawToChar(as.raw(i[y,x])))
  #     cat("\n")
  # }
    cat("P1", "\n")
    cat(paste("# Glass: ",fractionSignal, orient), "\n")
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

##################################################################
# A little test
##################################################################
#i <- drawCanvas(1.0 * NUM_DOTS, CLOCKWISE)
#z <- which(i == DOT_COLOUR, arr.ind=T)
#plot(i[z], pch=19, xlim=c(1,WIDTH), ylim=c(1,HEIGHT))
#stop("All Good")

##################################################################
# Main
##################################################################
if (length(commandArgs()) != 5) {
    print("Usage: R --slave --args fraction c|a < glass.r")
} else {
    fractionSignal <- as.numeric(commandArgs()[4])
    orient         <- ifelse(commandArgs()[5]=='c',CLOCKWISE,ANTI_CLOCKWISE)
    i <- drawCanvas(fractionSignal * NUM_DOTS, orient)

    # border for testing size
#    for(x in 1:WIDTH)
#        i[c(1,HEIGHT), x] <- DOT_COLOUR
#    for(y in 1:HEIGHT)
#        i[y, c(1,WIDTH)] <- DOT_COLOUR

    printPBM(i, fractionSignal, orient)
}
