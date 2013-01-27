
public class MapperAppTests : CompositeAppTests {

    public MapperAppTests() {
        base("Mapper");
    }

    public override void set_up() {
        Gee.HashMap<string, VSGI.Application> map = new Gee.HashMap<string, VSGI.Application>();
        test_compositeapp = new VSGI.Mapper(map);
    }

    public override void tear_down() {
        test_compositeapp = null;
    }

}
