/* tests/lib/vsgi/utils/body_tests.vala
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
public class BodyTests : Gee.TestCase {

    public BodyTests() {
        base("Body");
        add_test("body from string correctly converts back to string", () => {
            test_body = new VSGI.SimpleBody.from_string("foobar");
            assert(body_to_string(test_body) == "foobar");
        });
    }

    protected VSGI.Body test_body;

    public override void tear_down() {
        test_body = null;
    }
}
