using Gee;
namespace VSGI {

const uint16 DEFAULT_PORT = 8080;

public class SimpleServer {

    private ThreadedSocketService socket_service;
    private Application app;

    public SimpleServer(Application app) {
        this.app = app;

        socket_service = new ThreadedSocketService(150);
        InetAddress addr = new InetAddress.any(SocketFamily.IPV4);
        InetSocketAddress socket = new InetSocketAddress(addr, DEFAULT_PORT);

        try {
            socket_service.add_address(socket, SocketType.STREAM,
                SocketProtocol.TCP, null, null);
        } catch(Error e) {
            log("simple", LogLevelFlags.LEVEL_CRITICAL, "%s", e.message);
            return;
        }

        socket_service.run.connect( connection_handler );
    }

    public void run() {
        MainLoop main_loop = new MainLoop();
        socket_service.start();
        log("simple", LogLevelFlags.LEVEL_INFO, "Server on port %d",
            DEFAULT_PORT);
        main_loop.run();
    }

    private bool connection_handler(SocketConnection conn) {

        string req_line = "";
        size_t size = 0;

        DataInputStream input = new DataInputStream(conn.input_stream);
        OutputStream output = conn.output_stream;
        input.set_newline_type(DataStreamNewlineType.CR_LF);

        try {
            req_line = input.read_line_utf8(out size);
        } catch(Error e) {
            log("simple", LogLevelFlags.LEVEL_WARNING, "%s", e.message);
        }

        /* Parse Initial Request */
        string[] req = req_line.split(" ");
        Method method = Method.from_string(req[0]);

        string[] resource = req[1].split("?", 2);
        string path_info = resource[0];
        string query_string;
        if (resource.length == 2)
            query_string = resource[1];
        else
            query_string = "";
        HashMap<string, string> headers = new HashMap<string, string>();

        /* Parse Headers */
        try {
            req_line = input.read_line_utf8(out size);
        } catch(Error e) {
            log("simple", LogLevelFlags.LEVEL_WARNING, "%s", e.message);
        }
        while(size != 0) {
            string[] header = req_line.split(": ", 2);
            headers.set(header[0].up(), header[1]);
            try {
                req_line = input.read_line_utf8(out size);
            } catch(Error e) {
                log("simple", LogLevelFlags.LEVEL_WARNING, "%s", e.message);
            }
        }

        IterableByteStream body = new IterableByteStream(input);

        /* Form Request */
        Request request = new Request(method, "", path_info, query_string,
            "127.0.0.1", "127.0.0.1", DEFAULT_PORT, Protocol.HTTP1_1,
            Scheme.HTTP, headers, body);

        Response response = app.call(request);

        try {
            output.write("%s %u %s\r\n".printf(Protocol.HTTP1_1.to_string(),
                response.status, Utils.status_message(response.status)).data);
            foreach (var header in response.headers.entries)
                output.write("%s: %s\r\n".printf(header.key,
                    header.value).data);
            output.write("\r\n".data);
            foreach (Bytes chunk in response.body) {
                size_t written = 0;
                while (written < chunk.length)
                    written += output.write(
                        chunk.get_data()[written:chunk.length]);
            }
            output.close();

        } catch(Error e) {
            log("simple", LogLevelFlags.LEVEL_WARNING, "%s", e.message);
        }

        return true;
    }
}

}
