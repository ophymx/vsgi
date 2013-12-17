/* tests/lib/vsgi/utils/iterable_chunked_bytes_tests.vala
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
public class ChunkedBodyTests : Gee.TestCase {

    public ChunkedBodyTests() {
        base("ChunkedBody");
        add_test("correctly chunks simple string", () => {
            var test_stream = new Gee.ArrayList<Bytes>();
            test_stream.add(new Bytes("foobar".data));
            test_stream.add(new Bytes("barbaz".data));
            var wrapper = new VSGI.IterableBytesBody(test_stream);
            chunked_bytes = new VSGI.ChunkedBody(wrapper);
            var body_string = body_to_string(chunked_bytes);
            assert(body_string == "6\r\nfoobar\r\n6\r\nbarbaz\r\n0\r\n\r\n");
        });
    }

    protected VSGI.ChunkedBody chunked_bytes;

    public override void set_up() {
    }

    public override void tear_down() {
        chunked_bytes = null;
    }

}
