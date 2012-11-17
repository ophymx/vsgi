namespace VSGI {

/**
 * Implemented by classes that run as apps on VSGI.
 */
public interface Application : Object {

    /**
     * Called when a request is made to the app.
     *
     * @param request   the request
     * @return          response to request
     */
    public abstract Response call(Request request);
}

/**
 * Implemented by classes that can be chained together.
 */
public interface CompositeApp : Object, Application {

    /**
     * The app to call through to.
     */
    public abstract Application app { get; set; }
}

}
