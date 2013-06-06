/* lib/vsgi/apps/composite_stack.vala
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

    private CompositeApp top;

    private CompositeApp bottom;

    private Application _app;
    public Application app {
        get {
            return this._app;
        }
        set {
            this._app = value;
            restack();
        }
    }

    /**
     * @param apps List of composite applications to chain
     * @param app Application that ends the chain
     */
    public CompositeStack(Application? app=null,
        Gee.List<CompositeApp>? apps=null) {
        if (apps == null)
            this.apps = new Gee.ArrayList<CompositeApp>();
        else
            this.apps = (!) apps;
        this.app = app;
    }

    /**
     * Add application to the end of the helper chain (not final app)
     */
    public void add(CompositeApp app) {
        apps.add(app);
        restack();
    }

    private void restack() {
        top = null;
        bottom = null;

        foreach (CompositeApp app in apps) {
            if (top == null) {
                top = app;
                bottom = app;
            } else {
                bottom.app = app;
                bottom = app;
            }
        }
        if (bottom != null)
            bottom.app = app;
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        assert(app != null);

        if (top == null) {
            return this.app.call(request);
        }

        return top.call(request);
    }
}

}
