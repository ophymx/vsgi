using Gee;
using VSGI;

SimpleServer ws;

VSGI.Application app() {
    var apps = new HashMap<string, VSGI.Application>();
    var stack = new CompositeStack();
    stack.add(new CommonLogger());
    stack.add(new SuffixMapper());
    stack.app = new FileServer("public");

    apps["/foobar"] = stack;

    return new Mapper(apps);
}

const int[] STOP_SIGNALS = { Posix.SIGTERM, Posix.SIGINT, Posix.SIGQUIT };

void stdout_logfunc(string? domain, LogLevelFlags levels, string message) {
    stdout.printf("%s\n", message.split(" ", 2)[1]);
}

int main(string[] args) {
    Log.set_handler("VSGI.CommonLogger", LogLevelFlags.LEVEL_MASK,
        stdout_logfunc);
    Log.set_handler("simple", LogLevelFlags.LEVEL_MASK, stdout_logfunc);

    ws = new SimpleServer(app());

    foreach(int signum in STOP_SIGNALS) {
        Posix.signal(signum, (s) => { ws.stop(); });
    }

    ws.run();
    return 0;
}
