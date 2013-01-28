using Gee;
using VSGI;

VSGI.Application setup_app(Server server) {
    var stack = new CompositeStack();
    stack.app = new NotFound();

    return stack;
}
