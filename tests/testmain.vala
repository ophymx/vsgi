
int main (string[] args) {
    Test.init(ref args);
    TestSuite tests = TestSuite.get_root();

    tests.add_suite(new NotFoundAppTests().get_suite());
    tests.add_suite(new NoContentAppTests().get_suite());
    tests.add_suite(new SuffixMapperAppTests().get_suite());
    tests.add_suite(new CascadeAppTests().get_suite());
    tests.add_suite(new CompositeStackAppTests().get_suite());
    tests.add_suite(new CommonLoggerAppTests().get_suite());

    return Test.run();
}
