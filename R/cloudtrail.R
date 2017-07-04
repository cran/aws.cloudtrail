#' @rdname trails
#' @title Trails
#' @description Create, update, or delete a Cloudtrail
#' @details
#' \code{create_trail} sets up a trail to log requests into a specified S3 bucket. A maximum of five trails can exist in a region.
#' \code{update_trail} can update specific details for a trail. The trail can be active at the time.
#' \code{delete_trail} deletes a trail.
#' @template name
#' @param bucket A character string specifying the name of an S3 bucket to deposit Cloudtrail logs into. AWS recommends this be a dedicated bucket exclusively for Cloudtrail logs. In order to succeed, the bucket must have an appropriate policy (see \href{http://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html}{documentation}).
#' @param log_group Optionally, a character string specifying a log group name using an Amazon Resource Name (ARN), a unique identifier that represents the log group to which CloudTrail logs will be delivered. 
#' @param log_role Optionally, a character string specifying the role for the CloudWatch Logs endpoint to assume to write to a user's log group.
#' @param global Specifies whether the trail is publishing events from global services such as IAM to the log files.
#' @param multi_region A logical specifying whether the trail will cover all regions (\code{TRUE}) or only the region in which the trail is created (\code{FALSE}).
#' @param key_prefix Optionally, a prefix for the log file names created by the trail.
#' @param sns_topic Optionally, a character string specifying an AWS SNS topic, to which notifications will be sent when each new log file is created.
#' @param kms Optionally, a character string specifying a Key Management Service (KMS) key alias (of the form \dQuote{alias/KEYALIAS}) or ARN to be used to encrypt logs.
#' @template dots
#' @return For \code{create_trail} and \code{update_trail}, a list. For \code{delete_trail}, a logical.
#' @seealso \code{\link{get_trails}}, \code{\link{trail_status}}, \code{\link{start_logging}}
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_CreateTrail.html}
#' @examples
#' \dontrun{
#'   require("aws.s3")
#'   # create a bucket
#'   mybucket <- "mycloudtrailbucket"
#'   stopifnot(put_bucket(mybucket))
#'   # set bucket policy for CloudTrail
#'   ctpolicy <- cloudtrail_s3policy(mybucket, "my_aws_id")
#'   stopifnot(put_bucket_policy(mybucket, policy = ctpolicy))
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
#' @importFrom aws.s3 get_bucketname
#' @export
create_trail <- 
function(name, bucket, 
         log_group = NULL, 
         log_role = NULL,
         global = FALSE,
         multi_region = FALSE,
         key_prefix = NULL,
         sns_topic = NULL,
         kms = NULL,
         ...) {
    query_args <- list(Action = "CreateTrail")
    query_args$Name <- get_trailname(name)
    query_args$S3BucketName <- get_bucketname(bucket)
    if (!is.null(log_group)) {
        query_args$CloudWatchLogsLogGroupArn <- log_group
    }
    if (!is.null(log_role)) {
        query_args$CloudWatchLogsRoleArn <- log_role
    }
    if (!is.null(global)) {
        query_args$IncludeGlobalServiceEvents <- tolower(global)
    }
    if (!is.null(multi_region)) {
        query_args$IsMultiRegionTrail <- tolower(multi_region)
    }
    if (!is.null(key_prefix)) {
        if (nchar(key_prefix) > 200) {
            stop("'key_prefix' must be max 200 characters")
        }
        query_args$S3KeyPrefix <- key_prefix
    }
    if (!is.null(sns_topic)) {
        query_args$SnsTopicName <- as.character(sns_topic)
    }
    if (!is.null(kms)) {
        query_args$KmsKeyId <- kms
    }
    out <- cloudtrailHTTP(query = query_args, ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(out$CreateTrailResponse$CreateTrailResult,
              RequestId = out$CreateTrailResponse$ResponseMetadata$RequestId,
              class = "aws_cloudtrail")
}

#' @rdname trails
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_UpdateTrail.html}
#' @export
update_trail <- 
function(name, 
         bucket = NULL, 
         log_group = NULL, 
         log_role = NULL,
         global = NULL,
         key_prefix = NULL,
         sns_topic = NULL,
         ...) {
    query_args <- list(Action = "UpdateTrail")
    query_args$Name <- get_trailname(name)
    if (!is.null(bucket)) {
        query_args$S3BucketName <- get_bucketname(bucket)
    }
    if (!is.null(log_group)) {
        query_args$CloudWatchLogsLogGroupArn <- log_group
    }
    if (!is.null(log_role)) {
        query_args$CloudWatchLogsRoleArn <- log_role
    }
    if (!is.null(global)) {
        query_args$IncludeGlobalServiceEvents <- tolower(global)
    }
    if (!is.null(key_prefix)) {
        query_args$S3KeyPrefix <- key_prefix
    }
    if (!is.null(sns_topic)) {
        query_args$SnsTopicName <- as.character(sns_topic)
    }
    out <- cloudtrailHTTP(query = query_args, ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(out$UpdateTrailResponse$UpdateTrailResult,
              RequestId = out$UpdateTrailResponse$ResponseMetadata$RequestId,
              class = "aws_cloudtrail")
}

#' @rdname trails
#' @references \url{http://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DeleteTrail.html}
#' @export
delete_trail <- function(name, ...) {
    out <- cloudtrailHTTP(query = list(Action = "DeleteTrail", Name = get_trailname(name)), ...)
    if (inherits(out, "aws-error")) {
        return(out)
    }
    structure(TRUE, RequestId = out$DeleteTrailResponse$ResponseMetadata$RequestId)
}

