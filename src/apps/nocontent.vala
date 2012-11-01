using Gee;

namespace VSGI {

public class NoContent : Object, Application {
    public NoContent() {
    }

    public Response call(Request request) {
        HashMap<string, string> headers = new HashMap<string, string>();
        ArrayList<string> body = new ArrayList<string>();

        return new Response(204, headers, body);
    }
}

}
