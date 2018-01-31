package cn.com.hkgt.idp.client.util;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.LinkedHashMap;
import java.util.Map;

public class ResourceLoadTest {
	public static LinkedHashMap sections = new LinkedHashMap();
	public static void main(String[] args) throws FileNotFoundException {
		// TODO Auto-generated method stub
		String path = "D:/home/ap/data/groupdata/idp" + "/portalUrlLink.conf";
		load(path);
		System.out.println("load portalUrlLink.conf ok.");
	}
	
	public static void load(String fileName) throws FileNotFoundException {
		InputStream is = null;
		try {
			is = new FileInputStream(fileName);
			load(is);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (is != null)
				try {
					is.close();
				} catch (IOException localIOException2) {
				}
		}
	}

	public static void load(InputStream is) throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
		String line = null;
		String lastSectionName = null;
		while ((line = reader.readLine()) != null) {
			line = line.trim();
			if (line.startsWith("#")) {
				continue;
			}
			if ((line.startsWith("[")) && (line.endsWith("]"))) {
				lastSectionName = line.trim().substring(1, line.length() - 1);
				sections.put(lastSectionName, new LinkedHashMap());
			} else {
				if (line.length() == 0) {
					continue;
				}
				if (lastSectionName != null) {
					Map section = (Map) sections.get(lastSectionName);
					int index = line.indexOf('=');
					String key = (index > 0) ? line.substring(0, index) : line;
					String value = (index > 0) ? line.substring(index + 1) : line;
					section.put(key, value);
				}
			}
		}
	}

}
