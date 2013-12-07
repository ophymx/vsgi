/* src/lib/vsgi/request.vala
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
namespace VSGI {

public errordomain InvalidRequest {
    UNKNOWN_METHOD,
    INVALID_SCRIPT_NAME,
    INVALID_PATH,
    INVALID_CONTENT_LENGTH,
    MISSING_PATH_AND_SCRIPT_NAME
}

public struct AddressPort {
    public string addr;
    public uint16 port;

    public AddressPort.default() {
        addr = "0.0.0.0";
        port = 0;
    }

    public string to_string() {
        return "%s:%s".printf(addr, port.to_string());
    }

    public bool equal(AddressPort other) {
        return addr == other.addr && port == other.port;
    }
}

public struct ConnectionInfo {
    public Scheme scheme;
    public AddressPort remote;
    public AddressPort local;

    public ConnectionInfo.default() {
        scheme = Scheme.HTTP;
        remote = AddressPort.default();
        local  = AddressPort.default();
    }

    public bool equal(ConnectionInfo other) {
        return scheme == other.scheme &&
                remote.equal(other.remote) &&
                local.equal(other.local);
    }

    public string local_url(string? host=null) {
        if (host == null) {
            host = local.addr;
        }
        var builder = new StringBuilder();
        builder.printf("%s://%s", scheme.to_string(), host);
        if (local.port != scheme.default_port()) {
            builder.append_printf(":%u", local.port);
        }
        return builder.str;
    }
}

/**
 *
 */
public class Request : Object {

    public signal void headers_recieved();
    public signal void body_recieved();

    /**
     *
     */
    public Method method { get; private set; }
    /**
     *
     */
    public string script_name { get; set; default = ""; }
    /**
     *
     */
    public string path_info { get; set; default = "/"; }
    /**
     *
     */
    public string query_string { get; private set; default = ""; }
    /**
     *
     */
    public ConnectionInfo connection_info {
        get;
        private set;
        default = ConnectionInfo.default();
    }
    /**
     *
     */
    public string remote_user { get; private set; default = ""; }
    /**
     *
     */
    public string server_software { get; private set; default = ""; }
    /**
     *
     */
    public Protocol protocol { get; private set; default = Protocol.HTTP1_1; }
    /**
     *
     */
    public Gee.Map<string, string> headers { get; set; }
    /**
     *
     */
    public Gee.Iterable<Bytes> body;

    /**
     * @param method       http request method {@link VSGI.Method}
     * @param script_name  path of script invoked by request
     * @param path_info    path of the request after the script
     * @param query_string query string in request
     * @param conn_info    connection information {@link Vsgi.ConnectionInfo}
     * @param protocol     http protocol (1.0 or 1.1) {@link VSGI.Protocol}
     * @param headers      request headers
     * @param body         request body as an iterable collection of Bytes
     * @return             newly created request
     */
    public Request(Method method,
                   string script_name,
                   string path_info,
                   string query_string,
                   ConnectionInfo conn_info,
                   Protocol protocol,
                   Gee.Map<string, string> headers,
                   Gee.Iterable<Bytes> body) {

        this.method = method;
        this.script_name = script_name;
        this.path_info = path_info;
        this.query_string = query_string;
        this.connection_info = conn_info;
        this.protocol = protocol;

        this.headers = headers;
        this.body = body;
    }

