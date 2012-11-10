using Gee;

namespace VSGI {

public class NotFound : Object, Application {


    public NotFound() {
    }

    public Response call(Request request) {
        HashMap<string, string> headers = new HashMap<string, string>();

        string message = "Not Found: '%s%s'\r\n".printf(request.script_name,
            request.path_info);

        Body body = new Body.from_string(message);
        headers["Content-Type"] = "text/plain";
        headers["Content-Length"] = message.length.to_string();

        return new Response(404, headers, body);
    }

}

}
