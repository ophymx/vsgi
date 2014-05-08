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
    public Cascade(Gee.List<Application> apps, Status[] catches) {
        this.apps = apps;
        this.catches = array_to_set(catches);
    }

    /**
     * @param apps List of applications to cascade through
     * @param catches return codes to catch and cascade on
     */
    public Cascade.default(Gee.List<Application> apps) {
        this.apps = apps;
        this.catches = array_to_set({404, 405});
    }

    private static Gee.HashSet<Status> array_to_set(Status[] statuses) {
        var catches = new Gee.HashSet<Status>();
        foreach (var status in statuses)
            catches.add(status);
        return catches;
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        var default_response = NotFound.static_call(request);

        foreach (var app in apps){
            var response = app.call(request);
            if (!(response.status in catches))
                return response;
        }
        return default_response;
    }
}

}
