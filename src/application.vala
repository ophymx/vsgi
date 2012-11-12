namespace VSGI {

/**
 * Implemented by classes that run as apps on VSGI
 */
public interface Application : Object {

    /**
     * Called when a request is made to the app
     *
     * @param request   the request
     * @return          response to request
     */
    public abstract Response call(Request request);
}

public interface CompositeApp : Object, Application {

    public abstract Application app { get; private set; }

    /* public CompositeApp(Application app, ...) */
}

}
