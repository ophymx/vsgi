/* tests/lib/vsgi/app_tests.vala
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
public abstract class AppTests : Gee.TestCase {

    public AppTests(string name) {
        base(name);
        add_test("[Application] call() returns valid response",
            test_valid_response);
    }

    protected VSGI.Application test_app;
    protected VSGI.Request test_request;

    public virtual void test_valid_response() {
        var test_response = test_app.call(test_request);
        try {
            assert(test_response.validate());
        } catch (VSGI.InvalidResponse e) {
            assert_not_reached();
        }
    }

    public override void set_up() {
        test_request = mock_request();
    }

    public override void tear_down() {
        test_request = null;
        test_app = null;
    }
}