    public Request.from_cgi(Gee.Map<string, string> cgi_env,
        Gee.Iterable<Bytes> body) {
        headers = new Gee.HashMap<string, string>();
        foreach(var cgi_var in cgi_env.entries) {
            var key = cgi_var.key;
            var val = cgi_var.value;
            switch(key) {
                case "AUTH_TYPE":
                    break;
                case "CONTENT_LENGTH":
                    headers["Content-Length"] = val;
                    break;
                case "CONTENT_TYPE":
                    headers["Content-Type"] = val;
                    break;
                case "GATEWAY_INTERFACE":
                    break;
                case "PATH_INFO":
                    path_info = val;
                    break;
                case "PATH_TRANSLATED":
                    break;
                case "QUERY_STRING":
                    query_string = val;
                    break;
                case "REMOTE_ADDR":
                    connection_info.remote.addr = val;
                    break;
                case "REMOTE_HOST":
                    break;
                case "REMOTE_IDENT":
                    break;
                case "REMOTE_USER":
                    break;
                case "REQUEST_METHOD":
                    method = Method.from_string(val);
                    break;
                case "SCRIPT_NAME":
                    script_name = val;
                    break;
                case "SERVER_NAME":
                    connection_info.local.addr = val;
                    break;
                case "SERVER_PORT":
                    connection_info.local.port = (uint16) int.parse(val);
                    break;
                case "SERVER_PROTOCOL":
                    protocol = Protocol.from_string(val);
                    break;
                case "SERVER_SOFTWARE":
                    server_software = val;
                    break;
                default:
                    if (key.has_prefix("HTTP_"))
                        headers[Utils.cgi_var_to_header(key)] = val;
                    break;
            }
        }

        this.body = body;
    }

    /**
     * @return combined script_name and path_info.
     */
    public string path() {
        var builder = new StringBuilder(script_name);
        builder.append(path_info);
        return builder.str;
    }

    /**
     * @return combined path and query_string.
     */
    public string full_path() {
        var builder = new StringBuilder(path());
        if (query_string.length > 0)
            builder.printf("?%s", query_string);
        return builder.str;
    }

    /**
     * @return full url
     */
    public string full_url() {
        return connection_info.local_url(headers["Host"]) + full_path();
    }

    /**
     * @return host
     */
    public string host() {
        if (headers.has_key("Host")) {
            return headers["Host"];
        } else {
            return connection_info.local.addr;
        }
    }

    public ssize_t content_length() {
        ssize_t length = -1;
        if (headers.has_key("Content-Length"))
            headers["Content-Length"].scanf("%" + ssize_t.FORMAT, &length);
        return length;
    }

    /**
     * @return true if other request equals this request
     */
    public bool equal_to(Request other) {
        if (method       != other.method       ||
            script_name  != other.script_name  ||
            path_info    != other.path_info    ||
            query_string != other.query_string ||
            protocol     != other.protocol     ||
            !connection_info.equal(other.connection_info) ||
            !headers.keys.contains_all(other.headers.keys) ||
            !other.headers.keys.contains_all(headers.keys)) {
            return false;
        }
        foreach (var key in headers.keys) {
            if (headers[key] != other.headers[key]) {
                return false;
            }
        }

        var body_data = new ByteArray();
        foreach (var chunk in body) {
            body_data.append(chunk.get_data());
        }
        var other_body_data = new ByteArray();
        foreach (var chunk in other.body) {
            other_body_data.append(chunk.get_data());
        }
        if (body_data.len != other_body_data.len)
            return false;

        for (int i = 0; i < body_data.len; i++) {
            if (body_data.data[i] != other_body_data.data[i])
                return false;
        }
        return true;
    }

    /**
     *
     */
    public bool validate() throws InvalidRequest {
        if (script_name.length > 0 && !script_name.has_prefix("/"))
            throw new InvalidRequest.INVALID_SCRIPT_NAME(
                "script_name must begin with a '/'");

        if (path_info.length > 0 && !path_info.has_prefix("/"))
            throw new InvalidRequest.INVALID_PATH(
                "path_info must begin with a '/'");

        if (path_info.length == 0 && script_name.length == 0)
            throw new InvalidRequest.MISSING_PATH_AND_SCRIPT_NAME(
                "either script_name or path_info must be set");

        if (script_name == "/")
            throw new InvalidRequest.INVALID_SCRIPT_NAME(
                "script_name must not be '/' but instead be empty");

        if (headers.has_key("Content-Length")) {
            var content_length = headers["Content-Length"];
            if (uint64.parse(content_length).to_string() !=
                    content_length.strip())
                throw new InvalidRequest.INVALID_CONTENT_LENGTH(
                    "Content-Length header must only consist of digits");
        }

        return true;
    }
}

}
