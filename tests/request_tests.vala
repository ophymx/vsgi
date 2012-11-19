
public class RequestTests : Gee.TestCase {

    public RequestTests() {
        base("Request");
    }

    protected VSGI.Request test_request;

    public override void set_up() {
    }

    public override void tear_down() {
        test_request = null;
    }

}
