using Gee;

namespace VSGI {

/**
 * Mapper app
 */
public class Mapper : Object, Application {

    private Map<string, Application> apps;
    private Application default_app;

    /**
     *
     */
    public Mapper(Map<string, Application> apps,
        Application? default_app=null) {
        this.apps = apps;

        if (default_app == null)
            this.default_app = new NotFound();
        else
            this.default_app = default_app;
    }

    /**
     *
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
        return default_app.call(request);
    }
}

}
