/* tests/testmain.vala
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

static const string ASSETS_DIR = "tests/assets";

int main (string[] args) {
    Test.init(ref args);
    TestSuite tests = TestSuite.get_root();

    /* Core */
    TestSuite core_tests = new TestSuite("Core");
    core_tests.add_suite(new RequestTests().get_suite());
    core_tests.add_suite(new ResponseTests().get_suite());
    tests.add_suite(core_tests);

    /* Utils */
    TestSuite utils_tests = new TestSuite("Utils");
    utils_tests.add_suite(new IterableByteStreamTests().get_suite());
    utils_tests.add_suite(new IterableChunkedBytesTests().get_suite());
    tests.add_suite(utils_tests);

    /* Applications */
    TestSuite app_tests = new TestSuite("Applications");
    app_tests.add_suite(new CascadeAppTests().get_suite());
    app_tests.add_suite(new EchoAppTests().get_suite());
    app_tests.add_suite(new FileServerAppTests().get_suite());
    app_tests.add_suite(new NoContentAppTests().get_suite());
    app_tests.add_suite(new NotFoundAppTests().get_suite());
    tests.add_suite(app_tests);

    /* CompositeApps */
    TestSuite composite_tests = new TestSuite("CompositeApps");
    composite_tests.add_suite(new CommonLoggerAppTests().get_suite());
    composite_tests.add_suite(new CompositeStackAppTests().get_suite());
    composite_tests.add_suite(new LintAppTests().get_suite());
    composite_tests.add_suite(new MapperAppTests().get_suite());
    composite_tests.add_suite(new SuffixMapperAppTests().get_suite());
    app_tests.add_suite(composite_tests);

    /* Server */
    TestSuite server_tests = new TestSuite("Servers");
    server_tests.add_suite(new SimpleServerTests().get_suite());
    server_tests.add_suite(new FcgiServerTests().get_suite());
    tests.add_suite(server_tests);


    return Test.run();
}
