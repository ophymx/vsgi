
public class CommonLoggerAppTests : CompositeAppTests {

    public CommonLoggerAppTests() {
        base("CommonLogger");
    }

    public override void set_up() {
        test_compositeapp = new VSGI.CommonLogger();
    }

    public override void tear_down() {
        test_compositeapp = null;
    }

}
