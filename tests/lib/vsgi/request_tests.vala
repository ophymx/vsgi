/* tests/lib/vsgi/request_tests.vala
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
public class RequestTests : Gee.TestCase {

    public RequestTests() {
        base("Request");
        add_test("request equals duplicate request", () => {
            assert(test_request.equal_to(mock_request()));
        });
        add_test("request does not equal different request", () => {
            test_request.path_info = "/baz/";
            assert(!test_request.equal_to(mock_request()));
        });
        add_test("validate() returns true for valid request", () => {
            try {
                assert(test_request.validate());
            } catch (VSGI.InvalidRequest e) {
                assert_not_reached();
            }
        });
        add_test("validate() raises error when " +
            "script_name is not empty and does not begin with slash", () => {
            test_request.script_name = "foo";
            try {
                test_request.validate();
                assert_not_reached();
            } catch (VSGI.InvalidRequest e) {
                assert(e is VSGI.InvalidRequest.INVALID_SCRIPT_NAME);
            }
        });
        add_test("validate() raises error when " +
            "path_info is not empty and does not begin with slash", () => {
            test_request.path_info = "foo";
            try {
                test_request.validate();
                assert_not_reached();
            } catch (VSGI.InvalidRequest e) {
                assert(e is VSGI.InvalidRequest.INVALID_PATH);
            }
        });
        add_test("validate() raises error when " +
            "script_name and path_info are both empty", () => {
            test_request.path_info = "";
            test_request.script_name = "";
            try {
                test_request.validate();
                assert_not_reached();
            } catch (VSGI.InvalidRequest e) {
                assert(e is VSGI.InvalidRequest.MISSING_PATH_AND_SCRIPT_NAME);
            }
        });
        add_test("validate() raises error when " +
            "script_name is only a single slash", () => {
            test_request.script_name = "/";
            try {
                test_request.validate();
                assert_not_reached();
            } catch (VSGI.InvalidRequest e) {
                assert(e is VSGI.InvalidRequest.INVALID_SCRIPT_NAME);
            }
        });
        add_test("validate() raises error when " +
            "Content-Length header has non-digit characters", () => {
            test_request.headers["Content-Length"] = "a4";
            try {
                test_request.validate();
                assert_not_reached();
            } catch (VSGI.InvalidRequest e) {
                assert(e is VSGI.InvalidRequest.INVALID_CONTENT_LENGTH);
            }
        });
    }

    protected VSGI.Request test_request;
    protected Gee.HashMap<string, string> test_headers;
    protected Gee.Iterable<Bytes> test_body;

    public override void set_up() {
        test_request = mock_request();
    }

    public override void tear_down() {
        test_request = null;
        test_headers = null;
        test_body = null;
    }
}
