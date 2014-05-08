/* tests/lib/vsgi/apps/cascade_tests.vala
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

public class CascadeAppTests : AppTests {

    public CascadeAppTests() {
        base("Cascade");
        add_test("[Cascade] converts catches array to Gee.HashSet", () => {
            var test_cascade_app = new VSGI.Cascade(test_apps, {404});
            assert(test_cascade_app.catches.size == 1);
            assert(test_cascade_app.catches.contains(404));
        });
        add_test("[Cascade] call() returns a 404 response when " +
            "all apps return caught responses", () => {
            test_apps.add(new VSGI.NoContent());
            test_apps.add(new VSGI.Echo());
            var test_cascade_app = new VSGI.Cascade(test_apps, {200, 204});
            var test_response = test_cascade_app.call(test_request);
            assert(test_response.status == 404);
        });
        add_test("[Cascade] call() returns a non-404 response when " +
            "at least one app response is not caught", () => {
            test_apps.add(new VSGI.NotFound());
            test_apps.add(new VSGI.Echo());
            var test_cascade_app = new VSGI.Cascade.default(test_apps);
            var test_response = test_cascade_app.call(test_request);
            assert(test_response.status == 200);
        });
    }

    protected Gee.ArrayList<VSGI.Application> test_apps;

    public override void set_up() {
        base.set_up();
        test_apps = new Gee.ArrayList<VSGI.Application>();
        test_app = new VSGI.Cascade.default(test_apps);
    }

    public override void tear_down() {
        test_apps = null;
        base.tear_down();
    }

}
