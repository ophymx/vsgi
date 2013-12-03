VSGI.FcgiServer ws;

const int[] STOP_SIGNALS = {
    Posix.SIGTERM,
    Posix.SIGINT,
    Posix.SIGQUIT
};

const string[] LOG_DOMAINS = {
    "VSGI.CommonLogger",
    "VSGI.FcgiServer",
    "VSGI.Lint"
};

void stdout_logfunc(string? domain, LogLevelFlags levels, string message) {
    stdout.printf("%s\n", message.split(" ", 2)[1]);
}

int main(string[] args) {
    foreach (var domain in LOG_DOMAINS) {
        Log.set_handler(domain, LogLevelFlags.LEVEL_MASK, stdout_logfunc);
    }

    ws = new VSGI.FcgiServer(":5000");
    try {
        ws.load_app("setup_app");
    } catch (VSGI.AppLoadError e) {
        error("%s", e.message);
    }

    foreach (var signum in STOP_SIGNALS) {
        Posix.signal(signum, (s) => { ws.stop(); });
    }

    ws.start();
    return 0;
}
