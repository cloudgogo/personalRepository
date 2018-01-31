package com.fr.data;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.axiom.om.OMElement;

public class TransformOMElement {
	public String[][] transformElement() {
		TestWSDLdataGet testWSDLdataGet = new TestWSDLdataGet();
		OMElement element = testWSDLdataGet.getdata();
		Iterator iterator = element.getChildElements();
		Iterator inneritr;
		List<String> list = new ArrayList<String>();
		OMElement result = null;
		while (iterator.hasNext()) {
			result = (OMElement) iterator.next();
			inneritr = result.getChildElements();
			while (inneritr.hasNext()) {
				OMElement elem = (OMElement) inneritr.next();
				list.add(elem.getText());
			}
		}
		String[] result1 = list.toArray(new String[list.size()]);
		String results[][] = new String[result1.length][3];
		String b1, b2, b3;
		for (int i = 0; i < result1.length; i++) {
			if (result1[i].length() != 0) {
				b1 = result1[i].substring(0, result1[i].indexOf(" "));
				b2 = result1[i].substring(result1[i].indexOf(" ") + 1).substring(0,
						result1[i].substring(result1[i].indexOf(" ") + 1).indexOf(" "));
				b3 = result1[i].substring(result1[i].indexOf(" ") + 1)
						.substring(result1[i].substring(result1[i].indexOf(" ") + 1).indexOf(" ") + 1);
				results[i][0] = b1;
				results[i][1] = b2;
				results[i][2] = b3;

			}
		}
		return results;
	}

}
