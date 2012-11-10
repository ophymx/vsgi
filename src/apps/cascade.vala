using Gee;

namespace VSGI {

public class Cascade : Object, Application {

    public ArrayList<Application> apps;
    private Application not_found;

    public Cascade(ArrayList<Application> apps) {
        this.apps = new ArrayList<Application>();
        foreach (Application app in apps)
            this.apps.add(app);

        not_found = new NotFound();
    }

    public Response call(Request request) {
        Response response = not_found.call(request);

        foreach (Application app in apps){
            response = app.call(request);
            if (response.status != 404 & response.status != 405 )
                return response;
        }
        return response;
    }
}

}
