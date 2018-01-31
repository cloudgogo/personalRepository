package com.fr.data;

import com.fr.general.data.TableDataException;

public class Main {
	 public static void main(String[] args) {
		
		System.out.println(new  TestWSDLdataGet().getdata());
		try {
			System.out.println(new GetData().getColumnCount());
			System.out.println(new GetData().getRowCount());
		} catch (TableDataException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
}
