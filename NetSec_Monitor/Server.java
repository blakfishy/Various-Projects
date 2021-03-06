// Collin Atkins, Brandon Watson, Kyle Koch, Juanita Dickhaus
// Net Sec, Prof. Franco
// Cool Cats - Monitor Project

import java.io.*;
import java.net.*;
import java.util.*;
import java.lang.*;

public class Server implements Runnable{

    ServerSocket s = null;
    public static int MONITOR_PORT;
    public static int LOCAL_PORT; 
    Thread runner;
    String IDENT;
    String PASSWORD;

    public Server(int p, int lp, String name, String password) {
	IDENT = name;
	PASSWORD = password;
	try {
	    s = new ServerSocket(p);
	    MONITOR_PORT = p;
	    LOCAL_PORT=lp;
	    int i = 1;
	} catch (IOException e) {
	}
    }

    public void start() {
	if (runner == null) {
	    runner = new Thread(this);
	    runner.start();
	} 
    }

    public void run() {
	try {
	    int i = 1;
	    for (;;) {
		Socket incoming =  s.accept();
		new ConnectionHandler(incoming,i,IDENT,PASSWORD).start(); 
		//Spawn a new thread for each new connection
		i++;
	    } 
	} catch (Exception e) {
	    System.out.println("Server [run]: Error in Server: "  + e);
	}
    }
}

class ConnectionHandler extends MessageParser implements Runnable {
    private Socket incoming;
    private int counter; 
    Thread runner;
        
    public ConnectionHandler (Socket i, int c, String name, String password) { 
	super(name, password);
	incoming = i;  counter = c; 
    }
  
    public void run() {
	try {
	    in = new BufferedReader(new InputStreamReader(incoming.getInputStream()));
	    out = new PrintWriter(incoming.getOutputStream(),true);
	 
	    boolean done = false;
	    HOST_PORT = Server.LOCAL_PORT;
	    // Indicates that this is the server
	    CType = 1;
	 
	    System.out.println("\nStarting login from Server..\n");
	    if(Login()) {
	    	System.out.println("\nServer log in successful!\n");
	    }
	    else {
		System.out.println("Server log in failure. Exiting.");
		System.exit(1);
	    }

	    incoming.close();
	    in.close();
	    out.close();
	 
	} catch (IOException e) {
	} catch (NullPointerException n) {
	}
    }

    public void start() {
	if (runner == null) {
	    runner = new Thread(this);
	    runner.start();
	}
    }
}
