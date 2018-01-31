package com.webService.getCustomerInfoBean;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "BASIC_SIGEN")
@XmlType(propOrder = { "industry_info","listed" ,"custname_info","companyadd_info"})
public class BASIC_SIGEN {
	@XmlElement(name="INDUSTRY_INFO")
	private INDUSTRY_INFO industry_info;
	@XmlElement(name="LISTED")
	private LISTED listed;
	@XmlElement(name="CUSTNAME_INFO")
	private CUSTNAME_INFO custname_info;
	@XmlElement(name="COMPANYADD_INFO")
	private COMPANYADD_INFO companyadd_info;
	public INDUSTRY_INFO getIndustry_info() {
		return industry_info;
	}
	public void setIndustry_info(INDUSTRY_INFO industry_info) {
		this.industry_info = industry_info;
	}
	public LISTED getListed() {
		return listed;
	}
	public void setListed(LISTED listed) {
		this.listed = listed;
	}
	public CUSTNAME_INFO getCustname_info() {
		return custname_info;
	}
	public void setCustname_info(CUSTNAME_INFO custname_info) {
		this.custname_info = custname_info;
	}
	public COMPANYADD_INFO getCompanyadd_info() {
		return companyadd_info;
	}
	public void setCompanyadd_info(COMPANYADD_INFO companyadd_info) {
		this.companyadd_info = companyadd_info;
	}

}
