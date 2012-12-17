/* servers/simple.vala
 *
 * Copyright (C) 2012 Jeffrey T. Peckham
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 *      Jeffrey T. Peckham <abic@ophymx.com>
 */

/**
 *
 */
public class SimpleServer : VSGI.Server {

    private ThreadedSocketService socket_service;
    private MainLoop main_loop;
    private uint port;

    public SimpleServer(port=8080) {
        this.port = port;

        socket_service = new ThreadedSocketService(150);
        InetAddress addr = new InetAddress.any(SocketFamily.IPV4);
        InetSocketAddress socket = new InetSocketAddress(addr, this.port);
        main_loop = new MainLoop();

        try {
            socket_service.add_address(socket, SocketType.STREAM,
                SocketProtocol.TCP, null, null);
        } catch(Error e) {
            log("simple", LogLevelFlags.LEVEL_CRITICAL, "%s", e.message);
            return;
        }

        socket_service.run.connect( connection_handler );
    }

    public override void start() {
        socket_service.start();
        log("simple", LogLevelFlags.LEVEL_INFO, "Server on port %d",
            this.port);
        main_loop.run();
    }

    public override void stop() {
        log("simple", LogLevelFlags.LEVEL_INFO, "Shutting down");
        socket_service.stop();
        main_loop.quit();
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
        VSGI.Method method = VSGI.Method.from_string(req[0]);

        string[] resource = req[1].split("?", 2);
        string path_info = resource[0];
        string query_string;
        if (resource.length == 2)
            query_string = resource[1];
        else
            query_string = "";
        Gee.HashMap<string, string> headers = new Gee.HashMap<string, string>();

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

        VSGI.IterableByteStream body = new VSGI.IterableByteStream(input);

        /* Form Request */
        VSGI.Request request = new VSGI.Request(method, "", path_info,
            query_string, "127.0.0.1", "127.0.0.1", this.port,
            VSGI.Protocol.HTTP1_1, VSGI.Scheme.HTTP, headers, body);

        VSGI.Response response = this.app.call(request);

        try {
            output.write("%s %u %s\r\n".printf(
                VSGI.Protocol.HTTP1_1.to_string(), response.status,
                VSGI.Utils.status_message(response.status)).data);
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
