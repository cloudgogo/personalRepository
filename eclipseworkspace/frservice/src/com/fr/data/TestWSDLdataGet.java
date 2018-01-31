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
	  // 指定调用WebService的URL  
    String url = "http://www.webxml.com.cn/WebServices/MobileCodeWS.asmx?wsdl";  
    EndpointReference targetEPR = new EndpointReference(url);  
    // 创建一个OMFactory，下面的namespace、方法与参数均需由它创建  
    OMFactory fac = OMAbstractFactory.getOMFactory();  
    // 命名空间  
    OMNamespace omNs = fac.createOMNamespace("http://WebXml.com.cn","a");  
    // 下面创建的是参数对数  
    /* 
     * OMElement symbol = fac.createOMElement("mobileCode", omNs); 
     * symbol.addChild(fac.createOMText(symbol, "18795842")); 
     */  
    // 下面创建一个method对象 ,方法  
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
