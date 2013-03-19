/* tests/lib/vsgi/apps/file_server_tests.vala
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
public class FileServerAppTests : AppTests {

    public FileServerAppTests() {
        base("FileServer");
        add_test("returns output of file as response body", () => {
            test_app = new VSGI.FileServer(ASSETS_DIR);
            test_request.path_info = "/test_file.txt";
            test_request.script_name = "";
            var test_response = test_app.call(test_request);
            assert(test_response.status == 200);
            assert(test_response.headers["Content-Length"] == "13");
            var body_string = body_to_string(test_response.body);
            assert(body_string.length == 13);
            assert(body_string == "Hello World!\n");
        });
        add_test("sets correct content type based on filename", () => {
            test_app = new VSGI.FileServer(ASSETS_DIR);
            test_request.path_info = "/test_file.html";
            test_request.script_name = "";
            var test_response = test_app.call(test_request);
            assert(test_response.headers["Content-Type"] == "text/html");
        });
        add_test("uses content type text plain for unknown extension", () => {
            test_app = new VSGI.FileServer(ASSETS_DIR);
            test_request.path_info = "/test_file";
            test_request.script_name = "";
            var test_response = test_app.call(test_request);
            assert(test_response.headers["Content-Type"] == "text/plain");
        });
    }

    public override void set_up() {
        base.set_up();
        test_app = new VSGI.FileServer("/tmp");
    }

}
