#' @title cloudtrailHTTP
#' @description AWS Cloudtrail API Requests
#' @details This is the workhorse function for executing Cloudtrail API requests. It is typically not necessary to call this function directly.
#' @param query A list.
#' @param body The body of the request.
#' @param headers A list of headers to pass to the REST request.
#' @param version A character string specifying the API version.
#' @param region A character string containing the AWS region. If missing, defaults to the value of environment variable \samp{AWS_DEFAULT_REGION}.
#' @param key A character string containing an AWS Access Key ID. If missing, defaults to value stored in environment variable \dQuote{AWS_ACCESS_KEY_ID}.
#' @param secret A character string containing an AWS Secret Access Key. If missing, defaults to value stored in environment variable \dQuote{AWS_SECRET_ACCESS_KEY}.
#' @param session_token Optionally, a character string containing an AWS temporary Session Token. If missing, defaults to value stored in environment variable \dQuote{AWS_SESSION_TOKEN}.
#' @param \dots Additional arguments passed to \code{\link[httr]{POST}}.
#' @return A list.
#' @import httr
#' @importFrom utils str
#' @importFrom aws.signature signature_v4_auth
#' @importFrom jsonlite fromJSON
#' @export
cloudtrailHTTP <- 
function(query, 
         body = NULL, 
         headers = list(),
         version = "2013-11-01",
         region = Sys.getenv("AWS_DEFAULT_REGION", "us-east-1"), 
         key = NULL, 
         secret = NULL, 
         session_token = NULL,
         ...) {
    if (region == "") {
        region <- "us-east-1"
    }
    url <- paste0("https://cloudtrail.",region,".amazonaws.com")
    d_timestamp <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
    query <- c(query, Version = version)
    Sig <- signature_v4_auth(
           datetime = d_timestamp,
           region = region,
           service = "cloudtrail",
           verb = "POST",
           action = "/",
           query_args = query,
           canonical_headers = list(host = paste0("cloudtrail.",region,".amazonaws.com"),
                                    `x-amz-date` = d_timestamp),
           request_body = "",
           key = key, 
           secret = secret,
           session_token = session_token)
    headers[["x-amz-date"]] <- d_timestamp
    headers[["x-amz-content-sha256"]] <- Sig$BodyHash
    if (!is.null(session_token) && session_token != "") {
        headers[["x-amz-security-token"]] <- session_token
    }
    headers[["Authorization"]] <- Sig[["SignatureHeader"]]
    H <- do.call(add_headers, headers)

    r <- POST(url, H, query = query, ...)
    
    if (http_error(r)) {
        x <- try(fromJSON(content(r, "text", encoding = "UTF-8"))$Error, silent = TRUE)
        h <- headers(r)
        out <- structure(x, headers = h, class = "aws_error")
        attr(out, "request_canonical") <- Sig$CanonicalRequest
        attr(out, "request_string_to_sign") <- Sig$StringToSign
        attr(out, "request_signature") <- Sig$SignatureHeader
        print(str(out))
        stop_for_status(r)
    } else {
        out <- try(fromJSON(content(r, "text", encoding = "UTF-8"), simplifyDataFrame = FALSE), silent = TRUE)
        if(inherits(out, "try-error"))
            out <- structure(content(r, "text", encoding = "UTF-8"), "unknown")
    }
    return(out)
}
