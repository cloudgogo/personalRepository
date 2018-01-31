package com.fr.function;

public class TestMainClass {
	public static void main(String[] args) {
		GetCustmerInfo g=new GetCustmerInfo();
		Object[] a={"EO000000000079662","123456","cust_name"};
		String result=(String) g.run(a);
		System.out.println(result);
	}

}
