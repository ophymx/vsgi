namespace VSGI {

public enum Method {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD,
    OPTIONS,
    TRACE,
    CONNECT,
    PATCH;

    public static Method? from_string(string method) {
        switch (method.up()) {
            case "GET":
                return GET;

            case "POST":
                return POST;

            case "PUT":
                return PUT;

            case "DELETE":
                return DELETE;

            case "HEAD":
                return HEAD;

            case "OPTIONS":
                return OPTIONS;

            case "TRACE":
                return TRACE;

            case "CONNECT":
                return CONNECT;

            case "PATCH":
                return PATCH;

            default:
                return null;
        }
    }

    public string to_string() {
        switch (this) {
            case GET:
                return "GET";

            case POST:
                return "POST";

            case PUT:
                return "PUT";

            case DELETE:
                return "DELETE";

            case HEAD:
                return "HEAD";

            case OPTIONS:
                return "OPTIONS";

            case TRACE:
                return "TRACE";

            case CONNECT:
                return "CONNECT";

            case PATCH:
                return "PATCH";

            default:
                assert_not_reached();
        }
    }
}

}
