/* tests/lib/vsgi/utils/scheme_tests.vala
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

public class SchemeTests : Gee.TestCase {

    public SchemeTests() {
        base("Scheme");
        add_test("can lookup Scheme from string", () => {
            assert(VSGI.Scheme.from_string("HtTp") == VSGI.Scheme.HTTP);
        });
        add_test("from_string() returns null for unkown scheme", () => {
            assert(VSGI.Scheme.from_string("foo") == null);
        });
        add_test("can convert Scheme to string", () => {
            assert(VSGI.Scheme.HTTPS.to_string() == "https");
        });
        add_test("can lookup Scheme by port", () => {
            assert(VSGI.Scheme.from_port(80) == VSGI.Scheme.HTTP);
        });
        add_test("from_port() returns null for unknown port", () => {
            assert(VSGI.Scheme.from_port(8080) == null);
        });
        add_test("can get default port for Scheme", () => {
            assert(VSGI.Scheme.HTTPS.default_port() == 443);
        });

    }

}
