using Gee;
using VSGI;

VSGI.Application setup_app(Server server) {
    var apps = new HashMap<string, VSGI.Application>();
    var stack = new CompositeStack();
    stack.add(new CommonLogger());
    stack.add(new SuffixMapper());
    stack.app = new FileServer("public");

    apps["/foobar"] = stack;

    return new Mapper(apps);
}
