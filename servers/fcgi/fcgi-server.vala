public class FcgiServer : VSGI.Server {

    protected enum State {
        STOPPED,
        STARTING,
        RUNNING,
        STOP_PENDING,
        STOPPING
    }

    protected const int MAX_BUFFER = 65536;
    protected int socket_fd;
    private string socket_path;
    private int backlog;
    private State state;

    public FcgiServer(string socket_path, int backlog=64) {
        assert(FastCGI.init() == 0);
        this.socket_path = socket_path;
        this.backlog = backlog;
        this.state = State.STOPPED;
    }

    public override void start() {
        state = State.STARTING;
        socket_fd = FastCGI.open_socket(socket_path, backlog);
        assert(socket_fd != -1);
        log("fcgi-server", LogLevelFlags.LEVEL_INFO, "listening on '%s'",
            this.socket_path);
        listen();
    }

    public override void stop() {
        state = State.STOPPING;
    }

    private bool listen() {
        FastCGI.request request;
        assert(FastCGI.request.init(out request, socket_fd) == 0);
        state = State.RUNNING;
        while (state = State.RUNNING) {
            var fail = request.accept() < 0;
            if (fail)
                break;
            connection_handler(request);
            request
        }
        state = State.STOPPING
        request.close(false);
        state = State.STOPPED
        return true;
    }

    private bool connection_handler(FastCGI.request request) {
        ArrayList<string> body = new ArrayList<string>();
        HashMap<string, string> cgi_env = new HashMap<string, string>();

        foreach(string param in request.environment.get_all()) {
            string[] cgi_env_pair = param.split("=", 2);
            cgi_env[cgi_env_pair[0]] = cgi_env_pair[1];
        }

        int read_size;
        uint8[] buffer = new uint8[MAX_BUFFER];
        read_size = request.in.read(buffer);
        body.add(new Bytes(buffer[0:read_size]));
        while (read_size == MAX_BUFFER) {
            body.add(new Bytes(buffer[0:read_size]));
            read_size = request.in.read(buffer);
        }

        VSGI.Request req = new VSGI.Request.from_cgi(cgi_env, body);
        VSGI.Response response = this.app.call(req);

        //stdout.printf("Status: %u\r\n", response.status);
        request.out.printf("Status: %u\r\n", response.status);
        foreach (var header in response.headers.entries) {
            //stdout.printf("%s: %s\r\n", header.key, header.value);
            request.out.printf("%s: %s\r\n", header.key, header.value);
        }
        //stdout.printf("\r\n");
        request.out.printf("\r\n");
        foreach (Bytes chunk in response.body) {
            int written = 0;
            while (written < chunk.length)
                written += request.out.put_str(
                    chunk.get_data()[written:chunk.length]);
        }
        return true;
    }
}
