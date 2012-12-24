
int main (string[] args) {
    Test.init(ref args);
    TestSuite tests = TestSuite.get_root();

    /* Core */
    tests.add_suite(new RequestTests().get_suite());
    tests.add_suite(new ResponseTests().get_suite());

    /* Applications */
    tests.add_suite(new CascadeAppTests().get_suite());
    tests.add_suite(new CommonLoggerAppTests().get_suite());
    tests.add_suite(new CompositeStackAppTests().get_suite());
    tests.add_suite(new EchoAppTests().get_suite());
    tests.add_suite(new FileServerAppTests().get_suite());
    tests.add_suite(new LintAppTests().get_suite());
    tests.add_suite(new MapperAppTests().get_suite());
    tests.add_suite(new NoContentAppTests().get_suite());
    tests.add_suite(new NotFoundAppTests().get_suite());
    tests.add_suite(new SuffixMapperAppTests().get_suite());

    /* Server */
    tests.add_suite(new SimpleServerTests().get_suite());
    tests.add_suite(new FcgiServerTests().get_suite());

    return Test.run();
}
