package com.fr.data;

import org.apache.axiom.om.OMAbstractFactory;
import org.apache.axiom.om.OMElement;
import org.apache.axiom.om.OMFactory;
import org.apache.axiom.om.OMNamespace;
import org.apache.axis2.addressing.EndpointReference;
import org.apache.axis2.client.Options;
import org.apache.axis2.client.ServiceClient;

import org.apache.axis2.AxisFault;
public class TestWSDLdataGet {
	OMElement result1 =null;
    public OMElement getdata() {
	try{	
	  // ָ������WebService��URL  
    String url = "http://www.webxml.com.cn/WebServices/MobileCodeWS.asmx?wsdl";  
    EndpointReference targetEPR = new EndpointReference(url);  
    // ����һ��OMFactory�������namespace�����������������������  
    OMFactory fac = OMAbstractFactory.getOMFactory();  
    // �����ռ�  
    OMNamespace omNs = fac.createOMNamespace("http://WebXml.com.cn","a");  
    // ���洴�����ǲ�������  
    /* 
     * OMElement symbol = fac.createOMElement("mobileCode", omNs); 
     * symbol.addChild(fac.createOMText(symbol, "18795842")); 
     */  
    // ���洴��һ��method���� ,����  
    OMElement method = fac.createOMElement("getDatabaseInfo", omNs);  
    // method.addChild(symbol);  
    Options options =new Options();  
    options.setTo(targetEPR);  
    options.setAction("http://WebXml.com.cn/getDatabaseInfo");  
    ServiceClient sender = new ServiceClient();  
    sender.setOptions(options);  
    result1 = sender.sendReceive(method);  
    
	}catch (AxisFault axisFault) {
		 axisFault.printStackTrace(); 
	}
	return result1;
	}
}
