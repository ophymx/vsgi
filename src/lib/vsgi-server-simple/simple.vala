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
public class VSGI.SimpleServer : VSGI.Server {

    private ThreadedSocketService socket_service;
    private MainLoop main_loop;
    private uint16 port;

    public SimpleServer(uint16 port=8080) {
        this.port = port;

        socket_service = new ThreadedSocketService(150);
        InetAddress addr = new InetAddress.any(SocketFamily.IPV4);
        InetSocketAddress socket = new InetSocketAddress(addr, this.port);
        main_loop = new MainLoop();

        try {
            socket_service.add_address(socket, SocketType.STREAM,
                SocketProtocol.TCP, null, null);
        } catch(Error e) {
            log("VSGI.SimpleServer", LogLevelFlags.LEVEL_CRITICAL, "%s",
                e.message);
            return;
        }

        socket_service.run.connect( connection_handler );
    }

    /**
     * {@inheritDoc}
     */
    public override void start() {
        assert(this.app != null);
        socket_service.start();
        log("VSGI.SimpleServer", LogLevelFlags.LEVEL_INFO, "Server on port %d",
            this.port);
        main_loop.run();
    }

    /**
     * {@inheritDoc}
     */
    public override void stop() {
        log("VSGI.SimpleServer", LogLevelFlags.LEVEL_INFO, "Shutting down");
        socket_service.stop();
        main_loop.quit();
    }

    private Gee.Map<string, string> parse_headers(DataInputStream input) {
        Gee.HashMap<string, string> headers = new Gee.HashMap<string, string>();
        string req_line = "";
        size_t size = 0;
        try {
             req_line = input.read_line_utf8(out size);
        } catch(Error e) {
            log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                e.message);
        }
        while(size != 0) {
            string[] header = req_line.split(": ", 2);
            headers[header[0]] = header[1];
            try {
                 req_line= input.read_line_utf8(out size);
            } catch(Error e) {
                log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                    e.message);
            }
        }
        return headers;
    }

    private bool send_response(OutputStream output, Response response) {
        StringBuilder builder = new StringBuilder();
        builder.append_printf("%s %u %s\r\n",
                                VSGI.Protocol.HTTP1_1.to_string(),
                                response.status,
                                VSGI.Utils.status_message(response.status));
        foreach (var header in response.headers.entries) {
            builder.append_printf("%s: %s\r\n", header.key, header.value);
        }
        builder.append("\r\n");
        try {
            size_t  written = 0;
            uint8[] data    = builder.data;
            size_t  length  = builder.len;
            while (written < length) {
                written += output.write(data[written:length]);
            }
            response.headers_sent();
            foreach (Bytes chunk in response.body) {
                written = 0;
                data = chunk.get_data();
                length = chunk.length;
                while (written < length) {
                    written += output.write(data[written:length]);
                }
            }
            response.body_sent();
        } catch(Error e) {
            log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                e.message);
            return false;
        }
        return true;
    }

    private bool get_connection_values(SocketConnection conn,
                                        out string remote_addr,
                                        out uint16 remote_port,
                                        out string server_addr,
                                        out uint16 server_port) {
        remote_addr = "";
        remote_port = 0;
        server_addr = "";
        server_port = 0;
        Posix.SockAddrIn local_sock_addr = Posix.SockAddrIn();
        Posix.SockAddrIn remote_sock_addr = Posix.SockAddrIn();

        try {
            if (!conn.get_local_address().to_native(
                    &local_sock_addr, sizeof(Posix.SockAddrIn))) {
                return false;
            }
            if (!conn.get_remote_address().to_native(
                    &remote_sock_addr, sizeof(Posix.SockAddrIn))) {
                return false;
            }
        } catch (Error e) {
            log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                e.message);
            return false;
        }

        remote_addr = Posix.inet_ntoa(remote_sock_addr.sin_addr);
        remote_port = Posix.ntohs(remote_sock_addr.sin_port);
        server_addr = Posix.inet_ntoa(local_sock_addr.sin_addr);
        server_port = Posix.ntohs(local_sock_addr.sin_port);

        return true;
    }

    private bool connection_handler(SocketConnection conn) {
        /* Get Connection Info */
        string script_name = "";
        string remote_addr;
        uint16 remote_port;
        string server_addr;
        uint16 server_port;
        VSGI.Scheme scheme = VSGI.Scheme.HTTP;
        if (!get_connection_values(conn, out remote_addr, out remote_port,
                out server_addr, out server_port)) {
            return false;
        }

        string req_line;
        size_t size;
        DataInputStream input = new DataInputStream(conn.input_stream);
        OutputStream output = conn.output_stream;
        input.set_newline_type(DataStreamNewlineType.CR_LF);

        while (conn.is_connected()) {
            req_line = "";
            size = 0;

            /* Parse Initial Request */
            try {
                req_line = input.read_line_utf8(out size);
            } catch(Error e) {
                log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                    e.message);
                break;
            }
            /* Connection Closed */
            if (req_line == null)
                break;
            /* Blank Line */
            if (size == 0)
                continue;

            string[] req = req_line.split(" ");
            VSGI.Method? method = VSGI.Method.from_string(req[0]);
            /* Invalid Method */
            if (method == null) {
                send_response(output, new Response(405));
                continue;
            }
            /* Invalid Protocol */
            VSGI.Protocol? protocol = VSGI.Protocol.from_string(req[2]);
            if (protocol == null) {
                send_response(output, new Response(505));
                continue;
            }

            string[] resource = req[1].split("?", 2);
            string? path_info = Uri.unescape_string(resource[0]);
            string? query_string = Uri.unescape_string(resource[1]);
            /* Invalid Path */
            if (path_info == null) {
                send_response(output, new Response(400));
                continue;
            }
            if (query_string == null) {
                query_string = "";
            }

            /* Parse Headers */
            Gee.Map<string, string> headers = parse_headers(input);

            bool connection_close = (headers["Connection"] == "close");

            /* Form Request */
            VSGI.IterableByteStream body = new VSGI.IterableByteStream(input);
            VSGI.Request request = new VSGI.Request(method, script_name,
                path_info, query_string, remote_addr, remote_port, server_addr,
                server_port, protocol, scheme, headers, body);
            request.headers_recieved();

            /* Call App */
            VSGI.Response response = this.app.call(request);

            /* Send Response */
            if (!send_response(output, response))
                break;
            if (connection_close)
                break;
        }

        try {
            input.close();
            output.close();
        } catch (Error e) {
            log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                                e.message);
        }
        return true;
    }
}
