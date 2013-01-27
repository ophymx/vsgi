
public class LintAppTests : CompositeAppTests {

    public LintAppTests() {
        base("Lint");
    }

    public override void set_up() {
        test_compositeapp = new VSGI.Lint();
    }

    public override void tear_down() {
        test_compositeapp = null;
    }

}
