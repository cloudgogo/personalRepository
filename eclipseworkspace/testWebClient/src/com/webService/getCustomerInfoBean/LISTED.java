package com.webService.getCustomerInfoBean;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "LISTED")
@XmlType(propOrder = { "is_listed" })
public class LISTED {
	@XmlElement(name="IS_LISTED")
	private String is_listed;

	public String getIs_listed() {
		return is_listed;
	}

	public void setIs_listed(String is_listed) {
		this.is_listed = is_listed;
	}

}
