using Gee;
namespace VSGI {

/**
 *
 */
public errordomain InvalidRequest {
    UNKNOWN_METHOD,
    INVALID_SCRIPT_NAME,
    INVALID_PATH,
    INVALID_CONTENT_LENGTH,
    MISSING_PATH_AND_SCRIPT_NAME
}

/**
 *
 */
public class Request : Object {
    /**
     *
     */
    public Method method { get; private set; }
    /**
     *
     */
    public string script_name { get; set; }
    /**
     *
     */
    public string path_info { get; set; }
    /**
     *
     */
    public string query_string { get; private set; }
    /**
     *
     */
    public string remote_addr { get; private set; }
    /**
     *
     */
    public string server_addr { get; private set; }
    /**
     *
     */
    public uint16 server_port { get; private set; }
    /**
     *
     */
    public string server_software { get; private set; }
    /**
     *
     */
    public Protocol protocol { get; private set; }
    /**
     *
     */
    public Map<string, string> headers { get; set; }
    /**
     *
     */
    public Iterable<Bytes> body;

    /**
     * @param method            http request method {@link VSGI.Method}
     * @param script_name       path of script invoked by request
     * @param path_info         path of the request after the script
     * @param query_string      query string in request
     * @param server_addr       server address
     * @param server_port       server port
     * @param protocol          protocol (http or https)
     * @param headers           request headers
     * @param body              request body as an iterable collection of bytes
     * @return                  newly created request
     */
    public Request(Method method, string script_name, string path_info,
        string query_string, string server_addr, uint16 server_port,
        Protocol protocol, Map<string, string> headers,
        Iterable<Bytes> body) {

        this.method = method;
        this.script_name = script_name;
        this.path_info = path_info;
        this.query_string = query_string;
        this.server_addr = server_addr;
        this.server_port = server_port;
        this.protocol = protocol;

        this.headers = headers;
        this.body = body;

    }

    /**
     * @return  combined script_name and path_info.
     */
    public string full_path() {
        return script_name.concat(path_info);
    }

    /**
     *
     */
    public bool validate() throws InvalidRequest {
        if (script_name.length > 0 & script_name[0] != '/' )
            throw new InvalidRequest.INVALID_SCRIPT_NAME(
                "script_name must begin with a '/'");

        if (path_info.length > 0 & path_info[0] != '/')
            throw new InvalidRequest.INVALID_PATH(
                "path_info must begin with a '/'");

        if (path_info.length == 0 & script_name.length == 0)
            throw new InvalidRequest.MISSING_PATH_AND_SCRIPT_NAME(
                "either script_name or path_info must be set");

        if (script_name.length == 0 & path_info != "/")
            throw new InvalidRequest.INVALID_PATH(
                "path_info must be '/' if script_name is empty");

        if (script_name == "/")
            throw new InvalidRequest.INVALID_SCRIPT_NAME(
                "script_name must not be '/' but instead be empty");

        if (headers.has_key("Content-Length")) {
            string content_length = headers["Content-Length"];
            if (uint64.parse(content_length).to_string() !=
                    content_length.strip())
                throw new InvalidRequest.INVALID_CONTENT_LENGTH(
                    "Content-Length header must only consist of digits");
        }

        return true;
    }
}

}
