#' @rdname logging
#' @title logging
#' @description Start/stop logging
#' @details \code{start_logging} starts a 
#' @template name
#' @template dots
#' @seealso \code{\link{create_trail}}, \code{\link{trail_status}}
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_StartLogging.html}, \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_StopLogging.html}
#' @examples
#' \dontrun{
#'   require("aws.s3")
#'   # create a bucket
#'   mybucket <- "mybucket_for_cloudtrail"
#'   stopifnot(put_bucket(mybucket))
#'   
#'   # create a trail
#'   trail <- create_trail("exampletrail", mybucket)
#'   # confirm trail created
#'   get_trails()
#' 
#'   # start/stop logging to the trail
#'   start_logging(trail)
#'   stop_logging(trail)
#'   
#'   # check trail status
#'   trail_status(trail)
#'   
#'   # delete trail
#'   delete_trail(trail)
#' }
#' @export
start_logging <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "StartLogging", Name = get_trailname(name)), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$StartLoggingResponse$ResponseMetadata$RequestId)
}

#' @rdname logging
#' @export
stop_logging <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "StopLogging", Name = get_trailname(name)), ...)
     if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$StopLoggingResponse$ResponseMetadata$RequestId)
}
