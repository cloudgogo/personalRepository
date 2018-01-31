package action;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Action {

	public void resp(HttpServletRequest request, HttpServletResponse response) throws IOException {
		Date date = new Date();
		PrintWriter out = response.getWriter();
		out.println("now:" + date);
		out.close();
	}

}
