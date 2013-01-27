
public class IterableByteStreamTests : Gee.TestCase {

    public IterableByteStreamTests() {
        base("IterableByteStream");
    }

    protected VSGI.IterableByteStream test_stream;

    public override void set_up() {
    }

    public override void tear_down() {
        test_stream = null;
    }

}
