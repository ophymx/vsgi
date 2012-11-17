namespace VSGI {

/**
 * CompositeStack is an app that nests a list of Composite Apps
 * together. The goal is to be similar to the 'use' feature in
 * rack helper apps.
 */
public class CompositeStack : Object, Application, CompositeApp {

    private Gee.List<CompositeApp> apps;
    public Application app { get; set; }

    public CompositeStack(Gee.List<CompositeApp>? apps=null) {
        if (apps == null)
            this.apps = new Gee.ArrayList<CompositeApp>();
        else
            this.apps = apps;
    }

    public void add(CompositeApp app) {
        apps.add(app);
    }

    public Response call(Request request) {
        CompositeApp start_app = null;
        CompositeApp current_app = null;

        foreach(CompositeApp app in apps) {
            if (start_app == null) {
                start_app = app;
                current_app = app;
            } else {
                current_app.app = app;
                current_app = app;
            }
        }
        if (start_app == null) {
            return this.app.call(request);
        }
        current_app.app = this.app;

        return start_app.call(request);
    }
}

}
