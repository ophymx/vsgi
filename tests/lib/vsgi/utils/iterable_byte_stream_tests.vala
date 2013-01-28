/* tests/lib/vsgi/utils/iterable_byte_stream_tests.vala
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
public class IterableByteStreamTests : Gee.TestCase {

    public IterableByteStreamTests() {
        base("IterableByteStream");
        add_test("can iterate over lorem ipsum correctly", () => {
            var mis = new MemoryInputStream();
            test_stream = new VSGI.IterableByteStream(mis);

            mis.add_data("Lorem ipsum dolor sit amet, consectetur ".data, free);
            mis.add_data("adipisicing elit, sed do eiusmod tempor ".data, free);
            mis.add_data("incididunt ut labore et dolore magna ".data, free);
            mis.add_data("aliqua. Ut enim ad minim veniam, quis ".data, free);
            mis.add_data("nostrud exercitation ullamco laboris ".data, free);
            mis.add_data("nisi ut aliquip ex ea commodo consequat.".data, free);
            mis.add_data(" Duis aute irure dolor in reprehenderit ".data, free);
            mis.add_data("in voluptate velit esse cillum dolore eu".data, free);
            mis.add_data(" fugiat nulla pariatur. Excepteur sint ".data, free);
            mis.add_data("occaecat cupidatat non proident, sunt in".data, free);
            mis.add_data(" culpa qui officia deserunt mollit anim ".data, free);
            mis.add_data("id est laborum.".data, free);

            var body_string = body_to_string(test_stream);

            assert(body_string == "Lorem ipsum dolor sit amet, consectetur " +
                "adipisicing elit, sed do eiusmod tempor incididunt ut labore" +
                " et dolore magna aliqua. Ut enim ad minim veniam, quis " +
                "nostrud exercitation ullamco laboris nisi ut aliquip ex ea " +
                "commodo consequat. Duis aute irure dolor in reprehenderit " +
                "in voluptate velit esse cillum dolore eu fugiat nulla " +
                "pariatur. Excepteur sint occaecat cupidatat non proident, " +
                "sunt in culpa qui officia deserunt mollit anim id est laborum."
            );

        });

        add_test("can iterate over a file stream correctly", () => {
            var test_file = File.new_for_path(ASSETS_DIR + "/test_file.txt");
            try {
                test_stream = new VSGI.IterableByteStream(test_file.read());
                var body_string = body_to_string(test_stream);
                assert(body_string == "Hello World!\n");
            } catch (Error e) {
                assert_not_reached();
            }
        });

        add_test("closes stream when once consumed", () => {
            var test_file = File.new_for_path(ASSETS_DIR + "/test_file.txt");
            try {
                var fis = test_file.read();
                test_stream = new VSGI.IterableByteStream(fis);
                body_to_string(test_stream);
                assert(fis.is_closed());
            } catch (Error e) {
                assert_not_reached();
            }
        });


    }

    protected VSGI.IterableByteStream test_stream;

    public override void set_up() {
    }

    public override void tear_down() {
        test_stream = null;
    }

}
