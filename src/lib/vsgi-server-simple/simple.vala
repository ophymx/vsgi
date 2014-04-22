/* src/lib/vsgi-server-simple/simple.vala
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
namespace VSGI {

public class SimpleServer : Object, Server {

    private ThreadedSocketService socket_service;
    private MainLoop main_loop;
    private uint16 port;

    public Application app { get; protected set; }

    public SimpleServer(Application app, uint16 port=8080) {
        this.app = app;
        this.port = port;

        socket_service = new ThreadedSocketService(150);
        var addr = new InetAddress.any(SocketFamily.IPV4);
        var socket = new InetSocketAddress(addr, this.port);
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
    public void start() {
        assert(this.app != null);
        socket_service.start();
        log("VSGI.SimpleServer", LogLevelFlags.LEVEL_INFO, "Server on port %d",
            this.port);
        main_loop.run();
    }

    /**
     * {@inheritDoc}
     */
    public void stop() {
        log("VSGI.SimpleServer", LogLevelFlags.LEVEL_INFO, "Shutting down");
        socket_service.stop();
        main_loop.quit();
    }

    private Gee.Map<string, string> parse_headers(DataInputStream input) {
        var headers = new Gee.HashMap<string, string>();
        var req_line = "";
        size_t size = 0;
        try {
             req_line = input.read_line(out size);
        } catch(Error e) {
            log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                e.message);
        }
        while(size != 0) {
            var header = req_line.split(": ", 2);
            headers[header[0]] = header[1];
            try {
                 req_line= input.read_line(out size);
            } catch(Error e) {
                log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                    e.message);
            }
        }
        return headers;
    }

    private bool send_response(OutputStream output, Response response) {
        var builder = new StringBuilder();
        builder.append_printf("%s %s %s\r\n", Protocol.HTTP1_1.to_string(),
            response.status.to_string(), response.status.message());
        foreach (var header in response.headers.entries) {
            builder.append_printf("%s: %s\r\n", header.key, header.value);
        }
        builder.append("\r\n");
        try {
            size_t  written = 0;
            var     data    = builder.data;
            var  length  = builder.len;
            while (written < length) {
                written += output.write(data[written:length]);
            }
            response.headers_sent();
            foreach (var chunk in response.body) {
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

    private ConnectionInfo? get_connection_info(SocketConnection conn) {
        var local_sock_addr = Posix.SockAddrIn();
        var remote_sock_addr = Posix.SockAddrIn();

        try {
            if (!conn.get_local_address().to_native(
                    &local_sock_addr, sizeof(Posix.SockAddrIn))) {
                return null;
            }
            if (!conn.get_remote_address().to_native(
                    &remote_sock_addr, sizeof(Posix.SockAddrIn))) {
                return null;
            }
        } catch (Error e) {
            log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                e.message);
            return null;
        }

        var conn_info = ConnectionInfo() {
            scheme = Scheme.HTTP,
            remote = AddressPort() {
                addr = Posix.inet_ntoa(remote_sock_addr.sin_addr),
                port = Posix.ntohs(remote_sock_addr.sin_port)
            },
            local = AddressPort() {
                addr = Posix.inet_ntoa(local_sock_addr.sin_addr),
                port = Posix.ntohs(local_sock_addr.sin_port)
            }
        };


        return conn_info;
    }

    private bool parse_request_line(string request_line,
                                    out Method method,
                                    out Protocol protocol,
                                    out string path,
                                    out string query_string)
                                    throws ParseRequestError {

        var req = request_line.split(" ");
        var _method = Method.from_string(req[0]);
        /* Invalid Method */
        if (_method == null) {
            throw new ParseRequestError.UNSUPPORTED_METHOD(
                "Unsupported HTTP Method '%s'", req[0]);
        }
        method = (!) _method;

        /* Invalid Protocol */
        var _protocol = Protocol.from_string(req[2]);
        if (_protocol == null) {
            throw new ParseRequestError.UNSUPPORTED_PROTOCOL(
                "Unsupported HTTP Protocol version '%s'", req[2]);
        }
        protocol = (!) _protocol;

        var url = req[1].split("?", 2);

        var _path = Uri.unescape_string(url[0]);
        /* Invalid Path */
        if (_path == null) {
            throw new ParseRequestError.INVALID_URL(
              "Invalid request url '%s'", url[0]);
        }
        path = (!) _path;

        var _query_string = Uri.unescape_string(url[1]);
        query_string = (_query_string == null) ? "" : (!) _query_string;

        return true;
    }

    private delegate bool IsConnectedFunc();

    private bool connection_handler(SocketConnection conn) {
        /* Get Connection Info */
        var conn_info = get_connection_info(conn);
        if (conn_info == null) {
            return false;
        }

        var input = new DataInputStream(conn.input_stream);
        var output = conn.output_stream;
        input.set_newline_type(DataStreamNewlineType.CR_LF);

        IsConnectedFunc connected = () => { return conn.is_connected(); };
        return input_handler(input, output, conn_info, connected);
    }

    private bool input_handler(DataInputStream input, OutputStream output,
                               ConnectionInfo conn_info,
                               IsConnectedFunc connected) {
        var script_name = "";

        while (connected()) {
            var req_line = "";
            size_t size = 0;

            /* Parse Initial Request */
            try {
                req_line = input.read_line(out size);
            } catch(Error e) {
                log("VSGI.SimpleServer", LogLevelFlags.LEVEL_WARNING, "%s",
                    e.message);
                break;
            }
            if (req_line == null) /* Connection Closed */
                break;
            if (size == 0) /* Blank Line */
                continue;

            /* Parse Request (first line) */
            VSGI.Method method;
            VSGI.Protocol protocol;
            string path_info;
            string query_string;

            try {
                parse_request_line(req_line, out method, out protocol,
                    out path_info, out query_string);
            } catch(ParseRequestError e) {
                Status status_code = 500;
                if (e is ParseRequestError.UNSUPPORTED_METHOD)
                    status_code = 405;
                if (e is ParseRequestError.UNSUPPORTED_PROTOCOL)
                    status_code = 505;
                if (e is ParseRequestError.INVALID_URL)
                    status_code = 400;
                send_response(output,
                    new Response.simple(status_code, e.message + "\r\n"));
                break;
            }

            /* Parse Request Headers */
            var headers = parse_headers(input);

            var connection_close = (headers["Connection"] == "close");

            /* Form Internal Request */
            var body = new VSGI.InputStreamBody(input);
            var request = new VSGI.Request(conn_info, method, script_name,
                path_info, query_string, protocol, headers, body);
            request.headers_recieved();

            /* Call App */
            var response = this.app.call(request);

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

}
