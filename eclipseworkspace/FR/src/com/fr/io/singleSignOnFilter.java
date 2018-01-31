package com.fr.io;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Scanner;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.fr.base.FRContext;
import com.fr.fs.base.entity.User;
import com.fr.fs.base.entity.UserInfo;
import com.fr.fs.control.UserControl;
import com.fr.fs.privilege.auth.FSAuthentication;
import com.fr.fs.privilege.base.FServicePrivilegeLoader;
import com.fr.fs.privilege.entity.DaoFSAuthentication;
import com.fr.privilege.session.PrivilegeInfoSessionMananger;
import com.fr.web.utils.WebUtils;

public class singleSignOnFilter implements Filter {
	private static final String validation = "4f5a4d1beddca76114344a3bcf094ccb";
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain filterChain)
			throws IOException, ServletException {
		HttpServletRequest re = (HttpServletRequest) req;
		HttpServletResponse resp = (HttpServletResponse) res;
		HttpSession session = re.getSession(true);
		String UserID = WebUtils.getHTTPRequestParameter(re, "username");
		//String fromServer = WebUtils.getHTTPRequestParameter(re, "from");
		//String handShakeKey = WebUtils.getHTTPRequestParameter(re, "handShake");
/*		if ((UserID != null && referer != null && isThrough(referer)) ||
				(UserID != null && fromServer != null && handShakeKey != null &&
						isThrough(fromServer) && validation.equals(handShakeKey))) */
		String referer = re.getHeader("referer");
		if (UserID != null && referer != null && isThrough(referer)) {
			String cut = "username=" + UserID;
			String newURI = WebUtils.getOriginalURL(re);
			newURI = newURI.replace(cut, "");
			if (UserID != null) {
				try {
					User U = UserControl.getInstance().getByUserName(UserID);
					if (U == null) {
						System.out.println("找不到用户啊");
						resp.sendRedirect(newURI);
						return;
					}
					FSAuthentication authentication = new DaoFSAuthentication(new UserInfo(U.getId(), UserID, UserID));
					long userid = authentication.getUserInfo().getId();
					PrivilegeInfoSessionMananger.login(
							new FServicePrivilegeLoader(UserID, UserControl.getInstance().getAllSRoleNames(userid),
									UserControl.getInstance().getUserDP(userid)),
							session, resp);
					session.setAttribute("fr_fs_auth_key", authentication);
					UserControl.getInstance().login(userid);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			resp.sendRedirect(newURI);
		} else {
			filterChain.doFilter(req, res);
		}
	}
	public boolean isThrough(String referer) {
		if (referer == null)
			return false;
		Scanner in = null;
		try {
			String path = FRContext.getCurrentEnv().getPath() + "/resources/fineReportConfig.properties";
			in = new Scanner(new File(path));
			while (in.hasNextLine()) {
				String str = in.nextLine();
				if (str != null && 0 < str.length() && str.contains(referer.trim())) {
					return true;
				}					
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} finally {
			if (in != null) {
				in.close();
			}
		}
		return false;
	}

	public void init(FilterConfig arg0) throws ServletException {
	}

	public void destroy() {
	}
}