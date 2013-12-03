/* src/lib/vsgi/apps/cascade.vala
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
 * Cascades through list of apps until one returns a response other
 * than what is in `catches'.
 */
public class Cascade : Object, Application {

    public Gee.List<Application> apps { get; private set; }
    public Gee.HashSet<uint> catches { get; private set; }

    /**
     * @param apps List of applications to cascade through
     * @param catches return codes to catch and cascade on
     */
    public Cascade(Gee.List<Application> apps =
        new Gee.ArrayList<Application>(), Status[] catches = {404, 405}) {

        this.apps = apps;

        this.catches = new Gee.HashSet<uint>();
        foreach (uint status in catches)
            this.catches.add(status);
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        Response default_response = NotFound.static_call(request);

        foreach (Application app in apps){
            Response response = app.call(request);
            if (!(response.status in catches))
                return response;
        }
        return default_response;
    }
}

}
