/* tests/lib/vsgi/compositeapp_tests.vala
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
public abstract class CompositeAppTests : AppTests {

    public CompositeAppTests(string name) {
        base(name);
        add_test("[CompositeApp] call() asserts that app is not null", () => {
            if (Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT |
                                    TestTrapFlags.SILENCE_STDERR)) {
                test_compositeapp.call(test_request);
                Process.exit(0);
            }

            Test.trap_assert_failed();
        });
    }

    protected VSGI.CompositeApp test_compositeapp;

    public override void test_valid_response() {
        test_compositeapp.app = new VSGI.NoContent();
        test_app = test_compositeapp;
        base.test_valid_response();
        test_app = null;
        test_compositeapp.app = null;
    }

    public override void tear_down() {
        test_compositeapp = null;
        base.tear_down();
    }

}
