
public class EchoAppTests : AppTests {

    public EchoAppTests() {
        base("Echo");
    }

    public override void set_up() {
        test_app = new VSGI.Echo();
    }

    public override void tear_down() {
        test_app = null;
    }

}
