package com.fr.function;

import java.io.StringReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;

import org.apache.axis.client.Call;
import org.apache.axis.client.Service;

import com.fr.script.AbstractFunction;
import com.webService.getCustomerInfoBean.BASIC_SIGEN;

public class GetCustmerInfo extends AbstractFunction {
	private String recordflag=null;
	private Map<String, String> infoMap;
	
	@Override
	public Object run(Object[] args) {
		String returnvalue = null;
		if (3 == args.length) {
			returnvalue = run(args[0].toString(), args[1].toString(), args[2].toString());
		} else if (4 == args.length) {
			returnvalue = run(args[0].toString(), args[1].toString(), args[2].toString(), args[3].toString());
		}
		return returnvalue;
	}
    
	private String run(String code, String fruser,String condition, String flag) {
       if(flag.equals(recordflag)){
    	   return infoMap.get(condition);
       }else{
    	   infoMap=new HashMap<>();
    	   recordflag=flag;
    	   BASIC_SIGEN baSigen= this.getInfoBean(code, fruser);
    	   infoMap.put("cust_name", baSigen.getCustname_info().getCust_name());
    	   infoMap.put("addinfoser_num", baSigen.getCompanyadd_info().getAddinfoser_num());
    	   infoMap.put("addr_type", baSigen.getCompanyadd_info().getAddr_type());
    	   infoMap.put("country", baSigen.getCompanyadd_info().getCountry());
    	   return infoMap.get(condition);
       }
       
	}

	private String run(String code, String fruser,String condition) {
		return this.run(code, fruser, condition, String.valueOf(System.currentTimeMillis()));
	}

	private String getxml(String code, String fruser) {

		String returnxml = null;
		String returnMessagr = "无返回信恄1�7";
		String Cust_Code=code;
		//String Cust_Code = "EO000000000079662";
		String Request_Service = "fr";
		String Request_Person = fruser;
		String Request_Date = new SimpleDateFormat("yyyy/MM/dd").format(new Date());

		String parm = "<msgBody> " + " <Cust_Code>" + Cust_Code + "</Cust_Code> " + " <Request_Service>"
				+ Request_Service + "</Request_Service>" + " <Request_Person>" + Request_Person + "</Request_Person>"
				+ " <Request_Date>" + Request_Date + "</Request_Date>" + " </msgBody></msg> ";
		String xml = "<msg>    " + "<msgHeader>                                                                 "
				+ "<version>V200</version>                                                       "
				+ "<inSysId>ECIFJT01</inSysId>                                                 "
				+ "<originSysId>YWSHZC02</originSysId>                                         "
				+ "<serialNo>2016072800000101ECIFJT0116421800</serialNo>                          "
				+ "<UUID>2016072800000101ECIFJT0116421800</UUID>                               "
				+ "<requestDate>20160728</requestDate>                                         "
				+ "<requestTime>164218</requestTime>                                           "
				+ "<channelId>001</channelId>                                                     "
				+ "<serviceName>ECIF_EcifServiceV200</serviceName>                                "
				+ "<methodName>queryComCustmerInfo</methodName>                                "
				+ "<orgNo>0000</orgNo>                                                         "
				+ "<terminalNo>0000</terminalNo>                                               "
				+ "<tellerId>0000</tellerId>                                                   "
				+ "<respType/>                                                                 "
				+ "<respSerialNo/>                                                             "
				+ "<respCode/>                                                                 "
				+ "<respCodeDec/>                                                              "
				+ "<memo/>                                                                     "
				+ "</msgHeader>                                                                "
				+ parm;

		Service service = new Service();
		try {
			Call call = new Call(service);
			call.setTargetEndpointAddress("http://80.32.9.232:9001/ECIF/EcifServiceV200");
			call.setOperation("queryComCustmerInfo");
			// System.out.println(call.getSOAPActionURI());
			returnMessagr = (String) call.invoke(new Object[] { xml });
			System.out.println(returnMessagr);
			returnxml = returnMessagr;
		} catch (Exception e) {
			returnMessagr = "调用客户端异帄1�7";
			e.printStackTrace();
		}
		// TODO need return error
		return returnxml;

	}
    private BASIC_SIGEN getInfoBean(String code,String fruser){
    	   String xml= this.getxml(code, fruser);
    	   String needxml=xml.substring(xml.indexOf("<BASIC_SIGEN>"), xml.indexOf("</BASIC_SIGEN>")+14);
    	    	BASIC_SIGEN baSigen=this.converyToJavaBean(needxml, BASIC_SIGEN.class);
    	    	return baSigen;
    }
    private <T> T converyToJavaBean(String xml, Class<T> c) {  
        T t = null;  
        try {  
            JAXBContext context = JAXBContext.newInstance(c);  
            Unmarshaller unmarshaller = context.createUnmarshaller();  
            t = (T) unmarshaller.unmarshal(new StringReader(xml));  
        } catch (Exception e) {  
            e.printStackTrace();  
        }  
        return t;  
    }  
}
