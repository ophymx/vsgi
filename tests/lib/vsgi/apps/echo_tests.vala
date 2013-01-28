/* tests/lib/vsgi/apps/echo_tests.vala
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
public class EchoAppTests : AppTests {

    public EchoAppTests() {
        base("Echo");
        add_test("[Echo] body of response should match expected", () => {
            var test_response = test_app.call(test_request);

            assert(body_to_string(test_response.body) ==
                "Connection: 10.0.0.2:42222 -> http://10.0.1.2:8080\r\n" +
                "Method: GET\r\n" +
                "ScriptName: /foo\r\n" +
                "PathInfo: /bar/\r\n" +
                "Query: foo1=bar1&foo2=bar2\r\n" +
                "Protocol: HTTP/1.1\r\n" +
                "Headers:\r\n" +
                "    Accept: */*\r\n" +
                "    Host: myhost\r\n" +
                "    User-Agent: Mock Agent\r\n" +
                "\r\nBody:\r\n");
        });
    }

    public override void set_up() {
        base.set_up();
        test_app = new VSGI.Echo();
    }

}
