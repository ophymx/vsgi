/* src/lib/vsgi/apps/chunked.vala
 *
 * Copyright (C) 2013 Jeffrey T. Peckham
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
public class Chunked : Object, Application, CompositeApp {

    public Application app { set; get; }

    /**
     * @param app Application to wrap with chunked transfer
     */
    public Chunked(Application? app=null) {
        this.app = app;
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        var response = app.call(request);

        if (request.protocol != Protocol.HTTP1_0 &&
                response.status.has_entity() &&
                !response.headers.has_key("Content-Length") &&
                !response.headers.has_key("Transfer-Encoding")) {
            response.headers["Transfer-Encoding"] = "chunked";
            response.body = new ChunkedBody(response.body);
        }

        return response;
    }
}

}
