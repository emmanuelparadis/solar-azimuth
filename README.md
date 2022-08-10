# solar-azimuth
## Solar azimuth formula (angle of the sun rays with the Earth surface)

This R function computes solar azimuth, that is the angle between the rays of the sun and the surface of the Earth. The formula is from:

Zhang T., Stackhouse P. W., Macpherson B., Mikovitz J. C. (2021) A solar azimuth formula that renders circumstantial treatment unnecessary without compromising mathematical rigor: mathematical setup, application and extension of a formula based on the subsolar point and atan2 function. Renewable Energy Volume 172: 1333-1340. [Doi: 10.1016/j.renene.2021.03.047](https://doi.org/10.1016/j.renene.2021.03.047).

The code is inspired directly from a Fortran code provided with the above paper. The arguments and the returned value are described in the code.

I used this code to find the time of the day when the sun is "vertical" (i.e., at zenith). For all locations between both tropics, the sun is at the zenith twice every year. For example, at the location E 100.93°, N 13.24°, on 18 August 2021, it is possible to find the exact time of the sun's zenith. We first input the geographical coordinates and date:
```r
mylon <- 100.93
mylat <- 13.24
year <- 2021
month <- 8
day <- 18
```
We presume that the zenith happened between 11:00 AM and 1:00 PM, so we create a vector from 11 to 13 with a reasonable resolution:
```r
Time <- seq(11, 13, .001)
```
The R function is not vectorized, so we build a standard small loop and plot the results:
```r
Time <- seq(11, 13, .001)
n <- length(Time)
A <- numeric(n)
for (i in 1:n)
    A[i] <- sunpos_ultimate_azi_atan2(year, month, day, Time[i] - 7, mylat, mylon)[1]

plot(Time, A, "l", col = "blue", lwd = 3)
abline(h = 0, lwd = 0.5)
```
The time of the sun zenith can be found with:
```r
> Time[which.min(A)]
[1] 12.339
> (Time[which.min(A)] - 12) * 60
[1] 20.34
```
which is around 12:20:20. Note that the location is in the UTC+7 (aka GMT+7) time zone, hence the ` - 7` in the fourth argument.

Another way to find this result is the find the values of day and time that minimise the output angle. We first build a function that has these parameters as arguments:
```r
## optimise both day and time
foo <- function(p)
    sunpos_ultimate_azi_atan2(year, month, p[1], p[2] - 7, mylat, mylon)[1]
```
This function can be minimised with, for instance, `nlminb`:
```r
> nlminb(c(24, 12), foo)
$par
[1] 18.06177 12.33834

$objective
[1] 0.0001805908

$convergence
[1] 0

$iterations
[1] 22

$evaluations
function gradient
      54       44
```
Note that the variable 'date' is considered as continuous! Instead, we do the same optimisation for several dates. We first modify the small function which has now a single argument (time) and minimise it for a few days around 18 August 2021:
```r
## optimise only time for each day
bar <- function(p)
    sunpos_ultimate_azi_atan2(year, month, day, p - 7, mylat, mylon)[1]
for (day in 16:20) {
    cat(day, "August: ")
    print(unname(unlist(nlminb(12, bar)[1:2])))
}
```
The output is (printing the local time and the angle):
```r
16 August: [1] 12.345570  0.654415
17 August: [1] 12.3421344  0.3388352
18 August: [1] 12.33855488  0.01967185
19 August: [1] 12.3348343  0.3029877
20 August: [1] 12.3309759  0.6290558
```
