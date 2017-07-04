#' @title get_trails
#' @description Get list of trails
#' @details Get a list of available cloudtrails.
#' @template dots
#' @return A list of objects of class \dQuote{aws_cloudtrail}.
#' @seealso \code{\link{create_trail}}
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DescribeTrails.html}
#' @examples
#' \dontrun{
#' get_trails()
#' }
#' @export
get_trails <- function(...) {
    out <- cloudtrailHTTP(query = list(Action = "DescribeTrails"), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    trail_list <- out$DescribeTrailsResponse$DescribeTrailsResult$trailList
    structure(lapply(trail_list, `class<-`, "aws_cloudtrail"),
              RequestId = out$DescribeTrailsResponse$ResponseMetadata$RequestId)
}
