// Collin Atkins, Brandon Watson, Kyle Koch, Juanita Dickhaus
// Net Sec, Prof. Franco
// Cool Cats - Monitor Project

import java.io.*;
import java.math.*;
import java.security.*;

class DiffieHellmanExchange {
    int keysize;
    DHKey key;
    BigInteger x, x_pub, s_secret;

    public DiffieHellmanExchange () {  this.keysize = 512;  }

    // Get the numbers p,g from file (in "key" object)
    // Generate a secure random number and create a public key from p,g
    public BigInteger getDHParmMakePublicKey (String filename)
	throws Exception {
	FileInputStream fis = new FileInputStream(filename);
	ObjectInputStream oin = new ObjectInputStream(fis);
	key = (DHKey)oin.readObject();
	oin.close();
	SecureRandom sr = new SecureRandom();  // Get a secure random number
	x = new BigInteger(keysize, sr);  // Generate the secure secret key
	x_pub = key.g.modPow(x, key.p);   // Compute the public key from p,g
	return x_pub;
    }

    // Gets servers public key as arg
    // Builds the secret
    public BigInteger getSecret (BigInteger pkey) {  
	s_secret = pkey.modPow(x, key.p);
	System.out.println("Shared secret computed!");
	return s_secret;
    }
}
