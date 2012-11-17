using Gee;
using VSGI;

public static VSGI.Application app() {
    var apps = new HashMap<string, VSGI.Application>();
    var stack = new CompositeStack();
    stack.add(new CommonLogger());
    stack.add(new SuffixMapper());
    stack.app = new FileServer("public");

    apps["/foobar"] = stack;

    return new Mapper(apps);
}

public static void main() {
    Log.set_handler("VSGI.CommonLogger", LogLevelFlags.LEVEL_MASK,
        (domain, levels, msg) => {
            stderr.printf("%s\n", msg.split(" ", 2)[1]);
        });

    var ws = new SimpleServer(app());
    ws.run();
}
