using Gee;
using VSGI;

SimpleServer ws;

const int[] STOP_SIGNALS = { Posix.SIGTERM, Posix.SIGINT, Posix.SIGQUIT };

void stdout_logfunc(string? domain, LogLevelFlags levels, string message) {
    stdout.printf("%s\n", message.split(" ", 2)[1]);
}

int main(string[] args) {
    Log.set_handler("VSGI.CommonLogger", LogLevelFlags.LEVEL_MASK,
        stdout_logfunc);
    Log.set_handler("simple", LogLevelFlags.LEVEL_MASK, stdout_logfunc);

    ws = new SimpleServer();
    try {
        ws.load_app("libsetup_app");
    } catch (AppLoadError e) {
        error("%s", e.message);
    }

    foreach(int signum in STOP_SIGNALS) {
        Posix.signal(signum, (s) => { ws.stop(); });
    }

    ws.run();
    return 0;
}
