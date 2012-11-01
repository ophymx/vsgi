namespace VSGI {
namespace Utils {

public static string status_message(uint status) {
    switch (status) {
        /* 1XX Info */
        case 100:
            return "Continue";
        case 101:
            return "Switching Protocols";
        case 102: /* RFC 2518*/
            return "Processing";

        /* 2XX Success */
        case 200:
            return "OK";
        case 201:
            return "Created";
        case 202:
            return "Accepted";
        case 203:
            return "Non-Authoritative Information";
        case 204:
            return "No Content";
        case 205:
            return "Reset Content";
        case 206:
            return "Partial Content";
        case 207: /* RFC 4918 */
            return "Multi-Status";
        case 208: /* RFC 5842 */
            return "Already Reported";
        case 226: /* RFC 3229 */
            return "IM Used";

        /* 3XX Redirection */
        case 300:
            return "Multiple Choices";
        case 301:
            return "Moved Permanently";
        case 302:
            return "Found";
        case 303:
            return "See Other";
        case 304:
            return "Not Modified";
        case 305:
            return "Use Proxy";
        case 306:
            return "Switch Proxy";
        case 307:
            return "Temporary Redirect";
        case 308:
            return "Premanent Redirect";

        /* 4XX Client Error */
        case 400:
            return "Bad Request";
        case 401:
            return "Unauthorized";
        case 402:
            return "Payment Required";
        case 403:
            return "Forbidden";
        case 404:
            return "Not Found";
        case 405:
            return "Method Not Allowed";
        case 406:
            return "Not Acceptable";
        case 407:
            return "Proxy Authentication Required";
        case 408:
            return "Request Timeout";
        case 409:
            return "Conflict";
        case 410:
            return "Gone";
        case 411:
            return "Length Required";
        case 412:
            return "Precondition Failed";
        case 413:
            return "Request Entity Too Large";
        case 414:
            return "Request-URI Too Long";
        case 415:
            return "Unsupported Media Type";
        case 416:
            return "Requested Range Not Satisfiable";
        case 417:
            return "Expectation Failed";
        case 422: /* RFC 4918 */
            return "Unprecessable Entity";
        case 423: /* RFC 4918 */
            return "Locked";
        case 424: /* RFC 4918 */
            return "Failed Dependency";
        case 426: /* RFC 2817 */
            return "Upgrade Required";
        case 428: /* RFC 6585 */
            return "Precondition Required";
        case 429: /* RFC 6585 */
            return "Too Many Requests";
        case 431: /* RFC 6585 */
            return "Request Header Fields Too Large";

        /* 5XX Server Error */
        case 500:
            return "Internal Server Error";
        case 501:
            return "Not Implemented";
        case 502:
            return "Bad Gateway";
        case 503:
            return "Service Unavailable";
        case 504:
            return "Gateway Timeout";
        case 505:
            return "HTTP Version Not Supported";
        case 506: /* RFC 2295 */
            return "Variant Also Negotiates";
        case 507: /* RFC 4918 */
            return "Insufficient Storage";
        case 508: /* RFC 5842 */
            return "Loop Detected";
        case 509:
            return "Bandwidth Limit Exceeded";
        case 510: /* RFC 2774 */
            return "Not Extended";
        case 511: /* RFC 6585 */
            return "Network Authentication Required";

        default:
            return "";
    }
}

}}
