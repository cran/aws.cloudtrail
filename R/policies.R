#' @rdname policies
#' @title Example Policies for CloudTrail
#' @description Construct an S3 or SNS policy document for use with CloudTrail
#' @param bucket A character string containing an S3 bucket name, or an object of class \dQuote{s3_bucket}.
#' @param topic A character string specifying the SNS topic ARN.
#' @param account_id A character string containing an AWS account ID.
#' @param prefix Optionally, a character string containing the prefix for the Account ID. This can be retrieved from the AWS console or via a call to \code{aws.iam::get_caller_identity()}.
#' @return A character string containing the policy
#' @importFrom aws.s3 get_bucketname
#' @importFrom jsonlite toJSON fromJSON
#' @export
cloudtrail_s3policy <- function(bucket, account_id, prefix = NULL) {
    bucket <- get_bucketname(bucket)
    
    paste0('{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::',bucket,'"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::',bucket,if(!is.null(prefix)) paste0("/", prefix) else "",'/AWSLogs/',account_id,'/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}')
}

#' @rdname policies
#' @export
cloudtrail_snspolicy <- function(topic) {
    paste0('{
    "Version": "2012-10-17",
    "Statement": [{   
        "Sid": "AWSCloudTrailSNSPolicy20131101",
        "Effect": "Allow",   
        "Principal": {
            "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "SNS:Publish",   
        "Resource": ', topic, '"
    }]
}')
}
