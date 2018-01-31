package fintest;

public class test {
	public static void main(String[] args) {
		Double a=1.22;
		Object b=a;
		String c="2016-09-11";
		Object d=c;
		System.out.println("double "+ (b instanceof Double));
		System.out.println("String "+ (d instanceof Double));
	}

}
