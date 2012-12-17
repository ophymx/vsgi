using Gee;
using VSGI;

FcgiServer fs;

const int[] STOP_SIGNALS = { Posix.SIGTERM, Posix.SIGINT, Posix.SIGQUIT };

void stdout_logfunc(string? domain, LogLevelFlags levels, string message) {
    stdout.printf("%s\n", message.split(" ", 2)[1]);
}

int main() {
    Log.set_handler("VSGI.CommonLogger", LogLevelFlags.LEVEL_MASK,
        stdout_logfunc);
    Log.set_handler("fcgi-server", LogLevelFlags.LEVEL_MASK, stdout_logfunc);

    fs = new FcgiServer(":5000");
    try {
        fs.load_app("libsetup_app");
    } catch (AppLoadError e) {
        error("%s", e.message);
    }

    foreach(int signum in STOP_SIGNALS) {
        Posix.signal(signum, (s) => { fs.stop(); });
    }

    fs.run();
    return 0;
}
