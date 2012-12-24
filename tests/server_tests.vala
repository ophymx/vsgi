
public abstract class ServerTests : Gee.TestCase {

    public ServerTests(string name) {
        base(name);
        add_test("[Server] can instantiate", test_instantiation);
    }

    protected VSGI.Server test_server;

    public override void set_up() {
    }

    public override void tear_down() {
        test_server = null;
    }

    public virtual void test_instantiation() {
        assert(test_server != null);
    }

}
