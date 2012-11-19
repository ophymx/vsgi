
public class CompositeStackAppTests : CompositeAppTests {

    public CompositeStackAppTests() {
        base("CompositeStack");
    }

    public override void set_up() {
        test_compositeapp = new VSGI.CompositeStack();
    }

    public override void tear_down() {
        test_compositeapp = null;
    }

}
