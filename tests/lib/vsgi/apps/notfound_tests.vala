
public class NotFoundAppTests : AppTests {

    public NotFoundAppTests() {
        base("NotFound");
    }

    public override void set_up() {
        test_app = new VSGI.NotFound();
    }

    public override void tear_down() {
        test_app = null;
    }

}
