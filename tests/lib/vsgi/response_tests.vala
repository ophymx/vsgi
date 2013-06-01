/* tests/lib/vsgi/response_tests.vala
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
public class ResponseTests : Gee.TestCase {

    public ResponseTests() {
        base("Response");
        add_test("validate() raises error when " +
            "status code is below 100", () => {
                test_response = new VSGI.Response(80);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.INVALID_STATUS_CODE);
                    assert(e.message == "status code '80' is invalid");
                }
            });

        add_test("validate() raises error when " +
            "status code is above 599", () => {
                test_response = new VSGI.Response(655);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.INVALID_STATUS_CODE);
                    assert(e.message == "status code '655' is invalid");
                }
            });

        add_test("validate() raises error when " +
            "Content-Type is missing and status should have entity", () => {
                test_headers["Content-Length"] = "0";
                test_response = new VSGI.Response(200, test_headers);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.MISSING_CONTENT_TYPE);
                    assert(e.message == "Content-Type header must be set for " +
                                        "status code '200'");
                }
            });

        add_test("validate() raises error when " +
            "Content-Type is set and response should not have entity", () => {
                test_headers["Content-Type"] = "text/plain";
                test_response = new VSGI.Response(204, test_headers);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.HAS_CONTENT_TYPE);
                    assert(e.message == "Content-Type header must not be set " +
                                        "with status code '204'");
                }
            });

        add_test("validate() raises error when " +
            "Content-Length is set and response should not have entity", () => {
                test_headers["Content-Length"] = "5";
                test_response = new VSGI.Response(204, test_headers);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.HAS_CONTENT_LENGTH);
                    assert(e.message == "Content-Length header must not be " +
                                        "set with status code '204'");
                }
            });

        add_test("validate() raises error when " +
            "Status header is set", () => {
                test_headers["Status"] = "Ok";
                test_response = new VSGI.Response(204, test_headers);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.INVALID_HEADER);
                    assert(e.message == "must not set header of 'Status'");
                }
            });

        add_test("validate() raises error when " +
            "header key contains a ':'", () => {
                test_headers["Foo:Bar"] = "Ok";
                test_response = new VSGI.Response(204, test_headers);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.INVALID_HEADER);
                    assert(e.message == "header key must not contain ':'");
                }
            });

        add_test("validate() raises error when " +
            "header key ends with a '_'", () => {
                test_headers["FooBar_"] = "Ok";
                test_response = new VSGI.Response(204, test_headers);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.INVALID_HEADER);
                    assert(e.message == "header key must not end with '-' " +
                                        "or '_'");
                }
            });

        add_test("validate() raises error when " +
            "header key ends with a '-'", () => {
                test_headers["FooBar-"] = "Ok";
                test_response = new VSGI.Response(204, test_headers);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.INVALID_HEADER);
                    assert(e.message == "header key must not end with '-' " +
                                        "or '_'");
                }
            });

        add_test("validate() raises error when " +
            "header key contains a newline", () => {
                test_headers["FooBar\n"] = "Ok";
                test_response = new VSGI.Response(204, test_headers);
                try {
                    test_response.validate();
                    assert_not_reached();
                } catch (VSGI.InvalidResponse e) {
                    assert(e is VSGI.InvalidResponse.INVALID_HEADER);
                    assert(e.message == "header key must not contain a " +
                                        "newline");
                }
            });
    }

    protected VSGI.Response test_response;
    protected Gee.HashMap<string, string> test_headers;

    public override void set_up() {
        test_headers = new Gee.HashMap<string, string>();
    }

    public override void tear_down() {
        test_response = null;
        test_headers = null;
    }
}
