namespace VSGI {

/**
 * Cascade app
 */
public class Cascade : Object, Application {

    public Gee.List<Application> apps;
    private Gee.HashSet<uint> catches;

    /**
     *
     */
    public Cascade(Gee.List<Application> apps=null,
        uint[] catches = {404, 405}) {
        if (apps == null)
            this.apps = new Gee.ArrayList<Application>();
        else
            this.apps = apps;

        this.catches = new Gee.HashSet<uint>();
        foreach(uint status in catches)
            this.catches.add(status);
    }

    /**
     *
     */
    public Response call(Request request) {
        Response response = NotFound.static_call(request);

        foreach (Application app in apps){
            response = app.call(request);
            if (!catches.contains(response.status))
                return response;
        }
        return response;
    }
}

}
