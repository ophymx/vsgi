/* tests/lib/vsgi/utils/protocols_tests.vala
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

public class ProtocolTests : Gee.TestCase {

    public ProtocolTests() {
        base("Protocol");
        add_test("can lookup Protocol from string", () => {
            assert(VSGI.Protocol.from_string("HTTP/1.1") ==
                VSGI.Protocol.HTTP1_1);
        });
        add_test("Protocol 'INCLUDED' returns HTTP 1.0", () => {
            assert(VSGI.Protocol.from_string("INCLUDED") ==
                VSGI.Protocol.HTTP1_0);
        });
        add_test("from_string() returns null for unkown protocol", () => {
            assert(VSGI.Protocol.from_string("foo") == null);
        });
        add_test("can convert Protocol to string", () => {
            assert(VSGI.Protocol.HTTP1_0.to_string() == "HTTP/1.0");
        });
    }

}
