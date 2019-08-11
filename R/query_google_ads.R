#' @title Query Google Ads Data
#' @description Queries data from Google Ads API.
#' @param mcc_id Google Ads Client Center MCC Manager Id
#' @param google_auth auth object
#' @param service Google Ads API Service Object
#' @param raw_data T/F returns raw data or content only
#' @importFrom curl new_handle handle_setheaders handle_setopt curl_fetch_memory
#' @importFrom jsonlite fromJSON
#' @return Dataframe
#' @export
query_google_ads <- function(mcc_id,
                             google_auth,
                             service,
                             raw_data = F
                             ) {

  access <- google_auth$access
  credlist <- google_auth$credentials

  if (as.numeric(Sys.time()) - 3600 >= access$timeStamp) {
    access <- refresh_token(google_auth)
  }


  mcc_id <- gsub("-", "", mcc_id)
  google.auth <- paste(access$token_type, access$access_token)

  h <- build_handle(service)

  handle_setheaders(h,
    "Host" = "googleads.googleapis.com",
    "User-Agent" = "curl",
    "Content-Type" = "application/json",
    "Accept" = "application/json",
    "Authorization" = google.auth,
    "developer-token" = credlist$auth.developerToken,
    "login-customer-id" = mcc_id
  )

  req <- curl_fetch_memory(service$url, handle = h)
  class(req) <- append(class(req), paste0(service$service_name, "Result"))

  extract_data(req, raw_data)
}