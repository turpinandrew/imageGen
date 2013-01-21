#
# Generate Radial Frequency search tasks.
# Adapted from David Badcock's Matlab.
#
# Fri 11 Jan 2013 08:33:11 EST
# Modified Thu 17 Jan 2013 07:11:30 EST: allow for aspect ratio of pixels
#

#WIDTH  <- 752
#HEIGHT <- 752
WIDTH  <- 480
HEIGHT <- 480

viewingDistance   <- 40     # cm
screen.width      <- 980/2  # pixels
screen.height     <- 560    # pixels
screenWidthCm     <- 18.7/2 # cm
screenHeightCm    <- 10.7   # cm
cmPerPixelWidth  <- screenWidthCm / screen.width 
cmPerPixelHeight <- screenHeightCm / screen.height

#################################################
# Create a single RF stim of dimension 128x128
# Intiially use r in cms, then map back to pixels
#  radius is in degrees
#################################################
rfCreate <- function(RF_number, radius, Weber_amp, phase) {

    radiusCm <- viewingDistance * tan(radius/180*pi)
    SIGMA <- 2 # sigma defines path thickness (Gaussian profile path section)

    mod_amp <- Weber_amp*radius # mod amp is the amplitude of the RF modulation
 
    xy <- expand.grid(-63:64, -63:64)  # X and Y are Cartesian

        # ?? theta numbers off conventionally from the +ve X axis anti-clockwise
    theta <- apply(xy, 1, function(p) atan2(p[2], p[1]))
    rCm   <- apply(xy, 1, function(p) sqrt(sum((p * c(cmPerPixelWidth, cmPerPixelHeight))^2)))
     
        # calculate the RF_radius for all values of theta (in cm)
    RF_radiusCm <- radiusCm + sin(RF_number*theta + phase) * mod_amp

        # create an RF path with a Gaussian luminance profile in section
        # maximum luminance when RF_radius-r is equal to zero
    f <- (cmPerPixelHeight + cmPerPixelWidth)/2
    RF <- exp(-(((RF_radiusCm-rCm)/f)^2/(2*SIGMA^2)))

    return(matrix(RF, 128, 128))
}

#######################################################
# function to create a stimulus and reference
# pass in the RF of the target and distractor and total number of elements 
#   Radius is in degrees
#######################################################
createImage <- function(RF_target, RF_distract, number, Radius, 
                        RF_amp_target=1/(1+RF_target^2), 
                        RF_amp_distract=1/(1+RF_distract^2)) {
        # grid of available positions for the RF patterns
        # Random jitter each location
        # Random permute of order
    xs <- seq(42, WIDTH - 128-42, 90)
    grid<- expand.grid(xs, xs) + matrix(round(runif(2*length(xs),min=-6, max=+6)),ncol=2)
    grid<- grid[order(runif(nrow(grid))), ] 

    phase <- 2*pi*runif(number, min=1,max=49)

    image <- matrix(0, HEIGHT, WIDTH)

    #add each RF pattern in turn to stim and ref  
    for (i in 1:(number-1)) {
        y <- grid[i, 1]
        x <- grid[i, 2]
        image[y:(y+127),x:(x+127)] <- image[y:(y+127),x:(x+127)] + 
            rfCreate(RF_distract, Radius, RF_amp_distract, phase[i])
    } 
    y <- grid[number, 1]  # add target 
    x <- grid[number, 2]
    image[y:(y+127),x:(x+127)] <- image[y:(y+127),x:(x+127)] + 
        rfCreate(RF_target, Radius, RF_amp_target, phase[number])

    too_big <- which(image > 1)
    image[too_big] <- 1

    return(image)
}

#############################
# Test single stim
#s1 <- rfCreate(4, 30, 1/(1+5^2), 2*pi*runif(1,min=1,max=49))
#image(round(255*s1), col=grey.colors(256))
#stop("All good")

#############################
# Test image of mulitple stims
#i <- createImage(RF_target=3, RF_distract=4, number=8, 1)
#image(i)
#stop("All good")

##################################################################
# print matrix as a 8-bit pbm file
##################################################################
printPGM <- function(i, title) {
    cat("P2", "\n")
    cat("# RSF: ", title, "\n")
    cat(paste(WIDTH, HEIGHT), "\n")
    cat("255\n")
    c <- 1
    for(x in 1:WIDTH) 
        for(y in 1:HEIGHT) {
            cat(round(255*i[y,x]), " ")
            if (c == 30) {
                cat("\n")
                c <- 0
            }
            c <- c + 1
        }
}

#######################################################
# Test
#i <- createImage(3, 4, 4, 1)
#image(i)
#stop("All good")

#######################################################
# Command line param is 
#    number of distractors
#    target RF
#    distractor RF
#######################################################
if (length(commandArgs()) != 7) {
    print("Usage: R --slave --args number_of_shapes target_RF distractor_RF radius < RFS.r")
    print("where")
    print("     radius is in degrees (at 40cm viewing distance)")
} else {
    number       <- as.numeric(commandArgs()[4])
    targetRF     <- as.numeric(commandArgs()[5])
    distractorRF <- as.numeric(commandArgs()[6])
    radius       <- as.numeric(commandArgs()[7])

    i <- createImage(RF_target=targetRF, RF_distract=distractorRF, number=number, radius)

    printPGM(i, commandArgs())
}
