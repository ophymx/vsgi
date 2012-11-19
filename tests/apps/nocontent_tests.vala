
public class NoContentAppTests : AppTests {

    public NoContentAppTests() {
        base("NoContent");
    }

    public override void set_up() {
        test_app = new VSGI.NoContent();
    }

    public override void tear_down() {
        test_app = null;
    }

}
