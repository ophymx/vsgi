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
    Gee.HashMap<string, string> headers = new Gee.HashMap<string, string>();
    headers["User-Agent"] = "Mock Agent";
    headers["Host"] = "myhost";
    headers["Accept"] = "*/*";

    VSGI.Body body = new VSGI.Body.empty();
    return new VSGI.Request(
        VSGI.Method.GET,
        "/foo",
        "/bar/",
        "foo1=bar1&foo2=bar2",
        "10.0.0.2",
        42222,
        "10.0.1.2",
        8080,
        VSGI.Protocol.HTTP1_1,
        VSGI.Scheme.HTTP,
        headers,
        body
    );
}

string body_to_string(Gee.Iterable<Bytes> body) {
    ByteArray buf = new ByteArray();

    foreach(Bytes chunk in body) {
        buf.append(chunk.get_data());
    }
    return (string) buf.data;
}

public class MockRequest {
    public MockRequest() {

    }
}
