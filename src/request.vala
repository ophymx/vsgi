using Gee;

namespace VSGI {

public errordomain InvalidRequest {
    UNKNOWN_METHOD,
    INVALID_SCRIPT_NAME,
    INVALID_PATH,
    INVALID_CONTENT_LENGTH,
    MISSING_PATH_AND_SCRIPT_NAME
}

public class Request : Object {
    public Method method;
    public string script_name;
    public string path_info;
    public string query_string;
    public string remote_addr;
    public string server_addr;
    public uint16 server_port;
    public string server_software;
    public Protocol protocol;
    public HashMap<string, string> headers;
    public Iterable<string> body;

    public Request(Method method, string script_name, string path_info,
        string query_string, string server_addr, uint16 server_port,
        Protocol protocol, HashMap<string, string> headers,
        Iterable<string> body) {

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
