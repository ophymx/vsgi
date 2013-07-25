/* src/lib/vsgi/apps/mapper.vala
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
 * Maps path prefixes to apps.
 */
public class Mapper : Object, Application, CompositeApp {

    private Gee.Map<string, Application> apps;

    public Application app { get; set; }

    /**
     *
     */
    public Mapper(Gee.Map<string, Application> apps =
        new Gee.HashMap<string, Application>(), Application? app=null) {
        this.apps = apps;
        this.app = app;
    }

    /**
     *
     */
    public new Application @get(string key) {
        return apps[key];
    }

    /**
     *
     */
     public new void @set(string key, Application app) {
        apps[key] = app;
     }

    /**
     * {@inheritDoc}
     * TODO
     * * Rethink implementation and use
     */
    public Response call(Request request) {
        assert(app != null);
        string path = request.path_info;

        foreach (var entry in apps.entries) {
            string starts_with = entry.key;
            Application app = entry.value;
            if (path.has_prefix(starts_with)) {
                request.script_name += starts_with;
                request.path_info = path.substring(starts_with.length);
                return app.call(request);
            }
        }
        return app.call(request);
    }
}

}
