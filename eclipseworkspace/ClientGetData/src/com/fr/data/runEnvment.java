package com.fr.data;

import org.apache.axis.client.Call;
import org.apache.axis.client.Service;

public class runEnvment {
	public static void main(String[] args) {
		 String xml="<msg>    " 
					+"<msgHeader>                                                                 "
					+"<version>V200<ersion>                                                       "
					+"<inSysId>ECIFJT01</inSysId>                                                 "
					+"<originSysId>YWSHZC02</originSysId>                                         "
					+"<serialNo>2016072800000101ECIFJT0116421800<rialNo>                          "
					+"<UUID>2016072800000101ECIFJT0116421800</UUID>                               "
					+"<requestDate>20160728</requestDate>                                         "
					+"<requestTime>164218</requestTime>                                           "
					+"<channelId>001<annelId>                                                     "
					+"<serviceName>ECIF_EcifServiceV200<rviceName>                                "
					+"<methodName>queryComCustmerInfo</methodName>                                "
					+"<orgNo>0000</orgNo>                                                         "
					+"<terminalNo>0000</terminalNo>                                               "
					+"<tellerId>0000</tellerId>                                                   "
					+"<respType/>                                                                 "
					+"<respSerialNo/>                                                             "
					+"<respCode/>                                                                 "
					+"<respCodeDec/>                                                              "
					+"<memo/>                                                                     "
					+"</msgHeader>                                                                "
					+"<msgBody>                                                                   "
					+"<INPUT_XML>                                                                    "
					+"<CUST_NAME>神华新疆能源有限责任公司</CUST_NAME>                                   "
					+"<COMPANY_TYPE>06</COMPANY_TYPE>                                   "
					+"<CREDIT_CODE>91650000228860955P</CREDIT_CODE>                                   "
					+"<COUNTRY>CHN</COUNTRY>                                   "
					+"<ORG_CODE>228860955</ORG_CODE>                                   "
					+"<PROVINCE>130000</PROVINCE>                                   "
					+"<GROUP>神华集团</GROUP>                                   "
					+"<TRADE>B06</TRADE>                                   "
					+"<U_ID>10129074</U_ID>           "
					+"   </INPUT_XML>                                                                "
					+" </msgBody>                                                                    ";
			String returnMessagr="无返回信息";
			Service service = new Service();
			try {
				Call call = (Call) service.createCall();
				call.setTargetEndpointAddress("http://80.32.9.114:7001/ecif/services/EcifService");
				call.setOperation("queryCustmerByCondition");
				// 调用接口时，授权的用户
//				String userName = Global.getConfig("relatedName");
				// 证书存放路径
//				String certPath = Global.getConfig("relatedKey");
//				InputStream is = ServiceClient.class.getResourceAsStream(certPath);
//				String signedText = InitSign.initHkSign(is, userName);
//				is.close();
//				call.addHeader(new org.apache.axis.message.SOAPHeaderElement("Authorization", "username", userName));
//				call.addHeader(new org.apache.axis.message.SOAPHeaderElement("Authorization", "password", signedText));
				System.out.println(call.getSOAPActionURI());
				returnMessagr = (String) call.invoke(new Object[]{xml});
				System.out.println(returnMessagr);
			} catch (Exception e) {
				returnMessagr="调用客户端异常";
				e.printStackTrace();
			}
	}
}
