namespace VSGI.Utils {

public string cgi_var_to_header(string cgi_variable) {
    string cgi_var = cgi_variable.down();
    if (cgi_var.has_prefix("http_"))
        cgi_var = cgi_var.substring(cgi_var.index_of_nth_char(5));

    switch (cgi_var) {
        case "te":
            return "TE";

        case "www_authenticate":
            return "WWW-Authenticate";

        case "content_md5":
            return "Content-MD5";

        default:
            StringBuilder builder = new StringBuilder();
            foreach(string token in cgi_var.split_set("_-")) {
                builder.append(token.up(1));
                builder.append(token.substring(token.index_of_nth_char(1)));
                builder.append("-");
            }
            builder.truncate(cgi_var.length);
            return builder.str;
    }
}

public const string[] GENERAL_HEADERS = {
    "Cache-Control",
    "Connection",
    "Date",
    "Pragma",
    "Trailer",
    "Transfer-Encoding",
    "Upgrade",
    "Via",
    "Warning"
};
public bool general_header(string header) {
    return (header in GENERAL_HEADERS);
}

public const string[] REQUEST_HEADERS = {
    "Accept",
    "Accept-Charset",
    "Accept-Encoding",
    "Accept-Language",
    "Authorization",
    "Expect",
    "From",
    "Host",
    "If-Match",
    "If-Modified-Since",
    "If-None-Match",
    "If-Range",
    "If-Unmodified-Since",
    "Max-Forwards",
    "Proxy-Authorization",
    "Range",
    "Referer",
    "TE",
    "User-Agent",
    "Cookie",
    "X-Forwarded-For",
    "X-Forwarded-Proto"
};
public bool request_header(string header) {
    return (header in REQUEST_HEADERS);
}

public const string[] RESPONSE_HEADERS = {
    "Accept-Ranges",
    "Age",
    "ETag",
    "Location",
    "Proxy-Authenticate",
    "Retry-After",
    "Server",
    "Vary",
    "WWW-Authenticate",
    "Set-Cookie"
};
public bool response_header(string header) {
    return (header in RESPONSE_HEADERS);
}

public const string[] ENTITY_HEADERS = {
    "Allow",
    "Content-Encoding",
    "Content-Language",
    "Content-Length",
    "Content-Location",
    "Content-MD5",
    "Content-Range",
    "Content-Type",
    "Expires",
    "Last-Modified"
};
public bool entity_header(string header) {
    return (header in ENTITY_HEADERS);
}

}
