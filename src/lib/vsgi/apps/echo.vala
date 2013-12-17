/* src/lib/vsgi/apps/echo.vala
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
public class Echo : Object, Application {

    /**
     *
     */
    public Echo() {
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        return static_call(request);
    }

    /**
     *
     */
    public static Response static_call(Request request) {
        var headers = new Gee.HashMap<string, string>();
        var body = new Gee.ArrayList<Bytes>();
        var r = request;
        var builder = new StringBuilder();
        var ci = r.connection_info;
        builder.append_printf("Connection: %s -> %s\r\n",
            ci.remote.to_string(),
            ci.local_url()
        );
        builder.append_printf("Method: %s\r\n", r.method.to_string());
        builder.append_printf("ScriptName: %s\r\n", r.script_name);
        builder.append_printf("PathInfo: %s\r\n", r.path_info);
        builder.append_printf("Query: %s\r\n", r.query_string);
        builder.append_printf("Protocol: %s\r\n", r.protocol.to_string());
        builder.append("Headers:\r\n");
        foreach(var header in request.headers.entries) {
            builder.append_printf("    %s: %s\r\n", header.key, header.value);
        }
        builder.append("\r\nBody:\r\n");
        body.add(new Bytes(builder.data));

        var length = request.content_length();
        if (length > 0) {
            foreach (var chunk in request.body) {
                body.add(chunk);
                length -= (ssize_t) chunk.get_size();
                if (length <= 0)
                    break;
            }
        }
        length = 0;
        foreach (var chunk in body) {
            length += (ssize_t) chunk.get_size();
        }
        headers["Content-Length"] = length.to_string();
        headers["Content-Type"] = "text/plain";

        return new Response(200, headers, new IterableBytesBody(body));
    }
}

}
