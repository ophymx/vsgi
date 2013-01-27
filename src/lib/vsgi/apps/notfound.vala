/* apps/notfound.vala
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
 * Simply returns a 404 Not Found response.
 */
public class NotFound : Object, Application {

    public NotFound() {
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        return static_call(request);
    }

    /**
     * Static call to avoid instantiating an instance.
     */
    public static Response static_call(Request request) {
        Gee.HashMap<string, string> headers = new Gee.HashMap<string, string>();

        string message = "Not Found: '%s'\r\n".printf(request.full_path());

        Body body = new Body.from_string(message);
        headers["Content-Type"] = "text/plain";
        headers["Content-Length"] = message.length.to_string();

        return new Response(404, headers, body);
    }
}

}
