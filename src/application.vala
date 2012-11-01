namespace VSGI {

public interface Application : Object {
    public abstract Response call(Request request);
}

public interface CompositeApp : Object, Application {

    public abstract Application app { get; set; }
}

}
