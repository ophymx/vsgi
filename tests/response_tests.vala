
public class ResponseTests : Gee.TestCase {

    public ResponseTests() {
        base("Response");
    }

    protected VSGI.Response test_response;

    public override void set_up() {
    }

    public override void tear_down() {
        test_response = null;
    }

}
