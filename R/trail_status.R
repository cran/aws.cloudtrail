#' @title trail_status
#' @description Get trail status/history
#' @details This function returns full details and history for a trail, including errors and logging start/stop times.
#' @template name
#' @template dots
#' @return A list.
#' @seealso \code{\link{get_trails}}, \code{\link{start_logging}}, \code{\link{create_trail}}
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_GetTrailStatus.html}
#' @export
trail_status <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "GetTrailStatus", Name = get_trailname(name)), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(out$GetTrailStatusResponse$GetTrailStatusResult,
              RequestId = out$GetTrailStatusResponse$ResponseMetadata$RequestId)
}
