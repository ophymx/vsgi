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
 * A CompositApp that nests a list of CompositeApps
 * together. The goal is to be similar to the 'use' feature in
 * rack helper apps.
 */
public class CompositeStack : Object, CompositeApp {

    private Gee.ArrayList<CompositeApp> apps;

    public CompositeStack(Gee.ArrayList<CompositeApp> apps) {
        this.apps = apps;
    }

    public Application of(Application app) {
        var stack = app;
        var iter = apps.bidir_list_iterator();

        if (!iter.last()) {
            return stack;
        }

        stack = iter.get().of(stack);

        while (iter.previous()) {
            stack = iter.get().of(stack);
        }

        return stack;
    }
}

}
