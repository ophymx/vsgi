
public class FileServerAppTests : AppTests {

    public FileServerAppTests() {
        base("FileServer");
    }

    public override void set_up() {
        test_app = new VSGI.FileServer("/tmp");
    }

    public override void tear_down() {
        test_app = null;
    }

}
