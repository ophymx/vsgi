using Gee;

namespace VSGI {

public class NoContent : Object, Application {

    public NoContent() {
    }

    public Response call(Request request) {
        HashMap<string, string> headers = new HashMap<string, string>();

        return new Response(204, headers, new Body.empty());
    }
}

}
