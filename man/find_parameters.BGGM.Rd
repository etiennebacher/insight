% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_parameters_bayesian.R
\name{find_parameters.BGGM}
\alias{find_parameters.BGGM}
\alias{find_parameters.BFBayesFactor}
\alias{find_parameters.MCMCglmm}
\alias{find_parameters.bamlss}
\alias{find_parameters.brmsfit}
\alias{find_parameters.bayesx}
\alias{find_parameters.stanreg}
\alias{find_parameters.sim.merMod}
\title{Find names of model parameters from Bayesian models}
\usage{
\method{find_parameters}{BGGM}(
  x,
  component = c("correlation", "conditional", "intercept", "all"),
  flatten = FALSE,
  ...
)

\method{find_parameters}{BFBayesFactor}(
  x,
  effects = c("all", "fixed", "random"),
  component = c("all", "extra"),
  flatten = FALSE,
  ...
)

\method{find_parameters}{MCMCglmm}(x, effects = c("all", "fixed", "random"), flatten = FALSE, ...)

\method{find_parameters}{bamlss}(
  x,
  flatten = FALSE,
  component = c("all", "conditional", "location", "distributional", "auxiliary"),
  parameters = NULL,
  ...
)

\method{find_parameters}{brmsfit}(
  x,
  effects = "all",
  component = "all",
  flatten = FALSE,
  parameters = NULL,
  ...
)

\method{find_parameters}{bayesx}(
  x,
  component = c("all", "conditional", "smooth_terms"),
  flatten = FALSE,
  parameters = NULL,
  ...
)

\method{find_parameters}{stanreg}(
  x,
  effects = c("all", "fixed", "random"),
  component = c("location", "all", "conditional", "smooth_terms", "sigma",
    "distributional", "auxiliary"),
  flatten = FALSE,
  parameters = NULL,
  ...
)

\method{find_parameters}{sim.merMod}(
  x,
  effects = c("all", "fixed", "random"),
  flatten = FALSE,
  parameters = NULL,
  ...
)
}
\arguments{
\item{x}{A fitted model.}

\item{component}{Which type of parameters to return, such as parameters for the
conditional model, the zero-inflated part of the model, the dispersion
term, the instrumental variables or marginal effects be returned? Applies
to models with zero-inflated and/or dispersion formula, or to models with
instrumental variables (so called fixed-effects regressions), or models
with marginal effects from \pkg{mfx}. May be abbreviated. Note that the
\emph{conditional} component is also called \emph{count} or \emph{mean}
component, depending on the model. There are three convenient shortcuts:
\code{component = "all"} returns all possible parameters.
If \code{component = "location"}, location parameters such as \code{conditional},
\code{zero_inflated}, \code{smooth_terms}, or \code{instruments} are returned
(everything that are fixed or random effects - depending on the \code{effects}
argument - but no auxiliary parameters). For \code{component = "distributional"}
(or \code{"auxiliary"}), components like \code{sigma}, \code{dispersion},
\code{beta} or \code{precision} (and other auxiliary parameters) are returned.}

\item{flatten}{Logical, if \code{TRUE}, the values are returned
as character vector, not as list. Duplicated values are removed.}

\item{...}{Currently not used.}

\item{effects}{Should parameters for fixed effects, random effects
or both be returned? Only applies to mixed models. May be abbreviated.}

\item{parameters}{Regular expression pattern that describes the parameters that
should be returned.}
}
\value{
A list of parameter names. For simple models, only one list-element,
\code{conditional}, is returned. For more complex models, the returned
list may have following elements:
\itemize{
\item \code{conditional}, the "fixed effects" part from the model
\item \code{random}, the "random effects" part from the model
\item \code{zero_inflated}, the "fixed effects" part from the
zero-inflation component of the model
\item \code{zero_inflated_random}, the "random effects" part from the
zero-inflation component of the model
\item \code{smooth_terms}, the smooth parameters
}

Furthermore, some models, especially from \pkg{brms}, can also return
auxiliary parameters. These may be one of the following:
\itemize{
\item \code{sigma}, the residual standard deviation (auxiliary parameter)
\item \code{dispersion}, the dispersion parameters (auxiliary parameter)
\item \code{beta}, the beta parameter (auxiliary parameter)
\item \code{simplex}, simplex parameters of monotonic effects (\pkg{brms} only)
\item \code{mix}, mixture parameters (\pkg{brms} only)
\item \code{shiftprop}, shifted proportion parameters (\pkg{brms} only)
}
}
\description{
Returns the names of model parameters, like they typically
appear in the \code{summary()} output. For Bayesian models, the parameter
names equal the column names of the posterior samples after coercion
from \code{as.data.frame()}.
}
\examples{
data(mtcars)
m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
find_parameters(m)
}
