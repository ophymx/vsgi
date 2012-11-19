/* apps/composite_stack.vala
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
 * An app that nests a list of Composite Apps
 * together. The goal is to be similar to the 'use' feature in
 * rack helper apps.
 */
public class CompositeStack : Object, Application, CompositeApp {

    private Gee.List<CompositeApp> apps;
    public Application app { get; set; }

    public CompositeStack(Gee.List<CompositeApp>? apps=null) {
        if (apps == null)
            this.apps = new Gee.ArrayList<CompositeApp>();
        else
            this.apps = apps;
    }

    public void add(CompositeApp app) {
        apps.add(app);
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        CompositeApp start_app = null;
        CompositeApp current_app = null;

        foreach(CompositeApp app in apps) {
            if (start_app == null) {
                start_app = app;
                current_app = app;
            } else {
                current_app.app = app;
                current_app = app;
            }
        }
        if (start_app == null) {
            return this.app.call(request);
        }
        current_app.app = this.app;

        return start_app.call(request);
    }
}

}
