package cn.com.hkgt.idp.client.util;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;

public class ConfigHelper {
	public static LinkedHashMap sections = null;

	private static void init() {
		sections = new LinkedHashMap();
		try {
			Properties p = new Properties();
			p.load(ConfigHelper.class.getResourceAsStream("/path.properties"));
			String path = p.getProperty("path");

			load(path + "/portalUrlLink.conf");
			System.out.println("load portalUrlLink.conf ok.");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public LinkedHashMap getSections() {
		if (sections == null) {
			init();
		}
		return sections;
	}

	public LinkedHashMap getSection(String sectionName) {
		if (sections == null) {
			init();
		}

		if (sections != null) {
			return (LinkedHashMap) sections.get(sectionName);
		}
		return null;
	}

	public static String get(String sectionName, String key) {
		if (sections == null) {
			init();
		}

		Map section1 = (Map) sections.get(sectionName);
		if (section1 == null) {
			return "";
		}
		return (String) section1.get(key);
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