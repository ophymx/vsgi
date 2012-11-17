namespace VSGI {

public class NotFound : Object, Application {

    public NotFound() {
    }

    public Response call(Request request) {
        return static_call(request);
    }

    public static Response static_call(Request request) {
        Gee.HashMap<string, string> headers = new Gee.HashMap<string, string>();

        string message = "Not Found: '%s'\r\n".printf(request.full_path());

        Body body = new Body.from_string(message);
        headers["Content-Type"] = "text/plain";
        headers["Content-Length"] = message.length.to_string();

        return new Response(404, headers, body);
    }
}

}
