## https://www.thenauticalalmanac.com/

## 2019-12-26  Solar Geometry using subsolar point and atan2.
##             by Taiping Zhang.
## Input variables:
##     inyear: 4-digit year, e.g., 1998, 2020;
##     inmon: month, in the range of 1 - 12;
##     inday: day, in the range 1 - 28/29/30/31;
##     gmtime: GMT in decimal hour, e.g., 15.2167;
##     xlat: latitude in decimal degree, positive in Northern Hemisphere;
##     xlon: longitude in decimal degree, positive for East longitude.
## Output variables:
##     solarz: solar zenith angle in deg;
##     azi: solar azimuth in deg the range -180 to 180, South-Clockwise Convention.
## Note: The user may modify the code to output other variables.
## https://doi.org/10.1016/j.renene.2021.03.047

sunpos_ultimate_azi_atan2 <- function(inyear, inmon, inday, gmtime, xlat, xlon)
{
    rpd <- acos(-1)/180
    nday <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

    tmp <- inyear %% 100
    if ((tmp != 0 && (inyear %% 4) == 0) ||
        (tmp == 0 && (inyear %% 400) == 0)) nday[2] <- 29

    julday <- cumsum(nday)
    ## Note: julday[12] is equal to either 365 or 366.

    dyear <- inyear - 2000
    dayofyr <- julday[inmon - 1] + inday
    xleap <- dyear/4 # Note: xleap has the SAME SIGN as dyear
    if (dyear > 0 && !(dyear %% 4)) xleap <- xleap + 1 # "+ 1" is for year 2000

    ## --- Astronomical Almanac for the Year 2019, Page C5 ---
    n <- -1.5 + dyear*365 + xleap + dayofyr + gmtime/24

    L <- (280.460 + 0.9856474*n) %% 360
    g <- (357.528 + 0.9856003*n) %% 360
    lambda <- (L + 1.915*sin(g*rpd) + 0.020*sin(2*g*rpd)) %% 360
    epsilon <- 23.439 - 0.0000004*n
    alpha <- (atan2(cos(epsilon*rpd)*sin(lambda*rpd),
                    cos(lambda*rpd))/rpd) %% 360
    ## alpha in the same quadrant as lambda
    delta <- asin(sin(epsilon*rpd)*sin(lambda*rpd) )/rpd
    R <- 1.00014 - 0.01671*cos(g*rpd) - 0.00014*cos(2*g*rpd)
    EoT <- (((L - alpha) + 180) %% 360) - 180 # In deg

    ## --- Solar geometry ---
    sunlat <- delta # In deg
    sunlon <- -15*(gmtime-12 + EoT*4/60)
    PHIo <- xlat*rpd
    PHIs <- sunlat*rpd
    LAMo <- xlon*rpd
    LAMs <- sunlon*rpd
    Sx <- cos(PHIs)*sin(LAMs - LAMo)
    Sy <- cos(PHIo)*sin(PHIs) - sin(PHIo)*cos(PHIs)*cos(LAMs - LAMo)
    Sz <- sin(PHIo)*sin(PHIs) + cos(PHIo)*cos(PHIs)*cos(LAMs - LAMo)
    solarz <- acos(Sz)/rpd # In deg
    azi <- atan2(-Sx, -Sy)/rpd # In deg. South-Clockwise Convention.
    c(solarz = solarz, azi = azi)
}
