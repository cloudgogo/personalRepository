package math;

import java.text.ParseException;
import java.util.Date;
import java.util.List;

public class XIRR {
	public double calculate(List<Line> list) {
		double result = 1000.0;
		double compareresult = 0.0;
		double sumvalue = 1;
		double sumvaluec = 1;
		while (Math.abs(sumvalue) > 0.00001) { // 0.00001Îª¾«¶È
			sumvalue = this.calculate(list, (double) result);
			sumvaluec = this.calculate(list, (double) compareresult);
			double tempn = (double) (result + compareresult) / (double) 2;
			double sumvaluelast = this.calculate(list, tempn);
			if (sumvalue < 0 & sumvaluec > 0) {
				if (sumvaluelast < 0) {
					result = tempn;
				} else {
					compareresult = tempn;
				}

			} else if (sumvalue > 0 && sumvaluec < 0) {
				if (sumvaluelast > 0) {
					result = tempn;
				} else {
					compareresult = tempn;
				}

			} else {
				System.out.println("error");
			}
		}

		return result;
	}

	public double calculate(List<Line> list, double result) {
		Date startDate = list.get(0).date;
		String mathstr = "0=";
		double sum = 0;
		// for(Line line:list){
		for (int i = 1; i <= list.size(); i++) {
			Line line = list.get(i - 1);
/*
 			String appendstring = "";
			if (i == 1) {
				try {
					appendstring = line.value + "/" + "((1+result)^(" + line.daysBetween(startDate, line.date)
							+ "/365))";
					mathstr += appendstring;
				} catch (ParseException e) {
					System.out.println("calculate partner error");
				}
			} else {
				try {
					appendstring = "+" + line.value + "/" + "((1+result)^(" + line.daysBetween(startDate, line.date)
							+ "/365))";
					mathstr += appendstring;
				} catch (ParseException e) {
					System.out.println("calculate partner error");
				}

			}
*/
			try {
				double temp = line.value / Math.pow(1 + result, line.daysBetween(startDate, line.date) / (double) 365);
				sum += temp;
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
	//	System.out.println(mathstr);
	//	System.out.println(sum);
		return sum;

	}

}
