
public class FcgiServerTests : ServerTests {

    public FcgiServerTests() {
        base("FcgiServer");
    }

    public override void set_up() {
        test_server = new VSGI.FcgiServer(":5000");
    }

    public override void tear_down() {
        test_server = null;
    }

}
