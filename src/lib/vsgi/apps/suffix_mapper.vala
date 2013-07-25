/* src/lib/vsgi/apps/suffix_mapper.vala
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
 * A CompositeApp to try appending other suffixes onto
 * the end of a request path in the case that the results return 404.
 */
public class SuffixMapper : Object, Application, CompositeApp {

    public Application app { get; set; }

    private string[] suffixes;

    /**
     * @param app Application to add suffixes for in case of 404.
     * @param suffixes List of suffixes to attempt to add to request.
     */
    public SuffixMapper(Application? app=null,
        string[] suffixes = {".html", "index.hml", "/index.html"}) {
        this.suffixes = suffixes;
        this.app = app;
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        assert(app != null);
        Response original_response = app.call(request);
        if (original_response.status.code != 404)
            return original_response;

        Response response;
        string path_info = request.path_info;
        foreach (string suffix in suffixes) {
            request.path_info = path_info + suffix;
            response = app.call(request);
            if (response.status.code != 404)
                return response;
        }
        return original_response;
    }
}

}
