
public class RequestTests : Gee.TestCase {

    public RequestTests() {
        base("Request");
        add_test("request equals duplicate request", test_request_equals);
        add_test("request does not equal different request",
            test_request_not_equal);
    }

    protected VSGI.Request test_request;

    public override void set_up() {
        test_request = mock_request();
    }

    public override void tear_down() {
        test_request = null;
    }

    public virtual void test_request_equals() {
        assert(test_request.equal_to(mock_request()));
    }

    public virtual void test_request_not_equal() {
        test_request.path_info = "/baz/";
        assert(!test_request.equal_to(mock_request()));
    }


}
