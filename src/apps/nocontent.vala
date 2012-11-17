namespace VSGI {

public class NoContent : Object, Application {

    public NoContent() {
    }

    public Response call(Request request) {
        Gee.HashMap<string, string> headers = new Gee.HashMap<string, string>();

        return new Response(204, headers, new Body.empty());
    }
}

}
