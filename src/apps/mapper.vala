namespace VSGI {

/**
 * Mapper app
 */
public class Mapper : Object, Application, CompositeApp {

    private Gee.Map<string, Application> apps;
    public Application app { get; set; }

    /**
     *
     */
    public Mapper(Gee.Map<string, Application> apps,
        Application? app=null) {
        this.apps = apps;
        this.app = app;
    }

    /**
     *
     * TODO
     * * Rethink implementation and use
     */
    public Response call(Request request) {
        string path = request.path_info;

        foreach (var entry in apps.entries) {
            string starts_with = entry.key;
            Application app = entry.value;
            if (path.index_of(starts_with) == 0 &&
                path.get_char(starts_with.length) == '/') {

                request.script_name += starts_with;
                request.path_info = path[starts_with.length:path.length];
                return app.call(request);
            }
        }
        if (this.app == null)
            return NotFound.static_call(request);
        return this.app.call(request);
    }
}

}
