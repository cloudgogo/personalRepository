/*     */ package cn.com.hkgt.idp.client.util;

/*     */
/*     */ import java.io.BufferedReader;
/*     */ import java.io.IOException;
/*     */ import java.io.InputStreamReader;
/*     */ import java.io.UnsupportedEncodingException;
/*     */ import java.net.URL;
/*     */ import java.net.URLConnection;
/*     */ import java.net.URLEncoder;
/*     */ import javax.servlet.ServletException;
/*     */ import javax.servlet.http.HttpServletRequest;

/*     */
/*     */ public class HttpHelper
/*     */ {
	/*     */ public static String retrieve(String url)/*     */ throws IOException
	/*     */ {
		/* 17 */ BufferedReader rd = null;
		/*     */ try
		/*     */ {
			/* 20 */ URL u = new URL(url);
			/* 21 */ URLConnection uc = u.openConnection();
			/* 22 */ uc.setRequestProperty("Connection", "close");
			/*     */
			/* 24 */ System.setProperty("sun.net.client.defaultConnectTimeout", "5000");
			/* 25 */ System.setProperty("sun.net.client.defaultReadTimeout", "5000");
			/*     */
			/* 27 */ rd = new BufferedReader(new InputStreamReader(uc.getInputStream()));
			/*     */
			/* 29 */ String line = "";
			/* 30 */ StringBuffer buf = new StringBuffer();
			/* 31 */ while ((line = rd.readLine()) != null) {
				/* 32 */ buf.append(line + "\n");
				/*     */ }
			/*     */
			/* 35 */ return buf.toString();
			/*     */ } finally {
			/*     */ try {
				/* 38 */ if (rd != null)/* 39 */ rd.close();
				/*     */ }
				/*     */ catch (Exception localException1)
			/*     */ {
				/*     */ }
			/*     */ }
		/*     */ }

	/*     */
	/*     */ public static boolean isFilter(String uri, String notFliters)
	/*     */ {
		/* 50 */ boolean isfilter = true;
		/*     */
		/* 52 */ if (uri.endsWith(".xdp"))/* 53 */ return false;
		/* 54 */ if (uri.endsWith(".xml"))/* 55 */ return false;
		/* 56 */ if (uri.endsWith(".jpg"))/* 57 */ return false;
		/* 58 */ if (uri.endsWith(".gif"))/* 59 */ return false;
		/* 60 */ if (uri.endsWith(".bmp"))/* 61 */ return false;
		/* 62 */ if (uri.endsWith(".js"))/* 63 */ return false;
		/* 64 */ if (uri.endsWith(".css"))/* 65 */ return false;
		/* 66 */ if (uri.endsWith(".jpeg"))/* 67 */ return false;
		/* 68 */ if (uri.endsWith(".ico"))/* 69 */ return false;
		/* 70 */ if (uri.endsWith(".swf"))/* 71 */ return false;
		/* 72 */ if (uri.endsWith(".png"))/* 73 */ return false;
		/* 74 */ if (uri.endsWith(".htc"))/* 75 */ return false;
		/* 76 */ if (uri.endsWith(".xsl")) {
			/* 77 */ return false;
			/*     */ }
		/* 79 */ if ((notFliters != null) && (notFliters.trim().length() > 0)) {
			/* 80 */ String[] nots = notFliters.split(";");
			/*     */
			/* 82 */ for (int i = 0; i < nots.length; ++i) {
				/* 83 */ if (uri.indexOf(nots[i]) != -1) {
					/* 84 */ isfilter = false;
					/* 85 */ break;
					/*     */ }
				/*     */ }
			/*     */ }
		/*     */
		/* 90 */ return isfilter;
		/*     */ }

	/*     */
	/*     */ public static String getServiceURL(HttpServletRequest request)/*     */ throws ServletException
	/*     */ {
		/* 96 */ String url = request.getRequestURL().toString();
		/* 97 */ String queryStr = request.getQueryString();
		/*     */
		/* 100 */ String fromOtherIdp = request.getHeader("fromOtherIdp");
		/* 101 */ if (fromOtherIdp != null) {
			/* 102 */ int n = url.indexOf("//");
			/*     */
			/* 104 */ String server2 = url.substring(n + 2, url.length());
			/* 105 */ int v = server2.indexOf("/");
			/*     */
			/* 107 */ server2 = server2.substring(0, v);
			/* 108 */ url = url.replaceAll(server2, fromOtherIdp);
			/*     */ }
		/*     */
		/* 111 */ StringBuffer sb = new StringBuffer(url);
		/*     */
		/* 113 */ if ((queryStr != null) && (queryStr.length() > 1)) {
			/* 114 */ int ticketLoc = queryStr.indexOf("ticket=");
			/* 115 */ if (ticketLoc == -1)/* 116 */ sb.append("?" + queryStr);
			/* 117 */ else if (ticketLoc > 1) {
				/* 118 */ sb.append("?" + queryStr.substring(0, ticketLoc - 1));
				/*     */ }
			/*     */ }
		/*     */ try
		/*     */ {
			/* 123 */ return URLEncoder.encode(sb.toString(), "utf-8");
			/*     */ } catch (UnsupportedEncodingException e) {
			/* 125 */ throw new ServletException(e);
			/*     */ }
		/*     */ }
	/*     */ }

/*
 * Location: E:\Cinda\认证接口示例\lib\gumidpCilent\ Qualified Name:
 * cn.com.hkgt.idp.client.util.HttpHelper JD-Core Version: 0.5.4
 */