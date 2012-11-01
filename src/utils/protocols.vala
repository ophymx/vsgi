namespace VSGI {

public enum Protocol {
    HTTP,
    HTTPS,
    AJP;

    public static Protocol? from_string(string protocol) {
        switch (protocol.up()) {
            case "HTTP":
                return HTTP;

            case "HTTPS":
                return HTTPS;

            case "AJP":
                return AJP;

            default:
                return null;
        }
    }

    public string to_string() {
        switch (this) {
            case HTTP:
                return "HTTP";

            case HTTPS:
                return "HTTPS";

            case AJP:
                return "AJP";

            default:
                assert_not_reached();
        }
    }
}

}
