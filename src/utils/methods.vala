namespace VSGI {

public enum Method {
    OPTIONS,
    GET,
    HEAD,
    POST,
    PUT,
    DELETE,
    TRACE,
    CONNECT,
    PATCH;

    public static Method? from_string(string method) {
        switch (method.up()) {
            case "OPTIONS": return OPTIONS;
            case "GET":     return GET;
            case "HEAD":    return HEAD;
            case "POST":    return POST;
            case "PUT":     return PUT;
            case "DELETE":  return DELETE;
            case "TRACE":   return TRACE;
            case "CONNECT": return CONNECT;
            case "PATCH":   return PATCH;
            default: return null;
        }
    }

    public string to_string() {
        switch (this) {
            case OPTIONS: return "OPTIONS";
            case GET:     return "GET";
            case POST:    return "POST";
            case PUT:     return "PUT";
            case DELETE:  return "DELETE";
            case TRACE:   return "TRACE";
            case CONNECT: return "CONNECT";
            case PATCH:   return "PATCH";
            default: assert_not_reached();
        }
    }
}

}
