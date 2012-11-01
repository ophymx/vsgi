using Gee;
int socket_fd;
//Mutex mutex;

const int MAX_BUFFER = 65536;


bool handler(VSGI.Application app) {
    FastCGI.request request;
    uint8[] buffer = new uint8[MAX_BUFFER];
    int read_size;
    ArrayList<string> body = new ArrayList<string>();
    HashMap<string, string> headers = new HashMap<string, string>();

    assert(FastCGI.request.init(out request, socket_fd) == 0);
    while (true) {
        //mutex.lock();
        var fail = request.accept() < 0;
        //mutex.unlock();
        if (fail)
            break;

        VSGI.Method method = VSGI.Method.from_string(request.environment.get("REQUEST_METHOD"));
        string query_string = request.environment.get("QUERY_STRING");
        string path = request.environment.get("PATH_INFO");
        string script_name = request.environment.get("SCRIPT_NAME");
        string server_addr = request.environment.get("SERVER_ADDR");
        uint16 server_port = (uint16) uint64.parse(request.environment.get("SERVER_PORT"));

        read_size = request.in.read(buffer);
        stdout.printf("%s", (string) buffer);
        body.add(((string) buffer).dup());
        while (read_size == MAX_BUFFER) {
            stdout.printf("%s", (string) buffer);
            body.add(((string) buffer).dup());
            read_size = request.in.read(buffer);
        }

        foreach(string param in request.environment.get_all()){
            string[] hdr_pair = param.split("=", 2);
            switch (hdr_pair[0]) {
                case "CONTENT_LENGTH":
                    headers["content-length"] = hdr_pair[1];
                    break;

                case "CONTENT_TYPE":
                    headers["content-type"] = hdr_pair[1];
                    break;

                default:
                    if (hdr_pair[0].index_of("HTTP_") == 0)
                        headers[hdr_pair[0][5:-1].down()] = hdr_pair[0];
                    break;
            }
            stdout.printf("%s\n", param);
        }

        VSGI.Request req = new VSGI.Request(method, script_name, path, query_string,
            server_addr, server_port, VSGI.Protocol.HTTP, headers, body);

        VSGI.Response response = app.call(req);

        stdout.printf("Status: %u\r\n", response.status);
        request.out.printf("Status: %u\r\n", response.status);
        foreach (var header in response.headers.entries) {
            stdout.printf("%s: %s\r\n", header.key, header.value);
            request.out.printf("%s: %s\r\n", header.key, header.value);
        }
        stdout.printf("\r\n");
        request.out.printf("\r\n");
        foreach (string chunk in response.body) {
            //stdout.printf("%s", chunk);
            request.out.printf("%s", chunk);
        }

        request.finish();
    }
    request.close(false);
    return true;
}

void main() {

    int backlog = 64;
    string socket_path = ":5000";
    int thread_count = 1;

    //mutex = Mutex();
    assert(FastCGI.init() == 0);
    stderr.printf("I:open_socket path='%s' backlog='%d'\n",
        socket_path, backlog);
    socket_fd = FastCGI.open_socket(socket_path, backlog);
    assert(socket_fd != -1);

    /*
    try {
    */
        while (thread_count > 1) {
            //new Thread<bool>.try(null, handler);
            thread_count--;
        }
        handler(new VSGI.FileServer());
    /*
    } catch(Error e) {
        stderr.printf("%s\n", e.message);
    }
    */

}
