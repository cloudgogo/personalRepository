package com.webService.getCustomerInfoBean;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name="INDUSTRY_INFO")
@XmlType(propOrder={"trade","trade_dode"})
public class INDUSTRY_INFO {
	@XmlElement(name="TRADE")
	private String trade;
	
	@XmlElement(name="TRADE_DODE")
	private String trade_dode;

	public String getTrade() {
		return trade;
	}

	public void setTrade(String trade) {
		this.trade = trade;
	}

	public String getTrade_dode() {
		return trade_dode;
	}

	public void setTrade_dode(String trade_dode) {
		this.trade_dode = trade_dode;
	}
}
