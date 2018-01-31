package com.webService.getCustomerInfoBean;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "COMPANYADD_INFO")
@XmlType(propOrder = {"addinfoser_num","addr_type","country","province","city","district","address"})
public class COMPANYADD_INFO {

	@XmlElement(name = "ADDINFOSER_NUM")  
    private String addinfoser_num;  
	
	@XmlElement(name = "ADDR_TYPE")  
    private String addr_type; 
	
	@XmlElement(name = "COUNTRY")  
    private String country; 
	
	@XmlElement(name = "PROVINCE")  
    private String province; 
	
	@XmlElement(name = "CITY")  
    private String city; 
	
	//所属区/县
	@XmlElement(name = "DISTRICT")  
    private String district; 
	
	//详细地址
	@XmlElement(name = "ADDRESS")  
    private String address;

	public String getAddinfoser_num() {
		return addinfoser_num;
	}

	public String getAddr_type() {
		return addr_type;
	}

	public void setAddr_type(String addr_type) {
		this.addr_type = addr_type;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public String getProvince() {
		return province;
	}

	public void setProvince(String province) {
		this.province = province;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getDistrict() {
		return district;
	}

	public void setDistrict(String district) {
		this.district = district;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public void setAddinfoser_num(String addinfoser_num) {
		this.addinfoser_num = addinfoser_num;
	}
}
