using Gee;

namespace VSGI {

public errordomain InvalidResponse {
    HAS_CONTENT_TYPE,
    HAS_CONTENT_LENGTH,
    MISSING_CONTENT_TYPE,
    INVALID_STATUS_CODE,
    INVALID_HEADER
}

public class Response : Object {
    private uint _status;

    /**
     *
     */
    public uint status {
        get { return _status; }
        private set { _status = value; }
    }

    /**
     *
     */
    public Map<string, string> headers;

    /**
     *
     */
    public Iterable<Bytes> body;

    /**
     *
     */
    public Response(uint status, HashMap<string, string> headers,
        Iterable<Bytes> body) {
        this.status = status;
        this.headers = headers;
        this.body = body;
    }

    /**
     *
     */
    public bool validate() throws InvalidResponse {
        if (status < 100 | status > 599)
            throw new InvalidResponse.INVALID_STATUS_CODE(
                "status code '%u' is invalid".printf(status));

        if (status < 200 | status == 204 | status == 304) {
            if (headers.has_key("Content-Type"))
                throw new InvalidResponse.HAS_CONTENT_TYPE(
                    "Content-Type header must not be set with " +
                    "status code %u".printf(status));

            if (headers.has_key("Content-Length"))
                throw new InvalidResponse.HAS_CONTENT_LENGTH(
                    "Content-Length header must not be set with " +
                    "status code %u".printf(status));
        } else {
            if (!headers.has_key("Content-Type"))
                throw new InvalidResponse.MISSING_CONTENT_TYPE(
                    "Content-Type header must be set for " +
                    "status code '%u'".printf(status));
        }

        foreach (var header_key in headers.keys) {
            if (header_key == "Status")
                throw new InvalidResponse.INVALID_HEADER(
                    "must not set header of 'Status'");
            if (header_key[header_key.length - 1] == '-' |
                header_key[header_key.length - 1] == '_')
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not end with '-' or '_'");

            if (header_key.index_of_char(':') >= 0)
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not contain ':'");

            if (header_key.index_of_char('\n') >= 0)
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not contain a newline");
        }
        return true;
    }
}

}
