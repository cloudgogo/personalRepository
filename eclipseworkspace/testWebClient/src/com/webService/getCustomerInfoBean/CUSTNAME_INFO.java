package com.webService.getCustomerInfoBean;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "CUSTNAME_INFO")
@XmlType(propOrder = { "cust_name" })
public class CUSTNAME_INFO {
	@XmlElement(name = "CUST_NAME")
	private String cust_name;

	public String getCust_name() {
		return cust_name;
	}

	public void setCust_name(String cust_name) {
		this.cust_name = cust_name;
	}
}
