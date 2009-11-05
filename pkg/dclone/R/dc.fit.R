dc.fit <- 
function(data, params, model, inits, n.clones, multiply=NULL, unchanged=NULL, 
update=NULL, updatefun=NULL, initsfun=NULL, trace=1, flavour = c("jags", "bugs"), ...)
{
    flavour <- match.arg(flavour)
    if (identical(n.clones, 1))
        stop("'n.clones = 1' gives the Bayesian answer, no need for DC")
## relative convergence is compared with k=1, thus it is necessary to have it
#    if (!(1 %in% n.clones))
#        n.clones <- c(1, n.clones)
    k <- n.clones[order(n.clones)]
    k <- unique(k)
    times <- length(k)
    crit <- getOption("dclone.crit")
    ## evaluate updating
    if (!is.null(update) != !is.null(updatefun))
        stop("both 'update' and 'updatefun' must be provided")
    if (!is.null(update)) {
        unchanged <- c(unchanged, update)
        updatefun <- match.fun(updatefun)
    }
    ## evaluate inits
    if (missing(inits))
        inits <- NULL
    if (!is.null(initsfun))
        initsfun <- match.fun(initsfun)
## not sure if this is needed once convergence results are stored
#    converged <- FALSE
    ## internal function to calculate dctable statistics
    dctsfun <- function(x) {
        y <- mcmcapply(x, array)
        if (nch > 1) {
            rhat <- gelman.diag(x)$psrf[,1]
            rval <- rbind(mean = apply(y, 2, mean),
                sd = apply(y, 2, sd),
                apply(y, 2, quantile, probs=quantiles),
                    r.hat=rhat)
        } else {
            rval <- rbind(mean = apply(y, 2, mean),
                sd = apply(y, 2, sd),
                apply(y, 2, quantile, probs=quantiles))
        }
        t(rval)
    }
    ## iteration starts here
    for (i in 1:times) {
        tmpch <- if (k[i] == 1) "clone" else "clones"
        if (trace)
            cat("\nFitting model with", k[i], tmpch, "\n\n")
        jdat <- dclone(data, k[i], multiply=multiply, unchanged=unchanged)

#        mod <- if (is.null(initsfun)) {
#            jags.fit(jdat, params, model, ...)
#        } else {
#            jags.fit(jdat, params, model, inits = inits, ...)
#        }

#        mod <- bugs.fit(jdat, params, model, initsfun, ...)
#        mod <- as.mcmc.list(mod)

        mod <- if (flavour == "jags") {
            jags.fit(jdat, params, model, inits, ...)
        } else {
            bugs.fit(jdat, params, model, inits, format="mcmc.list", DIC=FALSE, ...)
        }

        ## dctable evaluation
        if (i == 1) {
            vn <- varnames(mod)
            nch <- nchain(mod)
#            ## dctable template
#            dctc <- matrix(0, times, 3 + as.numeric(nch > 1))
#            colnames(dctc) <- if (nch == 1) {
#                c("n.clones", "lambda.max", "p.shapiro")
#            } else {
#                c("n.clones", "lambda.max", "p.shapiro", "multivariate.r.hat")
#            }
#            dctc[,1] <- k
            dcts <- list()
            quantiles <- c(0.025, 0.25, 0.5, 0.75, 0.975)
            extracol <- if (nch > 1)
                4 else 3
            dcts0 <- matrix(0, times, extracol + length(quantiles))
            dcts0[,1] <- k
            colntmp <- c("n.clones", "mean", "sd", names(quantile(0, probs=quantiles)))
            colnames(dcts0) <- if (nch > 1)
                c(colntmp, "r.hat") else colntmp
            for (j in 1:length(vn))
                dcts[[vn[j]]] <- dcts0
        } else {
            if (!is.null(update))
                jdat[[update]] <- updatefun(mod)
            if (!is.null(initsfun))
                inits <- initsfun(mod)
        }
        dctmp <- dctsfun(mod)
        for (j in 1:length(vn)) {
            dcts[[j]][i,-1] <- dctmp[j,]
        }
#        dctc[i,2] <- lambdamax.diag(mod)
#        dctc[i,3] <- shapiro.diag(mod)$p.value
#        if (nch > 1)
#            dctc[i,4] <- gelman.diag(mod)$mpsrf

#        if (trace > 1)
#            print(dctc[i,-1])
#        if (dctc[i,2] < crit[1] && dctc[i,3] > crit[2]) {
#            converged <- TRUE
#            if (trace)
#                cat("\nConvergence reached with", k[i], tmpch, "\n\n")
#        } else cat("\nNo convergence reached with", k[i], tmpch, "\n\n")
#        if (converged && stop.if.converged)
#            break
    }
    if (nch > 1 && any(dctmp[,"r.hat"] >= crit["rhat"]))
        warning("chains convergence problem, see R.hat values")
    if (times > 1) {
#        dctc <- as.data.frame(dctc[1:i,])
        dcts <- lapply(dcts, function(z) as.data.frame(z[1:i,]))
    } else {
#        dctc <- as.data.frame(dctc)
        dcts <- lapply(dcts, function(z) as.data.frame(z))
    }
    dctable <- dcts
    class(dctable) <- "dctable"
#    attr(mod, "converged") <- converged
    attr(mod, "dctable") <- dctable
    mod
}