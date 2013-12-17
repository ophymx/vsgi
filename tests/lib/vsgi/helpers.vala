/* tests/lib/vsgi/helpers.vala
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
VSGI.Request mock_request() {
    var headers = new Gee.HashMap<string, string>();
    headers["User-Agent"] = "Mock Agent";
    headers["Host"] = "myhost";
    headers["Accept"] = "*/*";

    var body = new VSGI.SimpleBody.empty();
    var conn_info = VSGI.ConnectionInfo() {
        remote = VSGI.AddressPort() {
            addr = "10.0.0.2",
            port = 42222
        },
        local = VSGI.AddressPort() {
            addr = "10.0.1.2",
            port = 8080
        }
    };
    return new VSGI.Request(
        conn_info,
        VSGI.Method.GET,
        "/foo",
        "/bar/",
        "foo1=bar1&foo2=bar2",
        VSGI.Protocol.HTTP1_1,
        headers,
        body
    );
}

string body_to_string(VSGI.Body body) {
    var buf = new ByteArray();

    foreach(var chunk in body) {
        buf.append(chunk.get_data());
    }

    var data = buf.data;
    data += 0;

    return (string) data;
}

public class MockRequest {
    public MockRequest() {

    }
}
