package com.fr.function;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import com.fr.general.FArray;

import com.fr.script.AbstractFunction;

import in.satpathy.financial.XIRR;
import in.satpathy.financial.XIRRData;

public class XIRR_FUN extends AbstractFunction {
	private static final String ERROR_VALUE = "#NUM!";

	@Override
	public Object run(Object[] args) {
		//初始化返回值
        double returnvalue=0;
		try {
			if (2 == args.length) {
				returnvalue=run((FArray) args[0], (FArray) args[1]);
				return returnvalue;
			} else if (3 == args.length) {
				returnvalue=run((FArray) args[0], (FArray) args[1], args[2]);
				return returnvalue;
			} else if (4 == args.length) {
				returnvalue=run((FArray) args[0], (FArray) args[1], args[2], args[3]);
				return returnvalue;
			}
		} catch (Exception e) {
			System.out.println(e);
		}
		
		return ERROR_VALUE;
		

	}

	public static double run(FArray fArray, FArray fArray2, Object object, Object object2) {
		XIRRData data = new XIRRData(fArray.length(), Double.parseDouble(object2.toString()), toDouble(fArray),
				dateToDouble(fArray2, object.toString()));
		double xirrValue = XIRR.xirr(data);
		return xirrValue-1;
	}

	public static double run(FArray fArray, FArray fArray2) {
		return XIRR_FUN.run(fArray, fArray2, 1.0d);
	}

	public static double run(FArray fArray, FArray fArray2, Object object) {
		if (!(object instanceof String)) {
			XIRRData data = new XIRRData(fArray.length(), Double.parseDouble(object.toString()), toDouble(fArray),
					dateToDouble(fArray2));
			double xirrValue = XIRR.xirr(data);
			return xirrValue-1;
		} else {
			return run(fArray, fArray2, object, 1.0d);
		}
	}

	private static double[] toDouble(FArray in) {
		double[] a = new double[in.length()];
		for (int i = 0; i < in.length(); i++) {
			Object ele = in.elementAt(i);
			a[i] = Double.parseDouble(ele.toString());
		}
		return a;
	}

	private static double[] dateToDouble(FArray in) {
		double[] a = new double[in.length()];
		for (int i = 0; i < in.length(); i++) {
			Object ele = in.elementAt(i);
			String date = String.valueOf(ele);
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");// 修改页面值
			Calendar cal = Calendar.getInstance();
			try {
				cal.setTime(sdf.parse(date));
			} catch (ParseException e) {
				System.out.println("error in dateformat:" + date);
			}
			long time = cal.getTimeInMillis();
			long days = time / (1000 * 3600 * 24);
			a[i] = (double) days;
		}
		return a;
	}

	private static double[] dateToDouble(FArray in, Object object) {
		String format = object.toString();
		double[] a = new double[in.length()];
		for (int i = 0; i < in.length(); i++) {
			Object ele = in.elementAt(i);
			String date = String.valueOf(ele);
			SimpleDateFormat sdf = new SimpleDateFormat(format);// 修改页面值
			Calendar cal = Calendar.getInstance();
			try {
				cal.setTime(sdf.parse(date));
			} catch (ParseException e) {
				System.out.println("error in dateformat:" + date);
			}
			long time = cal.getTimeInMillis();
			long days = time / (1000 * 3600 * 24);
			a[i] = (double) days;
		}
		return a;
	}

}
