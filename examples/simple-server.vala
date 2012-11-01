using Gee;

public static void main() {
    VSGI.SimpleServer ws = new VSGI.SimpleServer(new VSGI.FileServer("public"));
    ws.run();
}
