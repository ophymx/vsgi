using VSGI;

public static int main(string[] args) {
    var apps = new Gee.ArrayList<CompositeApp>.wrap({ new CommonLogger.Composite() });
    var stack = new CompositeStack(apps);
    var server = new SimpleServer(stack.of(new Echo()), 8080);

    return Server.run(server);
}
