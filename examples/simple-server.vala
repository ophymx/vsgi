using Gee;

public static void main() {
    var fs = new VSGI.FileServer("public");
    var apps = new HashMap<string, VSGI.Application>();
    apps["/foobar"] = fs;

    var map = new VSGI.Mapper(apps);
    var ws = new VSGI.SimpleServer(map);
    ws.run();
}
