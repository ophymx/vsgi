/* tests/lib/vsgi/apps/composite_stack_tests.vala
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
public class CompositeStackAppTests : CompositeAppTests {

    public CompositeStackAppTests() {
        base("CompositeStack");
    }

    private Gee.ArrayList<VSGI.CompositeApp> test_apps;

    public override void set_up() {
        base.set_up();
        test_apps = new Gee.ArrayList<VSGI.CompositeApp>();
        test_compositeapp = new VSGI.CompositeStack(test_apps);
    }

    public override void tear_down() {
        test_apps = null;
        base.tear_down();
    }

}
