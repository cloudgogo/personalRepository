package cn.com.hkgt.idp.client.proxy;

import java.util.ArrayList;
import java.util.List;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class ProxyTicketValidator extends ServiceTicketValidator {
	protected List proxyList;

	public List getProxyList() {
		/* 15 */ return this.proxyList;
	}

	protected DefaultHandler newHandler() {
		/* 19 */ return new ProxyHandler();
	}

	protected void clear() {
		/* 56 */ super.clear();
		/* 57 */ this.proxyList = null;
	}

	protected class ProxyHandler extends ServiceTicketValidator.Handler {
		protected static final String PROXIES = "idp:proxies";
		protected static final String PROXY = "idp:proxy";
		/* 27 */ protected List proxyList = new ArrayList();
		/* 28 */ protected boolean proxyFragment = false;

		protected ProxyHandler() {
			/* 22 */ super(ProxyTicketValidator.this);
		}

		public void startElement(String ns, String ln, String qn, Attributes a) {
			/* 31 */ super.startElement(ns, ln, qn, a);
			/* 32 */ if ((this.authenticationSuccess) && (qn.equals("idp:proxies")))/* 33 */ this.proxyFragment = true;
		}

		public void endElement(String ns, String ln, String qn) throws SAXException {
			/* 39 */ super.endElement(ns, ln, qn);
			/* 40 */ if (qn.equals("idp:proxies"))/* 41 */ this.proxyFragment = false;
			/* 42 */ else if ((this.proxyFragment) && (qn.equals("idp:proxy")))
				/* 43 */ this.proxyList.add(this.currentText.toString().trim());
		}

		public void endDocument() throws SAXException {
			/* 48 */ super.endDocument();
			/* 49 */ if (this.authenticationSuccess)/* 50 */ ProxyTicketValidator.this.proxyList = this.proxyList;
		}
	}
}

/*
 * Location: E:\Cinda\认证接口示例\lib\gumidpCilent\ Qualified Name:
 * cn.com.hkgt.idp.client.proxy.ProxyTicketValidator JD-Core Version: 0.5.4
 */