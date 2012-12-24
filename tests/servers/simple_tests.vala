
public class SimpleServerTests : ServerTests {

    public SimpleServerTests() {
        base("SimpleServer");
    }

    public override void set_up() {
        test_server = new VSGI.SimpleServer(8080);
    }

    public override void tear_down() {
        test_server = null;
    }

}
