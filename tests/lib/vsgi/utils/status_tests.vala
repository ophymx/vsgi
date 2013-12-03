/* tests/lib/vsgi/utils/status_tests.vala
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

public class StatusTests : Gee.TestCase {

    public StatusTests() {
        base("status functions");
        add_test("can lookup status messages from codes", () => {
            assert(((VSGI.Status) 405).message() == "Method Not Allowed");
        });
        add_test("can test status code 204 should not have entity", () => {
            assert(!((VSGI.Status) 204).has_entity());
        });
        add_test("can test status code 403 should have entity", () => {
            assert(((VSGI.Status) 403).has_entity());
        });
    }

}
