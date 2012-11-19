
public class CascadeAppTests : AppTests {

    public CascadeAppTests() {
        base("Cascade");
    }

    public override void set_up() {
        test_app = new VSGI.Cascade();
    }

    public override void tear_down() {
        test_app = null;
    }

}
