namespace VSGI {

public enum Protocol {
    HTTP,
    HTTPS;

    public static Protocol? from_string(string protocol) {
        switch (protocol.down()) {
            case "http": return HTTP;
            case "https": return HTTPS;
            default: return null;
        }
    }

    public string to_string() {
        switch (this) {
            case HTTP: return "http";
            case HTTPS: return "https";
            default: assert_not_reached();
        }
    }
}

}
