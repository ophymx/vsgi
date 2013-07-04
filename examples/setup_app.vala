using Gee;
using VSGI;

VSGI.Application setup_app(Server server) {
    var stack = new CompositeStack();
    stack.add(new CommonLogger());
    stack.app = new Echo();

    return stack;
}
