using Gee;

namespace VSGI {

public class NotFound : Object, Application {


    public NotFound() {
    }

    public Response call(Request request) {
        HashMap<string, string> headers = new HashMap<string, string>();
        ArrayList<string> body = new ArrayList<string>();

        string message = "Not Found: '%s%s'\r\n".printf(request.script_name,
            request.path);

        body.add(message);
        headers.set("Content-Type", "text/plain");
        headers.set("Content-Length", message.length.to_string());

        return new Response(404, headers, body);
    }

}

}
