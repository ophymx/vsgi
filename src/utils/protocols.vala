namespace VSGI {

public enum Protocol {
    HTTP1_0,
    HTTP1_1;

    public static Protocol? from_string(string protocol) {
        switch (protocol.up()) {
            case "HTTP/1.0": return HTTP1_0;
            case "HTTP/1.1": return HTTP1_1;
            default: return null;
        }
    }

    public string to_string() {
        switch (this) {
            case HTTP1_0: return "HTTP/1.0";
            case HTTP1_1: return "HTTP/1.1";
            default: assert_not_reached();
        }
    }
}

}
