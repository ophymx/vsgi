/* apps/nocontent.vala
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
 * Simply returns a 204 NoContent response.
 */
public class NoContent : Object, Application {

    public NoContent() {
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        return NoContent.static_call(request);
    }

    /**
     *
     */
    public static Response static_call(Request request) {
        Gee.HashMap<string, string> headers = new Gee.HashMap<string, string>();

        return new Response(204, headers, new Body.empty());
    }


}

}
