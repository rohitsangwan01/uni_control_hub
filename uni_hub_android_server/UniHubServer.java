import java.io.*;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.concurrent.ConcurrentHashMap;

import android.net.LocalSocket;
import android.net.LocalSocketAddress;
import android.system.ErrnoException;
import android.system.Os;
import android.system.OsConstants;

public class UniHubServer extends Thread {
    private static final ConcurrentHashMap<Integer, FileDescriptor> fds = new ConcurrentHashMap<>();
    private static BufferedOutputStream bufferedOutputStream;
    private static Thread thread;
    private final static byte CMD_OPEN = 1;
    private final static byte CMD_WRITE = 2;
    private final static byte CMD_CLOSE = 3;
    private final static byte CMD_CLOSE_ALL = 4;

    // Args
    private static String deviceId;
    private static String localSocket;
    private static String host;
    private static int port;

    public static void main(String... args) {
        System.out.println("Starting server... " + Arrays.toString(args));
        if (args.length == 0 || args[0].equals("-h") || args[0].equals("--help")) {
            showHelp();
            return;
        }

        deviceId = parseArgs("deviceId", args);
        if (deviceId == null) {
            showHelp();
            return;
        }

        // Start thread
        thread = new UniHubServer();

        // If LocalSocket is used, then the following code can be used
        localSocket = parseArgs("localSocket", args);

        if (localSocket != null) {
            thread.start();
            return;
        }


        // If host and port are used, then the following code can be used
        host = parseArgs("host", args);
        String portString = parseArgs("port", args);
        if (host == null || portString == null) {
            showHelp();
            return;
        }
        port = Integer.parseInt(portString);
        thread.start();
    }

    @Override
    public void run() {
        System.out.println("Thread started running..");
        if (localSocket != null) {
            connectToLocalServer(localSocket);
        } else {
            connectToServer(host, port);
        }
    }

    private static void showHelp() {
        System.out.println("Usage: "
                + "UniHubServer \n"
                + "-deviceId <id> ( device id for uhid )\n"
                + "-host <host> -port <port> ( connect to socket )\n"
                + "-localSocket <socketName> ( use local socket for communication )\n"
        );
    }


    private static void connectToServer(String host, int port) {
        try (Socket socket = new Socket(host, port)) {
            bufferedOutputStream = new BufferedOutputStream(socket.getOutputStream(), 1024);
            notifyServer();
            listenToServer(socket.getInputStream());
        } catch (Exception e) {
            System.out.println("Error connecting to server: " + e.getMessage());
            sendOutput("Error connecting to server: " + e.getMessage());
        }
    }

    private static void connectToLocalServer(String name) {
        try (LocalSocket localSocket = new LocalSocket()) {
            localSocket.connect(new LocalSocketAddress(name));
            bufferedOutputStream = new BufferedOutputStream(localSocket.getOutputStream(), 1024);
            notifyServer();
            listenToServer(localSocket.getInputStream());
        } catch (Exception e) {
            System.out.println("Error connecting to server: " + e.getMessage());
            sendOutput("Error connecting to server: " + e.getMessage());
        }
    }

    private static void notifyServer() {
        if (deviceId == null) {
            System.out.println("Device ID is not set");
            sendOutput("Device ID is not set");
            return;
        }
        sendOutput("device_id:" + deviceId);
    }

    private static void listenToServer(InputStream inputStream) throws IOException {
        byte[] buffer = new byte[1024];
        int bytesRead;
        while ((bytesRead = inputStream.read(buffer)) != -1) {
            handleCommand(buffer, bytesRead);
        }
        System.out.println("Connection closed");
    }

    private static void handleCommand(byte[] buffer, int bytesRead) throws IOException {
        byte command = buffer[0];
        byte deviceId = buffer[1];
        byte[] data = Arrays.copyOfRange(buffer, 2, bytesRead);
        // System.out.println("Command: " + command + " DeviceID: " + deviceId + " Data: " + Arrays.toString(data));
        switch (command) {
            case CMD_OPEN:
                open(deviceId, data);
                break;
            case CMD_WRITE:
                writeInput(deviceId, data);
                break;
            case CMD_CLOSE:
                close(deviceId);
                break;
            case CMD_CLOSE_ALL:
                closeAll();
                break;
            default:
                sendOutput("Unknown command");
                break;
        }
    }

    /// Handle UHID methods
    public static void open(int id, byte[] reportDesc) {
        try {
            FileDescriptor fd = Os.open("/dev/uhid", OsConstants.O_RDWR, 0);
            FileDescriptor old = fds.put(id, fd);
            if (old != null) close(old);

            byte[] req = buildUhidCreateReq(reportDesc);
            Os.write(fd, req, 0, req.length);
        } catch (ErrnoException | IOException e) {
            sendOutput("Error opening uhid: " + e.getMessage());
        }
    }

    private static void writeInput(int id, byte[] data) {
        FileDescriptor fd = fds.get(id);
        if (fd == null) {
            sendOutput("Unknown UHID id: " + id);
            return;
        }
        try {
            byte[] req = buildUhidInputReq(data);
            Os.write(fd, req, 0, req.length);
        } catch (ErrnoException | IOException e) {
            sendOutput("Error writing uhid: " + e.getMessage());
        }
    }

    private static void close(int id) {
        FileDescriptor fd = fds.remove(id);
        if (fd != null) {
            close(fd);
        }
    }

    private static void closeAll() {
        for (FileDescriptor fd : fds.values()) {
            close(fd);
        }
        thread.interrupt();
    }

    private static byte[] buildUhidCreateReq(byte[] reportDesc) {
       byte[] empty = new byte[256];
        ByteBuffer buf = ByteBuffer.allocate(280 + reportDesc.length).order(ByteOrder.nativeOrder());
        buf.putInt(11);
        buf.put("unihub".getBytes(StandardCharsets.US_ASCII));
        buf.put(empty, 0, 256 - "unihub".length());
        buf.putShort((short) reportDesc.length);
        buf.putShort((short) 0x06);
        buf.putInt(0); // vendor id
        buf.putInt(0); // product id
        buf.putInt(0); // version
        buf.putInt(0); // country;
        buf.put(reportDesc);
        return buf.array();
    }

    private static byte[] buildUhidInputReq(byte[] data) {
        ByteBuffer buf = ByteBuffer.allocate(6 + data.length).order(ByteOrder.nativeOrder());
        buf.putInt(12);
        buf.putShort((short) data.length);
        buf.put(data);
        return buf.array();
    }

    private static void close(FileDescriptor fd) {
        try {
            Os.close(fd);
        } catch (ErrnoException e) {
            System.out.print("Failed to close uhid: " + e.getMessage());
            sendOutput("Failed to close uhid: " + e.getMessage());
        }
    }

    private static String parseArgs(String arg, String[] args) {
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("-" + arg)) {
                return args[i + 1];
            }
        }
        return null;
    }

    private static void sendOutput(String data) {
        try {
            if (bufferedOutputStream != null) {
                bufferedOutputStream.write(data.getBytes());
                bufferedOutputStream.flush();
            }
        } catch (IOException e) {
            System.out.println("Error sending data: " + e.getMessage());
        }
    }
}
