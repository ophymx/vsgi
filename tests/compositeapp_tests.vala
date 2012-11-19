
public abstract class CompositeAppTests : AppTests {

    public CompositeAppTests(string name) {
        base(name);
    }

    protected VSGI.CompositeApp test_compositeapp;

    public override void test_valid_response() {
        test_compositeapp.app = new VSGI.NoContent();
        test_app = test_compositeapp;
        base.test_valid_response();
        test_app = null;
        test_compositeapp.app = null;
    }

}
