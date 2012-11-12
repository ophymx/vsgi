using Gee;

namespace VSGI {

public class FileServer : Object, Application {

    private string dir;

    public FileServer(string dir = "public") {
        this.dir = dir;
    }

    public Response call(Request request) {
        HashMap<string, string> headers = new HashMap<string, string>();
        IterableByteStream body;

        try {
            string filename = Path.build_filename(dir, request.path_info);
            headers["Content-Type"] = "text/plain";

            File file = File.new_for_path(filename);
            FileInfo file_info = file.query_info("*", FileQueryInfoFlags.NONE);
            headers["Content-Length"] = file_info.get_size().to_string();

            FileInputStream file_stream = file.read();
            body = new IterableByteStream(file_stream);
        } catch(Error e) {
            return NotFound.static_call(request);
        }

        return new Response(200, headers, body);
    }
}

}
