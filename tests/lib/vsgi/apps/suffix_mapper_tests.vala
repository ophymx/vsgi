
public class SuffixMapperAppTests : CompositeAppTests {

    public SuffixMapperAppTests() {
        base("SuffixMapper");
    }

    public override void set_up() {
        test_compositeapp = new VSGI.SuffixMapper();
    }

    public override void tear_down() {
        test_compositeapp = null;
    }

}
