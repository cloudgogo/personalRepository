package math;

import java.math.BigDecimal;
import java.util.*;

public class test {
	public static void main(String[] args) {
		XIRR x = new XIRR();
		Line l1 = new Line((double) -10000, "2015-06-01");
		Line l2 = new Line((double) 5000, "2015-07-01");
		Line l3 = new Line((double) 8000, "2015-08-01");
		Line l4 = new Line((double) 5000, "2015-09-01");
		Line l5 = new Line((double) 8000, "2015-10-01");
		List<Line> lines = new ArrayList<>();
		lines.add(l1);
		lines.add(l2);
		lines.add(l3);
		lines.add(l4);
		lines.add(l5);
		double result = x.calculate(lines);
		System.out.println(result);

	}

}
