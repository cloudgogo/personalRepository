package cn.com.hkgt.idp.client.proxy;

import cn.com.hkgt.idp.client.util.HttpHelper;
import java.io.IOException;
import java.io.StringReader;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;

public class ServiceTicketValidator {
	private String idpValidateUrl;
	private String proxyCallbackUrl;
	private String st;
	private String service;
	private String pgtIou;
	private String user;
	private String errorCode;
	private String errorMessage;
	private String entireResponse;
    private boolean renew = false;
	private boolean successfulAuthentication;

	public void setIdpValidateUrl(String x) {
		this.idpValidateUrl = x;
	}

	public String getIdpValidateUrl() {
		return this.idpValidateUrl;
	}

	public void setProxyCallbackUrl(String x) {
		this.proxyCallbackUrl = x;
	}

	public void setRenew(boolean b) {
		this.renew = b;
	}

	public String getProxyCallbackUrl() {
		return this.proxyCallbackUrl;
	}

	public void setServiceTicket(String x) {
		this.st = x;
	}

	public void setService(String x) {
		this.service = x;
	}

	public String getUser() {
		return this.user;
	}

	public String getPgtIou() {
		return this.pgtIou;
	}

	public boolean isAuthenticationSuccesful() {
		return this.successfulAuthentication;
	}

	public String getErrorMessage() {
		return this.errorMessage;
	}

	public String getErrorCode() {
		return this.errorCode;
	}

	public String getResponse() {
		return this.entireResponse;
	}

	public void validate() throws IOException, SAXException, ParserConfigurationException {
		if ((this.idpValidateUrl == null) || (this.st == null)) {
			throw new IllegalStateException(/* 88 */ "must set validation URL and ticket");
		}

		clear();

		StringBuffer sb = new StringBuffer();
		sb.append(this.idpValidateUrl);
		if (this.idpValidateUrl.indexOf('?') == -1)
			sb.append("?service=" + this.service + "&ticket=" + this.st);
		else {
			sb.append("&service=" + this.service + "&ticket=" + this.st);
		}

		if (this.proxyCallbackUrl != null) {
			sb.append("&pgtUrl=" + this.proxyCallbackUrl);
		}
		if (this.renew) {
			sb.append("&renew=true");
		}

		this.entireResponse = HttpHelper.retrieve(sb.toString());

		if (this.entireResponse != null) {
			XMLReader r = SAXParserFactory.newInstance()/* 114 */ .newSAXParser().getXMLReader();
			r.setFeature("http://xml.org/sax/features/namespaces", false);
			r.setContentHandler(newHandler());
			r.parse(new InputSource(new StringReader(this.entireResponse)));
		}
	}

	protected DefaultHandler newHandler() {
		return new Handler();
	}

	protected void clear() {
		this.user = null;
		this.pgtIou = null;
		this.successfulAuthentication = false;
		this.errorMessage = null;
		this.errorCode = null;
		this.successfulAuthentication = false;
	}

	protected class Handler extends DefaultHandler {
		protected static final String AUTHENTICATION_SUCCESS = "idp:authenticationSuccess";
		protected static final String AUTHENTICATION_FAILURE = "idp:authenticationFailure";
		protected static final String PROXY_GRANTING_TICKET = "idp:proxyGrantingTicket";
		protected static final String USER = "idp:user";
		/* 132 */ protected StringBuffer currentText = new StringBuffer();
		/* 133 */ protected boolean authenticationSuccess = false;
		/* 134 */ protected boolean authenticationFailure = false;
		protected String netid;
		protected String pgtIou;
		protected String errorCode;
		protected String errorMessage;

		protected Handler() {
		}

		public Handler(ProxyTicketValidator proxyTicketValidator) {
			// TODO Auto-generated constructor stub
		}

		public void startElement(String ns, String ln, String qn, Attributes a) {
			/* 142 */ this.currentText = new StringBuffer();

			/* 145 */ if (qn.equals("idp:authenticationSuccess")) {
				/* 146 */ this.authenticationSuccess = true;
				/* 147 */ } else if (qn.equals("idp:authenticationFailure")) {
				/* 148 */ this.authenticationFailure = true;
				/* 149 */ this.errorCode = a.getValue("code");
				/* 150 */ if (this.errorCode != null)/* 151 */ this.errorCode = this.errorCode.trim();
			}
		}

		public void characters(char[] ch, int start, int length) {
			/* 158 */ this.currentText.append(ch, start, length);
		}

		public void endElement(String ns, String ln, String qn) throws SAXException {
			/* 163 */ if (this.authenticationSuccess) {
				/* 164 */ if (qn.equals("idp:user"))
					/* 165 */ ServiceTicketValidator.this.user = this.currentText.toString().trim();
				/* 166 */ if (qn.equals("idp:proxyGrantingTicket"))
					/* 167 */ this.pgtIou = this.currentText.toString().trim();
			} else {
				/* 168 */ if ((!this.authenticationFailure) ||
						/* 169 */ (!qn.equals("idp:authenticationFailure")))
					return;
				/* 170 */ this.errorMessage = this.currentText.toString().trim();
			}
		}

		public void endDocument() throws SAXException {
			/* 176 */ if (this.authenticationSuccess) {
				/* 177 */ ServiceTicketValidator.this.user = ServiceTicketValidator.this.user;
				/* 178 */ ServiceTicketValidator.this.pgtIou = this.pgtIou;
				/* 179 */ ServiceTicketValidator.this.successfulAuthentication = true;
				/* 180 */ } else if (this.authenticationFailure) {
				/* 181 */ ServiceTicketValidator.this.errorMessage = this.errorMessage;
				/* 182 */ ServiceTicketValidator.this.errorCode = this.errorCode;
				/* 183 */ ServiceTicketValidator.this.successfulAuthentication = false;
			} else {
				/* 185 */ throw new SAXException(/* 186 */ "no indication of success of failure from CAS");
			}
		}
	}
}

/*
 * Location: E:\Cinda\认证接口示例\lib\gumidpCilent\ Qualified Name:
 * cn.com.hkgt.idp.client.proxy.ServiceTicketValidator JD-Core Version: 0.5.4
 */