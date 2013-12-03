/* src/lib/vsgi/apps/composite_stack.vala
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

    private Gee.ArrayList<CompositeApp> apps;

    private Application _app;
    public Application app {
        get {
            return this._app;
        }
        set {
            this._app = value;
            if (!apps.is_empty)
                apps.last().app = value;
        }
    }

    /**
     * @param apps List of composite applications to chain
     * @param app Application that ends the chain
     */
    public CompositeStack(Application? app = null,
        Gee.ArrayList<CompositeApp> apps = new Gee.ArrayList<CompositeApp>()) {

        this.apps = apps;
        this.app = app;
    }

    /**
     * Add application to the end of the helper chain (not final app)
     */
    public bool add(CompositeApp app) {
        if (apps.add(app)) {
            restack();
            return true;
        } else {
            return false;
        }
    }

    private void restack() {
        CompositeApp previous = new PassThrough();

        foreach (var app in apps) {
            previous.app = app;
            previous = app;
        }
        previous.app = app;
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        assert(app != null);

        return (apps.is_empty ? app :
            apps.first() as Application).call(request);
    }
}

}
