#
# Generate a Global Dot Motion stimuli as a sequence of PGM files
#
# Assumes that dots are small enough that if they fall on distance
# radius from the centre, then they will still be in the image.
# (See width, height, radius, AND dot_size globals.)
#
# Andrew Turpin aturpin@unimelb.edu.au
# Sat 12 Jan 2013 21:03:56 EST
# Mon 14 Jan 2013 14:50:23 EST: Modified heavily under Ally's direction
#

NUM_DOTS          <- 50
BACKGROUND_COLOUR <- 0     # black
DOT_COLOUR        <- 1     # white
NUM_FRAMES        <- 8

FRAME_RATE       <- 50/1000  # seconds (per frame)
VIEWING_DISTANCE <- 40       # cm
STIM_DIAMETER    <- 10.0     # degrees
DOT_DIAMETER     <-  8.6     # degrees
DOT_SPEED        <- 5.0      # degrees per second

SCREEN_WIDTH     <- 980/2  # pixels
SCREEN_HEIGHT    <- 560    # pixels
SCREEN_WIDTH_CM  <- 18.7/2 # cm
SCREEN_HEIGHT_CM <- 10.7  # cm

stimDiameterCm    <- atan(STIM_DIAMETER*pi/180.0) * VIEWING_DISTANCE   # number of cm across the stim
dotDiameterCm     <- atan(DOT_DIAMETER/60*pi/180.0)* VIEWING_DISTANCE  # number of cm across a dot
pixelsPerCmWidth  <- SCREEN_WIDTH  / SCREEN_WIDTH_CM
pixelsPerCmHeight <- SCREEN_HEIGHT / SCREEN_HEIGHT_CM
pixelsPerCm       <- (pixelsPerCmWidth + pixelsPerCmHeight) / 2
pixelsToMovePerFrame <- round(DOT_SPEED * pixelsPerCm * atan(1.0*pi/180.0)*VIEWING_DISTANCE * FRAME_RATE)

radius   <- round(stimDiameterCm / 2.0 * pixelsPerCm)   # pixels
dot_size <- floor(dotDiameterCm / 2.0  * pixelsPerCm )  # pixels
width    <- SCREEN_WIDTH                                # pixels
height   <- SCREEN_HEIGHT                               # pixels

##################################################################
# Draw dot of radius DOT_SIZE at (x,y)
#  (x,y)  - cartesian relative to (0,0) in centre of image
#  image  - matrix of pixels
##################################################################
drawDot <- function(x,y,image) {
    for(xx in -dot_size:+dot_size)
        for(yy in -dot_size:+dot_size) {
            if (xx*xx + yy*yy <= dot_size*dot_size) {
                xxx <- width/2 + xx + x
                yyy <- height/2 + yy - y
                image[yyy,xxx] <- DOT_COLOUR
            }
        }

    return(image)
}

##################################################################
# Return 0 if (x,y) is in image, otherwise
#   the abs distance that the dot is over the line (rounded up).
#
#  (x,y)  - cartesian relative to (0,0) in centre of image
##################################################################
inBounds <- function(x,y) { 
    d <- sqrt(x^2 + y^2)
    if (d < radius) 
        return(0)
    else 
        return(ceiling(abs(d-radius)))
}

##################################################################
# write image to filename as PGM
##################################################################
savePGM <- function(image, filename, tit) {
    cat("P2\n", 
        "# GDM: ", tit, "\n", 
        width, " ", height, "\n",
        "1\n",
        file=filename, sep="")

    s <- NULL
    c <- 1
    for(y in 1:height) 
        for(x in 1:width) {
            s <- c(s, image[y,x])
            if (c == 30) {
                cat(s, "\n", file=filename, append=TRUE)
                s <- NULL
                c <- 0
            }
            c <- c + 1
        }
    if (!is.null(s))
        cat(s, file=filename, append=TRUE)
    cat("\n", file=filename, append=TRUE)
}

##########################################################
# Chose a random location inside circle of radius
# Returns: (x,y) relative to (0,0) in centre of circle
##########################################################
chooseRandomDot <- function() {
    x <- -2 * width
    y <- -2 * height
    while (inBounds(x, y) > 0) {
        x <- runif(1, min=1, max=2*radius) - radius
        y <- runif(1, min=1, max=2*radius) - radius
    }
    return(c(x,y))
}

##################################
# Make initial list of points
##################################
initialDotList <- function() { return(lapply(1:NUM_DOTS, function(i) chooseRandomDot())) }

########################################################
# Take in a list of (x,y), move fractionSignal of them
# in direction orient, and write an image with name filename
# fractionSignal - b/w 0 and 1
# orient - degrees.
########################################################
writeFrame <- function(dots, fractionSignal, orient, filename) {
    orientRad <- orient*pi/180
    n         <- length(dots)
    numS      <- round(fractionSignal * n)

    image     <- matrix(BACKGROUND_COLOUR, height, width)

    dots <- dots[order(runif(n))]   # randomly order dots

        # first move signal dots, wrap around if nec.
    for(i in 1:length(dots)) {
        x <- dots[[i]][1]
        y <- dots[[i]][2]
        
        o <- ifelse(i <= numS, orientRad, runif(1, min=0, max=2*pi))
        newX <- x + pixelsToMovePerFrame*cos(o)
        newY <- y + pixelsToMovePerFrame*sin(o)

        if (d <- inBounds(newX, newY) > 0) {  # wrap around if neccessary
            newO <- atan2(newY, newX) + pi
            newX <- (radius - max(d, dot_size))*cos(newO)
            newY <- (radius - max(d, dot_size))*sin(newO)
        }
        dots[[i]] <- c(newX, newY)
        image <- drawDot(dots[[i]][1],dots[[i]][2],image)
    }

    savePGM(image, filename=filename,
            tit=sprintf("numDots=%3.0f fraction signal=%5.3f orient=%3.0f",n, numS, orient))

    return(dots)
}

#################################################################
# Main
#################################################################
#dots <- initialDotList()
##layout(matrix(1:2,1,2))
##plot(unlist(lapply(dots,"[",1)), unlist(lapply(dots, "[", 2)))
#dots <- writeFrame(dots, 0.5, 45, filename=paste("x.pbm"))
#stop("All good")

if (length(commandArgs()) != 6) {
    print("Usage: R --slave --args fraction angle_of_motion dirPrefix < GDM.r")
} else {
    fractionSignal <- as.numeric(commandArgs()[4])
    orient         <- as.numeric(commandArgs()[5])
    dirPrefix      <- commandArgs()[6]

    dots <- initialDotList()
    for(frame in 1:NUM_FRAMES) 
        dots <- writeFrame(dots, fractionSignal, orient, filename=paste(dirPrefix,"/frame_",frame,".pbm",sep=""))
}

if (grep("package:Rmpi",search()) != 0)
   mpi.quit()

