namespace VSGI {

public enum Scheme {
    HTTP,
    HTTPS;

    public static Scheme? from_string(string scheme) {
        switch (scheme.down()) {
            case "http":  return HTTP;
            case "https": return HTTPS;
            default: return null;
        }
    }

    public static Scheme? from_port(uint16 port) {
        switch (port) {
            case 80:  return HTTP;
            case 443: return HTTPS;
            default: return null;
        }
    }

    public string to_string() {
        switch (this) {
            case HTTP:  return "http";
            case HTTPS: return "https";
            default: assert_not_reached();
        }
    }

    public uint16 default_port() {
        switch (this) {
            case HTTP:  return 80;
            case HTTPS: return 443;
            default: assert_not_reached();
        }
    }

}

}
