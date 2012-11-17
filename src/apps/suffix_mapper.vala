namespace VSGI {

/**
 * SuffixMapper is a CompositeApp to try appending other suffixes onto
 * the end of a request path in the case that the results return 404.
 */
public class SuffixMapper : Object, Application, CompositeApp {

    public Application app { get; set; }
    private string[] suffixes;

    public SuffixMapper(string[] suffixes = {
        ".html", "index.hml", "/index.html"}, Application? app=null) {
        this.suffixes = suffixes;
        this.app = app;
    }

    public Response call(Request request) {
        Response original_response = app.call(request);
        if (original_response.status != 404)
            return original_response;

        Response response;
        string path_info = request.path_info;
        foreach(string suffix in suffixes) {
            request.path_info = path_info + suffix;
            response = app.call(request);
            if (response.status != 404)
                return response;
        }
        return original_response;
    }
}

}
