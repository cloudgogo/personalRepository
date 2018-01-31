package com.fr.io;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.Cookie;
//import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import com.fr.base.FRContext;
import com.fr.fs.base.entity.User;
import com.fr.fs.base.entity.UserInfo;
import com.fr.fs.control.UserControl;
import com.fr.fs.privilege.auth.FSAuthentication;
import com.fr.fs.privilege.base.FServicePrivilegeLoader;
import com.fr.fs.privilege.entity.DaoFSAuthentication;
import com.fr.privilege.session.PrivilegeInfoSessionMananger;

public class CindaSingleSignOnFilter implements Filter {

	private static final String FR_FS_AUTH_KEY = "fr_fs_auth_key";
	private static final String TOKEN_KEY = "cn.com.hkgt.idp.client.filter.user";
	private static final String COOKIE_KEY = "test";
	private Logger log;
	
	public CindaSingleSignOnFilter() {
		this.log = Logger.getLogger(CindaSingleSignOnFilter.class);
	}
	
	@Override
	public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
			throws IOException, ServletException {
		
		//get user id information from session
		HttpServletRequest request = (HttpServletRequest) servletRequest;
		HttpServletResponse response = (HttpServletResponse) servletResponse;
		HttpSession session = request.getSession(true);
		String userLoginID = (String)request.getSession().getAttribute(TOKEN_KEY);
		//if cannot get user id from session, then try to get from cookie
		if (userLoginID == null || "".equals(userLoginID.trim())) {
			Cookie userCookie = this.getCookieByName(request, COOKIE_KEY);
			if (userCookie != null) {
				userLoginID = userCookie.getValue();
			}
			//new sys get userid from url
			if (userLoginID == null || "".equals(userLoginID.trim())) {
				userLoginID = request.getParameter("cindauserid");
			}
		}
		
		if (userLoginID != null && !"".equals(userLoginID.trim())) {		
			try {
				//try to get user inforamiton from fine report system
				User user = UserControl.getInstance().getByUserName(userLoginID);
				if (user == null) {
					log.error("No user found in Fine report system, userId = " + userLoginID);
					filterChain.doFilter(request, response);
					return;
				}

				FSAuthentication authentication = new DaoFSAuthentication(
						new UserInfo(user.getId(), userLoginID, userLoginID));
				long userIdLong = authentication.getUserInfo().getId();
				PrivilegeInfoSessionMananger
						.login(new FServicePrivilegeLoader(userLoginID, UserControl.getInstance().getAllSRoleNames(userIdLong),
								UserControl.getInstance().getUserDP(userIdLong)), session, response);
				session.setAttribute(FR_FS_AUTH_KEY, authentication);
				UserControl.getInstance().login(userIdLong);
				filterChain.doFilter(request, response);
                return;
			} catch (Exception e) {
				FRContext.getLogger().info(e.getMessage());
			}			
		} 
		filterChain.doFilter(request, response);
	}

	/**
	 * Get cookie by name
	 * @param request
	 * @param name
	 * @return
	 */
	private Cookie getCookieByName(HttpServletRequest request, String name){
	    Map<String,Cookie> cookieMap = ReadCookieMap(request);
	    if(cookieMap.containsKey(name)){
	        Cookie cookie = (Cookie)cookieMap.get(name);
	        return cookie;
	    }else{
	        return null;
	    }   
	}
	
	/**
	 * Construct cookie list to map
	 * @param request
	 * @param name
	 * @return
	 */
	private static Map<String,Cookie> ReadCookieMap(HttpServletRequest request){  
	    Map<String,Cookie> cookieMap = new HashMap<String,Cookie>();
	    Cookie[] cookies = request.getCookies();
	    if(null != cookies){
	        for(Cookie cookie : cookies){
	            cookieMap.put(cookie.getName(), cookie);
	        }
	    }
	    return cookieMap;
	}
	
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {

	}
	
	@Override
	public void destroy() {
		
	}
}
