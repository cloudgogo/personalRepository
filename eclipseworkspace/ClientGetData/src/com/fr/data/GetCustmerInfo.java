package com.fr.data;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.axiom.om.OMAbstractFactory;
import org.apache.axiom.om.OMElement;
import org.apache.axiom.om.OMFactory;
import org.apache.axiom.om.OMNamespace;
import org.apache.axis2.AxisFault;
import org.apache.axis2.addressing.EndpointReference;
import org.apache.axis2.client.Options;
import org.apache.axis2.client.ServiceClient;

public class GetCustmerInfo {
	OMElement result1 = null;
	public OMElement getdata() {
		 String url ="http://80.32.9.232:9001/ECIF/EcifServiceV200?wsdl";
		 EndpointReference targetEPR = new EndpointReference(url);
		 OMFactory fac = OMAbstractFactory.getOMFactory();  
		 OMNamespace omNs = fac.createOMNamespace("http://esb.cinda.ccb:9001/ECIF/EcifServiceV200","a");
		 String Cust_Code="123456";
		 String Request_Service="fr";
		 String Request_Person="123456";
		 String Request_Date=new SimpleDateFormat("yyyy/MM/dd").format(new Date());
		 
		 
		 String parm="<msgBody> "
		 		+ " <Cust_Code>"+Cust_Code+"</Cust_Code> "
		 		+ " <Request_Service>"+Request_Service+"</Request_Service>"
		 		+ " <Request_Person>"+Request_Person+"</Request_Person>"
		 		+ " <Request_Date>"+Request_Date+"</Request_Date>"
		 		+ " </msgBody> ";
		 OMElement symbol = fac.createOMElement(parm, omNs); 
		 //symbol.addChild(fac.createOMText(symbol, "18795842")); 
		 OMElement method = fac.createOMElement("queryComCustmerInfo", omNs);  
		    Options options =new Options();  
		    options.setTo(targetEPR);  
		    options.setAction("http://esb.cinda.ccb:9001/ECIF/EcifServiceV200/queryComCustmerInfo");  
		    try {
				ServiceClient sender = new ServiceClient();  
				sender.setOptions(options);  
				result1 = sender.sendReceive(method);
			} catch (AxisFault e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		    return result1;
	}
	
}
