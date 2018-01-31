 package cn.com.hkgt.idp.client.util;


 import java.io.PrintStream;
 import java.security.SecureRandom;
 import javax.crypto.Cipher;
 import javax.crypto.SecretKey;
 import javax.crypto.SecretKeyFactory;
 import javax.crypto.spec.DESKeySpec;


 public class DESUtils
 {
	 private static final String PASSWORD_CRYPT_KEY = "cindaportal";
	 private static final String DES = "DES";

	
	 public static byte[] encrypt(byte[] src, byte[] key) throws Exception
	 {
		/* 27 */ SecureRandom sr = new SecureRandom();
		
		/* 29 */ DESKeySpec dks = new DESKeySpec(key);
		
		/* 32 */ SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
		/* 33 */ SecretKey securekey = keyFactory.generateSecret(dks);
		
		/* 35 */ Cipher cipher = Cipher.getInstance("DES");
		
		/* 37 */ cipher.init(1, securekey, sr);
		
		/* 40 */ return cipher.doFinal(src);
		 }

	
	 public static byte[] decrypt(byte[] src, byte[] key) throws Exception
	 {
		/* 52 */ SecureRandom sr = new SecureRandom();
		
		/* 54 */ DESKeySpec dks = new DESKeySpec(key);
		
		/* 57 */ SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
		/* 58 */ SecretKey securekey = keyFactory.generateSecret(dks);
		
		/* 60 */ Cipher cipher = Cipher.getInstance("DES");
		
		/* 62 */ cipher.init(2, securekey, sr);
		
		/* 65 */ return cipher.doFinal(src);
		 }

	
	 public static final String decrypt(String data)
	 {
		 try
		 {
			/* 76 */ return new String(decrypt(hex2byte(data.getBytes()), /* 77 */ "cindaportal".getBytes()));
			 }
			 catch (Exception localException) {
			 }
		/* 81 */ return null;
		 }

	
	 public static final String encrypt(String password)
	 {
		 try
		 {
			/* 92 */ return byte2hex(encrypt(password.getBytes(), "cindaportal".getBytes()));
			 }
			 catch (Exception localException) {
			 }
		/* 96 */ return null;
		 }

	
	 public static String byte2hex(byte[] b)
	 {
		/* 105 */ String hs = "";
		/* 106 */ String stmp = "";
		/* 107 */ for (int n = 0; n < b.length; ++n) {
			/* 108 */ stmp = Integer.toHexString(b[n] & 0xFF);
			/* 109 */ if (stmp.length() == 1) {
				/* 110 */ hs = hs + "0" + stmp;
				 }
				 else {
				/* 113 */ hs = hs + stmp;
				 }
			 }
		/* 116 */ return hs.toUpperCase();
		 }

	
	 public static byte[] hex2byte(byte[] b) {
		/* 120 */ if (b.length % 2 != 0) {
			/* 121 */ throw new IllegalArgumentException("长度不是偶数");
			 }
		/* 123 */ byte[] b2 = new byte[b.length / 2];
		/* 124 */ for (int n = 0; n < b.length; n += 2) {
			/* 125 */ String item = new String(b, n, 2);
			/* 126 */ b2[(n / 2)] = (byte) Integer.parseInt(item, 16);
			 }
		/* 128 */ return b2;
		 }

	
	 public static void main(String[] args)
	 {
		/* 133 */ String pwd = "portuid=zcbhmh";
		/* 134 */ System.out.println("测试数据=" + pwd);
		/* 135 */ String data = encrypt(pwd);
		/* 136 */ System.out.println("加密后的数据=" + data);
		/* 137 */ pwd = decrypt(data);
		/* 138 */ System.out.println("解密后的数据=" + pwd);
		 }
	 }

/*
 * Location: E:\Cinda\认证接口示例\lib\gumidpCilent\ Qualified Name:
 * cn.com.hkgt.idp.client.util.DESUtils JD-Core Version: 0.5.4
 */