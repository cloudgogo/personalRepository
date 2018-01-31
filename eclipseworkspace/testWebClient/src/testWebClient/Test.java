package testWebClient;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.axis.client.Call;
import org.apache.axis.client.Service;

public class Test {
	public static void main(String[] args) {
		String returnMessagr = "无返回信恄1�7";
		String Cust_Code = "EO000000000079662";
		String Request_Service = "fr";
		String Request_Person = "123456";
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
				/*
				 * +"<msgBody>                                                                   "
				 * +"<INPUT_XML>                                                                    "
				 * +"<CUST_NAME>神华新疆能源有限责任公司</CUST_NAME>                                   "
				 * +"<COMPANY_TYPE>06</COMPANY_TYPE>                                   "
				 * +"<CREDIT_CODE>91650000228860955P</CREDIT_CODE>                                   "
				 * +"<COUNTRY>CHN</COUNTRY>                                   "
				 * +"<ORG_CODE>228860955</ORG_CODE>                                   "
				 * +"<PROVINCE>130000</PROVINCE>                                   "
				 * +"<GROUP>神华集团</GROUP>                                   "
				 * +"<TRADE>B06</TRADE>                                   "
				 * +"<U_ID>10129074</U_ID>           "
				 * +"   </INPUT_XML>                                                                "
				 * +" </msgBody>                                                                    "
				 * ;
				 * 
				 */
				+ parm;

		Service service = new Service();
		try {
			Call call = new Call(service);
			call.setTargetEndpointAddress("http://80.32.9.232:9001/ECIF/EcifServiceV200");
			call.setOperation("queryComCustmerInfo");
			//System.out.println(call.getSOAPActionURI());
			returnMessagr = (String) call.invoke(new Object[] { xml });
			System.out.println(returnMessagr);
		} catch (Exception e) {
			returnMessagr = "调用客户端异帄1�7";
			e.printStackTrace();
		}
	}

}
