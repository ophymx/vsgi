VSGI.SimpleServer ws;

const int[] STOP_SIGNALS = {
    Posix.SIGTERM,
    Posix.SIGINT,
    Posix.SIGQUIT
};

const string[] LOG_DOMAINS = {
    "VSGI.CommonLogger",
    "VSGI.SimpleServer",
    "VSGI.Lint"
};

void stdout_logfunc(string? domain, LogLevelFlags levels, string message) {
    stdout.printf("%s\n", message.split(" ", 2)[1]);
}

int main() {
    foreach (string domain in LOG_DOMAINS) {
        Log.set_handler(domain, LogLevelFlags.LEVEL_MASK, stdout_logfunc);
    }

    ws = new VSGI.SimpleServer(8080);
    try {
        ws.load_app("setup_app");
    } catch (VSGI.AppLoadError e) {
        error("%s", e.message);
    }

    foreach (int signum in STOP_SIGNALS) {
        Posix.signal(signum, (s) => { ws.stop(); });
    }

    ws.start();
    return 0;
}
