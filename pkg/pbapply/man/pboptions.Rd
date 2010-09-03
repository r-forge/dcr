\name{pboptions}
\alias{pboptions}
\alias{startpb}
\alias{setpb}
\alias{getpb}
\alias{closepb}
\alias{dopb}
\title{
Creating Progress Bar and Setting Options
}
\description{
Creating progress bar and setting options.
}
\usage{
pboptions(pb, txt, gui)
startpb(min = 0, max = 1)
setpb(pb, value)
getpb(pb)
closepb(pb)
dopb()
}
\arguments{
  \item{pb}{
For \code{pboptions} it is the progress bar option, a list as returned by 
\code{getOption("pbapply.pb")}.
For the other functions, it is a progress bar object created by \code{startpb}.
}
  \item{txt}{
Text progress bar options, a list as returned by 
\code{getOption("pbapply.txt")} (or some elements of it to change).
}
  \item{gui}{
GUI progress bar options, a list as returned by 
\code{getOption("pbapply.gui")} (or some elements of it to change).
}
  \item{min, max}{
Finite numeric values for the extremes of the progress bar. Must have \code{min < max}.
}
  \item{value}{
New value for the progress bar.
}
}
\details{
\code{pboptions} is a convenient way of handling options related to progress bar.

Other functions can be used for conveniently adding progress bar to \code{for}-like loops
(see Examples).
}
\value{
When parameters are set by \code{pboptions}, their former values are returned in an invisible named list. Such a list can be passed as an argument to \code{pboptions} to restore the parameter values.

For \code{startpb} a progress bar object.

For \code{getpb} and \code{setpb}, a length-one numeric vector giving the previous value (invisibly for \code{setpb}).
The return value is \code{NULL} if the progress bar is turned off by \code{getOption("pbapply.pb")} (\code{"none"} or \code{NULL} value).

\code{dopb} returns a logical value if progress bar is to be shown based on the option \code{getOption("pbapply.pb")}. 
It is \code{FALSE} if the type of progress bar is \code{"none"} or \code{NULL}.

For \code{closepb} closes the connection for the progress bar.
}
\author{
Peter Solymos <solymos@ualberta.ca>
}
\seealso{
Progress bars used in the functions:
#ifdef windows
\code{\link[utils]{winProgressBar}}, 
#endif
\code{\link[utils]{txtProgressBar}}, 
\code{\link[tcltk]{tkProgressBar}}
}
\examples{
pb <- startpb(0, 10)
for (i in 1:10) {
    Sys.sleep(0.2)
    setpb(pb, i)
}
closepb(pb)
## resetting pboptions
opb <- pboptions(txt=list(style=1, char=">"))
## check new settings
getOption("pbapply.txt")
## running again with new settings
pb <- startpb(0, 10)
i <- 1
while (i < 10) {
    Sys.sleep(0.2)
    setpb(pb, i)
    i <- i + 1
}
closepb(pb)
## resetting original
pboptions(opb)
## check reset
getOption("pbapply.txt")
}
\keyword{ IO }
\keyword{ utilities }