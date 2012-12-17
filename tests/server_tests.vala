
public abstract class ServerTests : Gee.TestCase {

    public ServerTests(string name) {
        base(name);
    }

    protected VSGI.Server test_server;

    public override void set_up() {
    }

    public override void tear_down() {
        test_server = null;
    }

}
