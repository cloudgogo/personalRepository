package cn.com.hkgt.idp.client.filter;

import java.io.IOException;
import java.util.StringTokenizer;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import cn.com.hkgt.idp.client.proxy.ProxyTicketValidator;
import cn.com.hkgt.idp.client.util.ConfigHelper;
import cn.com.hkgt.idp.client.util.HttpHelper;

public class IDPFilter implements Filter {
	private Logger log;
	private String idpHost;
	public static final String IDP_FILTER_USER = "cn.com.hkgt.idp.client.filter.user";
	private String idpLogin;
	private String idpValidate;
	private String idplogOut;
	private String idpAuthorizedProxy;
	private String idpRenew;
	private String notFliters;

	public IDPFilter() {
		this.log = Logger.getLogger(IDPFilter.class);
	}

	public void init(FilterConfig config) throws ServletException {
		this.log.info("dpFilter...");

		this.idpHost = ConfigHelper.get("IDPHOST", "SRC");
		this.idpLogin = (this.idpHost + "/login");
		this.idpValidate = (this.idpHost + "/proxyValidate");
		this.idplogOut = "/idp/logOut.jpg";

		this.log.info("idpFilter idpLogin:" + this.idpLogin);
		this.log.info("idpFilter idpValidate:" + this.idpValidate);
		this.log.info("idpFilter idplogOut:" + this.idplogOut);

		this.idpAuthorizedProxy = config.getInitParameter("cn.com.hkgt.idp.client.filter.authorizedProxy");

		this.idpRenew = config.getInitParameter("cn.com.hkgt.idp.client.filter.renew");

		if ((this.idpRenew == null) || (!"true".equals(this.idpRenew))) {
			this.idpRenew = "false";
		}
		this.notFliters = config.getInitParameter("cn.com.hkgt.idp.client.filter.notFilters");

		this.log.info("idpFilter idpAuthorizedProxy:" + this.idpAuthorizedProxy);
		this.log.info("idpFilter idpRenew:" + this.idpRenew);
		this.log.info("idpFilter notFliters:" + this.notFliters);

		this.log.info("鍒濆鍖杋dpFilter鎴愬姛銆�");
	}

	public void reAlias(String remoteAddr) {
		this.log.info("idpFilter remote access Addr:" + remoteAddr);

		this.idpHost = ConfigHelper.get("IDPALIAS", remoteAddr);
		this.idpLogin = (this.idpHost + "/login");
		this.idpValidate = (this.idpHost + "/proxyValidate");
		this.idplogOut = "/idp/logOut.jpg";

		this.log.info("idpFilter rewrite idpLogin:" + this.idpLogin);
	}

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain fc)
			throws ServletException, IOException {
		HttpServletResponse httpResponse = (HttpServletResponse) response;
		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpSession session = httpRequest.getSession();

		httpResponse.addHeader("P3P", "CP=CAO PSA OUR");

		String ticket = httpRequest.getParameter("ticket");
		String uri = httpRequest.getRequestURI();

		if (uri.endsWith(this.idplogOut)) {
			if (session != null) {
				session.invalidate();
			}

			fc.doFilter(request, response);
			return;
		}

		if ((!"true".equals(this.idpRenew)) && (session.getAttribute("cn.com.hkgt.idp.client.filter.user") != null)) {
			fc.doFilter(request, response);

			return;
		}

		boolean flagFilter = HttpHelper.isFilter(uri, this.notFliters);
		if (!flagFilter) {
			fc.doFilter(request, response);
			return;
		}
		
		//For testing 	
		//String refererUrl = httpRequest.getHeader("referer");
//        String ssoFlag = httpRequest.getParameter("sso");
        System.out.println("ticket="+ticket);
        if (ticket == null || ticket.trim().equals("")) {
        	fc.doFilter(request, response);
			return;
        }

        String ssoFlag = httpRequest.getParameter("sso");
        if ((ssoFlag == null) || (ssoFlag.trim().equals("")))
        {
          fc.doFilter(request, response);
          return;
        }
        
		String serviceURL = HttpHelper.getServiceURL(httpRequest);

		if ("true".equals(ConfigHelper.get("IDPALIAS", "USEALIAS"))) {
			try {
				String otherIdpServer = httpRequest.getHeader("otherIdpServerIPAddress");

				reAlias(otherIdpServer);
			} catch (Exception e) {
				e.printStackTrace();
			}

		}

		if ((ticket == null) || ("".equals(ticket))) {
			this.log.debug("don't have ticket ,go to login");

			httpResponse.sendRedirect(this.idpLogin + "?service=" + serviceURL + "&renew=" + this.idpRenew);

			return;
		}

		String user = null;
		try {
			user = getAuthenticatedUser(ticket, serviceURL);
		} catch (Exception ex) {
			this.log.error("getAuthenticatedUser error.");
			this.log.error("access service url: " + uri);
			ex.printStackTrace();

			httpResponse.sendRedirect(this.idpLogin + "?service=" + serviceURL + "&renew=" + this.idpRenew);

			return;
		}

		this.log.info("getAuthenticatedUser: " + user);

		session.setAttribute("cn.com.hkgt.idp.client.filter.user", user);

		fc.doFilter(request, response);
	}

	private String getAuthenticatedUser(String ticket, String serviceURL) throws ServletException {
		ProxyTicketValidator pv = null;
		try {
			pv = new ProxyTicketValidator();
			pv.setIdpValidateUrl(this.idpValidate);
			pv.setServiceTicket(ticket);
			pv.setService(serviceURL);
			pv.setRenew(Boolean.valueOf(this.idpRenew).booleanValue());
			pv.validate();

			if (!pv.isAuthenticationSuccesful()) {
				throw new ServletException(
						"IDP authentication error: " + pv.getErrorCode() + ": " + pv.getErrorMessage());
			}

			if (pv.getProxyList().size() > 0) {
				if (this.idpAuthorizedProxy == null) {
					throw new ServletException("this page does not accept proxied tickets.");
				}

				boolean authorized = false;
				String proxy = (String) pv.getProxyList().get(0);
				StringTokenizer idpProxies = new StringTokenizer(this.idpAuthorizedProxy);

				if (!idpProxies.hasMoreTokens()) {
					while (!proxy.equals(idpProxies.nextToken())) {
						authorized = true;
					}
				}

				if (!authorized) {
					throw new ServletException("unauthorized top-level proxy: " + proxy);
				}

			}

			return pv.getUser();
		} catch (Exception ex) {
			throw new ServletException(ex);
		}
	}

	public void destroy() {
	}
}
