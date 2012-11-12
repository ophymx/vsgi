using Gee;

namespace VSGI {

/**
 * Cascade app
 */
public class Cascade : Object, Application {

    public ArrayList<Application> apps;
    private HashSet<uint> catches;

    /**
     *
     */
    public Cascade(ArrayList<Application> apps, uint[] catches = {404, 405}) {
        this.apps = new ArrayList<Application>();
        foreach (Application app in apps)
            this.apps.add(app);

        this.catches = new HashSet<uint>();
        foreach(uint value in catches)
            this.catches.add(value);
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
