
public abstract class AppTests : Gee.TestCase {

    public AppTests(string name) {
        base(name);
        add_test("[Application] valid response", test_valid_response);
    }

    protected VSGI.Application test_app;

    public virtual void test_valid_response() {
        var test_request = mock_request();
        var test_response = test_app.call(test_request);

        try {
            assert(test_response.validate());
        } catch (VSGI.InvalidResponse e) {
            assert_not_reached();
        }
    }
}
