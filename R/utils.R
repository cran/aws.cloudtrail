#' @export
print.aws_cloudtrail <- function(x, ...) {
    cat("Name:    ", x[["Name"]], "\n")
    cat("Arn:     ", x[["TrailARN"]], "\n")
    cat("Bucket:  ", x[["S3BucketName"]], "\n")
    cat("Region:  ", x[["HomeRegion"]], "\n")
    cat("SNSTopic:", x[["SnsTopicARN"]], "\n")
    invisible(x)
}

get_trailname <- function(x, ...) {
    UseMethod("get_trailname")
}

get_trailname.default <- function(x, ...) {
    x
}

get_trailname.aws_cloudtrail <- function(x, ...) {
    x[["Name"]]
}
