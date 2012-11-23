/* request.vala
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

/**
 *
 */
public errordomain InvalidRequest {
    UNKNOWN_METHOD,
    INVALID_SCRIPT_NAME,
    INVALID_PATH,
    INVALID_CONTENT_LENGTH,
    MISSING_PATH_AND_SCRIPT_NAME
}

/**
 *
 */
public class Request : Object {
    /**
     *
     */
    public Method method { get; private set; }
    /**
     *
     */
    public string script_name { get; set; }
    /**
     *
     */
    public string path_info { get; set; }
    /**
     *
     */
    public string query_string { get; private set; }
    /**
     *
     */
    public string remote_addr { get; private set; }
    /**
     *
     */
    public string server_addr { get; private set; }
    /**
     *
     */
    public uint16 server_port { get; private set; }
    /**
     *
     */
    public string server_software { get; private set; }
    /**
     *
     */
    public Protocol protocol { get; private set; }
    /**
     *
     */
    public Scheme scheme { get; private set; }
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
     * @param server_addr  server address
     * @param server_port  server port
     * @param protocol     http protocol (1.0 or 1.1) {@link VSGI.Protocol}
     * @param scheme       scheme (http or https) {@link VSGI.Scheme}
     * @param headers      request headers
     * @param body         request body as an iterable collection of Bytes
     * @return             newly created request
     */
    public Request(Method method,
                   string script_name,
                   string path_info,
                   string query_string,
                   string remote_addr,
                   string server_addr,
                   uint16 server_port,
                   Protocol protocol,
                   Scheme scheme,
                   Gee.Map<string, string> headers,
                   Gee.Iterable<Bytes> body) {

        this.method = method;
        this.script_name = script_name;
        this.path_info = path_info;
        this.query_string = query_string;
        this.remote_addr = remote_addr;
        this.server_addr = server_addr;
        this.server_port = server_port;
        this.protocol = protocol;
        this.scheme = scheme;

        this.headers = headers;
        this.body = body;
    }

    public Request.from_cgi(Gee.Map<string, string> cgi_env,
        Gee.Iterable<Bytes> body) {
        this.headers = new Gee.HashMap<string, string>();
        foreach(Gee.Map.Entry<string, string> cgi_var in cgi_env.entries) {
            string key = cgi_var.key;
            string val = cgi_var.value;
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
                    this.path_info = val;
                    break;
                case "PATH_TRANSLATED":
                    break;
                case "QUERY_STRING":
                    this.query_string = val;
                    break;
                case "REMOTE_ADDR":
                    this.remote_addr = val;
                    break;
                case "REMOTE_HOST":
                    break;
                case "REMOTE_IDENT":
                    break;
                case "REMOTE_USER":
                    break;
                case "REQUEST_METHOD":
                    this.method = Method.from_string(val);
                    break;
                case "SCRIPT_NAME":
                    this.script_name = val;
                    break;
                case "SERVER_NAME":
                    this.server_addr = val;
                    break;
                case "SERVER_PORT":
                    this.server_port = (uint16) int.parse(val);
                    break;
                case "SERVER_PROTOCOL":
                    this.protocol = Protocol.from_string(val);
                    break;
                case "SERVER_SOFTWARE":
                    this.server_software = val;
                    break;
                default:
                    if (cgi_var.key.index_of("HTTP_") == 0)
                        headers[key[5:key.length]] = val;
                    break;
            }
        }

        this.body = body;
    }


    /**
     * @return  combined script_name and path_info.
     */
    public string full_path() {
        return script_name.concat(path_info);
    }

    /**
     *
     */
    public bool validate() throws InvalidRequest {
        if (script_name.length > 0 & script_name[0] != '/' )
            throw new InvalidRequest.INVALID_SCRIPT_NAME(
                "script_name must begin with a '/'");

        if (path_info.length > 0 & path_info[0] != '/')
            throw new InvalidRequest.INVALID_PATH(
                "path_info must begin with a '/'");

        if (path_info.length == 0 & script_name.length == 0)
            throw new InvalidRequest.MISSING_PATH_AND_SCRIPT_NAME(
                "either script_name or path_info must be set");

        if (script_name.length == 0 & path_info != "/")
            throw new InvalidRequest.INVALID_PATH(
                "path_info must be '/' if script_name is empty");

        if (script_name == "/")
            throw new InvalidRequest.INVALID_SCRIPT_NAME(
                "script_name must not be '/' but instead be empty");

        if (headers.has_key("Content-Length")) {
            string content_length = headers["Content-Length"];
            if (uint64.parse(content_length).to_string() !=
                    content_length.strip())
                throw new InvalidRequest.INVALID_CONTENT_LENGTH(
                    "Content-Length header must only consist of digits");
        }

        return true;
    }
}

}
